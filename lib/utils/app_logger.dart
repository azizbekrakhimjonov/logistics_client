import 'package:flutter/foundation.dart';

/// Har bir jarayon uchun birlashtirilgan log. API to'liq ishlashini va muammo joyini aniqlash uchun.
class AppLogger {
  AppLogger._();

  static const bool _enable = true;

  static void _log(String tag, String message, {Object? detail}) {
    if (!_enable) return;
    final time = DateTime.now().toIso8601String();
    final detailStr = detail != null ? ' | $detail' : '';
    if (kDebugMode) {
      print('[$time] [$tag] $message$detailStr');
    }
  }

  /// Auth: login, register, OTP, token
  static void auth(String message, {Object? detail}) =>
      _log('AUTH', message, detail: detail);

  /// API so'rov boshlandi
  static void apiStart(String method, String path, {Object? body}) =>
      _log('API_REQ', '$method $path', detail: body);

  /// API javob muvaffaqiyatli
  static void apiOk(String path, int status, {Object? data}) =>
      _log('API_OK', '$path → $status', detail: data);

  /// API xato (4xx, 5xx yoki network)
  static void apiFail(String path, Object error, {Object? response}) =>
      _log('API_FAIL', path, detail: 'error=$error response=$response');

  /// Preorder: xom ashyo / buyurtma yaratish
  static void preorder(String message, {Object? detail}) =>
      _log('PREORDER', message, detail: detail);

  /// Kategoriyalar (hom ashyolar) yuklanishi
  static void categories(String message, {Object? detail}) =>
      _log('CATEGORIES', message, detail: detail);

  /// Foydalanuvchi / check user
  static void user(String message, {Object? detail}) =>
      _log('USER', message, detail: detail);

  /// Order: buyurtma detali, ro'yxat, yaratish
  static void order(String message, {Object? detail}) =>
      _log('ORDER', message, detail: detail);

  /// Umumiy jarayon (navigation, UI)
  static void app(String message, {Object? detail}) =>
      _log('APP', message, detail: detail);
}
