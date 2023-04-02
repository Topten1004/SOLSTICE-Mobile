import 'package:cloud_firestore/cloud_firestore.dart';

class StitchRoutineSelectionModel {
  String id;
  String description;
  String image;
  String title;
  var createdAt;
  String createdBy;
  var updatedAt;
  bool isSelected = false;
  List<String> post_ids;


  StitchRoutineSelectionModel(
      {this.id,
      this.description,
      this.image,
      this.title,
      this.createdAt,
      this.createdBy,
      this.updatedAt,this.isSelected,this.post_ids});

  StitchRoutineSelectionModel.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    image = json['image'];
    title = json['title'];
    createdAt = json['created_at'];
    createdBy = json['created_by'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['image'] = this.image;
    data['title'] = this.title;
    data['created_at'] = this.createdAt;
    data['created_by'] = this.createdBy;
    data['updated_at'] = this.updatedAt;

    return data;
  }

  StitchRoutineSelectionModel.fromSnapshot(DocumentSnapshot snapshot) {
     Map<String, dynamic> mapObject = snapshot.data();
    this.description = mapObject["description"];
    this.image = mapObject["image"];
    this.createdAt = mapObject["created_at"];
    this.createdBy = mapObject["created_by"];
    this.title = mapObject["title"];
    this.updatedAt = mapObject["updated_at"];
    this.post_ids = mapObject.containsKey('post_ids') ? List.from(mapObject['post_ids']) : new List();
  }
}
