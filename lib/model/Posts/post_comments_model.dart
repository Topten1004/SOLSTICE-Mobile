import 'package:cloud_firestore/cloud_firestore.dart';

import '../forum_model.dart';

class PostCommentsFireBaseModel {
  String id;
  String comment;
  String postId;
  String uid;
  String timestamp;
  UserFirebaseModel user;

  PostCommentsFireBaseModel(
      {String comment, String postId, String uid, String timestamp}) {
    this.comment = comment;
    this.postId = postId;
    this.uid = uid;
    this.timestamp = timestamp;
  }

  PostCommentsFireBaseModel.fromSnapshot(DocumentSnapshot snapshot) {
    this.id = snapshot.id;
    Map<String, dynamic> mapObject = snapshot.data();
    this.comment = mapObject["comment"];
    this.postId = mapObject['post_id'];
    this.uid = mapObject['uid'];
    this.timestamp = mapObject["timestamp"];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      "comment": this.comment,
      "post_id": this.postId,
      "uid": this.uid,
      "timestamp": this.timestamp
    };
    return map;
  }
}
