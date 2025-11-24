// import 'dart:convert';

// User userFromJson(String str) => User.fromJson(json.decode(str));

// String userToJson(User data) => json.encode(data.toJson());

// class User {
//     final int id;
//     final String phoneNumber;
//     final String? name;
//     final String? picCompress;
//     final String url;
//     final List<MyAddress> myAddresses;

//     User({
//         required this.id,
//         required this.phoneNumber,
//         required this.name,
//         required this.picCompress,
//         required this.url,
//         required this.myAddresses,
//     });

//     factory User.fromJson(Map<String, dynamic> json) => User(
//         id: json["id"],
//         phoneNumber: json["phone_number"],
//         name: json["name"] ?? "",
//         picCompress: json["pic_compress"] ?? "",
//         url: json["url"],
//         myAddresses: List<MyAddress>.from(json["my_addresses"].map((x) => MyAddress.fromJson(x))),
//     );

//     Map<String, dynamic> toJson() => {
//         "id": id,
//         "phone_number": phoneNumber,
//         "name": name,
//         "pic_compress": picCompress,
//         "url": url,
//         "my_addresses": List<dynamic>.from(myAddresses.map((x) => x.toJson())),
//     };
// }

// class MyAddress {
//     final int id;
//     final String name;
//     final double long;
//     final double lat;
//     final int user;

//     MyAddress({
//         required this.id,
//         required this.name,
//         required this.long,
//         required this.lat,
//         required this.user,
//     });

//     factory MyAddress.fromJson(Map<String, dynamic> json) => MyAddress(
//         id: json["id"],
//         name: json["name"],
//         long: json["long"],
//         lat: json["lat"],
//         user: json["user"],
//     );

//     Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//         "long": long,
//         "lat": lat,
//         "user": user,
//     };
// }