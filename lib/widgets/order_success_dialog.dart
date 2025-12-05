import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/app_text_style.dart';
import 'custom_button.dart';

class OrderSuccessDialog extends StatelessWidget {
  final VoidCallback onOk;

  const OrderSuccessDialog({
    Key? key,
    required this.onOk,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: AppColor.lightGreen,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              "Buyurtma yaratildi!",
              style: boldBlack.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Buyurtmangiz muvaffaqiyatli yaratildi. Tez orada siz bilan bog'lanamiz va buyurtma tafsilotlari haqida ma'lumot beramiz!",
              style: mediumBlack.copyWith(
                fontSize: 14,
                color: AppColor.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Button(
              title: "OK",
              onPress: () {
                Navigator.of(context).pop();
                onOk();
              },
            ),
          ],
        ),
      ),
    );
  }
}



