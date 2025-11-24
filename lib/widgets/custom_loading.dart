import 'package:flutter/material.dart';
import 'package:logistic/constants/colors.dart';

class CustomLoadingDialog extends StatelessWidget {
  static bool _ignoring = true;
  static bool _canPop = false;

  const CustomLoadingDialog._({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context, {bool ignoring = true}) async {
    _ignoring = ignoring;
    _canPop = true;
    await showDialog(
      context: context,
      builder: (_) => const CustomLoadingDialog._(),
    );
  }

  static void hide(BuildContext context) {
    if (_canPop) Navigator.pop(context);
    _canPop = false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_ignoring) _canPop = false;
        return !_ignoring;
      },
      child: Scaffold(
        backgroundColor: const Color(0x00000000),
        body: GestureDetector(
          onTap: _ignoring
              ? null
              : () {
                  if (_canPop) Navigator.pop(context);
                  _canPop = false;
                },
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(
                AppColor.primary,
              )),
            ),
          ),
        ),
      ),
    );
  }
}
