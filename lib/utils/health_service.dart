import 'package:dio/dio.dart';

/// Health check: GET https://yuktashish.coded.uz/api/health/
/// Success: statusCode 200 and body["status"] == "ok"
class HealthService {
  static const String healthUrl = 'https://yuktashish.coded.uz/api/health/';

  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    responseType: ResponseType.json,
  ));

  /// Returns true if server responds with 200 and { "status": "ok" }.
  static Future<bool> check() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(healthUrl);
      if (response.statusCode != 200) return false;
      final data = response.data;
      return data != null &&
          data['status'] != null &&
          data['status'].toString().toLowerCase() == 'ok';
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
