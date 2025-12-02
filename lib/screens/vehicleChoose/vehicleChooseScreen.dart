import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logistic/constants/constants.dart';
import 'package:lottie/lottie.dart';

import 'package:logistic/models/order.dart';
import 'package:logistic/screens/vehicleChoose/bloc/order_bloc.dart';
import 'package:logistic/screens/vehicleChoose/detail.dart';
import 'package:logistic/screens/vehicleChoose/paymentType.dart';
import 'package:logistic/utils/utils.dart';

import '../../routes.dart';
import '../../widgets/widgets.dart';

class VehicleChooseScreen extends StatefulWidget {
  const VehicleChooseScreen({super.key});
  static const String routeName = "vehiclechoose";

  @override
  State<VehicleChooseScreen> createState() => _VehicleChooseScreenState();
}

class _VehicleChooseScreenState extends State<VehicleChooseScreen>
    with TickerProviderStateMixin {
  var activeIndex = -1;
  var _isDetailSheet = false;
  var _isPaymentSheet = false;

  final _detailSheet = GlobalKey();
  final _paymentSheet = GlobalKey();

  final OrderBloc _bloc = OrderBloc();
  dynamic args;
  var orderList = [];
  Order? _currentOrderData; // Store current order data

  void _openDetailSheet() {
    setState(() {
      _isDetailSheet = true;
    });
  }

  void _closeDetailSheet() {
    setState(() {
      _isDetailSheet = false;
    });
  }

  void _openPaymentSheet() {
    setState(() {
      _isPaymentSheet = true;
    });
  }

  void _closePaymentSheet() {
    setState(() {
      _isPaymentSheet = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    setState(() {
      args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    });
    if (args != null) {
      getOrder();
    }
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  getOrder() {
    if (args == null) return;
    _bloc.add(GetOrder(id: args["id"]));
  }

  deleteOrder() {
    if (args == null) return;
    _bloc.add(DeleteOrder(id: args["id"]));
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("DEBUG");
    return BlocProvider.value(
      value: _bloc,
      child: WillPopScope(
        onWillPop: () async {
          print("willpop");
          _showMyDialog();
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Buyurtmani qabul qilishga tayyor yuk mashinalar",
              style: mediumBlack,
              maxLines: 3,
            ),
            iconTheme: IconThemeData(color: AppColor.black),
          ),
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  orderList = [];
                  activeIndex = -1;
                  getOrder();
                },
                child: BlocConsumer<OrderBloc, OrderState>(
                    listener: (context, state) {
                  if (state is OrderDeleteLoadingState) {
                    CustomLoadingDialog.show(context);
                  }
                  if (state is OrderDeleteSuccessState) {
                    CustomLoadingDialog.hide(context);
                    Navigator.popAndPushNamed(context, Routes.mainScreen);
                  }
                  if (state is OrderDeleteErrorState) {
                    CustomLoadingDialog.hide(context);
                    Services.showSnackBar(
                        context, state.message, AppColor.errorRed);
                  }
                  if (state is OrderSuccessState) {
                    setState(() {
                      orderList = state.data.proposedPrices;
                      _currentOrderData = state.data; // Store order data
                    });
                  }
                  if (state is OrderErrorState) {
                    Services.showSnackBar(
                        context, state.message, AppColor.errorRed);
                  }
                }, builder: (context, state) {
                  if (state is OrderLoadingState) {
                    return Center(
                      child: Container(
                        height: 200,
                        width: 200,
                        child: Lottie.asset(AssetImages.lottieFile,
                            fit: BoxFit.cover, repeat: true, animate: true),
                      ),
                    );
                  }
                  if (orderList.isEmpty) {
                    return Center(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("List is empty"),
                        SizedBox(height: 20),
                        FloatingActionButton.extended(
                            backgroundColor: AppColor.primary,
                            onPressed: () {
                              getOrder();
                            },
                            icon: Icon(
                              Icons.refresh,
                              color: AppColor.white,
                            ),
                            label: Text(
                              "Refresh",
                              style:
                                  mediumBlack.copyWith(color: AppColor.white),
                            ))
                      ],
                    ));
                  } else {
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      itemBuilder: (BuildContext context, int index) {
                        return item(orderList[index]);
                      },
                      itemCount: orderList.length,
                    );
                  }
                  // return Container(child: Text("text"),);
                }),
              ),
              if (activeIndex != -1)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        spreadRadius: 50,
                        blurRadius: 100,
                        color: AppColor.white.withOpacity(0.7),
                        offset: Offset(1.0, 1.0),
                      )
                    ]),
                    height: 50,
                    child: DefaultButton(
                        disable: false,
                        title: "Tayyor",
                        onPress: () {
                          _openDetailSheet();
                        }),
                  ),
                ),
              // : null,
              if (_isDetailSheet)
                details(orderList
                    .firstWhere((element) => element.driver.id == activeIndex)),
              if (_isPaymentSheet) paymentType()
            ],
          ),
        ),
      ),
    );
  }

  Widget details(ProposedPrice item) {
    return Detail(
        sheet: _detailSheet,
        closeSheet: () => _closeDetailSheet(),
        item: item,
        activeIndex: activeIndex,
        orderData: _currentOrderData, // Pass stored order data
        onDone: () {
          _openPaymentSheet();
          _closeDetailSheet();
        });
  }

  Widget paymentType() {
    var selectedDriver = orderList.firstWhere(
      (element) => element.driver.id == activeIndex,
    );
    return PaymentType(
      sheet: _paymentSheet,
      closeSheet: () => _closePaymentSheet(),
      driverId: selectedDriver.driver.id,
      preorderId: args != null ? args["id"] : 0,
    );
  }

  Widget item(ProposedPrice item) {
    var id = item.driver.id;
    final isSelected = activeIndex == id;
    final carName = Services.translate(
      context.locale.toString(),
      item.driver.car.nameUz,
      item.driver.car.nameRu,
    );
    final formattedPrice = _formatPrice(item.price);

    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: isSelected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColor.primary,
                  AppColor.primary.withOpacity(0.85),
                ],
              )
            : null,
        color: isSelected ? null : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColor.primary.withOpacity(0.35)
                : Colors.black.withOpacity(0.06),
            blurRadius: isSelected ? 15 : 10,
            offset: Offset(0, isSelected ? 5 : 3),
            spreadRadius: isSelected ? 0 : 0,
          ),
        ],
        border: isSelected
            ? null
            : Border.all(
                color: AppColor.gray.withOpacity(0.25),
                width: 1.5,
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              activeIndex = id;
            });
          },
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
            child: Row(
              children: [
                // Vehicle icon with enhanced design
                AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.28)
                        : AppColor.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: isSelected
                        ? Border.all(
                            color: Colors.white.withOpacity(0.35),
                            width: 2,
                          )
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AssetImages.vehicle,
                      width: 38,
                      height: 38,
                      colorFilter: ColorFilter.mode(
                        isSelected ? AppColor.white : AppColor.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                // Vehicle name, driver name, and price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Vehicle name
                      Text(
                        carName,
                        style: mediumBlack.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: isSelected ? AppColor.white : AppColor.black,
                          height: 1.2,
                        ),
                      ),
                      // Driver name (if available)
                      if (item.driver.user?.name != null) ...[
                        SizedBox(height: 4),
                        Text(
                          item.driver.user!.name!,
                          style: regularText.copyWith(
                            fontSize: 13,
                            color: isSelected
                                ? AppColor.white.withOpacity(0.85)
                                : AppColor.secondaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: 8),
                      // Price with so'm
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.25)
                                  : AppColor.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: isSelected
                                  ? Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.attach_money_rounded,
                                  size: 18,
                                  color: isSelected
                                      ? AppColor.white
                                      : AppColor.primary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  formattedPrice,
                                  style: mediumBlack.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                    color: isSelected
                                        ? AppColor.white
                                        : AppColor.primary,
                                    height: 1.0,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "so'm",
                                  style: regularText.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? AppColor.white.withOpacity(0.9)
                                        : AppColor.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                // Selection indicator with enhanced animation
                AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColor.white : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColor.white
                          : AppColor.secondaryText.withOpacity(0.4),
                      width: 2.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColor.white.withOpacity(0.6),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          size: 20,
                          color: AppColor.primary,
                          weight: 3,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    // Format price with spaces for thousands
    String priceStr = price.toString();
    String formatted = '';
    int count = 0;
    for (int i = priceStr.length - 1; i >= 0; i--) {
      if (count == 3) {
        formatted = ' ' + formatted;
        count = 0;
      }
      formatted = priceStr[i] + formatted;
      count++;
    }
    return formatted;
  }

  Future<void> _showMyDialog() async {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        // title: const Text('Alert'),
        content: Text(
          'Zakazni bekor qilishni xohlaysizmi?',
          style: boldBlack,
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: Text("Yo'q", style: mediumBlack),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: Text('Ha', style: mediumBlack.copyWith(color: AppColor.red)),
            isDestructiveAction: true,
            onPressed: () {
              deleteOrder();
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}
