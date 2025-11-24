// To parse this JSON data, do
//
//     final category = categoryFromJson(jsonString);

import 'dart:convert';

List<Category> categoryFromJson(String str) => List<Category>.from(json.decode(str).map((x) => Category.fromJson(x)));

String categoryToJson(List<Category> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Category {
    final int id;
    final String nameUz;
    final String nameRu;
    final String icon;
    final List<Unit> units;

    Category({
        required this.id,
        required this.nameUz,
        required this.nameRu,
        required this.icon,
        required this.units,
    });

    factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        nameUz: json["name_uz"],
        nameRu: json["name_ru"],
        icon: json["icon"],
        units: List<Unit>.from(json["units"].map((x) => Unit.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name_uz": nameUz,
        "name_ru": nameRu,
        "icon": icon,
        "units": List<dynamic>.from(units.map((x) => x.toJson())),
    };
}

class Unit {
    final int id;
    final DateTime createdAt;
    final DateTime updatedAt;
    final int quantity;
    final String unit;
    final int priceFrom;
    final int priceTo;
    final int priceMaterial;

    Unit({
        required this.id,
        required this.createdAt,
        required this.updatedAt,
        required this.quantity,
        required this.unit,
        required this.priceFrom,
        required this.priceTo,
        required this.priceMaterial,
    });

    factory Unit.fromJson(Map<String, dynamic> json) => Unit(
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        quantity: json["quantity"],
        unit: json["unit"],
        priceFrom: json["price_from"],
        priceTo: json["price_to"],
        priceMaterial: json["price_material"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "quantity": quantity,
        "unit": unit,
        "price_from": priceFrom,
        "price_to": priceTo,
        "price_material": priceMaterial,
    };
}
