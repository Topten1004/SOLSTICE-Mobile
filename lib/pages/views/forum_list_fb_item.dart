import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:solstice/apiservice/api_call.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/forum_model.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/pages/profile/other_user_profile.dart';
import 'package:solstice/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/utils/size_utils.dart';

class ForumFbItem extends StatefulWidget {
  final ForumFireBaseModel forumItem;
  final String appUserId;

  ForumFbItem({Key key, @required this.forumItem, @required this.appUserId})
      : super(key: key);

  @override
  _ForumFbItemState createState() => _ForumFbItemState();
}

class _ForumFbItemState extends State<ForumFbItem> {
  bool isDataFetched = false;
  int forumLikesCount = 0;
  int commentsCount = 0;
  bool isForumLiked = false;
  UserFirebaseModel userItem;
  ForumFireBaseModel forumItemTemp;
  bool isNameUpdated = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //groupItem = widget.groupItem;
    forumItemTemp = widget.forumItem;

    if (!isDataFetched) {
      loadUser(widget.forumItem.createdBy);
      getForumsLikes();
      getCommentsCount();
      isDataFetched = true;
    }
  }
  /*@override
  void didUpdateWidget(ForumFireBaseModel oldWidget) {
    if(forumItemTemp != widget.forumItem) {
      setState((){
        forumItemTemp = widget.forumItem;
      });
    }
    super.didUpdateWidget(oldWidget);
  }*/

  Future<void> loadUser(String createdBy) async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(createdBy)
        .get();
    if (ds != null) {
      /*try{
        if(userItem.userImage != widget.forumItem.createdByImage || userItem.userName != widget.forumItem.createdByName){
          Firestore.instance.collection(Constants.ForumsFB).doc(widget.forumItem.id).update({'createdByName': userItem.userName, 'createdByImage': userItem.userImage});
        }
      }catch(e){

      }*/
      try {
        userItem = UserFirebaseModel.fromSnapshot(ds);

        if (userItem.userImage != widget.forumItem.createdByImage ||
            userItem.userName != widget.forumItem.createdByName) {
          if (!isNameUpdated) {
            FirebaseFirestore.instance
                .collection(Constants.ForumsFB)
                .doc(widget.forumItem.id)
                .update({
              'createdByName': userItem.userName,
              'createdByImage': userItem.userImage
            });
            isNameUpdated = true;
          }
        }
      } catch (e) {}

      if (mounted) setState(() {});
    }
  }

  Future<void> getCommentsCount() async {
    var snapshots = await FirebaseFirestore.instance
        .collection(Constants.ForumsCommentsFB)
        .doc(widget.forumItem.id)
        .collection(widget.forumItem.id)
        .snapshots();
    snapshots.listen((querySnapshot) {
      commentsCount = querySnapshot.docs.length;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> getForumsLikes() async {
    var snapshots = await FirebaseFirestore.instance
        .collection(Constants.ForumsLikesFB)
        .doc(Constants.ForumsLikesFB)
        .collection(widget.forumItem.id)
        .snapshots();
    snapshots.listen((querySnapshot) {
      forumLikesCount = querySnapshot.docs.length;
      if (mounted) {
        setState(() {});
      }
    });

    var isForumLikedSnapshot = await FirebaseFirestore.instance
        .collection(Constants.ForumsLikesFB)
        .doc(Constants.ForumsLikesFB)
        .collection(widget.forumItem.id)
        .where("likedBy", isEqualTo: widget.appUserId)
        .snapshots();

    isForumLikedSnapshot.listen((querySnapshot) {
      isForumLiked = querySnapshot.docs.length > 0 ? true : false;

      if (mounted) {
        setState(() {});
      }
    });
  }

  void likeUnLikeForum(
      ForumFireBaseModel forumModel, bool isLiked, String forumId) {
    if (!isLiked) {
      FirebaseFirestore.instance
          .collection(Constants.ForumsLikesFB)
          .doc(Constants.ForumsLikesFB)
          .collection(forumId)
          .doc(widget.appUserId)
          .set({
            "likedBy": widget.appUserId,
          })
          .then((docRef) {
          })
          .timeout(Duration(seconds: 10))
          .catchError((error) {
          });

      getUserTokenFromPost(forumModel, "Like");
    } else {
      FirebaseFirestore.instance
          .collection(Constants.ForumsLikesFB)
          .doc(Constants.ForumsLikesFB)
          .collection(forumId)
          .doc(widget.appUserId)
          .delete();
    }
  }

  void getUserTokenFromPost(
      ForumFireBaseModel forumFireBaseModel, String type) {
    try {
      if (forumFireBaseModel.createdBy != globalUserId) {
        FirebaseFirestore.instance
            .collection(Constants.UsersFB)
            .doc(forumFireBaseModel.createdBy)
            .snapshots()
            .listen((DocumentSnapshot documentSnapshot) {
          Map<String, dynamic> mapObject = documentSnapshot.data();
          if (mounted) {
            setState(() {
              if (mapObject.containsKey("token")) {
                String createdByToken = documentSnapshot['token'];
                if (type == "Like") {
                  sendNotificationToLikeAndComment(
                      createdByToken, forumFireBaseModel.id, type);
                }
              }
            });
          }
        }).onError((e) => print(e));
      }
    } catch (e) {}
  }

  void sendNotificationToLikeAndComment(
      String createdByToken, String forumId, String type) {
    var dataPayload = jsonEncode({
      'to': createdByToken,
      'data': {
        "type": "likeForum",
        "forumId": forumId,
        "priority": "high",
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "sound": "default",
        'userId': globalUserId,
        'userName': globalUserName,
        'userImage': globaUserProfileImage,
        'image': globaUserProfileImage
      },
      'notification': {
        'title': 'Your forum is Liked',
        'body': '$globalUserName liked your forum',
        'image': globaUserProfileImage,
        "badge": "1",
        "sound": "default"
      },
    });

    ApiCall.sendPushMessage(createdByToken, dataPayload);
  }

  @override
  Widget build(BuildContext context) {
    /*if(forumItemTemp != null){
      if(forumItemTemp.id != widget.forumItem.id){
        loadUser(widget.forumItem.createdBy);
        getForumsLikes();
        getCommentsCount();
        isDataFetched = true;
      }
    }
*/
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
                flex: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.all(ScreenUtil().setSp(20)),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OtherUserProfile(
                              userID: userItem.userId,
                              userName: userItem.userName,
                              userImage: userItem.userImage,
                            ),
                          ));
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        (userItem != null &&
                                userItem.userImage != null &&
                                userItem.userImage != "null" &&
                                userItem.userImage != "")
                            ? setUserImage(userItem.userImage)
                            : widget.forumItem != null &&
                                    widget.forumItem.createdByImage != null
                                ? setUserImage(widget.forumItem.createdByImage)
                                : Constants().setUserDefaultCircularImage(),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.all(ScreenUtil().setSp(12)),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    userItem != null
                                        ? " " + userItem.userName.toString()
                                        : widget.forumItem.createdByName != null
                                            ? " " +
                                                widget.forumItem.createdByName
                                                    .toString()
                                            : "",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: AppColors.titleTextColor,
                                        fontFamily: Constants.boldFont,
                                        fontSize: ScreenUtil().setSp(26)),
                                  ),
                                  SizedBox(height: 3),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          width: 16,
                                          height: 16,
                                          child: SvgPicture.asset(
                                            'assets/images/ic_marker.svg',
                                            alignment: Alignment.center,
                                            fit: BoxFit.fill,
                                            color: AppColors.accentColor,
                                          )),
                                      SizedBox(width: 3),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          widget.forumItem.postAddress
                                              .toString(),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: AppColors.accentColor,
                                              fontFamily: Constants.regularFont,
                                              fontSize: ScreenUtil().setSp(22)),
                                        ),
                                      ),
                                      Text(
                                        Constants.getTime(
                                            widget.forumItem.timestamp),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: AppColors.titleTextColor,
                                            fontFamily: Constants.mediumFont,
                                            fontSize: ScreenUtil().setSp(22)),
                                      ),
                                    ],
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            Container(
              margin: EdgeInsets.only(
                  top: ScreenUtil().setSp(10),
                  bottom: ScreenUtil().setSp(26),
                  right: ScreenUtil().setSp(20),
                  left: ScreenUtil().setSp(20)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.forumItem.description.toString(),
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppColors.titleTextColor,
                          height: 1.4,
                          fontFamily: Constants.regularFont,
                          fontSize: ScreenUtil().setSp(26)),
                    ),

                    /*RichText(
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,

                        text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text:
                              widget.forumItem.description.toString(),
                                style: TextStyle(
                                    color: AppColors.titleTextColor,
                                    height: 1.2,
                                    fontFamily: Constants.regularFont,
                                    fontSize: ScreenUtil().setSp(23)),
                              ),

                              if(widget.forumItem.description.length > 500) TextSpan(text:
                              "more",
                                style: TextStyle(
                                    color: AppColors.accentColor,
                                    height: 1.2,
                                    fontFamily: Constants.regularFont,
                                    fontSize: ScreenUtil().setSp(23)),
                              ),

                            ]
                        ),
                      )*/
                  ]),
            ),
            Container(
              margin: EdgeInsets.only(
                  right: ScreenUtil().setSp(20),
                  left: ScreenUtil().setSp(20),
                  bottom: ScreenUtil().setSp(10)),
              child: Row(
                children: [
                  InkWell(
                    child: Container(
                        padding: EdgeInsets.only(top: 6, bottom: 6),
                        alignment: Alignment.center,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                width: 18,
                                height: 18,
                                padding: EdgeInsets.all((1)),
                                child: SvgPicture.asset(
                                  'assets/images/ic_comment.svg',
                                  alignment: Alignment.center,
                                  color: AppColors.accentColor,
                                  fit: BoxFit.contain,
                                )),
                            SizedBox(width: 8),
                            Text(
                              Constants.changeToFormatedNumber(
                                  commentsCount.toString()),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: AppColors.titleTextColor,
                                  fontFamily: Constants.mediumFont,
                                  fontSize: ScreenUtil().setSp(24)),
                            ),
                            SizedBox(width: 3),
                            Text(
                              commentsCount > 1
                                  ? Constants.comments
                                  : Constants.comment,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: AppColors.titleTextColor,
                                  fontFamily: Constants.lightFont,
                                  fontSize: ScreenUtil().setSp(24)),
                            ),
                            SizedBox(width: 8),
                          ],
                        )), /*onTap: (){
                setState(() {
                  if(!isSelectedRecent){
                    isSelectedRecent = true;
                  }
                });
              },*/
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    child: Container(
                        padding: EdgeInsets.only(top: 4, bottom: 4),
                        alignment: Alignment.center,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                width: 18,
                                height: 18,
                                padding: EdgeInsets.all((1.5)),
                                child: SvgPicture.asset(
                                  'assets/images/ic_heart.svg',
                                  alignment: Alignment.center,
                                  color: isForumLiked
                                      ? AppColors.redColor
                                      : AppColors.accentColor,
                                  fit: BoxFit.contain,
                                )),
                            SizedBox(width: 8),
                            Text(
                              Constants.changeToFormatedNumber(
                                  forumLikesCount.toString()),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: AppColors.titleTextColor,
                                  fontFamily: Constants.mediumFont,
                                  fontSize: ScreenUtil().setSp(24)),
                            ),
                            SizedBox(width: 3),
                            Text(
                              forumLikesCount > 1
                                  ? Constants.likes
                                  : Constants.like,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: AppColors.titleTextColor,
                                  fontFamily: Constants.lightFont,
                                  fontSize: ScreenUtil().setSp(24)),
                            ),
                            SizedBox(width: 8),
                          ],
                        )),
                    onTap: () {
                      setState(() {
                        likeUnLikeForum(widget.forumItem, isForumLiked,
                            widget.forumItem.id);
                      });
                    },
                  ),
                  Expanded(flex: 1, child: Container()),
                ],
              ),
            )
          ],
        ));
  }

  setUserImage(String userImageUrl) {
    return CachedNetworkImage(
      imageUrl:
          (userImageUrl.contains("https:") || userImageUrl.contains("http:"))
              ? userImageUrl
              : UrlConstant.BaseUrlImg + userImageUrl,
      imageBuilder: (context, imageProvider) => Container(
        width: Dimens.imageSize25(),
        height: Dimens.imageSize25(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(50.0)),
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => Constants().setUserDefaultCircularImage(),
      errorWidget: (context, url, error) =>
          Constants().setUserDefaultCircularImage(),
    );
  }
}
