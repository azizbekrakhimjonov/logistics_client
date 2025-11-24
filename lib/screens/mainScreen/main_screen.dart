import 'dart:async';
import 'dart:io';
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
  bool _isSheetOpen = false;
  bool _isCapacitySheetOpen = false;
  bool _isInputSheetOpen = false;
  var activeIndex = null;
  var selectedProduct = null;
  List<dynamic> units = [];
  UserContent? userData = null;
  String comment = "";
  bool hideModal = false;
  int preOrderId = 0;
  bool dialogShown = false;
  int selectedAddressId = 0;
  List<dynamic> categories = [];

  bool get isDesktop => Platform.isLinux || Platform.isWindows || Platform.isMacOS;
  am.ActiveOrder? _overrideOrderToShow;
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
        final finished = !res.isActive || {
          'completed','cancelled','refunded','delivered'
        }.contains(status);
        if (!finished) {
          setState(() { _currentOrder = res; _hasActiveOrder = true; });
          return;
        }
      }

      // Otherwise, fall back to latest unpaid from history (map History -> ActiveOrder for display)
      final list = await ServicesRepository().getOrderHistoryList() as List<hm.History>;
      final candidates = list
          .where((e) {
            final s = e.status.toLowerCase();
            const finished = {'completed','cancelled','refunded','delivered'};
            return s != 'payment_confirm' && !finished.contains(s) && e.isActive;
          })
          .toList()
        ..sort((a,b)=> b.updatedAt.compareTo(a.updatedAt));
      if (candidates.isEmpty) {
        setState(() { _currentOrder = null; _hasActiveOrder = false; });
        return;
      }
      final h = candidates.first;
      final mapped = am.ActiveOrder(
        id: h.id,
        categoryObj: h.categoryObj == null ? null : am.CategoryObj(
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
      setState(() { _currentOrder = mapped; _hasActiveOrder = true; });
    } catch (_) {
      // Keep previous UI
    }
  }

  Future<void> _loadLatestUnpaidOrder() async {
    try {
      final repo = ServicesRepository();
      final List<hm.History> list = await repo.getOrderHistoryList();
      // pick latest by updatedAt where status != payment_confirm
      final Iterable<hm.History> candidates = list.where((e) => e.status.toLowerCase() != 'payment_confirm');
      if (candidates.isEmpty) {
        setState(() { _overrideOrderToShow = null; });
        return;
      }
      candidates.toList().sort((a,b)=> b.updatedAt.compareTo(a.updatedAt));
      final hm.History h = candidates.first;
      // Map History -> ActiveOrder (partial)
      final am.ActiveOrder mapped = am.ActiveOrder(
        id: h.id,
        categoryObj: h.categoryObj == null ? null : am.CategoryObj(
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
      setState(() { _overrideOrderToShow = mapped; });
    } catch (_) {
      setState(() { _overrideOrderToShow = null; });
    }
  }

 
  void _listenForPermission() async {
    // Skip permission checks on desktop platforms
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
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
    _bloc.add(GetUser());
    _categoryBloc.add(GetCategories());
    _startRealtimeUpdates();
    super.initState();
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
    _bloc.add(GetUser());
    super.didPopNext();
  }

  void _startRealtimeUpdates() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _bloc.add(GetUser());
      _ensureCurrentActiveOrder();
    });
  }

  void getLocation() async {
    debugPrint("getLocation");
    
    dynamic user = await SharedPref().read("user");

    // Default camera position (Tashkent, Uzbekistan)
    final defaultPosition = const CameraPosition(
      target: LatLng(
          41.3115743182368, 69.27959652630211),
      zoom: 12.4746,
    );
    
    // Try to get current location, fallback to default if on desktop
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          cameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 14.4746,
          );
          lat = position.latitude;
          long = position.longitude;
        });
      } else {
        // For desktop, use default location
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
    
    debugPrint("USER: ${user}");

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
                      pushToVehicle(id: state.id);
              
                    } else if (state is PreOrderErrorState) {
                      CustomLoadingDialog.hide(context);
                      Services.showSnackBar(
                          context, state.message.toString(), AppColor.red);
                    } else {
                      CustomLoadingDialog.hide(context);
                    }

                    if (state is MainSuccessState){
                      userData = state.data; // Set userData from API response
                      // Always determine the current active order using backend data
                      _ensureCurrentActiveOrder();
                    }

                    if (state is GetOrderSuccessState){
                      final order = state.data;
                      final status = order.status.toLowerCase();
                      final finishedStatuses = <String>{
                        'completed','cancelled','refunded','delivered',
                      };
                      // Treat payment_confirm as non-active for display purposes
                      final isFinished = !order.isActive || finishedStatuses.contains(status) || status == 'payment_confirm';
                      if (isFinished) {
                        _currentOrder = null;
                        _hasActiveOrder = false;
                        _ensureCurrentActiveOrder();
                      } else {
                        _currentOrder = order;
                        _hasActiveOrder = true;
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
                        iconWidget: MapPickerIcon(),
                        mapPickerController: mapPickerController,
                        child: isDesktop
                            ? fm.FlutterMap(
                                mapController: _desktopMapController,
                                options: fm.MapOptions(
                                  initialCenter: latlng.LatLng(lat, long),
                                  initialZoom: 14,
                                  onPositionChanged: (position, hasGesture) async {
                                    if (hasGesture == true) {
                                      mapPickerController.mapMoving!();
                                      textController.text = "checking ...";
                                      _desktopMoveDebounce?.cancel();
                                      _desktopMoveDebounce = Timer(const Duration(milliseconds: 600), () async {
                                        mapPickerController.mapFinishedMoving!();
                                        try {
                                          final place = await placemarkFromCoordinates(lat, long, localeIdentifier: "uz");
                                          if (place.isNotEmpty) {
                                            textController.text = '${place.first.name}, ${place.first.street}, ${place.first.administrativeArea}';
                                          } else {
                                            textController.text = "$lat, $long";
                                          }
                                        } catch (e) {
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
                                    try {
                                      final place = await placemarkFromCoordinates(lat, long, localeIdentifier: "uz");
                                      if (place.isNotEmpty) {
                                        textController.text = '${place.first.name}, ${place.first.street}, ${place.first.administrativeArea}';
                                      } else {
                                        textController.text = "$lat, $long";
                                      }
                                    } catch (e) {
                                      textController.text = "$lat, $long";
                                    }
                                  },
                                  interactionOptions: const fm.InteractionOptions(enableScrollWheel: true),
                                ),
                                children: [
                                  fm.TileLayer(
                                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    subdomains: ['a', 'b', 'c'],
                                  ),
                                ],
                              )
                            : GoogleMap(
                                myLocationEnabled: true,
                                zoomControlsEnabled: false,
                                myLocationButtonEnabled: true,
                                trafficEnabled: true,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 60),
                                mapType: MapType.normal,
                                initialCameraPosition: cameraPosition!,
                                onMapCreated: (GoogleMapController controller) async {
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
                                  try {
                                    List<Placemark> placemarks =
                                        await placemarkFromCoordinates(
                                            cameraPosition!.target.latitude,
                                            cameraPosition!.target.longitude,
                                            localeIdentifier: "uz");
                                    if (placemarks.isNotEmpty) {
                                      textController.text =
                                          '${placemarks.first.name}, ${placemarks.first.street}, ${placemarks.first.administrativeArea}';
                                    } else {
                                      textController.text = "${cameraPosition!.target.latitude}, ${cameraPosition!.target.longitude}";
                                    }
                                  } catch (e) {
                                    print("Geocoding error: $e");
                                    textController.text = "${cameraPosition!.target.latitude}, ${cameraPosition!.target.longitude}";
                                  }
                                },
                              ),
                      ),
                    ),
                    leftMenuButton(),
                    mapLocationText(),
                    BlocConsumer<MainBloc, MainState>(
                      listener: (context, state) {
                        if (state is MainLoadingState) {
                          const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is MainErrorState) {
                          Services.showSnackBar(
                              context, state.message.toString(), AppColor.red);
                        }
                      },
                      builder: (context, state) {
                        if (state is MainSuccessState) {
                          preOrderId = state.data.preOrder ?? 0;
                          // If we already resolved an active order, always show it
                          if (_hasActiveOrder && _currentOrder != null) {
                            return ActiveOrderContainer(order: _currentOrder!);
                          }
                          // Otherwise, only prompt for unfinished preorder when there is truly no active order
                          if ((state.data.order == 0 || state.data.order == null)) {
                            if (preOrderId != 0 && dialogShown == false) {
                              _showMyDialog();
                            }
                            return scrollableMapSelection(state);
                          }
                        }
                        if (state is GetOrderSuccessState){
                          final status = state.data.status.toLowerCase();
                          // If backend returns a paid order, but we resolved an unpaid one, prefer the unpaid
                          if (status == 'payment_confirm' && _currentOrder != null) {
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


void _showCustomBottomSheet(BuildContext context, StateSetter parentState, Widget Function(StateSetter) builder) {
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
      return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
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

void showCustomCapacityBottomSheet(BuildContext context, StateSetter parentState) {
  _showCustomBottomSheet(context, parentState, (StateSetter setState) {
    return selectCapacity(setState, parentState);
  });
}
void showCustomInputBottomSheet(BuildContext context, StateSetter parentState){
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
      setLocation: (id, longitude, latitude) =>
          _setLocation(id, longitude, latitude),
      openSheet: () => showCustomLuggagesBottomSheet(context), //_openSheet(),
      textController: textController,
      size: MediaQuery.of(context).size.width * 0.7,
    );
  }

  Future<void> _setLocation(id, longitude, latitude) async {
    print("long: ${longitude} lat: ${latitude}");
    selectedAddressId = id;
    lat = latitude;
    long = longitude;
    cameraPosition = CameraPosition(
      target: LatLng(lat, long), //LatLng(41.311158, 69.279737),
      zoom: 14.4746,
    );
    if (isDesktop) {
      _desktopMapController.move(latlng.LatLng(lat, long), 14);
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, long, localeIdentifier: "uz");
        if (placemarks.isNotEmpty) {
          textController.text = '${placemarks.first.name}, ${placemarks.first.street}, ${placemarks.first.administrativeArea}';
        } else {
          textController.text = "$lat, $long";
        }
      } catch (_) {
        textController.text = "$lat, $long";
      }
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
    print("object:${userData}");
    if (userData != null && userData.user != null) {
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
                imageUrl: image ?? "",
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CupertinoActivityIndicator(),
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
            var dto = PreOrder(
                address: Address(
                    id: selectedAddressId,
                    name: textController.text,
                    long: long,
                    lat: lat),
                comment: "",
                categoryUnit: activeIndex);
            print("PREORDER: ${dto.toJson()}");
            _bloc.add(PreOrderEvent(data: dto));
              selectedProduct = null;
              activeIndex = null;
            // _closeSheet();
          }
        });
  }

  Future<void> _showMyDialog() async {
    if (dialogShown) return;

    dialogShown = true;
    await Future.delayed(Duration.zero);
    print("ID:${preOrderId}");
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

  pushToVehicle({required int id}){
    Navigator.pushNamed(context, Routes.vehiclechoose,
                          arguments: {"id": id});
  }

  Widget inputSheet(setState,parentState) {
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
              categoryUnit: null);
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
        showCustomCapacityBottomSheet(context, setState);
      }),
      openInputSheet: () => showCustomInputBottomSheet(context,setState),
    );
  }

}
