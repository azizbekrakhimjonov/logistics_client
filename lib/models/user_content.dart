// To parse this JSON data, do
//
//     final userContent = userContentFromJson(jsonString);

import 'dart:convert';

UserContent userContentFromJson(String str) => UserContent.fromJson(json.decode(str));

// String userContentToJson(UserContent data) => json.encode(data.toJson());

class UserContent {
    final int? preOrder;
    final int? order;
    final User user;

    UserContent({
        required this.preOrder,
        required this.order,
        required this.user,
    });

    factory UserContent.fromJson(Map<String, dynamic> json) {
      int? orderId;
      if (json["order"] == null) {
        orderId = 0;
      } else if (json["order"] is Map) {
        // If order is an object, extract the id
        orderId = json["order"]["id"] as int?;
      } else {
        orderId = json["order"] as int?;
      }
      
      return UserContent(
        preOrder: json["pre_order"] == null ? 0 : json["pre_order"],
        order: orderId ?? 0,
        user: User.fromJson(json["user"]),
      );
    }
Map<String, dynamic> toJson() {
    return {
      "pre_order": preOrder ?? 0,
      "order": order ?? 0,
      "user": user.toJson(),
    };
  }
    // Map<String, dynamic> toJson() => {
    //     "pre_order": preOrder,
    //     "order": order,
    //     "user": user.toJson(),
    // };
}

class User {
    final int id;
    final String username;
    final String? name;
    final String? picCompress;
    final String url;
    final List<MyAddress> myAddresses;

    User({
        required this.id,
        required this.username,
        required this.name,
        required this.picCompress,
        required this.url,
        required this.myAddresses,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        username: json["username"],
        name: json["name"]??"",
        picCompress: json["pic_compress"]??"",
        url: json["url"],
        myAddresses: List<MyAddress>.from(json["my_addresses"].map((x) => MyAddress.fromJson(x))),
    );
Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "name": name ?? "",
      "pic_compress": picCompress ?? "",
      "url": url,
      "my_addresses": List<dynamic>.from(myAddresses.map((x) => x.toJson())),
    };
  }
    // Map<String, dynamic> toJson() => {
    //     "id": id,
    //     "phone_number": phoneNumber,
    //     "name": name,
    //     "pic_compress": picCompress,
    //     "url": url,
    //     "my_addresses": List<dynamic>.from(myAddresses.map((x) => x.toJson())),
    // };
}

class MyAddress {
    final int id;
    final bool isActive;
    // final DateTime createdAt;
    // final DateTime updatedAt;
    final String name;
    final double long;
    final double lat;
    final int user;

    MyAddress({
        required this.id,
        required this.isActive,
        // required this.createdAt,
        // required this.updatedAt,
        required this.name,
        required this.long,
        required this.lat,
        required this.user,
    });

    factory MyAddress.fromJson(Map<String, dynamic> json) => MyAddress(
        id: json["id"],
        isActive: json["is_active"],
        // createdAt: DateTime.parse(json["created_at"]),
        // updatedAt: DateTime.parse(json["updated_at"]),
        name: json["name"],
        long: json["long"],
        lat: json["lat"],
        user: json["user"],
    );
    Map<String, dynamic> toJson() {
    return {
      "id": id,
      "is_active": isActive,
      "name": name,
      "long": long,
      "lat": lat,
      "user": user,
    };
  }

    // Map<String, dynamic> toJson() => {
    //     "id": id,
    //     "is_active": isActive,
    //     "created_at": createdAt.toIso8601String(),
    //     "updated_at": updatedAt.toIso8601String(),
    //     "name": name,
    //     "long": long,
    //     "lat": lat,
    //     "user": user,
    // };
}
