import 'package:solstice/model/select_filter_model.dart';
import 'package:solstice/utils/constants.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

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

class ForumFireBaseNewModel {
  String id;
  String title;
  String createdBy;
  String createdByName;
  String createdByImage;
  String description;
  String postLatitude;
  String postLongitude;
  String postAddress;
  String timestamp;
  UserFirebaseModel user;
  int likeCount = 0;
  bool isForumLiked = false;

  ForumFireBaseNewModel(
      {String title,
      String createdBy,
      String createdByName,
      String createdByImage,
      String description,
      String postLatitude,
      String postLongitude,
      String postAddress,
      String timestamp}) {
    this.title = title;
    this.createdBy = createdBy;
    this.createdByName = createdByName;
    this.createdByImage = createdByImage;
    this.description = description;
    this.postLatitude = postLatitude;
    this.postLongitude = postLongitude;
    this.postAddress = postAddress;
    this.timestamp = timestamp;
  }

  ForumFireBaseNewModel.fromSnapshot(DocumentSnapshot snapshot) {
    this.id = snapshot.id;
    Map<String, dynamic> mapObject = snapshot.data();
    this.title = mapObject["title"];
    this.createdBy = mapObject['createdBy'];
    this.createdByName = mapObject['createdByName'];
    this.createdByImage = mapObject['createdByImage'];
    this.description = mapObject["description"];
    this.postLatitude = mapObject["postLatitude"];
    this.postLongitude = mapObject["postLongitude"];
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
    if (ds != null) {
      this.user = UserFirebaseModel.fromSnapshot(ds);
      var snapshots = FirebaseFirestore.instance
          .collection(Constants.ForumsLikesFB)
          .doc(Constants.ForumsLikesFB)
          .collection(this.id)
          .snapshots();
      snapshots.listen((querySnapshot) {
        this.likeCount = querySnapshot.docs.length;
      });
      var isForumLikedSnapshot = await FirebaseFirestore.instance
          .collection(Constants.ForumsLikesFB)
          .doc(Constants.ForumsLikesFB)
          .collection(this.id)
          .where("likedBy", isEqualTo: this.createdBy)
          .snapshots();

      isForumLikedSnapshot.listen((querySnapshot) {
        this.isForumLiked = querySnapshot.docs.length > 0 ? true : false;
      });
    }
  }

