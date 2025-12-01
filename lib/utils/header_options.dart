import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '/utils/shared_pref.dart';

class HeaderOptions {
  static String get uri {
    // Use CORS proxy for web development
    if (kIsWeb) {
      // Using a CORS proxy - replace with your own proxy if needed
      // For production, the backend should allow CORS
      return "https://airvive.coded.uz/";
    }
    return "https://airvive.coded.uz/";
  }
  
  static BaseOptions get options => BaseOptions(
    baseUrl: uri,
    responseType: ResponseType.json,
    contentType: Headers.jsonContentType,
    connectTimeout: Duration(seconds: 50),
    receiveTimeout: Duration(seconds: 30),
  );

  static late final Dio dio = Dio(options);

   Future<Options> option() async {
    String token = await SharedPref().read('token')??'';
    //  "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzA1NzM2NTgzLCJpYXQiOjE3MDU3MzYyODMsImp0aSI6Ijk4ZmJmYTgyZDE0ZTQ3ZmY5MDJiNzMzNDVjOTYzMGU3IiwidXNlcl9pZCI6MTF9.SoFWzbMM0trYtcph1fxBfJ-KxiGHmzZk6j858OVebDE";
    return Options(
      headers: {
        "accept": 'application/json',
        "Content-Type": "application/json",
        'Authorization':  "Bearer $token"
      },
      contentType: Headers.formUrlEncodedContentType,
    );
  }
  
}
