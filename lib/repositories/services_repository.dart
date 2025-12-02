// TODO Implement this library.

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logistic/models/active_order.dart';
import 'package:logistic/models/order.dart';
import 'package:logistic/models/history.dart';
import 'package:logistic/models/preorder.dart';
import 'package:logistic/utils/header_options.dart';

import '../constants/endpoints.dart';
// ignore: library_prefixes
import '../models/category.dart' as Model;
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
        print("DATA:$data");
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
    try {
      print("Request: ${json.encode(data)}");
      var jsonData = {
        "address": {
          // "id": null,
          "name": data.address.name,
          "long": data.address.long,
          "lat": data.address.lat
        },
        "comment": data.comment,
        "category_unit": data.categoryUnit,
        "service_type": data.serviceType
      };
      String token = await SharedPref().read('token') ?? '';
      print("RequestDATA: $jsonData");

      Response response = await HeaderOptions.dio.post(Endpoint.preOrder,
          data: json.encode(jsonData),
          options: Options(
            headers: {
              "accept": 'application/json',
              "Content-Type": "application/json",
              'Authorization': "Bearer $token"
            },
            contentType: Headers.jsonContentType,
            // contentType: Headers.formUrlEncodedContentType,
          ) // await HeaderOptions().option(),
          );
      print("REquest: ${response.data}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data["id"];
      } else {
        return [];
      }
    } on DioException catch (e) {
      print("ERR:${e.message} ${e.response}");
      print("ERROR:${e.response}");

      final errorMessage = DioExceptions.fromDioError(e).toString();

      throw errorMessage;
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
          "${Endpoint.preOrderDelete}$id/",
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
          "${Endpoint.preOrderDetail}/${id}",
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
          "${Endpoint.orderDetail}/${id}",
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

  Future<dynamic> createOrder(int driverId, int preorderId, String paymentType) async {
    try {
      print("createOrder - driverId: $driverId, preorderId: $preorderId, paymentType: $paymentType");
      String token = await SharedPref().read('token') ?? '';
      
      var jsonData = {
        "driver": driverId,
        "preorder_id": preorderId,
        "payment_type": paymentType
      };
      
      print("RequestDATA: ${json.encode(jsonData)}");

      Response response = await HeaderOptions.dio.post(
        Endpoint.orderCreate,
        data: json.encode(jsonData),
        options: Options(
          headers: {
            "accept": 'application/json',
            "Content-Type": "application/json",
            'Authorization': "Bearer $token"
          },
          contentType: Headers.jsonContentType,
        ),
      );

      print("Response: ${response.data}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception("Failed to create order");
      }
    } on DioException catch (e) {
      print("ERR:${e.message} ${e.response}");
      print("ERROR:${e.response}");
      
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }

}
