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
    var text = (message?.toString() ?? '').replaceAll("Exception:", "").trim();
    if (text.isEmpty) text = 'Something went wrong';
    if (text.length > 80 || text.contains('<')) text = 'Internal server error';
    final snackBar = SnackBar(
      content: Text(text).tr(),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(8),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
static String? moneyFormat(String price) {
  if (price.length > 0) {
  var value = price;
  value = value.replaceAll(RegExp(r'\D'), '');
  value = value.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ' ');
  return value;
  }
 }

 static String dateFormatter(DateTime date){
   final DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm');
  final String formatted = formatter.format(date);

  return formatted;
  print(formatted); // something like 2013-04-20
 }

  // static void _showSnackBar(BuildContext context, dynamic message) {
  //   final snackBar = SnackBar(
  //     content: Text(message),
  //     backgroundColor: color,
  //   );
  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
  // }

  static String getStatusString(String status) {
  switch (status) {
    case "pending":
      return 'Ожидание оплаты';
    case "payment_confirm":
      return 'Оплата подтверждена';
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
    case "pending_review":
      return 'Ожидает обзора';
    default:
      return 'Unknown status';
  }
}
}

