import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '/utils/shared_pref.dart';

class HeaderOptions {
  static String get uri {
    return "https://airvive.coded.uz/";
  }

  static BaseOptions get options => BaseOptions(
        baseUrl: uri,
        responseType: ResponseType.json,
        contentType: Headers.jsonContentType,
        connectTimeout: Duration(seconds: 50),
        receiveTimeout: Duration(seconds: 30),
      );

  static late final Dio dio = Dio(options)
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Log request for debugging CORS issues on web
          if (kIsWeb) {
            print(
                '🌐 Web Request: ${options.method} ${options.baseUrl}${options.path}');
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Better error logging for CORS issues
          if (kIsWeb && error.type == DioExceptionType.connectionError) {
            print('⚠️ CORS Error detected!');
            print('Server: ${error.requestOptions.baseUrl}');
            print('Path: ${error.requestOptions.path}');
            print('Message: ${error.message}');
            print('💡 Solution: Backend server needs to send CORS headers:');
            print('   Access-Control-Allow-Origin: * (or your domain)');
            print(
                '   Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
            print(
                '   Access-Control-Allow-Headers: Content-Type, Authorization');
          }
          handler.next(error);
        },
      ),
    );

  Future<Options> option() async {
    String token = await SharedPref().read('token') ?? '';
    //  "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzA1NzM2NTgzLCJpYXQiOjE3MDU3MzYyODMsImp0aSI6Ijk4ZmJmYTgyZDE0ZTQ3ZmY5MDJiNzMzNDVjOTYzMGU3IiwidXNlcl9pZCI6MTF9.SoFWzbMM0trYtcph1fxBfJ-KxiGHmzZk6j858OVebDE";
    return Options(
      headers: {
        "accept": 'application/json',
        "Content-Type": "application/json",
        'Authorization': "Bearer $token"
      },
      contentType: Headers.formUrlEncodedContentType,
    );
  }
}
