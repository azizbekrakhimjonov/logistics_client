import 'package:dio/dio.dart';
import 'package:logistic/utils/navigation_services.dart';
import 'package:logistic/utils/shared_pref.dart';

import '../di/locator.dart';
import '../repositories/auth_repositories.dart';

class DioExceptions implements Exception {
  String message = '';
  final AuthRepository _api = di.get();

  DioExceptions.fromDioError(DioException dioError) {
    print("DioException type: ${dioError.type}");
    print("DioException message: ${dioError.message}");
    
    switch (dioError.type) {
      case DioExceptionType.cancel:
        message = "Request to API server was cancelled";
        break;
      case DioExceptionType.connectionTimeout:
        message = "Connection timeout with API server";
        break;
      case DioExceptionType.unknown:
        message = "Connection to API server failed due to internet connection";
        break;
      case DioExceptionType.receiveTimeout:
        message = "Receive timeout in connection with API server";
        break;
      case DioExceptionType.badResponse:
        message = _handleError(
            dioError.response!.statusCode, dioError.response!.data);
        break;
      case DioExceptionType.sendTimeout:
        message = "Send timeout in connection with API server";
        break;
      case DioExceptionType.connectionError:
        message = "Connection error: CORS policy may be blocking the request. Please check if the server allows requests from this origin.";
        break;
      default:
        message = "Something went wrong - ${dioError.type}";
        break;
    }
  }

  String _handleError(dynamic statusCode, dynamic error) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        _handleUnauthorizedError();
        return "";
      case 404:
        return error["detail"] ?? "Not found";
      case 500:
        return 'Internal server error';
      case 422:
        return error["errors"]["username"][0];

      default:
        return 'Oops something went wrong';
    }
  }

  Future<void> _handleUnauthorizedError() async {
      SharedPref().remove('token');
      NavigationService.instance.navigateToReplacement('login');
    // await _api.refreshToken();
  }

  @override
  String toString() => message;
}