  Future<void> getCommentsCount() async {
    var snapshots = FirebaseFirestore.instance
        .collection(Constants.ForumsLikesFB)
        .doc(Constants.ForumsLikesFB)
        .collection(this.id)
        .snapshots();
    snapshots.listen((querySnapshot) {
      this.likeCount = querySnapshot.docs.length;
    });
    /*var isForumLikedSnapshot = await Firestore.instance
        .collection(Constants.ForumsLikesFB)
        .doc(Constants.ForumsLikesFB).collection(this.id)
        .where("likedBy", isEqualTo: this.createdBy)
        .snapshots();

    isForumLikedSnapshot.listen((querySnapshot) {
      this.isForumLiked = querySnapshot.docs.length > 0? true : false;
    });*/
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
  String userEmail;
  bool isFollow = false;
  List<String> followers;
  String token;
  String userType;
  int profileCommplete;
  String gender;
  String height,
      weight,
      age,
      heightUnit,
      weightUnit,
      height2,
      livingDesc,
      trainDesc,
      supplements;
  UserInterests userInterest;
  InjuryHistory injuryHistory;
  String phone;
  String country_code;
  String address;
  String is_login;
  String businessType;
  String website;
  String pageAdmin;
  BusinessProducts businessProducts;
  BusinessBrand businessBrand;
  String last_skipped_page;

  UserFirebaseModel(
      {String userId,
      String userImage,
      String userName,
      String postLongitude,
      String postAddress,
      String timestamp,
      this.phone,
      this.country_code,
      this.address,
      this.is_login,
      String userType,
      String height,
      String height2,
      String weight,
      String age,
      String heightUnit,
      String weightUnit,
      String livingDesc,
      String userEmail,
      String businessType,
      String trainDesc,
      String supplements,
      int profileCommplete,
      bool isFollow = false,
      List<String> followers,
      String website,
      String pageAdmin,
      String token,
      BusinessProducts businessProducts,
      UserInterests userInterest,
      BusinessBrand businessBrand,
      InjuryHistory injuryHistory,
      this.last_skipped_page}) {
    this.userId = userId;
    this.userImage = userImage;
    this.userName = userName;
    this.isFollow = isFollow;
    this.userType = userType;
    this.businessType = businessType;
    this.userEmail = userEmail;
    this.followers = followers;
    this.age = age;
    this.height2 = height2;
    this.businessBrand = businessBrand;
    this.height = height;
    this.livingDesc = livingDesc;
    this.trainDesc = trainDesc;
    this.supplements = supplements;
    this.weight = weight;
    this.businessProducts = businessProducts;
    this.heightUnit = heightUnit;
    this.weightUnit = weightUnit;
    
    this.profileCommplete = profileCommplete;
    this.token = token;
    this.website = website;
    this.pageAdmin = pageAdmin;
    this.userInterest = userInterest;
    this.injuryHistory = injuryHistory;
    this.last_skipped_page = last_skipped_page;
  }

  UserFirebaseModel.fromSnapshot(DocumentSnapshot snapshot) {
    this.id = snapshot.id;
    Map<String, dynamic> mapObject = snapshot.data();
    this.userId = mapObject["userId"];
    this.userImage = mapObject["userImage"];
    this.userEmail = mapObject["userEmail"];
    this.userName = mapObject["userName"];
    this.pageAdmin = mapObject["pageAdmin"];
    this.website = mapObject["website"];
    this.businessType = mapObject["businessType"];
    this.heightUnit = mapObject.containsKey("heightUnit")
        ? mapObject["heightUnit"]
        : 'Individual';
    this.weightUnit =
        mapObject.containsKey("weightUnit") ? mapObject["weightUnit"] : 'LB';
    this.last_skipped_page = mapObject["last_skipped_page"];
   
    this.weight = mapObject.containsKey("weight") ? mapObject["weight"] : '';
    this.businessProducts = mapObject.containsKey("businessProducts")
        ? BusinessProducts.fromJson(mapObject["businessProducts"])
        : null;
    this.businessBrand = mapObject.containsKey("businessBrand")
        ? BusinessBrand.fromJson(mapObject["businessBrand"])
        : null;

    this.height = mapObject.containsKey("height") ? mapObject["height"] : '';
    this.height2 = mapObject.containsKey("height2") ? mapObject["height2"] : '';
    this.age = mapObject.containsKey("age") ? mapObject["age"] : '';
    this.livingDesc =
        mapObject.containsKey("livingDesc") ? mapObject["livingDesc"] : '';
    this.trainDesc =
        mapObject.containsKey("trainDesc") ? mapObject["trainDesc"] : '';
    this.supplements =
        mapObject.containsKey("supplements") ? mapObject["supplements"] : '';
    this.userType =
        mapObject.containsKey("userType") ? mapObject["userType"] : 'FT';
    this.profileCommplete = mapObject.containsKey("profileComplete")
        ? mapObject["profileComplete"]
        : 0;
    if (mapObject.containsKey("followers")) {
      this.followers = mapObject["followers"].cast<String>();
    }
    if (mapObject.containsKey("token")) {
      this.token = mapObject["token"];
    }
    if (mapObject.containsKey("user_interest")) {
      this.userInterest = UserInterests.from(mapObject["user_interest"]);
    }
    if (mapObject.containsKey("injury_history")) {
      this.injuryHistory = InjuryHistory.from(mapObject["injury_history"]);
    }
  }

  Map toMap() {
    Map<String, dynamic> map = {
      "userId": this.userId,
      "userImage": this.userImage,
      "userName": this.userName,
      "userType": this.userType,
      "profileComplete": this.profileCommplete,
      "weightUnit": this.weightUnit,
      "weight": this.weight,
      "height": this.height,
      "height2": this.height2,
      "livingDesc": this.livingDesc,
      "trainDesc": this.trainDesc,
      "website": this.website,
      "pageAdmin": this.pageAdmin,
      "supplements": this.supplements,
      "businessType": this.businessType,
      "heightUnit": this.heightUnit,
      "businessBrand": this.businessBrand,
      "age": this.age,
      "user_interest": this.userInterest,
      "injury_history": this.injuryHistory,
    };
    return map;
  }
}

class UserInterests {
  List<SelectFilterModel> categoriesList;
  List<SelectFilterModel> subCategoriesList;
  List<String> categoriesTitleList;
  List<String> subCategoriesTitleList;
  String other;
  UserInterests(
      {this.categoriesList,
      this.subCategoriesTitleList,
      this.subCategoriesList,
      this.categoriesTitleList,
      this.other});
  UserInterests.from(Map<String, dynamic> mapObject) {
    // Map<String, dynamic> mapObject = snapshot.data();

    if (mapObject['categories_list'] != null) {
      categoriesList = new List<SelectFilterModel>();
      mapObject['categories_list'].forEach((v) {
        categoriesList.add(new SelectFilterModel.fromJson(v));
      });
    }
    if (mapObject['subcategories_list'] != null) {
      subCategoriesList = new List<SelectFilterModel>();
      mapObject['subcategories_list'].forEach((v) {
        subCategoriesList.add(new SelectFilterModel.fromJson(v));
      });
    }
    // this.categoriesList = mapObject["categories_list"];
    this.categoriesTitleList =
        mapObject["categories_title_list"].cast<String>();
    // this.subCategoriesList = mapObject["subcategories_list"];
    this.subCategoriesTitleList =
        mapObject["subcategories_title_list"].cast<String>();
    this.other = mapObject["other"];
  }

