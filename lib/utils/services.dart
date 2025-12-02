import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Services {
  Services._();

  static currencyFormatter(String amount) {
    var format = NumberFormat("###,##0", "en_US");
    if (amount.isEmpty) {
      return format.format(0);
    }
    return format.format(double.parse(amount));
  }

  static translate(String language, String uz, String ru) {
    // print("LAMGIA:$language");
    if (language == "ru") {
      return ru;
    } else if (language == "uz") {
      return uz;
    }
  }

  static void showSnackBar(BuildContext context, dynamic message, Color color) {
    // Hide any existing snackbar first
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(message.replaceAll("Exception:", "")).tr(),
      backgroundColor: color,
      duration: Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static String? moneyFormat(String price) {
    if (price.isNotEmpty) {
      var value = price;
      value = value.replaceAll(RegExp(r'\D'), '');
      value = value.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ' ');
      return value;
    }
    return null;
  }

  static String dateFormatter(DateTime date) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm');
    final String formatted = formatter.format(date);

    return formatted;
  }

  // static void _showSnackBar(BuildContext context, dynamic message) {
  //   final snackBar = SnackBar(
  //     content: Text(message),
  //     backgroundColor: color,
  //   );
  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
  // }

  static String getStatusString(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return 'Ожидание оплаты';
      case "payment_confirm":
        return 'Оплата подтверждена';
      case "truck_on_the_way":
        return 'Грузовик в пути';
      case "loading_delivery":
        return 'Загрузка доставки';
      case "loaded":
        return 'Загружено';
      case "order_confirm":
        return 'Заказ подтвержден';
      case "processing":
        return 'Обрабатывается';
      case "out_for_delivery":
        return 'На доставке';
      case "on_hold":
        return 'На удержании';
      case "delivered":
        return 'Доставлен';
      case "failed_delivery_attempt":
        return 'Неудачная попытка доставки';
      case "cancelled":
        return 'Отменен';
      case "returned":
        return 'Возвращен';
      case "refunded":
        return 'Возврат средств';
      case "completed":
        return 'Завершено';
      case "rated":
        return 'Оценен';
      case "pending_review":
        return 'Ожидает обзора';
      default:
        return 'Unknown status';
    }
  }
}
