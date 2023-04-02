import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/model/forum_model.dart';
import 'package:solstice/model/routine_model.dart';
import 'package:solstice/model/select_filter_model.dart';

class FeedModel {
  String id;
  String itemId;
  int saveCount;
  Timestamp timestamp;
  String type;
  List<String> viewCount;

  String userId;
  CardModel cardData;
  int feedViewCount;
  RoutineModel routineModel;
  UserFirebaseModel userFirebaseModel;
  List<String> categoryList;
  String sharedBy;
  String sharedByUsernName;
  // CardData routineData;

  FeedModel(
      {this.id,
      this.itemId,
      this.saveCount,
      this.timestamp,
      this.type,
      this.viewCount,
      this.feedViewCount,
      this.userId,
      this.categoryList,
      this.cardData,
      this.userFirebaseModel,
      this.sharedBy,
      this.sharedByUsernName,
      this.routineModel});

  FeedModel.fromJson(DocumentSnapshot snapshot) {
    try{
      Map<String, dynamic> json = snapshot.data();
      // print('snapshot ${snapshot.data()}');
      // print('json ${json}');
      id = snapshot.id;
      itemId = json['item_id'];
      saveCount = json['save_count'];
      timestamp = json['timestamp'];
      feedViewCount = json['feed_view_count'];
      type = json['type'];
      sharedBy = json.containsKey("shared_by") ? json['shared_by'] : '';
      sharedByUsernName = json.containsKey("shared_by_user_name") ? json['shared_by_user_name'] : '';


      categoryList = json.containsKey("category_list") ? json['category_list'].cast<String>() : [];
      viewCount = json['view_count'].cast<String>();
      userId = json['user_id'];
      // cardData = json['card_data'] != null ? new CardData.fromJson(json['card_data']) : null;
      // routineData = json['routine_data'] != null ? new CardData.fromJson(json['routine_data']) : null;
    } catch(err) {
      print("555555555555555");
      print(snapshot.data());
      print(err) ;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // data['id'] = this.id;
    data['item_id'] = this.itemId;
    data['save_count'] = this.saveCount;
    data['timestamp'] = this.timestamp;
    // if (this.categoryList != null) {
    //   data['category_list'] = this.categoryList.map((v) => v.toJson()).toList();
    // }
    data['type'] = this.type;
    data['shared_by'] = this.sharedBy;
    data['feed_view_count'] = this.feedViewCount;
    data['view_count'] = this.viewCount;
    data['shared_by_user_name'] = this.sharedByUsernName;
    data['category_list'] = this.categoryList;
    data['user_id'] = this.userId;
    // if (this.cardData != null) {
    //   data['card_data'] = this.cardData.toJson();
    // }
    // if (this.routineData != null) {
    //   data['routine_data'] = this.routineData.toJson();
    // }
    return data;
  }
}
