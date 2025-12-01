import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '/utils/shared_pref.dart';

class AuthService {
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
    connectTimeout: Duration(seconds: 50),
    receiveTimeout: Duration(seconds: 30),
  );

  static late final Dio dio = Dio(options);

   Future<Options> option() async {
    String token = await SharedPref().read('token')??'';

    return Options(
      headers: {
        "Accept": 'application/json',
        "Content-Type": "application/json",
        'Authorization':  "Bearer $token",
        // 'token':  '$token',
      },
      contentType: Headers.formUrlEncodedContentType,
    );
  }
  
}
