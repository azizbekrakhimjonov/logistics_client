// To parse this JSON data, do
//
//     final activeOrder = activeOrderFromJson(jsonString);

import 'dart:convert';

ActiveOrder activeOrderFromJson(String str) => ActiveOrder.fromJson(json.decode(str));

String activeOrderToJson(ActiveOrder data) => json.encode(data.toJson());

class ActiveOrder {
    final int id;
    final CategoryObj? categoryObj;
    final Driver? driver;
    final bool isActive;
    final DateTime createdAt;
    final DateTime updatedAt;
    final String status;
    final String paymentType;
    final String address;
    final dynamic comment;
    final int price;
    final int user;
    final int categoryUnit;
    final String? paymentUrl;

    ActiveOrder({
        required this.id,
        required this.categoryObj,
        required this.driver,
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
        this.paymentUrl,
    });

    factory ActiveOrder.fromJson(Map<String, dynamic> json) => ActiveOrder(
        id: json["id"] ?? 0,
        categoryObj: json["category_obj"] == null ? null : CategoryObj.fromJson(json["category_obj"]),
        driver: json["driver"] == null ? null : Driver.fromJson(json["driver"]),
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
        paymentUrl: json["payment_url"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "category_obj": categoryObj?.toJson(),
        "driver": driver?.toJson(),
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
        if (paymentUrl != null) "payment_url": paymentUrl,
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

class Driver {
    final int id;
    final Car car;
    final User user;

    Driver({
        required this.id,
        required this.car,
        required this.user,
    });

    factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        id: json["id"],
        car: Car.fromJson(json["car"]),
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "car": car.toJson(),
        "user": user.toJson(),
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

class User {
    final int id;
    final String username;
    final String name;
    final dynamic picCompress;
    final String url;

    User({
        required this.id,
        required this.username,
        required this.name,
        required this.picCompress,
        required this.url,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        username: json["username"],
        name: json["name"],
        picCompress: json["pic_compress"],
        url: json["url"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "name": name,
        "pic_compress": picCompress,
        "url": url,
    };
}
