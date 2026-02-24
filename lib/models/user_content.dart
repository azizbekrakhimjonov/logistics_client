// To parse this JSON data, do
//
//     final userContent = userContentFromJson(jsonString);

import 'dart:convert';

UserContent userContentFromJson(String str) => UserContent.fromJson(json.decode(str));

class UserContent {
    final int? preOrder;
    final int? order;
    final User user;

    UserContent({
        required this.preOrder,
        required this.order,
        required this.user,
    });

    /// SharedPref yoki API dan o'qiganda: null yoki not-Map bo'lsa ham xatosiz qaytadi.
    static UserContent fromJsonSafe(dynamic json) {
      if (json == null) return UserContent(preOrder: null, order: null, user: User.fromJson({}));
      if (json is! Map<String, dynamic>) return UserContent(preOrder: null, order: null, user: User.fromJson({}));
      return UserContent.fromJson(json);
    }

    factory UserContent.fromJson(Map<String, dynamic> json) {
      if (json.isEmpty) {
        return UserContent(preOrder: null, order: null, user: User.fromJson({}));
      }
      // order: null, int yoki { id: ... } ob'jekt bo'lishi mumkin
      int? orderId;
      final orderRaw = json["order"];
      if (orderRaw == null) {
        orderId = null;
      } else if (orderRaw is Map) {
        orderId = orderRaw["id"] is int ? orderRaw["id"] as int : null;
      } else if (orderRaw is int) {
        orderId = orderRaw;
      }

      // pre_order: null, int yoki { id: ... } ob'jekt bo'lishi mumkin
      int? preOrder;
      final preOrderRaw = json["pre_order"];
      if (preOrderRaw == null) {
        preOrder = null;
      } else if (preOrderRaw is Map) {
        preOrder = preOrderRaw["id"] is int ? preOrderRaw["id"] as int : null;
      } else if (preOrderRaw is int) {
        preOrder = preOrderRaw;
      }

      // user: nested ob'jekt yoki root o'zi user (eski format)
      final userJson = json["user"];
      final userMap = userJson is Map<String, dynamic>
          ? userJson
          : (json["username"] != null ? json : <String, dynamic>{});

      return UserContent(
        preOrder: preOrder,
        order: orderId,
        user: User.fromJson(userMap),
      );
    }
Map<String, dynamic> toJson() {
    return {
      "pre_order": preOrder,
      "order": order,
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

    factory User.fromJson(Map<String, dynamic> json) {
      final myAddressesRaw = json["my_addresses"];
      final myAddresses = myAddressesRaw is List
          ? List<MyAddress>.from(myAddressesRaw.map((x) => MyAddress.fromJson(x is Map<String, dynamic> ? x : {})))
          : <MyAddress>[];
      return User(
        id: json["id"] is int ? json["id"] as int : 0,
        username: json["username"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
        picCompress: json["pic_compress"]?.toString() ?? "",
        url: json["url"]?.toString() ?? "",
        myAddresses: myAddresses,
      );
    }
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
        id: json["id"] is int ? json["id"] as int : 0,
        isActive: json["is_active"] == true,
        name: json["name"]?.toString() ?? "",
        long: (json["long"] is num) ? (json["long"] as num).toDouble() : 0.0,
        lat: (json["lat"] is num) ? (json["lat"] as num).toDouble() : 0.0,
        user: json["user"] is int ? json["user"] as int : 0,
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
