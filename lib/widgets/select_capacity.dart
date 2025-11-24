import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logistic/widgets/button.dart';

import '../constants/constants.dart';
import '../utils/services.dart';

class SelectCapacity extends StatelessWidget {
  final GlobalKey sheet;
  final List<dynamic> units;
  final Function closeSheet;
  final Function selectItem;
  final int? activeIndex;
  final Function onDone;
  const SelectCapacity({
    super.key,
    required this.sheet,
    required this.units,
    required this.closeSheet,
    required this.selectItem,
    required this.activeIndex,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      key: sheet,
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      snap: true,
      snapSizes: const [0.7],
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16)),
            ),
            // padding: EdgeInsets.symmetric(horizontal: 35, vertical: 25),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  // SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () {
                            closeSheet();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close)),
                    ],
                  ),

                  Text("Sement",
                      style: mediumBlack.copyWith(fontSize: 20)),
                  const SizedBox(height: 5),
                  Text("Miqdorni tanlang",
                      style: lightBlack.copyWith(
                          color: AppColor.secondaryText)),
                  const SizedBox(height: 25),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: units.map((e) {
                        var item = e.id;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 10),
                          child: Column(children: [
                            InkWell(
                              onTap: () {
                                selectItem(item);
                              },
                              child: Container(
                                height: 60,
                                // width: 50,
                                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                decoration: BoxDecoration(
                                    color: item == activeIndex
                                        ? AppColor.primary
                                        : AppColor.gray,
                                    borderRadius:
                                        BorderRadius.circular(10)),
                                child: Center(
                                    child: Text(
                                  "${Services.moneyFormat(e.quantity.toString())} ${e.unit}",
                                  style: item == activeIndex
                                      ? mediumBlack.copyWith(
                                          color: AppColor.white)
                                      : mediumBlack,
                                )),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "${Services.moneyFormat(e.priceFrom.toString())} / \n ${Services.moneyFormat(e.priceTo.toString())}",
                              style: regularText.copyWith(
                                  fontSize: 12,
                                  color: AppColor.secondaryText),
                            )
                          ]),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 35),
                  DefaultButton(
                    disable: activeIndex == null,
                    title: "Tayyor",
                    onPress: () {
                      onDone();
                      // if (activeIndex != 0) {
                      //   Navigator.pushNamed(
                      //       context, Routes.vehiclechoose);
                      //   _closeCapacitySheet();
                      //   _closeSheet();
                      // }
                    },
                  )
                ],
              ),
            ));
      },
    );
  }
}
