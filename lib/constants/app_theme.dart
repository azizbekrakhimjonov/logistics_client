import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:logistic/constants/colors.dart';

// import 'app_font.dart';
// import 'colors.dart';

final ThemeData themeData = ThemeData(
    indicatorColor: Colors.black,
    fontFamily: "Stem",
    primaryColor: AppColor.primary,//Colors.black,
    scaffoldBackgroundColor: Colors.white,
    focusColor: AppColor.primary,
    // inputDecorationTheme: InputDecorationTheme(focusColor: AppColor.primary,focusedBorder: OutlineInputBorder(
    //         borderSide: BorderSide(color: AppColor.primary.withOpacity(0.5), width: 1.0),
    //       ),),
    // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    primaryIconTheme: IconThemeData(color: Colors.black),
    useMaterial3: true,
    // brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
      
      ),
      elevation: 0.0,
      backgroundColor: Colors.white,
      
      iconTheme: IconThemeData(
        color: Colors.white, //change your color here
      ),
      titleTextStyle: TextStyle(color: Colors.white),
    ),
    scrollbarTheme: ScrollbarThemeData(thumbColor: MaterialStateProperty.all<Color>(Colors.red)
        )
    
    );


