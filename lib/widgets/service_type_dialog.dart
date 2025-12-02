import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/app_text_style.dart';
import 'custom_button.dart';

class ServiceTypeDialog extends StatelessWidget {
  final Function(String) onSelected;

  const ServiceTypeDialog({
    Key? key,
    required this.onSelected,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Xizmat turini tanlang",
              style: boldBlack.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildOptionButton(
              context,
              title: "I need a material",
              icon: Icons.inventory_2,
              onTap: () {
                Navigator.of(context).pop();
                onSelected('material');
              },
            ),
            const SizedBox(height: 12),
            _buildOptionButton(
              context,
              title: "I need a driver",
              icon: Icons.person,
              onTap: () {
                Navigator.of(context).pop();
                onSelected('driver');
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Bekor qilish",
                style: mediumBlack.copyWith(color: AppColor.secondaryText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColor.grayBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColor.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColor.primary,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: mediumBlack.copyWith(fontSize: 16),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColor.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

