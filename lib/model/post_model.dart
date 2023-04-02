import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solstice/model/forum_model_new.dart';
import 'package:solstice/utils/constants.dart';

class PostModel {
  String userName;
  String userImage;
  String image;
  String locationName;
  String postTime;
  String title;
  String description;
  String commentsCount;
  String likes;
  bool isSaved;
  bool isContainCards;

  PostModel(
      this.userName,
      this.userImage,
      this.image,
      this.locationName,
      this.postTime,
      this.title,
      this.description,
      this.commentsCount,
      this.likes,
      this.isSaved,
      this.isContainCards);
}

class PostFeedModel {
  String postId;
  int active;

  Timestamp createdAt;
  String createdBy;
  String description;

  String location;
  // String stitchId;
  int likeCount;
  String latitude;
  String longitude;
  bool isPublic;
  int commentCount;
  bool isCardPost;
  String title;
  Timestamp upatedAt;
  UserFirebaseModel userFirebaseModel;
  List<MediaPostModel> mediaList;
  List<Map<String, dynamic>> mediaMapList;

  // Filter post fields
  String goal;
  String link;
  String movementNutrition;
  String movementType;
  String sportsActivity;
  String equipments;
  List<String> bodyParts;
  List<String> goalsList;
  List<String> movementTypeList;
  List<String> nutritionsList;
  List<String> sportsList;
  List<String> equipmentsList;

  PostFeedModel(
      {this.postId,
      this.active,
      this.createdAt,
      this.description,
      this.location,
      this.likeCount,
      this.commentCount,
      this.isPublic,
      this.createdBy,
      this.isCardPost,
      // this.stitchId,
      this.latitude,
      this.longitude,
      this.title,
      this.upatedAt,
      this.mediaList,
      this.mediaMapList,
      this.userFirebaseModel});

  PostFeedModel.fromSnapshot(DocumentSnapshot snapshot) {
    // loadUser(mapObject["created_by"]);
    this.postId = snapshot.id;
    Map<String, dynamic> mapObject = snapshot.data();
    this.active = mapObject["active"];

    this.createdAt = mapObject["created_at"];
    this.createdBy = mapObject["created_by"];
    this.description = mapObject["description"];

    var locationMap = mapObject["location"];
    this.location = locationMap["address"];
    this.longitude = locationMap["longitude"];
    this.latitude = locationMap["latitude"];
    var count = mapObject["counts"];
    this.isPublic = mapObject["is_public"];
    this.likeCount = count['likes'];
    this.commentCount = count['comments'];
    this.title = mapObject["title"];

    this.mediaList = mapObject.containsKey("media")
        ? List<MediaPostModel>.from(mapObject["media"].map((item) {
            return MediaPostModel(
                mediaType: item["type"],
                thumbnail: item['thumbnail'],
                url: item['url']);
          }))
        : List.empty();
    this.isCardPost = mapObject.containsKey("is_card_post")
        ? mapObject["is_card_post"]
        : false;

    this.upatedAt = mapObject["upated_at"];

    this.goal = mapObject['goal'];
    this.equipments = mapObject['equipment'];
    this.link = mapObject['link'];
    this.movementNutrition = mapObject['movement_nutrition'];
    this.movementType = mapObject['movement_type'];
    this.sportsActivity = mapObject['sports_activity'];
    this.bodyParts = mapObject.containsKey("bod_part_array")
        ? mapObject['bod_part_array'].cast<String>()
        : List.empty();
    this.bodyParts = mapObject.containsKey("body_part_array")
        ? mapObject['body_part_array'].cast<String>()
        : List.empty();
    this.goalsList = mapObject.containsKey("goal_array")
        ? mapObject['goal_array'].cast<String>()
        : List.empty();
    this.movementTypeList = mapObject.containsKey("movement_type_array")
        ? mapObject['movement_type_array'].cast<String>()
        : List.empty();
    this.nutritionsList = mapObject.containsKey("nutrition_array")
        ? mapObject['nutrition_array'].cast<String>()
        : List.empty();
    this.sportsList = mapObject.containsKey("sports_activity_array")
        ? mapObject['sports_activity_array'].cast<String>()
        : List.empty();
    this.equipmentsList = mapObject.containsKey("equipment_array")
        ? mapObject['equipment_array'].cast<String>()
        : List.empty();
  }
  // Future<UserFirebaseModel> getUser(String userId) async {
  //   return await loadUser(userId).then(
  //       (value) => userFirebaseModel2 = UserFirebaseModel.fromSnapshot(value));
  // }

  Future<void> loadUser(userId) async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(userId)
        .get();
    if (ds != null)

      // return ds;

    this.userFirebaseModel = UserFirebaseModel.fromSnapshot(ds);
  }

  Map toMap() {
    HashMap<String, dynamic> countMap = new HashMap();
    countMap["likes"] = this.likeCount;
    countMap["comments"] = this.commentCount;

    HashMap<String, dynamic> locationMap = new HashMap();
    locationMap["address"] = this.location;
    locationMap["latitude"] = this.latitude;
    locationMap["longitude"] = this.longitude;
    Map<String, dynamic> map = {
      "active": this.active,
      "created_at": this.createdAt,
      "created_by": this.createdBy,
      "description": this.description,
      // "images": this.imagesList.toList(),
      "location": locationMap,
      "is_public": this.isPublic,
      "media": this.mediaMapList,
      // "stitch_id": this.stitchId,
      "title": this.title,

      "is_card_post": this.isCardPost,
      "upated_at": this.upatedAt,
      "counts": countMap
    };
    return map;
  }
}

class MediaPostModel {
  String thumbnail;
  String mediaType;
  String url;

  MediaPostModel({this.thumbnail, this.mediaType, this.url});

  MediaPostModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> mapObject = snapshot.data();
    this.thumbnail = mapObject["created_at"];
  }

  Map toMap() {
    HashMap<String, dynamic> mediaMap = new HashMap();
    mediaMap["thumbnail"] = this.thumbnail;
    mediaMap["mediaType"] = this.mediaType;
    mediaMap["url"] = this.url;
    return mediaMap;
  }
}
