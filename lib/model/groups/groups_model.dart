import 'package:cloud_firestore/cloud_firestore.dart';

class GroupsFireBaseModel {
  String id;
  String title;
  String createdBy;
  String aboutGroup;
  String image;
  String description;
  String postLatitude;
  String postLongitude;
  String postAddress;
  Timestamp createdAt;
  Timestamp updatedAt;
  bool isPublic;
  List<String> stitchIds;
  List<String> routineIds;
  List<String> forumIds;
  bool isSelected=false;
  /* List<String> admin;
  List<String> users;
*/
  GroupsFireBaseModel(
      {String title,
      String created_by,
      String aboutGroup,
      String groupImage,
      String description,
      String postLatitude,
      String postLongitude,
      String postAddress,
      Timestamp createdAt,
      Timestamp updatedAt,
      bool isSelected,
      bool isPublic /*, List<String>admin, List<String>users*/}) {
    this.title = title;
    this.createdBy = created_by;
    this.aboutGroup = aboutGroup;
    this.image = image;
    this.description = description;
    this.postLatitude = postLatitude;
    this.postLongitude = postLongitude;
    this.postAddress = postAddress;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
    this.isPublic = isPublic;
    this.isSelected = isSelected;
    /*this.admin = admin;
    this.users = users;*/
  }

  GroupsFireBaseModel.fromSnapshot(DocumentSnapshot snapshot) {
    this.id = snapshot.id;
    Map<String, dynamic> mapObject = snapshot.data();
    this.title = mapObject["title"];
    this.createdBy = mapObject['created_by'];
    this.aboutGroup = mapObject['about_group'];
    this.image = mapObject['image'];
    this.description = mapObject["description"];
    this.postLatitude = mapObject["postLatitude"];
    this.postLongitude = mapObject["postLongitude"];
    this.postAddress = mapObject["postAddress"];
    this.createdAt = mapObject["created_at"];
    this.updatedAt = mapObject["updated_at"];
    this.isPublic = mapObject['is_public'];
    this.stitchIds = mapObject.containsKey('stitch_ids')
        ? mapObject["stitch_ids"].cast<String>()
        : new List.empty();
    this.routineIds = mapObject.containsKey('routine_ids')
        ? mapObject['routine_ids'].cast<String>()
        : new List.empty();
    this.forumIds = mapObject.containsKey('forum_ids')
        ? mapObject['forum_ids'].cast<String>()
        : new List.empty();

    /*this.admin = mapObject['admin'];
    this.users = mapObject['users'];*/
  }

  Map toMap() {
    Map<String, dynamic> map = {
      "title": this.title,
      "created_by": this.createdBy,
      "about_group": this.aboutGroup,
      "image": this.image,
      "description": this.description,
      "postLatitude": this.postLatitude,
      "postLongitude": this.postLongitude,
      "postAddress": this.postAddress,
      "created_at": this.createdAt,
      "updated_at": this.updatedAt,
      "is_public": this.isPublic
      /*"admin": this.admin,
      "users": this.users,*/
    };
    return map;
  }
}
