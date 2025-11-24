import 'package:dio/dio.dart';
import '/utils/shared_pref.dart';

class AuthService {
  static String uri = "https://airvive.coded.uz/";
  

  static BaseOptions options = BaseOptions(
    baseUrl: uri,
    responseType: ResponseType.json,
    connectTimeout: Duration(seconds: 50),
    receiveTimeout: Duration(seconds: 30),
  );

  static var dio = Dio(options);

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
