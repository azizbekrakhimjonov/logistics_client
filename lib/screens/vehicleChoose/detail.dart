import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final Order? orderData; // Add order data to show order details
  const Detail({
    super.key,
    required this.sheet,
    required this.closeSheet,
    required this.item,
    // required this.selectItem,
    required this.activeIndex,
    required this.onDone,
    this.orderData,
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
            offset: const Offset(1.0, 1.0),
          ),
        ]),
        child: DraggableScrollableSheet(
          key: sheet,
          initialChildSize: 0.75,
          minChildSize: 0.7,
          maxChildSize: 0.9,
          snap: false,
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 60,
                      height: 5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: AppColor.secondaryText.withOpacity(0.3),
                      ),
                    ),
                    // Close button
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
                    // Content - Scrollable to prevent overflow
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header Title
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text(
                                "Taklif ma'lumotlari",
                                style: boldBlack.copyWith(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Driver Information Card
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColor.grayBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      circleAvatar(),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Haydovchi",
                                              style: regularText.copyWith(
                                                fontSize: 11,
                                                color: AppColor.secondaryText,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              item.driver.user?.name ??
                                                  "Haydovchi",
                                              style: mediumBlack.copyWith(
                                                  fontSize: 16),
                                            ),
                                            if (item.driver.user?.username !=
                                                null) ...[
                                              const SizedBox(height: 3),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.phone,
                                                    size: 12,
                                                    color:
                                                        AppColor.secondaryText,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      item.driver.user!
                                                          .username!,
                                                      style:
                                                          regularText.copyWith(
                                                        fontSize: 11,
                                                        color: AppColor
                                                            .secondaryText,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Divider(
                                      color: AppColor.secondaryText
                                          .withOpacity(0.2)),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.local_shipping,
                                        size: 16,
                                        color: AppColor.primary,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Transport vositası",
                                              style: regularText.copyWith(
                                                fontSize: 11,
                                                color: AppColor.secondaryText,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              item.driver.car.nameUz.isNotEmpty
                                                  ? item.driver.car.nameUz
                                                  : item.driver.car.nameRu,
                                              style: mediumBlack.copyWith(
                                                  fontSize: 15),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Order Details Card (if available)
                            if (orderData != null) ...[
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColor.grayBackground,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Buyurtma ma'lumotlari",
                                      style: mediumBlack.copyWith(fontSize: 14),
                                    ),
                                    const SizedBox(height: 10),
                                    if (orderData!.comment != null &&
                                        orderData!.comment
                                            .toString()
                                            .isNotEmpty)
                                      _buildInfoRow(
                                        Icons.description,
                                        "Izoh",
                                        orderData!.comment.toString(),
                                      ),
                                    if (orderData!.serviceType.isNotEmpty)
                                      _buildInfoRow(
                                        orderData!.serviceType == 'material'
                                            ? Icons.inventory_2
                                            : Icons.person,
                                        "Xizmat turi",
                                        orderData!.serviceType == 'material'
                                            ? "Material kerak"
                                            : "Haydovchi kerak",
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                            // Proposed Price Section
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 18),
                              decoration: BoxDecoration(
                                color: AppColor.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColor.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Taklif qilingan narx",
                                    style: regularText.copyWith(
                                      fontSize: 12,
                                      color: AppColor.secondaryText,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "${_formatPrice(item.price)} ${"sum".tr()}",
                                    style: boldBlack.copyWith(
                                      fontSize: 26,
                                      color: AppColor.primary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: DefaultButton(
                                disable: false,
                                title: "Оплата",
                                onPress: () {
                                  onDone();
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget rowText(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 45),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            textAlign: TextAlign.start,
            style: regularText.copyWith(
                color: AppColor.secondaryText, fontSize: 14),
          ),
          Text(value,
              textAlign: TextAlign.end,
              style: regularText.copyWith(
                  color: AppColor.secondaryText, fontSize: 14))
        ],
      ),
    );
  }

  Widget circleAvatar() {
    String? imageUrl;
    if (item.driver.user?.picCompress != null &&
        item.driver.user!.picCompress!.isNotEmpty) {
      // If pic_compress is a relative URL, prepend base URL
      imageUrl = item.driver.user!.picCompress!.startsWith('http')
          ? item.driver.user!.picCompress!
          : "https://airvive.coded.uz${item.driver.user!.picCompress!}";
    } else {
      imageUrl = "https://cdn-icons-png.flaticon.com/512/3135/3135715.png";
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColor.primary,
          width: 2.0,
        ),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              const CupertinoActivityIndicator(),
          errorWidget: (context, url, error) => Container(
            color: AppColor.grayBackground,
            child: const Icon(
              Icons.person,
              color: AppColor.primary,
              size: 35,
            ),
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColor.secondaryText),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: regularText.copyWith(
                    fontSize: 12,
                    color: AppColor.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: mediumBlack.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
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
        formatted = ' $formatted';
        count = 0;
      }
      formatted = priceStr[i] + formatted;
      count++;
    }
    return formatted;
  }
}
