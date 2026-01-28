import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart';

class DefaultButton extends StatelessWidget {
  final bool disable;
  final String title;
  final Function onPress;

  const DefaultButton({
    super.key,
    required this.disable,
    required this.title,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disable ? null : () => onPress(),
      child: Container(
          width: 160,
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: disable ? AppColor.disableColor : AppColor.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
              child: Text(
            title,
            style: boldBlack.copyWith(
              fontSize: 20,
              color: disable ? AppColor.secondaryText : AppColor.white,
            ),
          ))),
    );
  }
}
