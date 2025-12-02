import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logistic/models/user_content.dart';
// import '../models/user.dart';
import '../utils/header_options.dart';
// import '../utils/shared_pref.dart';
import '../utils/auth.dart';
import '../utils/exceptions.dart';
import '../constants/constants.dart';
import '../utils/navigation_services.dart';
import '../utils/shared_pref.dart';

class AuthRepository {
  Future<dynamic> login(String phone, String name) async {
    try {
      var data = {"username": phone, "name": name, "language": "uz"};
      print("Login: $data");

      Response response = await AuthService.dio.post(
        Endpoint.register,
        data: json.encode(data),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        print("Response: ${response.data}");
        return response.data;
      } else {
        print("response: ${response.statusCode}");
        return [];
      }
    } on DioException catch (e) {
      String errorMessage;
      print("ER:${e.response}");
      print("Error Type: ${e.type}");
      print("Error Message: ${e.message}");
      print("Request URL: ${e.requestOptions.baseUrl}${e.requestOptions.path}");
      // print("ER1:${e.requestOptions}");

      if (e.type == DioExceptionType.badResponse) {
        errorMessage = "Xatolik sodir bo'ldi. ${e.response!.data["error"]}";
      } else {
        errorMessage = DioExceptions.fromDioError(e).toString();
      }

      throw errorMessage;
    }
  }

  Future<dynamic> codeEntry(String phone, String otp) async {
    try {
      // var data = {"phone_number": phone, "code": otp};
      var data = {"username": phone, "code": otp};

      print("DATA: ${json.encode(data)}");
      Response response = await AuthService.dio.post(
        Endpoint.verifyPhone,
        data: json.encode(data),
        options: Options(
          headers: {
            "accept": 'application/json',
            "Content-Type": 'application/json',
          },
          contentType: Headers.jsonContentType,
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("datas:${response.data}");

        await SharedPref().save('token', response.data["access"]);
        await SharedPref().save("refresh_token", response.data["refresh"]);

        return response.data;
      } else {
        return [];
      }
    } on DioException catch (e) {
      print("ER:$e");
      final errorMessage = DioExceptions.fromDioError(e).toString();

      throw errorMessage;
    }
  }

  Future<dynamic> getUser() async {
    try {
      Response response = await AuthService.dio.get(
        Endpoint.getUser,
        options: await HeaderOptions().option(),
      );

      if (response.statusCode == 200) {
        User data = User.fromJson(response.data);
        await SharedPref().save('user', data);
        
        return data;
      } else {
        return [];
      }
    } on DioException catch (e) {
      print("ERR:${e.message} ${e.requestOptions.path}");

      final errorMessage = DioExceptions.fromDioError(e).toString();

      throw errorMessage;
    }
  }
   
   Future<dynamic> checkUser() async {
    try {
      Response response = await HeaderOptions.dio.get(
        Endpoint.checkUser,
        options: await HeaderOptions().option(),
      );

      if (response.statusCode == 200) {
         print("RESPOMSE: ${response.data}");
        UserContent data = UserContent.fromJson(response.data);
        await SharedPref().save("user", data);
        // dynamic user = await SharedPref().read("user");

         print("RESPOMSE: $data");
        return data;
      } else {
        return [];
      }
    } on DioException catch (e) {
      print("ERR:${e.message} ${e.requestOptions.path}");

      final errorMessage = DioExceptions.fromDioError(e).toString();

      throw errorMessage;
    }
  }

  Future<dynamic> refreshToken() async {
    try {
     
      String refreshToken = await SharedPref().read('refresh_token') ?? '';
       print("REFRESH_TOKEN: $refreshToken");
      var data = {"refresh": refreshToken};
      Response response = await AuthService.dio.post(
        Endpoint.refreshToken,
        data: json.encode(data),
        options: await AuthService().option(),
      );

      if (response.statusCode == 200) {
        await SharedPref().save('token', response.data["access"]);

        return data;
      } else {
        return [];
      }
    } on DioException catch (e) {
      print("ERROR:${e.message} ${e.requestOptions.path}");

      // final errorMessage =
      if (e.type == DioExceptionType.badResponse) {
        if (e.response!.statusCode == 401) {
          print("remove token");
          SharedPref().remove('token');
          NavigationService.instance.navigateToReplacement('login');
        } else {
        throw DioExceptions.fromDioError(e).toString();
      }
      } else {
        throw DioExceptions.fromDioError(e).toString();
      }
      // throw errorMessage;
    }
  }

  Future<dynamic> updateProfile(
     String photo, String name,String phoneNumber) async {

    String fileName = photo.split('/').last;
    // String customer = await SharedPref().read("user")??"";

    
    try {
      FormData formData = FormData.fromMap({
        "name": name,
        "pic": photo.isNotEmpty
            ? await MultipartFile.fromFile(photo, filename: fileName)
            : "",
      });

      print("formData::::$formData");

      Response response = await HeaderOptions.dio.put(
        '${Endpoint.updateUser}/$phoneNumber/',
        queryParameters: {
          "_method": "PUT",
        },
        data: formData,
        options: await HeaderOptions().option(),
      );
      //  print("URL:${ Endpoint.sendData + '/$client_id'}");
      if (response.statusCode == 200) {
        // String token = await SharedPref().read("token");
        // await SharedPref().save("testToken", token);
        print("response:${response.data}");
      } else {
        return {};
      }
    } on DioException catch (e) {
      var errorMessage = DioExceptions.fromDioError(e).toString();
      
      throw errorMessage;
    }
  }
}
