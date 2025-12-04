import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    _bloc.add(const GetHistory());
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
                setState(() {
                  items = state.data;
                });
              }
            },
            builder: (context, state) {
              if (state is HistoryLoadingState){
                return const Center(child: CupertinoActivityIndicator(color: AppColor.primary,radius: 30,));
              }  if (state is HistorySuccessState) {
              // Ensure items are sorted by latest (updatedAt descending)
              final sortedItems = List<History>.from(state.data)
                ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
              return RefreshIndicator(
                onRefresh: () async {
                  _bloc.add(const GetHistory());
                },
                child: sortedItems.isNotEmpty ? ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return orderItem(item: sortedItems[index]);
                  },
                  itemCount: sortedItems.length,
                ): Center(child: Container(child: const Text("Sizda hali hech qanday zakaz yo'q")),),
              ); }
              return Container();
            },
          )),
    );
  }

  Widget orderItem({required History item}) {
    var categoryName = item.comment ?? Services.translate(context.locale.toString(), item.categoryObj!.category.nameUz, item.categoryObj!.category.nameRu);
    var quantity = item.comment == null ? " ${item.categoryObj!.quantity} ${item.categoryObj!.unit}" : "";
    var serviceTypeText = item.serviceType == 'material' ? 'I need a material' : 'I need a driver';
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, Routes.orderDetail, arguments: {"id": item.id});
      },
      child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      margin: const EdgeInsets.symmetric(vertical: 9, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColor.white,
        boxShadow: [
          BoxShadow(
            // blurRadius: 8.0,
            spreadRadius: 1,
            blurRadius: 5,
            color: AppColor.black.withOpacity(0.2),
            offset: const Offset(1.0, 1.0),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
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
              ),
              const SizedBox(width: 10),
              Text(Services.getStatusString(item.status),
                  style: mediumBlack.copyWith(color: AppColor.primary)),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.serviceType == 'material' 
                      ? AppColor.primary.withOpacity(0.1) 
                      : AppColor.lightGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  serviceTypeText,
                  style: mediumBlack.copyWith(
                    fontSize: 12,
                    color: item.serviceType == 'material' 
                        ? AppColor.primary 
                        : AppColor.lightGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.address,
                  style: mediumBlack.copyWith(color: AppColor.secondaryText),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 10),
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
          const SizedBox(height: 5),
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