  Map toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['other'] = this.other;
    if (this.categoriesList != null) {
      data['categories_list'] =
          this.categoriesList.map((v) => v.toJson()).toList();
    }
    if (this.subCategoriesList != null) {
      data['subcategory_list'] =
          this.subCategoriesList.map((v) => v.toJson()).toList();
    }
    data['categories_title_list'] = this.categoriesTitleList;
    data['subcategories_title_list'] = this.subCategoriesTitleList;
    return data;
  }
}

class InjuryHistory {
  List<SelectFilterModel> injuriesList;
  List<String> injuriesTextList;

  List<SelectFilterModel> pastInjuriesList;
  List<String> pastInjuriesTextList;
  String other;
  InjuryHistory(
      {this.injuriesList,
      this.other,
      this.injuriesTextList,
      this.pastInjuriesList,
      this.pastInjuriesTextList});
  InjuryHistory.from(Map<String, dynamic> mapObject) {
    // Map<String, dynamic> mapObject = snapshot.data();

    if (mapObject['injuries_list'] != null) {
      injuriesList = new List<SelectFilterModel>();
      mapObject['injuries_list'].forEach((v) {
        injuriesList.add(new SelectFilterModel.fromJson(v));
      });
    }
    if (mapObject['pastInjuriesList'] != null) {
      pastInjuriesList = new List<SelectFilterModel>();
      mapObject['pastInjuriesList'].forEach((v) {
        pastInjuriesList.add(new SelectFilterModel.fromJson(v));
      });
    }
    // this.injuriesList = mapObject["injuries_list"];
    this.injuriesTextList = mapObject["injuriesTextList"].cast<String>();
    // this.pastInjuriesList = mapObject["pastInjuriesList"];
    this.pastInjuriesTextList =
        mapObject["pastInjuriesTextList"].cast<String>();

    this.other = mapObject["other"];
  }

  Map toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['other'] = this.other;
    if (this.injuriesList != null) {
      data['injuries_list'] = this.injuriesList.map((v) => v.toJson()).toList();
    }
    if (this.pastInjuriesList != null) {
      data['pastInjuriesList'] =
          this.pastInjuriesList.map((v) => v.toJson()).toList();
    }
    data['injuriesTextList'] = this.injuriesTextList;
    data['pastInjuriesTextList'] = this.pastInjuriesTextList;

    return data;
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

class BusinessBrand {
  String other;
  List<dynamic> brandList;

  BusinessBrand({this.brandList, this.other});
  BusinessBrand.fromJson(Map<String, dynamic> mapObject) {
    this.brandList = mapObject["brandList"].cast<String>();
    this.other = mapObject["other"];
  }
  Map toMap() {
    Map<String, dynamic> map = new Map();
    map["brandList"] = this.brandList;
    map["other"] = this.other;
    return map;
  }
}
