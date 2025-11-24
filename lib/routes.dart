
import 'package:flutter/material.dart';
import 'package:logistic/screens/auth/code_entry.dart';
import 'package:logistic/screens/auth/login_screen.dart';
import 'package:logistic/screens/languageChange/language_change.dart';
import 'package:logistic/screens/orders/orders.dart';
import 'package:logistic/screens/vehicleChoose/vehicleChooseScreen.dart';
import 'package:logistic/screens/orders/order_detail.dart';

import 'screens/auth/account/account.dart';
import 'screens/mainScreen/main_screen.dart';

class Routes {
  Routes._();
     static const String mainScreen = MainScreen.routeName;
     static const String myOrders = MyOrdersScreen.routeName;
     static const String vehiclechoose = VehicleChooseScreen.routeName;
     static const String orderDetail = OrderDetailScreen.routeName;
     static const String languageChange = ChangeLanguage.routeName;
     static const String login = LoginScreen.routeName;
     static const String codeEntry = CodeEntryScreen.routeName;
     static const String account = AccountAppBar.routeName;

  static final routes = <String, WidgetBuilder>{
    login: (context) => LoginScreen(),
    codeEntry: (context) => CodeEntryScreen(),
    languageChange: (context) => ChangeLanguage(),
    mainScreen: (context) => MainScreen(),
    myOrders: (context) => MyOrdersScreen(),
    vehiclechoose: (context) => VehicleChooseScreen(),
    orderDetail: (context) => const OrderDetailScreen(),
    account: (context) => AccountAppBar()
  };
}
