// To parse this JSON data, do
//
//     final preOrder = preOrderFromJson(jsonString);

import 'dart:convert';

PreOrder preOrderFromJson(String str) => PreOrder.fromJson(json.decode(str));

String preOrderToJson(PreOrder data) => json.encode(data.toJson());

class PreOrder {
    final Address address;
    final String comment;
    final int? categoryUnit;
    final String serviceType;

    PreOrder({
        required this.address,
        required this.comment,
        required this.categoryUnit,
        this.serviceType = 'material',
    });

    factory PreOrder.fromJson(Map<String, dynamic> json) => PreOrder(
        address: Address.fromJson(json["address"]),
        comment: json["comment"],
        categoryUnit: json["category_unit"],
        serviceType: json["service_type"] ?? 'material',
    );

    Map<String, dynamic> toJson() => {
        "address": address.toJson(),
        "comment": comment,
        "category_unit": categoryUnit,
        "service_type": serviceType,
    };
}

class Address {
    final int? id;
    final String name;
    final double long;
    final double lat;

    Address({
        required this.id,
        required this.name,
        required this.long,
        required this.lat,
    });

    factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json["id"],
        name: json["name"],
        long: json["long"],
        lat: json["lat"]
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "long": long,
        "lat": lat
    };
}
