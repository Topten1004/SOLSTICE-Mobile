import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostCardModel {
  Key key;
  String cardId;
  String bodyPart;
  Timestamp createdAt;
  String description;
  String equipment;
  String image;
  String movementNutrition;
  String movementType;
  int position;
  int mediaType; //1=image, 2= video
  String sportsActivity;
  String videoUrl;
  String title;
  Timestamp updatedAt;

  PostCardModel(
      {this.cardId,
      this.key,
      this.bodyPart,
      this.createdAt,
      this.description,
      this.equipment,
      this.image,
      this.movementNutrition,
      this.movementType,
      this.position,
      this.videoUrl,
      this.mediaType,
      this.sportsActivity,
      this.title,
      this.updatedAt});

  PostCardModel.fromSnapshot(DocumentSnapshot snapshot) {
    this.cardId = snapshot.id;
     Map<String, dynamic> mapObject = snapshot.data();
    this.title = mapObject["title"];
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
   
    this.createdAt = mapObject["created_at"];
    this.updatedAt = mapObject["updated_at"];
    /*this.admin = mapObject['admin'];
    this.users = mapObject['users'];*/
  }
  Map toMap() {
    HashMap<String, dynamic> mediaMap = new HashMap();
    mediaMap["image"] = this.image;
    mediaMap["video"] = this.videoUrl;
    mediaMap["type"] = this.mediaType;
    Map<String, dynamic> map = {
      // "body_part": this.bodyPart,
      "created_at": this.createdAt,
      "description": this.description,
      "title": this.title,
      "mediaMap": mediaMap,
      // "equipment": this.equipment,

      // "movement_nutrition": this.movementNutrition,
      // "movement_type": this.movementType,
      "position": this.position,
     
      // "sports_activity": this.sportsActivity,
      "updated_at": this.updatedAt,
    };
    return map;
  }


}
