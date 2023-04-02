import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CardsFbModel {
  String id;
  String title;
  String body_part;
  String equipment;
  String image;
  String description;
  String movement_nutrition;
  String movement_type;
  String sports_activity;
  int mediaType;
  String videoUrl;
  Timestamp created_at;
  Timestamp updated_at;
  /* List<String> admin;
  List<String> users;
*/
  CardsFbModel(
      {String title,
      String body_part,
      String equipment,
      String groupImage,
      String description,
      String movement_nutrition,
      String movement_type,
      String sports_activity,
      Timestamp created_at,
      int mediaType,
      String videoUrl,
      Timestamp updated_at /*, List<String>admin, List<String>users*/}) {
    this.title = title;
    this.body_part = body_part;
    this.equipment = equipment;
    this.mediaType = mediaType;
    this.image = image;
    this.videoUrl = videoUrl;
    this.description = description;
    this.movement_nutrition = movement_nutrition;
    this.movement_type = movement_type;
    this.sports_activity = sports_activity;
    this.created_at = created_at;
    this.updated_at = updated_at;
    /*this.admin = admin;
    this.users = users;*/
  }

  CardsFbModel.fromSnapshot(DocumentSnapshot snapshot) {
    this.id = snapshot.id;
     Map<String, dynamic> mapObject = snapshot.data();
    this.title = mapObject["title"];
    this.body_part = mapObject['body_part'];
    this.equipment = mapObject['equipment'];

    if (mapObject.containsKey("mediaMap")) {
      var mediaMap = mapObject["mediaMap"];
      this.mediaType = mediaMap["type"];
      this.image = mediaMap["image"];
      this.videoUrl = mediaMap["video"];
    } else {
      this.image = mapObject['image'];
      this.mediaType = 1;
    }

    this.description = mapObject["description"];
    this.movement_nutrition = mapObject["movement_nutrition"];
    this.movement_type = mapObject["movement_type"];
    this.sports_activity = mapObject["sports_activity"];
    this.created_at = mapObject["created_at"];
    this.updated_at = mapObject["updated_at"];
    /*this.admin = mapObject['admin'];
    this.users = mapObject['users'];*/
  }

  Map toMap() {
    Map<String, dynamic> map = {
      "title": this.title,
      "body_part": this.body_part,
      "equipment": this.equipment,
      "image": this.image,
      "description": this.description,
      "movement_nutrition": this.movement_nutrition,
      "movement_type": this.movement_type,
      "sports_activity": this.sports_activity,
      "created_at": this.created_at,
      "updated_at": this.updated_at,
      /*"admin": this.admin,
      "users": this.users,*/
    };
    return map;
  }
}
