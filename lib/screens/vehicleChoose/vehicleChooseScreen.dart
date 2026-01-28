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
  late final AnimationController _controller;

  var activeIndex = -1;
  var _isDetailSheet = false;
  var _isPaymentSheet = false;

  final _detailSheet = GlobalKey();
  final _paymentSheet = GlobalKey();

  final OrderBloc _bloc = OrderBloc();
  dynamic args;
  var orderList = [];

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

  getOrder(){
    if (args == null) return;
    _bloc.add(GetOrder(id: args["id"]));
  }
  deleteOrder(){
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
                            style: mediumBlack.copyWith(color: AppColor.white),
                          )
                        )
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
                        title: "ready".tr(),
                        onPress: () {
                          _openDetailSheet();
                        }),
                  ),
                ),
              // : null,
              if (_isDetailSheet)
              details(orderList.firstWhere(
                          (element) => element.driver.id == activeIndex)),
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
    return InkWell(
      onTap: () {
        setState(() {
          activeIndex = id;
        });
      },
      child: Container(
        // padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            color: activeIndex == id ? AppColor.primary : AppColor.gray),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      Services.translate(context.locale.toString(),
                          item.driver.car.nameUz, item.driver.car.nameRu),
                      style: mediumBlack.copyWith(
                          fontSize: 17,
                          color: activeIndex == id ? AppColor.white : null)),
                  Text(
                    "${item.price}",
                    style: mediumBlack.copyWith(
                        color: activeIndex == id
                            ? AppColor.white
                            : AppColor.primary),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                    heightFactor: 0.65,
                    child: SvgPicture.asset(
                      AssetImages.vehicle,
                      alignment: Alignment.bottomLeft,
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 16),
                  child: Text(
                    "",
                    style: mediumBlack.copyWith(
                        color: activeIndex == id ? AppColor.white : null),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
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
