import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../constants/app_text_style.dart';
import '../constants/constants.dart';

class Button extends StatelessWidget {
  final String title;
  final Function onPress;
  final border;
  final bool loading;
  final bool disable;
  const Button(
      {Key? key,
      required this.title,
      required this.onPress,
      this.border = false,
      this.loading = false,
      this.disable = false
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>disable ? {} : onPress(),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 18),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: disable ? AppColor.disableColor : AppColor.primary,
          border: Border.all(
              color: border
                  ? AppColor.black.withOpacity(0.5)
                  : AppColor.transparent,
              width: 1),
          // boxShadow: [
          //   BoxShadow(
          //     color: AppColor.black.withOpacity(0.5),
          //     offset: Offset(1.0, 1.0), //(x,y)
          //     blurRadius: 10.0,
          //   ),
          // ],
        ),
        child: loading
            ? CupertinoTheme(
                data: CupertinoTheme.of(context)
                    .copyWith(brightness: Brightness.dark),
                child: const CupertinoActivityIndicator(
                  animating: true,
                  radius: 12,
                ),
              )
            : Text(
                title,
                style: border ? boldBlack.copyWith(fontSize: 18,color: AppColor.white) : boldBlack.copyWith(fontSize: 18,color: AppColor.white),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
