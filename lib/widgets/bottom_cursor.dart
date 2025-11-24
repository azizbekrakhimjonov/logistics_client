import 'package:flutter/material.dart';
import 'package:logistic/constants/app_text_style.dart';
import 'package:pinput/pinput.dart';

import '../constants/constants.dart';

class OnlyBottomCursor extends StatefulWidget {
  final TextEditingController controller;
  const OnlyBottomCursor({Key? key,required this.controller}) : super(key: key);

  @override
  _OnlyBottomCursorState createState() => _OnlyBottomCursorState();

  @override
  String toStringShort() => 'With Bottom Cursor';
}

class _OnlyBottomCursorState extends State<OnlyBottomCursor> {
  // final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    widget.controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = AppColor.primary;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: mediumBlack.copyWith(fontSize: 30),
    );

    final cursor = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 56,
          height: 5,
          decoration: BoxDecoration(
            color: borderColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
    final preFilledWidget = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 56,
          height: 5,
          decoration: BoxDecoration(
            color: AppColor.secondaryText.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );

    return Pinput(
      length: 4,
      pinAnimationType: PinAnimationType.slide,
      controller: widget.controller,
      focusNode: focusNode,
      defaultPinTheme: defaultPinTheme,
      submittedPinTheme: defaultPinTheme.copyWith(
        decoration: BoxDecoration(
           color: AppColor.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
        )
      ),
      showCursor: true,
      cursor: cursor,
      preFilledWidget: preFilledWidget,
      
    );
  }
}