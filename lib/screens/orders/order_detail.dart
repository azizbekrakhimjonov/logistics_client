import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:logistic/constants/constants.dart';
import 'package:logistic/models/active_order.dart';
import 'package:logistic/repositories/services_repository.dart';
import 'package:logistic/utils/services.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});
  static const String routeName = 'orderdetailscreen';

  Future<ActiveOrder> _load(BuildContext context) async {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int id = args['id'] as int;
    final ServicesRepository repo = ServicesRepository();
    final ActiveOrder order = await repo.getOrderDetail(id);
    // Debug API response
    // ignore: avoid_print
    print('OrderDetail loaded: ${order.toJson()}');
    return order;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order details'),
        backgroundColor: AppColor.primary,
      ),
      body: FutureBuilder<ActiveOrder>(
        future: _load(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CupertinoActivityIndicator(color: AppColor.primary, radius: 20),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  snapshot.error.toString(),
                  style: mediumBlack.copyWith(color: AppColor.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final order = snapshot.data!;
          final categoryName = order.comment ?? order.categoryObj!.category.nameUz;
          final quantity = order.comment == null ? "${order.categoryObj!.quantity} ${order.categoryObj!.unit}" : "";
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                title: const Text('Status'),
                subtitle: Text(Services.getStatusString(order.status)),
              ),
              const Divider(),
              ListTile(
                title: const Text('Address'),
                subtitle: Text(order.address),
              ),
              const Divider(),
              ListTile(
                title: const Text('Category'),
                subtitle: Text(categoryName),
              ),
              if (quantity.isNotEmpty) const Divider(),
              if (quantity.isNotEmpty)
                ListTile(
                  title: const Text('Quantity'),
                  subtitle: Text(quantity),
                ),
              const Divider(),
              ListTile(
                title: const Text('Price'),
                subtitle: Text(Services.moneyFormat(order.price.toString()) ?? ''),
              ),
              const SizedBox(height: 24),
              if (order.paymentUrl != null && order.paymentUrl!.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: AppColor.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      final uri = Uri.parse(order.paymentUrl!);
                      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                        // ignore: avoid_print
                        print('Could not launch ${order.paymentUrl!}');
                      }
                    },
                    child: Text('pay'.tr()),
                  ),
                ),
              if (order.paymentUrl == null || order.paymentUrl!.isEmpty)
                Text(
                  'No payment link',
                  style: regularText.copyWith(color: AppColor.secondaryText),
                ),
            ],
          );
        },
      ),
    );
  }
}


