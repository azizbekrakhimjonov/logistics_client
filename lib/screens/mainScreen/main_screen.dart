import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' if (dart.library.html) 'dart:html' as io;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:permission_handler/permission_handler.dart';
import 'package:map_picker/map_picker.dart';
// import 'package:easy_localization/easy_localization.dart';
//model
import 'package:logistic/models/preorder.dart';
import 'package:logistic/models/user_content.dart';
//bloc
import 'package:logistic/screens/mainScreen/bloc/main_bloc.dart';
import '../categories/bloc/category_bloc.dart';
import '../vehicleChoose/bloc/order_bloc.dart';
//screens
import 'package:logistic/screens/categories/select_luggages.dart';
import '../drawer/drawer.dart';
//services
import 'package:logistic/widgets/widgets.dart';
import '../../constants/constants.dart';
import '../../routes.dart';
import '../../utils/utils.dart';
import 'package:logistic/repositories/services_repository.dart';
import 'package:logistic/models/history.dart' as hm;
import 'package:logistic/models/active_order.dart' as am;
import '../../main.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  static const String routeName = 'mainscreen';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with RouteAware {
  final dynamic _controller = Completer<GoogleMapController>();
  final fm.MapController _desktopMapController = fm.MapController();
  Timer? _desktopMoveDebounce;
  MapPickerController mapPickerController = MapPickerController();
  final _sheet = GlobalKey();
  final _sheet2 = GlobalKey();
  final _capacitySheet = GlobalKey();
  final MainBloc _bloc = MainBloc();
  final CategoryBloc _categoryBloc = CategoryBloc();
  final OrderBloc _orderBloc = OrderBloc();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  CameraPosition? cameraPosition;
  late double lat, long;
  var textController = TextEditingController();
  late Permission permission;
  PermissionStatus permissionStatus = PermissionStatus.denied;
  var activeIndex;
  var selectedProduct;
  List<dynamic> units = [];
  UserContent? userData;
  String comment = "";
  bool hideModal = false;
  int preOrderId = 0;
  bool dialogShown = false;
  int selectedAddressId = 0;
  List<dynamic> categories = [];
  String selectedServiceType = 'material'; // Store selected service type
  String? entityType; // Store entity type: 'individual' or 'legal'
  String? jshshir; // Store JSHSHIR for individual
  String? stir; // Store STIR for legal entity
  String? mfo; // Store МФО for legal entity
  String?
      _selectedAddressName; // Store the selected address name to prevent geocoding override
  String?
      _lastShownError; // Store last shown error message to prevent duplicates
  DateTime? _lastErrorTime; // Track when last error was shown
  String? _lastOrderStatus; // Track last order status to detect completion
  bool _completionDialogShown = false; // Track if completion dialog was shown

  bool get isDesktop {
    if (kIsWeb) return false;
    return io.Platform.isLinux || io.Platform.isWindows || io.Platform.isMacOS;
  }

  Timer? _refreshTimer;
  am.ActiveOrder? _currentOrder;
  bool _hasActiveOrder = false;

  Future<void> _ensureCurrentActiveOrder() async {
    try {
      // If backend provides current order id, prefer it
      if (userData != null && (userData!.order ?? 0) != 0) {
        final id = userData!.order!;
        final res = await ServicesRepository().getOrderDetail(id);
        final status = res.status.toLowerCase();

        // Check if order was just completed
        if (_lastOrderStatus != null &&
            _lastOrderStatus != 'completed' &&
            status == 'completed' &&
            !_completionDialogShown) {
          _completionDialogShown = true;
          _showCompletionConfirmationDialog();
        }
        _lastOrderStatus = status;

        final finished = !res.isActive ||
            {'completed', 'cancelled', 'refunded', 'delivered'}
                .contains(status);
        if (!finished) {
          setState(() {
            _currentOrder = res;
            _hasActiveOrder = true;
            _completionDialogShown = false; // Reset when order is active again
          });
          return;
        }
      }

      // Otherwise, fall back to latest unpaid from history (map History -> ActiveOrder for display)
      final list =
          await ServicesRepository().getOrderHistoryList() as List<hm.History>;
      final candidates = list.where((e) {
        final s = e.status.toLowerCase();
        const finished = {
          'completed',
          'cancelled',
          'refunded',
          'delivered',
          'rated'
        };
        // Include pending, payment_confirm, and other active statuses
        return !finished.contains(s) && e.isActive;
      }).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      if (candidates.isEmpty) {
        setState(() {
          _currentOrder = null;
          _hasActiveOrder = false;
        });
        return;
      }
      final h = candidates.first;
      final mapped = am.ActiveOrder(
        id: h.id,
        categoryObj: h.categoryObj == null
            ? null
            : am.CategoryObj(
                id: h.categoryObj!.id,
                category: am.Category(
                  id: h.categoryObj!.category.id,
                  nameUz: h.categoryObj!.category.nameUz,
                  nameRu: h.categoryObj!.category.nameRu,
                  icon: h.categoryObj!.category.icon,
                ),
                quantity: h.categoryObj!.quantity,
                unit: h.categoryObj!.unit,
                priceFrom: h.categoryObj!.priceFrom,
                priceTo: h.categoryObj!.priceTo,
                priceMaterial: h.categoryObj!.priceMaterial,
              ),
        driver: null,
        isActive: h.isActive,
        createdAt: h.createdAt,
        updatedAt: h.updatedAt,
        status: h.status,
        paymentType: h.paymentType,
        address: h.address,
        comment: h.comment,
        price: h.price,
        user: h.user,
        categoryUnit: h.categoryUnit,
        paymentUrl: null,
      );
      setState(() {
        _currentOrder = mapped;
        _hasActiveOrder = true;
      });
    } catch (_) {
      // Keep previous UI
    }
  }

  void _listenForPermission() async {
    // Skip permission checks on desktop platforms and web
    if (kIsWeb ||
        (!kIsWeb &&
            (io.Platform.isLinux ||
                io.Platform.isWindows ||
                io.Platform.isMacOS))) {
      setState(() {
        permissionStatus = PermissionStatus.granted;
      });
      return;
    }

    try {
      final status = await Permission.location.status;
      Map<Permission, PermissionStatus> sts =
          await [Permission.location].request();
      print("status$sts");

      setState(() {
        permissionStatus = status;
      });

      switch (status) {
        case PermissionStatus.denied:
          requestForPermission();
          break;
        case PermissionStatus.granted:
          break;
        case PermissionStatus.limited:
          Navigator.pop(context);
          break;
        case PermissionStatus.restricted:
          Navigator.pop(context);
          break;
        case PermissionStatus.permanentlyDenied:
          Navigator.pop(context);
          break;
        case PermissionStatus.provisional:
      }
    } catch (e) {
      print("Permission error: $e");
      setState(() {
        permissionStatus = PermissionStatus.granted;
      });
    }
  }

  Future<void> requestForPermission() async {
    final status = await Permission.storage.request();
    setState(() {
      permissionStatus = status;
    });
  }

  @override
  void initState() {
    _listenForPermission();
    _bloc.add(const GetUser());
    _categoryBloc.add(const GetCategories());
    _startRealtimeUpdates();
    super.initState();
  }

  @override
  void didPush() {
    // Screen was pushed onto the stack, refresh data
    _bloc.add(const GetUser());
    super.didPush();
  }

  @override
  void didChangeDependencies() async {
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
    getLocation();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    try {
      routeObserver.unsubscribe(this);
    } catch (_) {}
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Returned to this screen; refresh user/order state
    _bloc.add(const GetUser());
    super.didPopNext();
  }

  void _startRealtimeUpdates() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _bloc.add(const GetUser());
      _ensureCurrentActiveOrder();
    });
  }

  void getLocation() async {
    debugPrint("getLocation");

    dynamic user = await SharedPref().read("user");

    // Default camera position (Tashkent, Uzbekistan)
    const defaultPosition = CameraPosition(
      target: LatLng(41.3115743182368, 69.27959652630211),
      zoom: 12.4746,
    );

    double finalLat = 41.3115743182368;
    double finalLong = 69.27959652630211;

    // Try to get current location, fallback to default if on desktop or web
    try {
      if (!kIsWeb && (io.Platform.isAndroid || io.Platform.isIOS)) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          cameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 14.4746,
          );
          lat = position.latitude;
          long = position.longitude;
          finalLat = position.latitude;
          finalLong = position.longitude;
        });
      } else {
        // For desktop and web, use default location
        setState(() {
          cameraPosition = defaultPosition;
          lat = 41.3115743182368;
          long = 69.27959652630211;
        });
      }
    } catch (e) {
      print("Location error: $e");
      // Fallback to default location
      setState(() {
        cameraPosition = defaultPosition;
        lat = 41.3115743182368;
        long = 69.27959652630211;
      });
    }

    // Geocode the address after setting location
    if (_selectedAddressName == null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          finalLat,
          finalLong,
          localeIdentifier: "uz_UZ",
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final addressText = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
          ].where((e) => e != null && e.isNotEmpty).join(", ");
          if (addressText.isNotEmpty) {
            setState(() {
              textController.text = addressText;
              _selectedAddressName = addressText;
            });
          }
        }
      } catch (e) {
        print("Geocoding error in getLocation: $e");
      }
    }

    debugPrint("USER: $user");

    // Note: SharedPref stores user data separately, not as UserContent
    // We just need to check if user exists for now
    // The actual UserContent will come from the MainBloc
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      // extendBodyBehindAppBar: true,
      // extendBody: true,
      resizeToAvoidBottomInset: false,
      body: cameraPosition == null
          ? const SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Center(
                child: CupertinoActivityIndicator(
                    color: AppColor.primary, radius: 20),
              ),
            )
          : MultiBlocProvider(
              providers: [
                BlocProvider.value(value: _bloc),
                BlocProvider.value(value: _categoryBloc),
                BlocProvider.value(value: _orderBloc)
              ],
              child: MultiBlocListener(
                listeners: [
                  BlocListener<OrderBloc, OrderState>(
                    listener: (context, state) {
                      if (state is OrderDeleteLoadingState) {
                        CustomLoadingDialog.show(context);
                      } else if (state is OrderDeleteErrorState) {
                        CustomLoadingDialog.hide(context);
                        Services.showSnackBar(
                            context, state.message, AppColor.errorRed);
                        dialogShown = false;
                        _showMyDialog();
                      } else {
                        CustomLoadingDialog.hide(context);
                      }
                    },
                  ),
                  BlocListener<CategoryBloc, CategoryState>(
                    listener: (context, state) {
                      if (state is CategorySuccessState) {
                        categories = state.data;
                      }
                      // TODO: implement listener
                    },
                  ),
                  BlocListener<MainBloc, MainState>(listener: (context, state) {
                    if (state is PreOrderLoadingState) {
                      CustomLoadingDialog.show(context);
                    } else if (state is PreOrderSuccessState) {
                      CustomLoadingDialog.hide(context);
                      // Reset entity type data after successful PreOrder creation
                      entityType = null;
                      jshshir = null;
                      stir = null;
                      mfo = null;
                      
                      // Check if it's a material order - show success dialog instead of driver selection
                      if (selectedServiceType == 'material') {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext dialogContext) {
                            return OrderSuccessDialog(
                              onOk: () {
                                // Close the dialog
                                Navigator.of(dialogContext).pop();
                                // Refresh the main screen data to show the new preorder
                                _bloc.add(const GetUser());
                              },
                            );
                          },
                        );
                      } else {
                        // For driver orders, proceed to vehicle selection
                        pushToVehicle(id: state.id);
                      }
                    } else if (state is PreOrderErrorState) {
                      CustomLoadingDialog.hide(context);
                      final errorMessage = state.message.toString();
                      final now = DateTime.now();

                      // Show error only if it's different from last one or more than 3 seconds passed
                      if (_lastShownError != errorMessage ||
                          _lastErrorTime == null ||
                          now.difference(_lastErrorTime!) >
                              Duration(seconds: 3)) {
                        _lastShownError = errorMessage;
                        _lastErrorTime = now;
                        // Extract a more user-friendly error message
                        String displayMessage = errorMessage;
                        if (errorMessage.contains("Entity type is required")) {
                          displayMessage = "Yuridik shaxs turini tanlang";
                        } else if (errorMessage.contains("JSHSHIR")) {
                          displayMessage = "JSHSHIR raqamini kiriting";
                        } else if (errorMessage.contains("STIR") || errorMessage.contains("МФО")) {
                          displayMessage = "STIR va МФО raqamlarini kiriting";
                        }
                        Services.showSnackBar(
                            context, displayMessage, AppColor.red);
                      }
                    } else {
                      CustomLoadingDialog.hide(context);
                    }

                    if (state is MainSuccessState) {
                      userData = state.data; // Set userData from API response
                      _ensureCurrentActiveOrder();
                    }

                    if (state is GetOrderSuccessState) {
                      final order = state.data;
                      final status = order.status.toLowerCase();

                      // Check if order was just completed by driver
                      if (_lastOrderStatus != null &&
                          _lastOrderStatus != 'completed' &&
                          status == 'completed' &&
                          !_completionDialogShown) {
                        _completionDialogShown = true;
                        _showCompletionConfirmationDialog();
                      }
                      _lastOrderStatus = status;

                      final finishedStatuses = <String>{
                        'completed',
                        'cancelled',
                        'refunded',
                        'delivered',
                      };
                      // Treat payment_confirm as non-active for display purposes
                      final isFinished = !order.isActive ||
                          finishedStatuses.contains(status) ||
                          status == 'payment_confirm';
                      if (isFinished) {
                        _currentOrder = null;
                        _hasActiveOrder = false;
                        _ensureCurrentActiveOrder();
                      } else {
                        _currentOrder = order;
                        _hasActiveOrder = true;
                        _completionDialogShown =
                            false; // Reset when order is active
                      }
                    }
                  })
                ],
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Listener(
                      onPointerMove: (move) {
                        selectedAddressId = 0;
                      },
                      child: MapPicker(
                        iconWidget: const MapPickerIcon(),
                        mapPickerController: mapPickerController,
                        child: isDesktop
                            ? fm.FlutterMap(
                                mapController: _desktopMapController,
                                options: fm.MapOptions(
                                  initialCenter: latlng.LatLng(lat, long),
                                  initialZoom: 14,
                                  onPositionChanged:
                                      (position, hasGesture) async {
                                    if (hasGesture == true) {
                                      mapPickerController.mapMoving!();
                                      // User is manually moving the map, clear saved address name
                                      _selectedAddressName = null;
                                      textController.text = "checking ...";
                                      _desktopMoveDebounce?.cancel();
                                      _desktopMoveDebounce = Timer(
                                          const Duration(milliseconds: 600),
                                          () async {
                                        mapPickerController
                                            .mapFinishedMoving!();
                                        try {
                                          final placemarks =
                                              await placemarkFromCoordinates(
                                                  lat, long,
                                                  localeIdentifier: "uz_UZ");
                                          if (placemarks.isNotEmpty) {
                                            final place = placemarks.first;
                                            final addressText = [
                                              place.street,
                                              place.subLocality,
                                              place.locality,
                                              place.administrativeArea,
                                            ]
                                                .where((e) =>
                                                    e != null && e.isNotEmpty)
                                                .join(", ");
                                            if (addressText.isNotEmpty) {
                                              textController.text = addressText;
                                              _selectedAddressName =
                                                  addressText;
                                            } else {
                                              // Fallback to name if other fields are empty
                                              final fallbackText = place.name ??
                                                  place.thoroughfare ??
                                                  "$lat, $long";
                                              textController.text =
                                                  fallbackText;
                                              _selectedAddressName =
                                                  fallbackText != "$lat, $long"
                                                      ? fallbackText
                                                      : null;
                                            }
                                          } else {
                                            textController.text = "$lat, $long";
                                          }
                                        } catch (e) {
                                          print(
                                              "Geocoding error in onPositionChanged: $e");
                                          textController.text = "$lat, $long";
                                        }
                                      });
                                    }
                                    final center = position.center;
                                    if (center != null) {
                                      lat = center.latitude;
                                      long = center.longitude;
                                    }
                                  },
                                  onMapReady: () async {
                                    // Only geocode on map ready if we don't have a saved address name
                                    if (_selectedAddressName == null) {
                                      try {
                                        final placemarks =
                                            await placemarkFromCoordinates(
                                                lat, long,
                                                localeIdentifier: "uz_UZ");
                                        if (placemarks.isNotEmpty) {
                                          final place = placemarks.first;
                                          final addressText = [
                                            place.street,
                                            place.subLocality,
                                            place.locality,
                                            place.administrativeArea,
                                          ]
                                              .where((e) =>
                                                  e != null && e.isNotEmpty)
                                              .join(", ");
                                          if (addressText.isNotEmpty) {
                                            textController.text = addressText;
                                            _selectedAddressName = addressText;
                                          } else {
                                            // Fallback to name if other fields are empty
                                            final fallbackText = place.name ??
                                                place.thoroughfare ??
                                                "$lat, $long";
                                            textController.text = fallbackText;
                                            _selectedAddressName =
                                                fallbackText != "$lat, $long"
                                                    ? fallbackText
                                                    : null;
                                          }
                                        } else {
                                          textController.text = "$lat, $long";
                                        }
                                      } catch (e) {
                                        print(
                                            "Geocoding error in onMapReady: $e");
                                        textController.text = "$lat, $long";
                                      }
                                    } else {
                                      // Restore the saved address name
                                      textController.text =
                                          _selectedAddressName!;
                                    }
                                  },
                                  interactionOptions:
                                      const fm.InteractionOptions(
                                          enableScrollWheel: true),
                                ),
                                children: [
                                  fm.TileLayer(
                                    urlTemplate:
                                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    subdomains: const ['a', 'b', 'c'],
                                  ),
                                ],
                              )
                            : GoogleMap(
                                myLocationEnabled: true,
                                zoomControlsEnabled: false,
                                myLocationButtonEnabled: false,
                                trafficEnabled: true,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 60),
                                mapType: MapType.normal,
                                initialCameraPosition: cameraPosition!,
                                onMapCreated:
                                    (GoogleMapController controller) async {
                                  _controller.complete(controller);
                                },
                                onCameraMoveStarted: () {
                                  mapPickerController.mapMoving!();
                                  textController.text = "checking ...";
                                },
                                onCameraMove: (cameraPosition) {
                                  this.cameraPosition = cameraPosition;
                                  lat = cameraPosition.target.latitude;
                                  long = cameraPosition.target.longitude;
                                },
                                onCameraIdle: () async {
                                  mapPickerController.mapFinishedMoving!();
                                  // Only geocode if we don't have a saved address name (user manually moved map)
                                  if (_selectedAddressName == null) {
                                    try {
                                      List<Placemark> placemarks =
                                          await placemarkFromCoordinates(
                                              cameraPosition!.target.latitude,
                                              cameraPosition!.target.longitude,
                                              localeIdentifier: "uz_UZ");
                                      if (placemarks.isNotEmpty) {
                                        final place = placemarks.first;
                                        final addressText = [
                                          place.street,
                                          place.subLocality,
                                          place.locality,
                                          place.administrativeArea,
                                        ]
                                            .where((e) =>
                                                e != null && e.isNotEmpty)
                                            .join(", ");
                                        if (addressText.isNotEmpty) {
                                          textController.text = addressText;
                                          _selectedAddressName = addressText;
                                        } else {
                                          // Fallback to name if other fields are empty
                                          final fallbackText = place.name ??
                                              place.thoroughfare ??
                                              "${cameraPosition!.target.latitude}, ${cameraPosition!.target.longitude}";
                                          textController.text = fallbackText;
                                          _selectedAddressName = fallbackText !=
                                                  "${cameraPosition!.target.latitude}, ${cameraPosition!.target.longitude}"
                                              ? fallbackText
                                              : null;
                                        }
                                      } else {
                                        textController.text =
                                            "${cameraPosition!.target.latitude}, ${cameraPosition!.target.longitude}";
                                      }
                                    } catch (e) {
                                      print("Geocoding error: $e");
                                      textController.text =
                                          "${cameraPosition!.target.latitude}, ${cameraPosition!.target.longitude}";
                                    }
                                  } else {
                                    // Restore the saved address name (from saved address selection)
                                    textController.text = _selectedAddressName!;
                                  }
                                },
                              ),
                      ),
                    ),
                    leftMenuButton(),
                    mapLocationText(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12, bottom: 8),
                        child: FloatingActionButton(
                          heroTag: "currentLocationBtn",
                          mini: true,
                          onPressed: () => getCurrentLocation(),
                          child: const Icon(Icons.my_location),
                        ),
                      ),
                    ),

                    BlocConsumer<MainBloc, MainState>(
                      listener: (context, state) {
                        if (state is MainLoadingState) {
                          const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is MainErrorState) {
                          final errorMessage = state.message.toString();
                          final now = DateTime.now();

                          // Show error only if it's different from last one or more than 3 seconds passed
                          if (_lastShownError != errorMessage ||
                              _lastErrorTime == null ||
                              now.difference(_lastErrorTime!) >
                                  Duration(seconds: 3)) {
                            _lastShownError = errorMessage;
                            _lastErrorTime = now;
                            Services.showSnackBar(
                                context, errorMessage, AppColor.red);
                          }
                        }
                      },
                      builder: (context, state) {
                        if (state is MainSuccessState) {
                          preOrderId = state.data.preOrder ?? 0;
                          // If we already resolved an active order, always show it
                          if (_hasActiveOrder && _currentOrder != null) {
                            return ActiveOrderContainer(order: _currentOrder!);
                          }
                          // If backend says there's an order, wait for _ensureCurrentActiveOrder to load it
                          // Otherwise, only prompt for unfinished preorder when there is truly no active order
                          if ((state.data.order == 0 ||
                                  state.data.order == null) &&
                              !_hasActiveOrder) {
                            if (preOrderId != 0 && dialogShown == false) {
                              _showMyDialog();
                            }
                            return scrollableMapSelection(state);
                          }
                          // If there's an order but we haven't loaded it yet, show loading or wait
                          if ((state.data.order ?? 0) != 0 &&
                              !_hasActiveOrder) {
                            // Order exists but not loaded yet, wait a bit for _ensureCurrentActiveOrder
                            return scrollableMapSelection(state);
                          }
                        }
                        if (state is GetOrderSuccessState) {
                          final status = state.data.status.toLowerCase();
                          // If backend returns a paid order, but we resolved an unpaid one, prefer the unpaid
                          if (status == 'payment_confirm' &&
                              _currentOrder != null) {
                            return ActiveOrderContainer(order: _currentOrder!);
                          }
                          if (_hasActiveOrder && _currentOrder != null) {
                            return ActiveOrderContainer(order: _currentOrder!);
                          }
                          return scrollableMapSelection(state);
                        }
                        // For loading/error/other states, keep stable UI
                        if (_hasActiveOrder && _currentOrder != null) {
                          return ActiveOrderContainer(order: _currentOrder!);
                        }
                        return scrollableMapSelection(state);
                      },
                    ),

                    // if (_isInputSheetOpen) inputSheet(),
                  ],
                ),
              ),
            ),
      drawer: MainDrawer(),
    );
  }

  Future<void> getCurrentLocation() async {
    debugPrint("getCurrentLocation started");

    const double fallbackLat = 41.3115743182368;
    const double fallbackLong = 69.27959652630211;

    try {
      // Desktop and web platformalarda faqat Tashkent
      if (kIsWeb ||
          (!kIsWeb &&
              (io.Platform.isWindows ||
                  io.Platform.isLinux ||
                  io.Platform.isMacOS))) {
        lat = fallbackLat;
        long = fallbackLong;
        _moveCameraTo(lat, long);
        return;
      }

      // Mobil: ruxsatni tekshirish
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint("Location permission denied, using Tashkent");
        lat = fallbackLat;
        long = fallbackLong;
        _moveCameraTo(lat, long);
        return;
      }

      // Haqiqiy joylashuvni olish
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      lat = position.latitude;
      long = position.longitude;

      debugPrint("Current location: $lat, $long");

      _moveCameraTo(lat, long);
    } catch (e) {
      debugPrint("Location error: $e, fallback to Tashkent");
      lat = fallbackLat;
      long = fallbackLong;
      _moveCameraTo(lat, long);
    }
  }

