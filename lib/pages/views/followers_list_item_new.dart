import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solstice/apiservice/api_call.dart';
import 'package:solstice/model/forum_model_new.dart';
import 'package:solstice/model/stitch_routine_model.dart';
import 'package:solstice/pages/onboardingflow/Profile_user.dart';
import 'package:solstice/pages/profile/other_user_profile.dart';
import 'package:solstice/utils/constants.dart';

class FollowersListItemNew extends StatefulWidget {
  final UserFirebaseModel _selectedItem;

  FollowersListItemNew(@required this._selectedItem);

  @override
  _FollowersListItemNewState createState() => _FollowersListItemNewState();
}

class _FollowersListItemNewState extends State<FollowersListItemNew> {
  bool isUserFollowed = false;
  bool isDataFetched = false;

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: ScreenUtil().setSp(24),
        right: ScreenUtil().setSp(24),
      ),
      child: widget._selectedItem != null
          ? setViewsOnTypeBasis(widget._selectedItem, context)
          : Container(),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //groupItem = widget.groupItem;
  }

  Future<void> checkIsUserFollwed(String follewerId) async {
    var snapshots = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(follewerId)
        .collection(Constants.FollowersFB)
        .where("userId", isEqualTo: globalUserId)
        .snapshots();

    snapshots.listen((querySnapshot) {
      isUserFollowed = querySnapshot.docs.length > 0 ? true : false;

      if (mounted) {
        setState(() {});
      }
    });
  }

  setViewsOnTypeBasis(UserFirebaseModel selectedItem, BuildContext context) {
    if (!isDataFetched) {
      checkIsUserFollwed(widget._selectedItem.userId);
      isDataFetched = true;
    }
    return Container(
        child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile_User_Screen(
                      userID: selectedItem.userId,
                      userName: selectedItem.userName,
                      userImage: selectedItem.userImage,
                      viewType: "followers",
                    ),
                  ));
            },
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                width: MediaQuery.of(context).size.width,
                child: Row(mainAxisSize: MainAxisSize.max, children: [
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      height: 55.0,
                      width: 55.0,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: selectedItem != null && selectedItem.userImage != null
                              ? CachedNetworkImage(
                                  imageUrl: selectedItem.userImage,
                                  height: 55.0,
                                  width: 55.0,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                    child: SizedBox(
                                      width: 30.0,
                                      height: 30.0,
                                      child: new CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      setUserDefaultCircularImage(),
                                )
                              : setUserDefaultCircularImage())),
                  SizedBox(
                    width: 5.0,
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    child: Text(
                      selectedItem != null ? selectedItem.userName : "",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  selectedItem != null
                      ? InkWell(
                          onTap: () {
                            setState(() {
                              followUnfollowCount(selectedItem);
                            });
                          },
                          child: Container(
                            height: 30,
                            width: 100,
                            alignment: Alignment.center,
                            decoration: isUserFollowed
                                ? BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                    color: Color.fromRGBO(26, 88, 231, 1))
                                : BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                    border: Border.all(color: Color.fromRGBO(26, 88, 231, 1)),
                                    color: Color.fromRGBO(235, 241, 255, 1)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  isUserFollowed ? Icons.check : Icons.add,
                                  color: isUserFollowed ? Colors.white : AppColors.primaryColor,
                                  size: 16,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 2),
                                  child: Text(isUserFollowed ? "Followed" : "Follow",
                                      style: new TextStyle(
                                          color: isUserFollowed
                                              ? Colors.white
                                              : AppColors.primaryColor,
                                          fontFamily: Constants.mediumFont,
                                          //fontWeight: FontWeight.bold,
                                          fontSize: 12.0)),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(),
                ]))));
  }

  void followUnfollowCount(UserFirebaseModel selectedUser) {
    if (isUserFollowed) {
      FirebaseFirestore.instance
          .collection(Constants.UsersFB)
          .doc(selectedUser.userId)
          .collection(Constants.FollowersFB)
          .doc(globalUserId)
          .delete();

      FirebaseFirestore.instance
          .collection(Constants.UsersFB)
          .doc(globalUserId)
          .collection(Constants.FollowingsFB)
          .doc(selectedUser.userId)
          .delete();
    } else {
      FirebaseFirestore.instance
          .collection(Constants.UsersFB)
          .doc(selectedUser.userId)
          .collection(Constants.FollowersFB)
          .doc(globalUserId)
          .set({'userId': globalUserId});

      FirebaseFirestore.instance
          .collection(Constants.UsersFB)
          .doc(globalUserId)
          .collection(Constants.FollowingsFB)
          .doc(selectedUser.userId)
          .set({'userId': selectedUser.userId});

      getUserTokenFromPost(selectedUser.userId);
    }
  }

  void getUserTokenFromPost(String receiveUseId) {
    try {
      if (receiveUseId != globalUserId) {
        FirebaseFirestore.instance
            .collection(Constants.UsersFB)
            .doc(receiveUseId)
            .snapshots()
            .listen((DocumentSnapshot documentSnapshot) {
          Map<String, dynamic> mapObject = documentSnapshot.data();
          if (mounted) {
            setState(() {
              if (mapObject.containsKey("token")) {
                String createdByToken = documentSnapshot['token'];
                sendNotification(createdByToken);
              }
            });
          }
        }).onError((e) => print(e));
      }
    } catch (e) {}
  }

  void sendNotification(String reciverToken) {
    var dataPayload = jsonEncode({
      'to': reciverToken,
      'data': {
        "type": "follow",
        "priority": "high",
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "sound": "default",
        'userId': globalUserId,
        'userName': globalUserName,
        'userImage': globaUserProfileImage,
        'image': globaUserProfileImage
      },
      'notification': {
        'title': 'You have a new follower',
        'body': '$globalUserName just followed you',
        'image': globaUserProfileImage,
        "badge": "1",
        "sound": "default"
      },
    });

    ApiCall.sendPushMessage(reciverToken, dataPayload);
  }

  setUserDefaultCircularImage() {
    return Container(
      height: 55.0,
      width: 55.0,
      child: SvgPicture.asset(
        'assets/images/ic_male_placeholder.svg',
        height: 55.0,
        width: 55.0,
        fit: BoxFit.fill,
      ),
    );
  }
}
