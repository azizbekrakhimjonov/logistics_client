import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logistic/constants/app_text_style.dart';
import 'package:logistic/constants/colors.dart';
import 'package:logistic/utils/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Yordam ekrani — aloqa uchun telefon raqami +998906463477
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  static const String routeName = 'help';

  static const String supportPhone = '+998906463477';

  Future<void> _launchCall(BuildContext context) async {
    final uri = Uri.parse('tel:$supportPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await Clipboard.setData(const ClipboardData(text: supportPhone));
      if (context.mounted) {
        final copied = Services.translate(
            context.locale.toString(), 'Nusxalandi', 'Скопировано');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$supportPhone $copied'),
            backgroundColor: AppColor.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.toString();
    final contactLabel = Services.translate(locale,
            'Aloqa uchun qo\'ng\'iroq qiling:', 'Для связи позвоните:') ??
        'Aloqa uchun qo\'ng\'iroq qiling:';
    final tapHint = Services.translate(
            locale, 'Bosib qo\'ng\'iroq qiling', 'Нажмите, чтобы позвонить') ??
        'Bosib qo\'ng\'iroq qiling';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColor.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'help'.tr(),
          style: boldBlack.copyWith(fontSize: 20, color: AppColor.white),
        ),
        backgroundColor: AppColor.primary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contactLabel,
                style: regularText.copyWith(
                  color: AppColor.secondaryText,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _launchCall(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColor.grayBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColor.grayText.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone,
                          color: AppColor.primary, size: 28),
                      const SizedBox(width: 16),
                      Text(
                        supportPhone,
                        style: boldBlack.copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tapHint,
                style: lightBlack.copyWith(
                  color: AppColor.secondaryText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
