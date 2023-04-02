import 'package:cloud_firestore/cloud_firestore.dart';

class RecentPostsModel {
  String title;
  String description;
  RecentPostsModel({
    String title,
    String description,
  }) {
    this.title = title;
    this.description = description;
  }

  RecentPostsModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> mapObject = snapshot.data();
    this.title = mapObject["title"];
    this.description = mapObject["description"];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      "title": this.title,
      "description": this.description,
    };
    return map;
  }
}
