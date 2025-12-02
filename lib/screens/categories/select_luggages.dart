import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logistic/utils/services.dart';

import '../../constants/constants.dart';

class SelectLuggages extends StatelessWidget {
  final List<dynamic> list;
  final int? selectedProduct;
  final GlobalKey sheet;
  final Function openSheet;
  final Function openInputSheet;
  // final Function closeSheet;

  const SelectLuggages(
      {super.key,
      required this.list,
      required this.selectedProduct,
      required this.sheet,
      required this.openSheet,
      required this.openInputSheet,
      // required this.closeSheet
      });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      key: sheet,
      initialChildSize: 0.7,
      minChildSize: 0.6,
      maxChildSize: 0.9,
      snap: true,
      expand: false,
      snapSizes: const [0.7],
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            // padding: EdgeInsets.symmetric(horizontal: 35, vertical: 25),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () {
                          // closeSheet();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close)),
                  ],
                ),
                // SizedBox(height: ),
                Text("Sizga qanday xom ashyo kerak?", style: boldBlack),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // number of items in each row
                        mainAxisSpacing: 0.0, // spacing between rows
                        crossAxisSpacing: 32.0, // spacing between columns
                        childAspectRatio: 0.55),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 35,
                        vertical: 25), // padding around the grid
                    itemCount: list
                        .length + 1, //items.length, // total number of items
                    itemBuilder: (context, index) {
                     
                       if (index != list
                        .length){
                           var item = list[index];
                      return  Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: InkWell(
                              onTap: () {
                                openSheet(item.id,item.units);
                              },
                              child: Container(
                                height: 100,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: AppColor.gray,
                                    border: Border.all(
                                      color: selectedProduct == item.id ? AppColor.primary: AppColor.white,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        10)), // color of grid items
                                child: Center(
                                  child: CachedNetworkImage(
                                    imageUrl: item.icon,
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) =>
                                            const CupertinoActivityIndicator(),
                                    // CircularProgressIndicator(value: downloadProgress.progress),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error,color: AppColor.primary,),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            Services.translate(context.locale.toString(),
                                item.nameUz, item.nameRu),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: mediumBlack.copyWith(fontSize: 12),
                          )
                        ],
                      );
                      } else {
                        return  Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: InkWell(
                              onTap: () {
                                openInputSheet();
                                // openSheet("","");
                              },
                              child: Container(
                                height: 100,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: AppColor.gray,
                                    border: Border.all(
                                      color: AppColor.white,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        10)), // color of grid items
                                child: const Center(
                                  child: Icon(Icons.add,size: 35,color: AppColor.primary,),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            "Boshqa xom ashyo kiritish",
                            // Services.translate(context.locale.toString(),
                            //     item.nameUz, item.nameRu),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: mediumBlack.copyWith(fontSize: 12),
                          )
                        ],
                      );
                      }
                    },
                  ),
                ),
              ],
            ));
      },
    );
  }
}
