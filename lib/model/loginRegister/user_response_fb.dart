import 'package:cloud_firestore/cloud_firestore.dart';

class UserResponseFirebase {
  String id;
  String userId;
  String userEmail;
  String userImage;
  String userName;
  String status;
  String phone;
  String country_code;
  String address;
  String is_login;
  String image;

  UserResponseFirebase(
      {this.id,
      this.userId,
      this.userEmail,
      this.userImage,
      this.userName,
      this.status,
      this.phone,
      this.country_code,
      this.address,
      this.is_login,
      this.image});

  UserResponseFirebase.fromSnapshot(DocumentSnapshot snapshot) {
    this.id = snapshot.id;
    Map<String, dynamic> mapObject = snapshot.data();
    this.userId = mapObject["userId"];
    this.userEmail = mapObject["userEmail"];
    this.userImage = mapObject["userImage"];
    this.userName = mapObject["userName"];
  }
}
