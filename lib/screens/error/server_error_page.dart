import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:logistic/constants/constants.dart';

class ServerErrorPage extends StatelessWidget {
  final VoidCallback onRetry;

  const ServerErrorPage({super.key, required this.onRetry});

  static const String routeName = 'server_error';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.grayBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: 80,
                  color: AppColor.secondaryText,
                ),
                const SizedBox(height: 24),
                Text(
                  'server_error'.tr(),
                  textAlign: TextAlign.center,
                  style: boldBlack.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  'server_error_description'.tr(),
                  textAlign: TextAlign.center,
                  style: mediumBlack.copyWith(
                    fontSize: 14,
                    color: AppColor.secondaryText,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: AppColor.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('retry'.tr(),
                        style: boldBlack.copyWith(color: AppColor.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
