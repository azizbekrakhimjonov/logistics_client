import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logistic/utils/services.dart';
import '../constants/constants.dart';
import '../models/active_order.dart';

class ActiveOrderContainer extends StatelessWidget {
  final ActiveOrder order;
  const ActiveOrderContainer({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    var categoryName = order.comment ??
        Services.translate(
            context.locale.toString(),
            order.categoryObj!.category.nameUz,
            order.categoryObj!.category.nameRu);
    var quantity = order.comment == null
        ? " ${order.categoryObj!.quantity} ${order.categoryObj!.unit}"
        : "";
    var image = order.driver?.user.picCompress;
    var serviceTypeText = order.serviceType == 'material'
        ? 'I need a material'
        : 'I need a driver';
    return Positioned(
      bottom: MediaQuery.of(context).viewPadding.bottom + 30,
      left: 24,
      right: 24,
      child: Container(
        // height: MediaQuery.of(context).size.height * 0.4,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
            color: AppColor.white, borderRadius: BorderRadius.circular(20)),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: [
                SizedBox(
                  width:
                      50, // Adjust the width and height as per your requirement
                  height: 50,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: image ?? "",
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              const CupertinoActivityIndicator(),
                      // CircularProgressIndicator(value: downloadProgress.progress),
                      errorWidget: (context, url, error) => Image.asset(
                          AssetImages.defaultImage,
                          fit: BoxFit.cover),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      order.driver?.user.name ?? "Haydovchi",
                      style: mediumBlack.copyWith(fontSize: 17),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: AppColor.primary),
                    child: const Icon(
                      Icons.call,
                      color: AppColor.white,
                    ),
                  ),
                ),
                // IconButton(onPressed: (){}, icon: Icon(Icons.call))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SvgPicture.asset(AssetImages.locationIcon, height: 30),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Yetkazish manzili",
                          style:
                              regularText.copyWith(color: AppColor.grayText)),
                      const SizedBox(height: 5),
                      Text(
                        order.address,
                        style: mediumBlack,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Divider(color: AppColor.black.withOpacity(0.1)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: quantity.isEmpty
                      ? Container()
                      : Image.asset(AssetImages.cementImage, height: 30),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName ?? "",
                        style: regularText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        quantity,
                        style: regularText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.serviceType == 'material'
                        ? AppColor.primary.withOpacity(0.1)
                        : AppColor.lightGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    serviceTypeText,
                    style: mediumBlack.copyWith(
                      fontSize: 12,
                      color: order.serviceType == 'material'
                          ? AppColor.primary
                          : AppColor.lightGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColor.black.withOpacity(0.1)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: SvgPicture.asset(AssetImages.vehicle, height: 35),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Status",
                            style:
                                regularText.copyWith(color: AppColor.grayText)),
                        const SizedBox(height: 5),
                        Text(
                          Services.getStatusString(order.status),
                          style: boldBlack.copyWith(color: AppColor.lightGreen),
                          maxLines: 2,
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Narxi",
                          style:
                              regularText.copyWith(color: AppColor.grayText)),
                      const SizedBox(height: 5),
                      Text(
                        Services.moneyFormat(order.price.toString()) ?? "",
                        style: boldBlack,
                        maxLines: 2,
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
