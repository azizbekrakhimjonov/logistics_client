import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logistic/models/order.dart';
import 'package:logistic/widgets/button.dart';

import '../../constants/constants.dart';

class Detail extends StatelessWidget {
  final GlobalKey sheet;
  final Function closeSheet;
  final ProposedPrice item;
  // final Function selectItem;
  final int activeIndex;
  final Function onDone;
  const Detail({
    super.key,
    required this.sheet,
    required this.closeSheet,
    required this.item,
    // required this.selectItem,
    required this.activeIndex,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            // blurRadius: 8.0,
            spreadRadius: 1,
            blurRadius: 5,
            color: AppColor.black.withOpacity(0.2),
            offset: Offset(1.0, 1.0),
          ),
        ]),
        child: DraggableScrollableSheet(
          key: sheet,
          initialChildSize: 0.5,
          minChildSize: 0.5,
          maxChildSize: 0.7,
          snap: true,
          snapSizes: const [0.7],
          builder: (BuildContext context, ScrollController scrollController) {
            return DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  // padding: EdgeInsets.symmetric(horizontal: 35, vertical: 25),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                                onPressed: () {
                                  closeSheet();
                                },
                                icon: const Icon(Icons.close)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            circleAvatar(),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Абдулла", style: mediumBlack),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    SvgPicture.asset(AssetImages.star),
                                    SizedBox(width: 5),
                                    Text(
                                      "4.9",
                                      style: mediumBlack.copyWith(
                                          color: AppColor.secondaryText),
                                    )
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 35),
                        Text("${item.price} " + "sum".tr(),
                            style: mediumBlack.copyWith(fontSize: 30),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        // rowText("Sement", "6 880 000so‘m"),
                        // rowText("Yuk tashish mashinasi", "120 000so‘m"),
                        // const SizedBox(height: 25),

                        const SizedBox(height: 35),
                        DefaultButton(
                          disable: false,
                          title: "Оплата",
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
                  )),
            );
          },
        ),
      ),
    );
  }

  Widget rowText(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 45),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, textAlign: TextAlign.start,style: regularText.copyWith(color: AppColor.secondaryText,fontSize: 14),),
          Text(value, textAlign: TextAlign.end,style: regularText.copyWith(color: AppColor.secondaryText,fontSize: 14))
        ],
      ),
    );
  }

  Widget circleAvatar() {
    return Container(
      width: 55, // Adjust the width and height as per your requirement
      height: 55,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColor.primary,
          width: 3.0,
        ),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
                imageUrl:
                    "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CupertinoActivityIndicator(),
                    // CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
        // Image.network(
        //   "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
        //   fit: BoxFit.cover,
        //   errorBuilder: (context, url, error) => Image.asset(
        //           AssetImages.defaultImage,
        //           height: 55,
        //           width: 55,
        //           fit: BoxFit.fill
                  
        //         ),
        // ),
      ),
    );
  }
}
