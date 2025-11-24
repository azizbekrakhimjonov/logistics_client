import 'dart:io';

import 'package:dio/dio.dart';
import '/utils/shared_pref.dart';

class HeaderOptions {
  static String uri = "https://airvive.coded.uz/";
  
  static BaseOptions options = BaseOptions(
    baseUrl: uri,
    responseType: ResponseType.json,
    contentType: Headers.jsonContentType,
    connectTimeout: Duration(seconds: 50),
    receiveTimeout: Duration(seconds: 30),
  );

  static var dio = Dio(options);

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
