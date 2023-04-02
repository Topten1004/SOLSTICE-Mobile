import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/forum_model.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/pages/profile/other_user_profile.dart';
import 'package:solstice/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/utils/size_utils.dart';

class ForumCommentsItem extends StatefulWidget {
  final ForumCommentsFireBaseModel forumCommentItem;
  final String appUserId;
  final String forumId;
  ForumCommentsItem(
      {Key key,
      @required this.forumCommentItem,
      @required this.appUserId,
      @required this.forumId})
      : super(key: key);

  @override
  _ForumCommentsItemState createState() => _ForumCommentsItemState();
}

class _ForumCommentsItemState extends State<ForumCommentsItem> {
  bool isDataFetched = false;
  int commentsLikesCount = 0;
  int commentsDisLikesCount = 0;
  int commentsCount = 0;
  bool isCommentLiked = false;
  bool isCommentDisliked = false;
  UserFirebaseModel userItem;

  ForumCommentsFireBaseModel forumCommentItemTemp;

  bool isNameUpdated = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //groupItem = widget.groupItem;

    forumCommentItemTemp = widget.forumCommentItem;

    if (!isDataFetched) {
      loadUser(widget.forumCommentItem.commentBy);
      getForumsLikesDislikes();
      getCommentsCount();
      isDataFetched = true;
    }
  }

  Future<void> loadUser(String createdBy) async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(createdBy)
        .get();
    if (ds != null) {
      userItem = UserFirebaseModel.fromSnapshot(ds);

      try {
        if (userItem.userImage != widget.forumCommentItem.createdByImage ||
            userItem.userName != widget.forumCommentItem.createdByName) {
          if (!isNameUpdated) {
            FirebaseFirestore.instance
                .collection(Constants.ForumsCommentsFB)
                .doc(widget.forumId)
                .collection(widget.forumId)
                .doc(widget.forumCommentItem.id)
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

  @override
  Widget build(BuildContext context) {
/*

    if(forumCommentItemTemp != null){
      if(forumCommentItemTemp.id != widget.forumCommentItem.id){
        loadUser(widget.forumCommentItem.commentBy);
        getForumsLikesDislikes();
        getCommentsCount();
        isDataFetched = true;
      }
    }
*/

    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Container(
          padding: EdgeInsets.only(top: 16.0, bottom: 0.0),
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: () {
                  if (globalUserId != userItem.userId) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtherUserProfile(
                            userID: userItem.userId,
                            userName: userItem.userName,
                            userImage: userItem.userImage,
                          ),
                        ));
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    (userItem != null &&
                            userItem.userImage != null &&
                            userItem.userImage != "null" &&
                            userItem.userImage != "")
                        ? setUserImage(userItem.userImage)
                        : widget.forumCommentItem != null &&
                                widget.forumCommentItem.createdByImage != null
                            ? setUserImage(
                                widget.forumCommentItem.createdByImage)
                            : setUserDefaultCircularImage(),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      userItem != null
                          ? " " + userItem.userName.toString()
                          : widget.forumCommentItem.createdByName != null
                              ? " " +
                                  widget.forumCommentItem.createdByName
                                      .toString()
                              : "",
                      style: TextStyle(
                          fontFamily: 'epilogue_semibold',
                          fontSize: ScreenUtil().setSp(27)),
                    ),
                    Spacer(),
                    Text(
                      Constants.getTime(widget.forumCommentItem.timestamp),
                      style: TextStyle(
                          fontFamily: 'epilogue_regular',
                          fontSize: ScreenUtil().setSp(22)),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: ScreenUtil().setSp(70) + 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      "" + widget.forumCommentItem.comment,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26),
                        height: 1.5,
                        letterSpacing: 0.8,
                        fontFamily: 'epilogue_regular',
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        InkWell(
                            child: Container(
                              width: 70,
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.arrow_drop_up,
                                    color: isCommentLiked
                                        ? AppColors.primaryColor
                                        : AppColors.accentColor,
                                    size: 35,
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Text(
                                    Constants.changeToFormatedNumber(
                                        commentsLikesCount.toString()),
                                    style: TextStyle(
                                        fontFamily: 'epilogue_medium',
                                        fontSize: ScreenUtil().setSp(25),
                                        color: Color(0xFF727272)),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                likeForumComment(
                                    isCommentLiked, widget.forumCommentItem.id);
                              });
                            }),
                        SizedBox(
                          width: 20,
                        ),
                        InkWell(
                            child: Container(
                              width: 70,
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: isCommentDisliked
                                        ? AppColors.redColor
                                        : AppColors.accentColor,
                                    size: 35,
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Text(
                                    Constants.changeToFormatedNumber(
                                        commentsDisLikesCount.toString()),
                                    style: TextStyle(
                                        fontFamily: 'epilogue_medium',
                                        fontSize: ScreenUtil().setSp(25),
                                        color: Color(0xFF727272)),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                dislikeForumComment(isCommentDisliked,
                                    widget.forumCommentItem.id);
                              });
                            }),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 1.0,
                      color: AppColors.viewLineColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  setUserDefaultCircularImage() {
    return Container(
      width: ScreenUtil().setSp(70),
      height: ScreenUtil().setSp(70),
      child: SvgPicture.asset(
        'assets/images/ic_male_placeholder.svg',
        width: ScreenUtil().setSp(70),
        height: ScreenUtil().setSp(70),
        fit: BoxFit.fill,
      ),
    );
  }

  Future<void> getCommentsCount() async {
    var snapshots = await FirebaseFirestore.instance
        .collection(Constants.ForumsCommentsFB)
        .doc(Constants.ForumsCommentsFB)
        .collection(widget.forumCommentItem.id)
        .snapshots();
    snapshots.listen((querySnapshot) {
      commentsCount = querySnapshot.docs.length;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> getForumsLikesDislikes() async {
    var snapshots = await FirebaseFirestore.instance
        .collection(Constants.ForumsCommentsLikesFB)
        .doc(Constants.ForumsCommentsLikesFB)
        .collection(widget.forumCommentItem.id)
        .where("isLiked", isEqualTo: true)
        .snapshots();
    snapshots.listen((querySnapshot) {
      commentsLikesCount = querySnapshot.docs.length;
      if (mounted) {
        setState(() {});
      }
    });

    var isCommentLikedSnapshot = await FirebaseFirestore.instance
        .collection(Constants.ForumsCommentsLikesFB)
        .doc(Constants.ForumsCommentsLikesFB)
        .collection(widget.forumCommentItem.id)
        .where("likedBy", isEqualTo: widget.appUserId)
        .where("isLiked", isEqualTo: true)
        .snapshots();

    isCommentLikedSnapshot.listen((querySnapshot) {
      isCommentLiked = querySnapshot.docs.length > 0 ? true : false;

      if (mounted) {
        setState(() {});
      }
    });

    var dislikeCountSnapshot = await FirebaseFirestore.instance
        .collection(Constants.ForumsCommentsLikesFB)
        .doc(Constants.ForumsCommentsLikesFB)
        .collection(widget.forumCommentItem.id)
        .where("isLiked", isEqualTo: false)
        .snapshots();
    dislikeCountSnapshot.listen((querySnapshot) {
      commentsDisLikesCount = querySnapshot.docs.length;
      if (mounted) {
        setState(() {});
      }
    });

    var isCommentDislikeSnapshot = await FirebaseFirestore.instance
        .collection(Constants.ForumsCommentsLikesFB)
        .doc(Constants.ForumsCommentsLikesFB)
        .collection(widget.forumCommentItem.id)
        .where("likedBy", isEqualTo: widget.appUserId)
        .where("isLiked", isEqualTo: false)
        .snapshots();

    isCommentDislikeSnapshot.listen((querySnapshot) {
      isCommentDisliked = querySnapshot.docs.length > 0 ? true : false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  void likeForumComment(bool isLiked, String forumId) {
    if (!isLiked) {
      FirebaseFirestore.instance
          .collection(Constants.ForumsCommentsLikesFB)
          .doc(Constants.ForumsCommentsLikesFB)
          .collection(forumId)
          .doc(widget.appUserId)
          .set({
            "likedBy": widget.appUserId,
            "isLiked": true,
          })
          .then((docRef) {
          })
          .timeout(Duration(seconds: 10))
          .catchError((error) {
          });
    } else {
      FirebaseFirestore.instance
          .collection(Constants.ForumsCommentsLikesFB)
          .doc(Constants.ForumsCommentsLikesFB)
          .collection(forumId)
          .doc(widget.appUserId)
          .delete();
    }
  }

  void dislikeForumComment(bool isDisliked, String forumId) {
    if (!isDisliked) {
      FirebaseFirestore.instance
          .collection(Constants.ForumsCommentsLikesFB)
          .doc(Constants.ForumsCommentsLikesFB)
          .collection(forumId)
          .doc(widget.appUserId)
          .set({
            "likedBy": widget.appUserId,
            "isLiked": false,
          })
          .then((docRef) {
          })
          .timeout(Duration(seconds: 10))
          .catchError((error) {
          });
    } else {
      FirebaseFirestore.instance
          .collection(Constants.ForumsCommentsLikesFB)
          .doc(Constants.ForumsCommentsLikesFB)
          .collection(forumId)
          .doc(widget.appUserId)
          .delete();
    }
  }

  setUserImage(String userImageUrl) {
    return CachedNetworkImage(
      imageUrl:
          (userImageUrl.contains("https:") || userImageUrl.contains("http:"))
              ? userImageUrl
              : UrlConstant.BaseUrlImg + userImageUrl,
      imageBuilder: (context, imageProvider) => Container(
        width: ScreenUtil().setSp(70),
        height: ScreenUtil().setSp(70),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(50.0)),
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => setUserDefaultCircularImage(),
      errorWidget: (context, url, error) => setUserDefaultCircularImage(),
    );
  }
}
