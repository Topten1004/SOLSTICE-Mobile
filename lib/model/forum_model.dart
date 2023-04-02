import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solstice/utils/constants.dart';

class ForumModel {
  String userName;
  String userImage;
  String locationName;
  String postTime;
  String title;
  String description;
  String commentsCount;
  String likesCount;

  ForumModel(this.userName, this.userImage, this.locationName, this.postTime,
      this.title, this.description, this.commentsCount, this.likesCount);
}

class ForumFireBaseModel {
  String id;
  String title;
  String createdBy;
  String createdByName;
  String createdByImage;
  String description;
  String postLatitude;
  bool isPublic = true;
  String postLongitude;
  String postAddress;
  String timestamp;
  UserFirebaseModel user;

  ForumFireBaseModel(
      {String id,
      String title,
      String createdBy,
      String createdByName,
      String createdByImage,
      String description,
      String postLatitude,
      String postLongitude,
      this.isPublic,
      String postAddress,
      String timestamp}) {
    this.id = id;
    this.title = title;
    this.createdBy = createdBy;
    this.createdByName = createdByName;
    this.createdByImage = createdByImage;
    this.description = description;
    this.postLatitude = postLatitude;
    this.isPublic = isPublic;
    this.postLongitude = postLongitude;
    this.postAddress = postAddress;
    this.timestamp = timestamp;
  }

  ForumFireBaseModel.fromSnapshot(DocumentSnapshot snapshot) {
    this.id = snapshot.id;
    Map<String, dynamic> mapObject = snapshot.data();
    this.title = mapObject["title"];
    this.createdBy = mapObject['createdBy'];
    this.createdByName = mapObject['createdByName'];
    this.createdByImage = mapObject['createdByImage'];
    this.description = mapObject["description"];
    this.postLatitude = mapObject["postLatitude"];
    this.postLongitude = mapObject["postLongitude"];
    this.isPublic = mapObject["is_public"];
    this.postAddress = mapObject["postAddress"];
    this.timestamp = mapObject["timestamp"];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      "title": this.title,
      "createdBy": this.createdBy,
      "createdByName": this.createdByName,
      "createdByImage": this.createdByImage,
      "description": this.description,
      "postLatitude": this.postLatitude,
      "postLongitude": this.postLongitude,
      "is_public": this.isPublic,
      "postAddress": this.postAddress,
      "timestamp": this.timestamp
    };
    return map;
  }

  Future<void> loadUser() async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(this.createdBy)
        .get();
    if (ds != null) this.user = UserFirebaseModel.fromSnapshot(ds);
  }
}

class ForumCommentsFireBaseModel {
  String id;
  String comment;
  String commentBy;
  String createdByName;
  String createdByImage;
  String timestamp;
  UserFirebaseModel user;

  ForumCommentsFireBaseModel(
      {String comment,
      String commentBy,
      String createdByName,
      String createdByImage,
      String timestamp}) {
    this.comment = comment;
    this.commentBy = commentBy;
    this.createdByName = createdByName;
    this.createdByImage = createdByImage;
    this.timestamp = timestamp;
  }

  ForumCommentsFireBaseModel.fromSnapshot(DocumentSnapshot snapshot) {
    this.id = snapshot.id;
    Map<String, dynamic> mapObject = snapshot.data();
    this.comment = mapObject["comment"];
    this.commentBy = mapObject['commentBy'];
    this.createdByName = mapObject['createdByName'];
    this.createdByImage = mapObject['createdByImage'];
    this.timestamp = mapObject["timestamp"];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      "comment": this.comment,
      "commentBy": this.commentBy,
      "createdByName": this.createdByName,
      "createdByImage": this.createdByImage,
      "timestamp": this.timestamp
    };
    return map;
  }
}

class UserFirebaseModel {
  String id;
  String userId;
  String userImage;
  String userName;
  String token;

  UserFirebaseModel(
      {String userId,
      String userImage,
      String userName,
      String postLongitude,
      String postAddress,
      String timestamp,
      String token}) {
    this.userId = userId;
    this.userImage = userImage;
    this.userName = userName;
    this.token = token;
  }

  UserFirebaseModel.fromSnapshot(DocumentSnapshot snapshot) {
   
    this.id = snapshot.id;
    Map<String, dynamic> mapObject = snapshot.data();
    this.userId = mapObject["userId"];
    this.userImage = mapObject["userImage"];
    this.userName = mapObject["userName"];
    if (mapObject.containsKey("token")) {
      this.token = mapObject["token"];
    }
  }

  Map toMap() {
    Map<String, dynamic> map = {
      "userId": this.userId,
      "userImage": this.userImage,
      "userName": this.userName,
    };
    return map;
  }
}

class BusinessProducts {
  String productDescription;
  List<String> productLinks;

  BusinessProducts({this.productDescription, this.productLinks});

  BusinessProducts.fromJson(Map<String, dynamic> mapObject) {
    this.productDescription = mapObject['productDescription'];
    this.productLinks = mapObject['productLinks'].cast<String>();
  }

  Map toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['productDescription'] = this.productDescription;
    data['productLinks'] = this.productLinks;
    return data;
  }
}
