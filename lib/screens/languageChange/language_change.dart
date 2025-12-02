import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:logistic/constants/colors.dart';

import '../../constants/constants.dart';
import '../../widgets/toggle_button.dart';

class ChangeLanguage extends StatefulWidget {
  const ChangeLanguage({super.key});
  static const String routeName = "change-language";

  @override
  State<ChangeLanguage> createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "settings",
          style: boldBlack.copyWith(fontSize: 20, color: AppColor.white),
        ).tr(),
        backgroundColor: AppColor.primary,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Language".tr(), style: regularText.copyWith(color: AppColor.secondaryText)),
            const SizedBox(height: 10),
            ToggleButton(
              width: 200.0,
              height: 40.0,
              toggleBackgroundColor: Colors.white,
              toggleBorderColor: (AppColor.secondaryText),
              toggleColor: (AppColor.primary),
              activeTextColor: Colors.white,
              inactiveTextColor: AppColor.secondaryText,
              leftDescription: 'Русский',
              rightDescription: "O'zbek",
              onLeftToggleActive: () {
                context.setLocale(const Locale("ru"));
                print('left toggle activated');
              },
              onRightToggleActive: () {
                context.setLocale(const Locale("uz"));
                print('right toggle activated');
              },
            ),
          ],
        ),
      ),
    );
  }
}
