// TODO Implement this library.

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logistic/models/active_order.dart';
import 'package:logistic/models/order.dart';
import 'package:logistic/models/history.dart';
import 'package:logistic/models/preorder.dart';
import 'package:logistic/utils/header_options.dart';

import '../constants/endpoints.dart';
// ignore: library_prefixes
import '../models/category.dart' as Model;
import '../utils/app_logger.dart';
import '../utils/exceptions.dart';
import '../utils/shared_pref.dart';

class ServicesRepository {
  Future<dynamic> getCategories() async {
    try {
      Response response = await HeaderOptions.dio.get(
        Endpoint.getCategories,
        options: await HeaderOptions().option(),
      );

      if (response.statusCode == 200) {
        print("datas:${response.data}");
        var data = List<Model.Category>.from(
            response.data.map((x) => Model.Category.fromJson(x)));
        //  List<dynamic> data = categoryFromJson(response.data);
        // User data = User.fromJson(response.data);
        print("DATA:${data}");
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

  Future<dynamic> preOrder(PreOrder data) async {
    const baseUrl = 'https://yuktashish.coded.uz/';
    final path = Endpoint.preOrder;
    final fullUrl = baseUrl + path;
    AppLogger.preorder('preOrder START', detail: 'category_unit=${data.categoryUnit}');

    String? requestBody;
    try {
      // main_yuk bilan bir xil: address faqat name, long, lat (id yuborilmaydi)
      final addressMap = <String, dynamic>{
        "name": data.address.name,
        "long": data.address.long,
        "lat": data.address.lat,
      };

      final jsonData = <String, dynamic>{
        "address": addressMap,
        "comment": data.comment,
        "category_unit": data.categoryUnit,
        "service_type": data.serviceType,
      };
      // Backend "material" uchun entity_type talab qiladi; berilmasa default "individual"
      jsonData["entity_type"] = (data.entityType != null && data.entityType!.isNotEmpty)
          ? data.entityType!
          : "individual";
      if (data.jshshir != null && data.jshshir!.isNotEmpty) jsonData["jshshir"] = data.jshshir;
      if (data.stir != null && data.stir!.isNotEmpty) jsonData["stir"] = data.stir;
      if (data.mfo != null && data.mfo!.isNotEmpty) jsonData["mfo"] = data.mfo;

      requestBody = json.encode(jsonData);
      if (kDebugMode) {
        print('PreOrder Request URL: $fullUrl');
        print('PreOrder Request body: $requestBody');
      }
      AppLogger.preorder('preOrder request body', detail: requestBody);

      String token = await SharedPref().read('token') ?? '';
      Response response = await HeaderOptions.dio.post(
        path,
        data: jsonData,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          contentType: Headers.jsonContentType,
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final rawId = response.data["id"];
        final id = rawId is int ? rawId : (rawId is num ? rawId.toInt() : null);
        if (id == null) {
          AppLogger.preorder('preOrder FAIL', detail: 'id not found in response');
          throw Exception('Invalid response: PreOrder ID not found');
        }
        AppLogger.preorder('preOrder OK', detail: 'id=$id');
        return id;
      } else {
        AppLogger.preorder('preOrder FAIL', detail: 'status=${response.statusCode}');
        return [];
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final respData = e.response?.data;
      if (kDebugMode) {
        print('PreOrder FAILED URL: $fullUrl');
        print('PreOrder FAILED body: $requestBody');
        print('PreOrder FAILED response: $statusCode $respData');
      }
      AppLogger.preorder('preOrder FAILED', detail: 'status=$statusCode body=$requestBody response=$respData');
      if (statusCode == 400 && respData != null) {
        String? detail;
        if (respData is Map) {
          detail = respData['detail']?.toString() ?? respData['message']?.toString() ?? respData['error']?.toString();
          if (detail == null && respData['errors'] is Map) {
            final errs = (respData['errors'] as Map).entries.map((e) => '${e.key}: ${e.value}').join('; ');
            if (errs.isNotEmpty) detail = errs;
          }
          // Backend { jshshir: ["..."], ... } kabi maydon xabarlarini ham o‘qish
          if (detail == null || detail.isEmpty) {
            final parts = <String>[];
            for (final e in respData.entries) {
              if (e.key == 'detail' || e.key == 'message' || e.key == 'error') continue;
              final v = e.value;
              if (v is List) {
                parts.add('${e.key}: ${v.map((x) => x.toString()).join(", ")}');
              } else if (v != null) {
                parts.add('${e.key}: $v');
              }
            }
            if (parts.isNotEmpty) detail = parts.join('; ');
          }
        } else if (respData is String) {
          detail = respData.length > 300 ? '${respData.substring(0, 300)}...' : respData;
        }
        throw detail != null && detail.isNotEmpty ? detail : 'Bad request';
      }
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  Future<dynamic> getOrderList() async {
    try {
      print("getOrderList");
      Response response = await HeaderOptions.dio
          .get(Endpoint.orderList, options: await HeaderOptions().option());

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("ORDERLIST: ${response.data.length}");
        var data =
            List<Order>.from(response.data.map((x) => Order.fromJson(x)));

        return data;
      } else {
        return [];
      }
    } on DioException catch (e) {
      print("ERR:${e.message} ${e.response}");
      final errorMessage = DioExceptions.fromDioError(e).toString();

      throw errorMessage;
    }
  }

  Future<dynamic> deleteOrder(int id) async {
    try {
      Response response = await HeaderOptions.dio.delete(
          Endpoint.preOrderDelete + "$id/",
          options: await HeaderOptions().option());

      if (response.statusCode == 200 || response.statusCode == 201) {
        // var data =
        //     List<Order>.from(response.data.map((x) => Order.fromJson(x)));

        // return data;
      } else {
        return [];
      }
    } on DioException catch (e) {
      print("ERR:${e.message} ${e.response}");
      final errorMessage = DioExceptions.fromDioError(e).toString();

      throw errorMessage;
    }
  }

  Future<dynamic> getPreOrderDetail(int id) async {
    try {
      print("getOrderDetail");
      Response response = await HeaderOptions.dio.get(
          Endpoint.preOrderDetail + "/${id}",
          options: await HeaderOptions().option());

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("ORDERLIST: ${response.data.length}");
        var data = Order.fromJson(response.data);

        return data;
      } else {
        return [];
      }
    } on DioException catch (e) {
      print("ERR:${e.message} ${e.response}");
      final errorMessage = DioExceptions.fromDioError(e).toString();

      throw errorMessage;
    }
  }

  Future<dynamic> getOrderHistoryList() async {
    try {
      Response response = await HeaderOptions.dio
          .get(Endpoint.orderHistory, options: await HeaderOptions().option());

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("HistoryLIST: ${response.data.length}");
        var data =
            List<History>.from(response.data.map((x) => History.fromJson(x)));
        return data;
      } else {
        return [];
      }
    } on DioException catch (e) {
      // print("ERR:${e.message} ${e.response}");
      final errorMessage = DioExceptions.fromDioError(e).toString();

      throw errorMessage;
    }
  }

   Future<dynamic> getOrderDetail(int id) async {
    try {
      print("getOrderDetail");
      Response response = await HeaderOptions.dio.get(
          Endpoint.orderDetail + "/${id}",
          options: await HeaderOptions().option());

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("ORDERLIST: ${response.data.length}");
        var data = ActiveOrder.fromJson(response.data);

        return data;
      } else {
        return [];
      }
    } on DioException catch (e) {
      print("ERR:${e.message} ${e.response}");
      final errorMessage = DioExceptions.fromDioError(e).toString();

      throw errorMessage;
    }
  }

  /// POST api/orders/order-create/ — client tanlagan haydovchi uchun buyurtma yaratadi.
  /// Body: driver (id), preorder_id, payment_type (payme|uzum|click|cash).
  /// Backend odatda order ni yaratib status beradi; driver da ko‘rinishi uchun backend
  /// driver app qaysi statuslarni ko‘rsatishini tekshiring.
  Future<dynamic> createOrder(int driverId, int preorderId, String paymentType) async {
    try {
      String token = await SharedPref().read('token') ?? '';
      final jsonData = <String, dynamic>{
        "driver": driverId,
        "preorder_id": preorderId,
        "payment_type": paymentType,
      };

      if (kDebugMode) {
        print("createOrder POST ${Endpoint.orderCreate}");
        print("createOrder body: driver=$driverId preorder_id=$preorderId payment_type=$paymentType");
      }

      Response response = await HeaderOptions.dio.post(
        Endpoint.orderCreate,
        data: jsonData,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          contentType: Headers.jsonContentType,
        ),
      );

      if (kDebugMode && response.data != null) {
        final res = response.data;
        print("createOrder response: status=${response.statusCode} data=$res");
        if (res is Map && res.containsKey("status")) {
          print("createOrder order status from server: ${res["status"]}");
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception("Failed to create order: ${response.statusCode}");
    } on DioException catch (e) {
      if (kDebugMode) {
        print("createOrder DioException: ${e.message}");
        print("createOrder response: ${e.response?.statusCode} ${e.response?.data}");
      }
      throw DioExceptions.fromDioError(e).toString();
    }
  }

}
