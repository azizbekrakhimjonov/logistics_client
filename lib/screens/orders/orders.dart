import 'dart:ffi';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logistic/constants/app_text_style.dart';
import 'package:logistic/constants/colors.dart';
import 'package:logistic/models/history.dart';
import 'package:logistic/screens/orders/bloc/history_bloc.dart';
import 'package:logistic/widgets/widgets.dart';

import '../../utils/utils.dart';
import '../../routes.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});
  static const String routeName = 'myorderscreen';

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final _bloc = HistoryBloc();
  List<History> items = [];

  @override
  void initState() {
    _bloc.add(GetHistory());
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              "myOrders".tr(),
              style: boldBlack.copyWith(fontSize: 20, color: AppColor.white),
            ),
            backgroundColor: AppColor.primary,
          ),
          body: BlocConsumer<HistoryBloc, HistoryState>(
            listener: (context, state) {
              // if (state is HistoryLoadingState){
              //     CustomLoadingDialog.show(context);
              // }
              if (state is HistoryErrorState) {
                CustomLoadingDialog.hide(context);
                Services.showSnackBar(
                    context, state.message.toString(), AppColor.red);
              }
              if (state is HistorySuccessState) {
                CustomLoadingDialog.hide(context);
                items = state.data;
              }
            },
            builder: (context, state) {
              if (state is HistoryLoadingState){
                return Center(child: CupertinoActivityIndicator(color: AppColor.primary,radius: 30,));
              }  if (state is HistorySuccessState) {
              return RefreshIndicator(
                onRefresh: () async {
                  _bloc.add(GetHistory());
                },
                child: items.isNotEmpty ? ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return orderItem(item:items[index]);
                  },
                  itemCount: items.length,
                ): Center(child: Container(child: Text("Sizda hali hech qanday zakaz yo'q")),),
              ); }
              return Container();
            },
          )),
    );
  }

  Widget orderItem({required History item}) {
    var categoryName = item.comment == null ? Services.translate(context.locale.toString(), item.categoryObj!.category.nameUz, item.categoryObj!.category.nameRu) : item.comment;
    var quantity = item.comment == null ? " ${item.categoryObj!.quantity} ${item.categoryObj!.unit}" : "";
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, Routes.orderDetail, arguments: {"id": item.id});
      },
      child: Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      margin: EdgeInsets.symmetric(vertical: 9, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColor.white,
        boxShadow: [
          BoxShadow(
            // blurRadius: 8.0,
            spreadRadius: 1,
            blurRadius: 5,
            color: AppColor.black.withOpacity(0.2),
            offset: Offset(1.0, 1.0),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      style: mediumBlack,
                      children: <TextSpan>[
                        TextSpan(text: categoryName),
                        TextSpan(
                          text: quantity,
                          style: mediumBlack.copyWith(color: AppColor.primary),
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  // Text(Services.dateFormatter(item.updatedAt), style: mediumBlack),
                ],
              ),
              Text(Services.getStatusString(item.status),
                  style: mediumBlack.copyWith(color: AppColor.primary)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.address,
                style: mediumBlack.copyWith(color: AppColor.secondaryText),
              ),
              RichText(
                text: TextSpan(
                  style: mediumBlack.copyWith(color: AppColor.secondaryText),
                  children: <TextSpan>[
                    TextSpan(text: Services.moneyFormat(item.price.toString())),
                    TextSpan(
                      text: " so'm",
                      style: mediumBlack.copyWith(color: AppColor.primary),
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(Services.dateFormatter(item.updatedAt), style: mediumBlack.copyWith(color: AppColor.secondaryText)),
            ],
          ),
        ],
      ),
    ),
    );
  }
}