// Yordamchi funksiya — kamerani to'g'ri joyga siljitish uchun
  Future<void> _moveCameraTo(double latitude, double longitude) async {
    setState(() {
      cameraPosition = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 15.5,
      );
    });

    // Muhim: GoogleMap ni majburan yangi joyga siljitish
    if (!isDesktop) {
      try {
        final GoogleMapController controller = await _controller.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(latitude, longitude),
              zoom: 15.5,
            ),
          ),
        );
      } catch (e) {
        debugPrint("Controller error: $e");
      }
    } else {
      // Desktop uchun flutter_map
      _desktopMapController.move(latlng.LatLng(latitude, longitude), 15.0);
    }

    // Adresni yangilash - only if we don't have a saved address name
    if (_selectedAddressName == null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          latitude,
          longitude,
          localeIdentifier: "uz_UZ",
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final addressText = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
          ].where((e) => e != null && e.isNotEmpty).join(", ");
          textController.text = addressText;
          _selectedAddressName = addressText;
        } else {
          textController.text = "$latitude, $longitude";
        }
      } catch (e) {
        textController.text = "$latitude, $longitude";
      }
    } else {
      // Restore the saved address name
      textController.text = _selectedAddressName!;
    }
  }

  void _showCustomBottomSheet(BuildContext context, StateSetter parentState,
      Widget Function(StateSetter) builder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return builder(setState);
        });
      },
    ).whenComplete(() {
      clearData();
      parentState(() {});
    });
  }

  void showCustomLuggagesBottomSheet(BuildContext context) {
    _showCustomBottomSheet(context, setState, (StateSetter setState) {
      return selectLuggages(setState);
    });
  }

  void showCustomCapacityBottomSheet(
      BuildContext context, StateSetter parentState) {
    _showCustomBottomSheet(context, parentState, (StateSetter setState) {
      return selectCapacity(setState, parentState);
    });
  }

  void showCustomInputBottomSheet(
      BuildContext context, StateSetter parentState) {
    _showCustomBottomSheet(context, parentState, (StateSetter setState) {
      return inputSheet(setState, parentState);
    });
  }

  void clearData() {
    selectedProduct = null;
    activeIndex = null;
  }

  Widget scrollableMapSelection(state) {
    return DraggableMapLocation(
      address: state is MainSuccessState ? state.data.user.myAddresses : [],
      sheet: _sheet,
      setLocation: (id, longitude, latitude, addressName) =>
          _setLocation(id, longitude, latitude, addressName),
      openSheet: () => _showServiceTypeDialog(context), //_openSheet(),
      textController: textController,
      size: MediaQuery.of(context).size.width * 0.7,
    );
  }

  void _showServiceTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ServiceTypeDialog(
          onSelected: (String serviceType) {
            setState(() {
              selectedServiceType = serviceType;
              // Reset entity type data when service type changes
              entityType = null;
              jshshir = null;
              stir = null;
              mfo = null;
            });
            // For now, both options proceed to material selection
            // You can add different logic for 'driver' later
            if (serviceType == 'material' || serviceType == 'driver') {
              showCustomLuggagesBottomSheet(context);
            }
          },
        );
      },
    );
  }

  void _showEntityTypeDialog(BuildContext context, StateSetter parentState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EntityTypeDialog(
          onContinue: (String selectedEntityType, String? jshshirValue, String? stirValue, String? mfoValue) {
            setState(() {
              entityType = selectedEntityType;
              jshshir = jshshirValue;
              stir = stirValue;
              mfo = mfoValue;
            });
            // After entity type is selected, proceed to capacity selection
            showCustomCapacityBottomSheet(context, parentState);
          },
        );
      },
    );
  }

  Future<void> _setLocation(id, longitude, latitude,
      [String? addressName]) async {
    print("long: $longitude lat: $latitude");
    selectedAddressId = id;
    lat = latitude;
    long = longitude;
    cameraPosition = CameraPosition(
      target: LatLng(lat, long), //LatLng(41.311158, 69.279737),
      zoom: 14.4746,
    );

    // Use the provided address name if available, otherwise try to geocode
    if (addressName != null && addressName.isNotEmpty) {
      _selectedAddressName = addressName; // Store the address name
      textController.text = addressName;
    } else {
      _selectedAddressName = null; // Clear stored address name
      // Fallback to geocoding if address name not provided
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, long,
            localeIdentifier: "uz_UZ");
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final addressText = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
          ].where((e) => e != null && e.isNotEmpty).join(", ");
          if (addressText.isNotEmpty) {
            textController.text = addressText;
            _selectedAddressName = addressText; // Store geocoded address
          } else {
            // Fallback to name if other fields are empty
            final fallbackText =
                place.name ?? place.thoroughfare ?? "$lat, $long";
            textController.text = fallbackText;
            _selectedAddressName =
                fallbackText != "$lat, $long" ? fallbackText : null;
          }
        } else {
          textController.text = "$lat, $long";
          _selectedAddressName = null;
        }
      } catch (e) {
        print("Geocoding error in _setLocation: $e");
        textController.text = "$lat, $long";
        _selectedAddressName = null;
      }
    }

    if (isDesktop) {
      _desktopMapController.move(latlng.LatLng(lat, long), 14);
    } else {
      final GoogleMapController controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(lat, long),
            zoom: 14,
          ),
        ),
      );
    }
  }

  Widget mapLocationText() {
    return Positioned(
      top: 130,
      width: MediaQuery.of(context).size.width - 50,
      height: 50,
      child: TextFormField(
        maxLines: 3,
        textAlign: TextAlign.center,
        readOnly: true,
        decoration: const InputDecoration(
            contentPadding: EdgeInsets.zero, border: InputBorder.none),
        controller: textController,
      ),
    );
  }

  String getImageUrl(UserContent? userData) {
    print("object:$userData");
    if (userData != null) {
      return userData.user.picCompress ?? "";
    }
    return "";
  }

  Widget leftMenuButton() {
    var image = getImageUrl(userData);
    return Positioned(
        top: MediaQuery.of(context).viewPadding.top + 30,
        left: 24,
        width: 55,
        height: 55,
        child: InkWell(
          onTap: () {
            print("Open");
            // Scaffold.of(context).openDrawer();
            scaffoldKey.currentState?.openDrawer();
          },
          child: Container(
            width: 50, // Adjust the width and height as per your requirement
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.red,
                width: 3.0,
              ),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: image,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    const CupertinoActivityIndicator(),
                // CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) =>
                    Image.asset(AssetImages.defaultImage, fit: BoxFit.cover),
              ),
            ),
          ),
        ));
  }

  Widget selectCapacity(setState, parentState) {
    return SelectCapacity(
        sheet: _capacitySheet,
        units: units,
        closeSheet: () => setState(() {
              selectedProduct = null;
              activeIndex = null;
              parentState(() {});
            }),
        selectItem: (item) {
          setState(() {
            activeIndex = item;
          });
        },
        activeIndex: activeIndex,
        onDone: () {
          if (activeIndex != null) {
            // Validate entity type data for material service type
            if (selectedServiceType == 'material') {
              if (entityType == null) {
                Services.showSnackBar(
                    context, 
                    "Iltimos, yuridik shaxs turini tanlang", 
                    AppColor.errorRed);
                return;
              }
              if (entityType == 'individual' && (jshshir == null || jshshir!.trim().isEmpty)) {
                Services.showSnackBar(
                    context, 
                    "Iltimos, JSHSHIR raqamini kiriting", 
                    AppColor.errorRed);
                return;
              }
              if (entityType == 'legal' && ((stir == null || stir!.trim().isEmpty) || (mfo == null || mfo!.trim().isEmpty))) {
                Services.showSnackBar(
                    context, 
                    "Iltimos, STIR va МФО raqamlarini kiriting", 
                    AppColor.errorRed);
                return;
              }
            }
            
            var dto = PreOrder(
                address: Address(
                    id: selectedAddressId,
                    name: textController.text,
                    long: long,
                    lat: lat),
                comment: "",
                categoryUnit: activeIndex,
                serviceType: selectedServiceType,
                entityType: entityType,
                jshshir: jshshir,
                stir: stir,
                mfo: mfo);
            print("PREORDER DTO: ${dto.toJson()}");
            _bloc.add(PreOrderEvent(data: dto));
            selectedProduct = null;
            activeIndex = null;
            // Don't reset entity type data here - wait until PreOrder is successfully created
          }
        });
  }

  Future<void> _showMyDialog() async {
    if (dialogShown) return;

    dialogShown = true;
    await Future.delayed(Duration.zero);
    print("ID:$preOrderId");
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return MyDialog(
            hideModal: () {
              _orderBloc.add(DeleteOrder(id: preOrderId));
              // setState(() {
              //   hideModal = true;
              // });
            },
            onDone: () {
              pushToVehicle(id: preOrderId);
            },
          );
        },
        barrierDismissible: false);
  }

  Future<void> _showCompletionConfirmationDialog() async {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(
          'Buyurtma yakunlandi',
          style: boldBlack.copyWith(fontSize: 18),
        ),
        content: Text(
          'Haydovchi buyurtmani tugatganini bildirdi. Rostdan ham tugatildimi?',
          style: mediumBlack.copyWith(fontSize: 15),
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: Text("Yo'q", style: mediumBlack),
            onPressed: () {
              Navigator.pop(context);
              _completionDialogShown = false;
            },
          ),
          CupertinoDialogAction(
            child: Text('Ha, tugatildi',
                style: mediumBlack.copyWith(color: AppColor.primary)),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              _completionDialogShown = false;
              // Refresh order status
              if (userData != null && (userData!.order ?? 0) != 0) {
                _bloc.add(GetOrderEvent(id: userData!.order!));
              }
            },
          )
        ],
      ),
    );
  }

  pushToVehicle({required int id}) {
    Navigator.pushNamed(context, Routes.vehiclechoose, arguments: {"id": id});
  }

  Widget inputSheet(setState, parentState) {
    return InputSheet(
        sheet: _capacitySheet,
        closeSheet: () => setState(() {
              selectedProduct = null;
              activeIndex = null;
              parentState(() {});
            }),
        onDone: (comment) {
          var dto = PreOrder(
              address: Address(
                  id: selectedAddressId,
                  name: textController.text,
                  long: long,
                  lat: lat),
              comment: comment,
              categoryUnit: null,
              serviceType: selectedServiceType);
          print("PREORDER: ${dto.toJson()}");
          _bloc.add(PreOrderEvent(data: dto));
          selectedProduct = null;
          activeIndex = null;
          Navigator.pop(context);
          Navigator.pop(context);

          // _closeSheet();
          // _closeInputSheet();
        });
  }

  Widget selectLuggages(setState) {
    return SelectLuggages(
      list: categories,
      sheet: _sheet2,
      selectedProduct: selectedProduct,
      openSheet: (id, unit) => setState(() {
        selectedProduct = id;
        units = unit;
        // If service type is 'material', show entity type dialog first
        if (selectedServiceType == 'material') {
          _showEntityTypeDialog(context, setState);
        } else {
          // For 'driver', proceed directly to capacity selection
          showCustomCapacityBottomSheet(context, setState);
        }
      }),
      openInputSheet: () => showCustomInputBottomSheet(context, setState),
    );
  }
}
