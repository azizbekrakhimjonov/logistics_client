// To parse this JSON data, do
//
//     final history = historyFromJson(jsonString);

import 'dart:convert';

import 'package:logistic/utils/utils.dart';

List<History> historyFromJson(String str) => List<History>.from(json.decode(str).map((x) => History.fromJson(x)));

String historyToJson(List<History> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class History {
    final int id;
    final CategoryObj? categoryObj;
    final bool isActive;
    final DateTime createdAt;
    final DateTime updatedAt;
    final String status;
    final String paymentType;
    final String address;
    final String? comment;
    final int price;
    final int user;
    final int categoryUnit;
    final int? driver;

    History({
        required this.id,
        required this.categoryObj,
        required this.isActive,
        required this.createdAt,
        required this.updatedAt,
        required this.status,
        required this.paymentType,
        required this.address,
        required this.comment,
        required this.price,
        required this.user,
        required this.categoryUnit,
        required this.driver,
    });

    factory History.fromJson(Map<String, dynamic> json) => History(
        id: json["id"] ?? 0,
        categoryObj: json["category_obj"] == null ? null : CategoryObj.fromJson(json["category_obj"]),
        isActive: json["is_active"] ?? false,
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        status: json["status"] ?? "",
        paymentType: json["payment_type"] ?? "",
        address: json["address"] ?? "",
        comment: json["comment"],
        price: json["price"] ?? 0,
        user: json["user"] ?? 0,
        categoryUnit: json["category_unit"] ?? 0,
        driver: json["driver"] as int?,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "category_obj": categoryObj?.toJson(),
        "is_active": isActive,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "status": status,
        "payment_type": paymentType,
        "address": address,
        "comment": comment,
        "price": price,
        "user": user,
        "category_unit": categoryUnit,
        "driver": driver,
    };
}

class CategoryObj {
    final int id;
    final Category category;
    final int quantity;
    final String unit;
    final int priceFrom;
    final int priceTo;
    final int priceMaterial;

    CategoryObj({
        required this.id,
        required this.category,
        required this.quantity,
        required this.unit,
        required this.priceFrom,
        required this.priceTo,
        required this.priceMaterial,
    });

    factory CategoryObj.fromJson(Map<String, dynamic> json) => CategoryObj(
        id: json["id"],
        category: Category.fromJson(json["category"]),
        quantity: json["quantity"],
        unit: json["unit"],
        priceFrom: json["price_from"],
        priceTo: json["price_to"],
        priceMaterial: json["price_material"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "category": category.toJson(),
        "quantity": quantity,
        "unit": unit,
        "price_from": priceFrom,
        "price_to": priceTo,
        "price_material": priceMaterial,
    };
}

class Category {
    final int id;
    final String nameUz;
    final String nameRu;
    final String icon;

    Category({
        required this.id,
        required this.nameUz,
        required this.nameRu,
        required this.icon,
    });

    factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        nameUz: json["name_uz"],
        nameRu: json["name_ru"],
        icon: json["icon"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name_uz": nameUz,
        "name_ru": nameRu,
        "icon": icon,
    };
}
