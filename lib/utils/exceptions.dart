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
        final statusCode = dioError.response!.statusCode;
        final data = dioError.response!.data;
        if (statusCode == 500) {
          // Server 500 — backend loglarini tekshiring; client faqat xabarni ko'rsatadi
          print("[$statusCode] Server response: $data");
        }
        message = _handleError(statusCode, data);
        break;
      case DioExceptionType.sendTimeout:
        message = "Send timeout in connection with API server";
        break;
      default:
        message = "Something went wrong - ${dioError.type}";
        break;
    }
  }

  String _handleError(dynamic statusCode, dynamic error) {
    final details = _extractDetail(error);
    switch (statusCode) {
      case 400:
        return details ?? 'Bad request';
      case 401:
        _handleUnauthorizedError();
        return "";
      case 404:
        return details ?? "Not found";
      case 500:
        return details ?? 'Internal server error';
      case 422:
        if (error is Map && error['errors'] is Map) {
          final errors = error['errors'] as Map;
          if (errors['username'] is List && (errors['username'] as List).isNotEmpty) {
            return (errors['username'] as List).first.toString();
          }
          if (errors['detail'] != null) return errors['detail'].toString();
        }
        return details ?? 'Bad request';

      default:
        return details ?? 'Oops something went wrong';
    }
  }

  /// Serverdan qaytgan detail/message ni xavfsiz o‘qiydi (500 va boshqalar uchun).
  /// HTML yoki juda uzun matn bo‘lsa null qaytaradi — pastda qisqa «Server error» ko‘rinadi.
  static String? _extractDetail(dynamic error) {
    if (error == null) return null;
    if (error is Map) {
      if (error['detail'] != null) return error['detail'].toString();
      if (error['message'] != null) return error['message'].toString();
      if (error['error'] != null) return error['error'].toString();
    }
    if (error is String && error.isNotEmpty) {
      final s = error;
      if (s.length > 120 || s.contains('<')) return null;
      return s;
    }
    return null;
  }

  Future<void> _handleUnauthorizedError() async {
      SharedPref().remove('token');
      NavigationService.instance.navigateToReplacement('login');
    // await _api.refreshToken();
  }

  @override
  String toString() => message;
}
