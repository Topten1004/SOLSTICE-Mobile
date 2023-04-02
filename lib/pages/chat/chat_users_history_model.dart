import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solstice/model/forum_model_new.dart';
import 'package:solstice/utils/constants.dart';


class ChatHistoryUsersModel {
  String roomId;
  String lastMsg;
  String msgFrom;
  String msgTo;
  int msgType;
  String timestamp;
  int unSeenMsgCount = 0;

  UserFirebaseModel userFirebaseModel;

  ChatHistoryUsersModel(
      {this.roomId,
        this.lastMsg,
      this.msgFrom,
      this.msgTo,
      this.msgType,
      this.timestamp,
        this.unSeenMsgCount,
      this.userFirebaseModel});

  ChatHistoryUsersModel.fromSnapshot(DocumentSnapshot snapshot) {
    this.roomId = snapshot.id;
     Map<String, dynamic> mapObject = snapshot.data();
    this.lastMsg = mapObject["lastMsg"];
    this.msgFrom = mapObject["msgFrom"];
    this.msgTo = mapObject["msgTo"];
    this.msgType = mapObject["msgType"];
    this.timestamp = mapObject["timestamp"];
    try{
      var unSeenCountMap = mapObject["unSeenCount"];
      this.unSeenMsgCount = unSeenCountMap[globalUserId];
    }catch(e){
      this.unSeenMsgCount = 0;
    }



  }


}
