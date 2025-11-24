// To parse this JSON data, do
//
//     final order = orderFromJson(jsonString);

import 'dart:convert';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {
    final int id;
    final List<ProposedPrice> proposedPrices;
    final bool isActive;
    final DateTime createdAt;
    final DateTime updatedAt;
    final dynamic comment;
    final int? categoryUnit;

    Order({
        required this.id,
        required this.proposedPrices,
        required this.isActive,
        required this.createdAt,
        required this.updatedAt,
        required this.comment,
        required this.categoryUnit,
    });

    factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        proposedPrices: List<ProposedPrice>.from(json["proposed_prices"].map((x) => ProposedPrice.fromJson(x))),
        isActive: json["is_active"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        comment: json["comment"],
        categoryUnit: json["category_unit"] == null ? 0: json["category_unit"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "proposed_prices": List<dynamic>.from(proposedPrices.map((x) => x.toJson())),
        "is_active": isActive,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "comment": comment ?? "",
        "category_unit": categoryUnit,
    };
}

class ProposedPrice {
    final Driver driver;
    final int price;

    ProposedPrice({
        required this.driver,
        required this.price,
    });

    factory ProposedPrice.fromJson(Map<String, dynamic> json) => ProposedPrice(
        driver: Driver.fromJson(json["driver"]),
        price: json["price"],
    );

    Map<String, dynamic> toJson() => {
        "driver": driver.toJson(),
        "price": price,
    };
}

class Driver {
    final int id;
    final Car car;

    Driver({
        required this.id,
        required this.car,
    });

    factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        id: json["id"],
        car: Car.fromJson(json["car"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "car": car.toJson(),
    };
}

class Car {
    final String nameRu;
    final String nameUz;

    Car({
        required this.nameRu,
        required this.nameUz,
    });

    factory Car.fromJson(Map<String, dynamic> json) => Car(
        nameRu: json["name_ru"],
        nameUz: json["name_uz"],
    );

    Map<String, dynamic> toJson() => {
        "name_ru": nameRu,
        "name_uz": nameUz,
    };
}
