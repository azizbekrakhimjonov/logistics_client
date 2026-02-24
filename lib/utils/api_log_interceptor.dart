import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'app_logger.dart';

/// Barcha API so'rov va javoblarini log qiladi. Muammo qayerda ekanini aniqlash uchun.
class ApiLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!kDebugMode) {
      handler.next(options);
      return;
    }
    final method = options.method;
    final path = options.uri.path;
    final fullUrl = options.uri.toString();
    Object? body = options.data;
    if (body is String && body.length > 500) body = '${body.substring(0, 500)}...';
    AppLogger.apiStart(method, path, body: body);
    print('  → URL: $fullUrl');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!kDebugMode) {
      handler.next(response);
      return;
    }
    final path = response.requestOptions.uri.path;
    final status = response.statusCode ?? 0;
    AppLogger.apiOk(path, status, data: response.data);
    if (response.data != null && response.data.toString().length < 300) {
      print('  ← body: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!kDebugMode) {
      handler.next(err);
      return;
    }
    final path = err.requestOptions.uri.path;
    final status = err.response?.statusCode;
    final data = err.response?.data;
    AppLogger.apiFail(path, err.message ?? err.type, response: 'status=$status data=$data');
    print('  ← ERROR: $status | $data');
    handler.next(err);
  }
}
