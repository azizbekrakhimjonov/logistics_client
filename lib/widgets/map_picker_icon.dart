import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/constants.dart';

class MapPickerIcon extends StatelessWidget {
  const MapPickerIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const FractionalOffset(0.2, -0.5),
      heightFactor: 0.7,
      child: AvatarGlow(
        glowColor: AppColor.primary,
        endRadius: 100.0,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        showTwoGlows: true,
        repeatPauseDuration: const Duration(milliseconds: 100),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: SvgPicture.asset(
            AssetImages.location,
            height: 70,
            // color: AppColor.black,
          ),
        ),
      ),
    );
  }
}