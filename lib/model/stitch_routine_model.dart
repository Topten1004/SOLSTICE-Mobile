import 'package:cloud_firestore/cloud_firestore.dart';

class StitchRoutineModel {
  String id;
  String description;
  String image;
  String title;
  bool isPublic = true;
  var createdAt;
  String createdBy;
  var updatedAt;
  bool isSelected = false;
  List<String> postsId;
  List<String> feedIds;
  List<String> sectionIds;

  StitchRoutineModel(
      {this.id,
      this.description,
      this.image,
      this.title,
      this.createdAt,
      this.isPublic,
      this.createdBy,
      this.postsId,
      this.updatedAt,
      this.sectionIds,
      this.isSelected});

  StitchRoutineModel.fromJson(Map<String, dynamic> json, {String stitchId}) {
    id = stitchId;
    description = json['description'];
    image = json['image'];
    title = json['title'];
    isPublic = json['is_public'];
    createdAt = json['created_at'];
    feedIds = json['feed_ids'].cast<String>();
    createdBy = json['created_by'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['image'] = this.image;
    data['is_public'] = this.isPublic;
    data['title'] = this.title;
    data['created_at'] = this.createdAt;
    data['created_by'] = this.createdBy;
    data['updated_at'] = this.updatedAt;

    return data;
  }

  StitchRoutineModel.fromSnapshot(DocumentSnapshot snapshot) {
    this.id = snapshot.id;
    Map<String, dynamic> mapObject = snapshot.data();
    this.description = mapObject["description"];
    this.image = mapObject["image"];
    this.createdAt = mapObject["created_at"];
    this.createdBy = mapObject["created_by"];
    this.isPublic = mapObject["is_public"];
    this.title = mapObject["title"];
    this.updatedAt = mapObject["updated_at"];
    if (mapObject.containsKey("post_ids")) {
      this.postsId = mapObject["post_ids"].cast<String>();
    }
  }
}
