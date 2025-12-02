import 'package:flutter/material.dart';

class NavigationService {
  late GlobalKey<NavigatorState> navigationKey;

  static NavigationService instance = NavigationService();

  NavigationService() {
    navigationKey = GlobalKey<NavigatorState>();
  }

  Future<dynamic> navigateToReplacement(String rn) {
    return navigationKey.currentState!.pushReplacementNamed(rn);
  }

  Future<dynamic> navigateTo(String rn) {
    return navigationKey.currentState!.pushNamed(rn);
  }

  Future<dynamic> navigateToRoute(MaterialPageRoute rn) {
    return navigationKey.currentState!.push(rn);
  }

  goback() {
    return navigationKey.currentState!.pop();
  }
}
