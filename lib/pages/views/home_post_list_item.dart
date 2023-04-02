import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solstice/apiservice/api_call.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/pages/filters/filter_post.dart';
import 'package:solstice/pages/home/create_post.dart';
import 'package:solstice/pages/home/post_filter.dart';
import 'package:solstice/pages/home/post_filter_new.dart';
import 'package:solstice/pages/home/save_to_routine.dart';
import 'package:solstice/pages/home/save_to_stitch.dart';
import 'package:solstice/pages/profile/other_user_profile.dart';
import 'package:solstice/pages/profile/profile_tab_screen.dart';
import 'package:solstice/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/utils/dialog_callback.dart';
import 'package:solstice/utils/size_utils.dart';
import 'package:solstice/utils/utilities.dart';

class HomePostListItem extends StatefulWidget {
  final PostFeedModel selectedItem;
  final int index;
  final String appUserId;

  HomePostListItem(
      {Key key,
      @required this.selectedItem,
      @required this.index,
      @required this.appUserId})
      : super(key: key);

  @override
  _HomePostListItemState createState() => _HomePostListItemState();
}

class _HomePostListItemState extends State<HomePostListItem>
    implements DialogCallBack {
  int imagePageIndex = 0;
  PageController pageController = new PageController();
  String stichId;
  String routineId;

  bool isPostLiked = false;
  bool isDataFetched = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //groupItem = widget.groupItem;

    if (!isDataFetched) {
      getPostLikes();
      isDataFetched = true;
    }
  }

  Future<void> getPostLikes() async {
    var isLikedSnapShot = await FirebaseFirestore.instance
        .collection(Constants.PostLikesFB)
        .doc(Constants.PostLikesFB)
        .collection(widget.selectedItem.postId)
        .where("liked_by", isEqualTo: widget.appUserId)
        .snapshots();

    isLikedSnapShot.listen((querySnapshot) {
      isPostLiked = querySnapshot.docs.length > 0 ? true : false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: ScreenUtil().setSp(16),
        right: ScreenUtil().setSp(16),
      ),
      child: setViewsOnTypeBasis(widget.selectedItem, context),
    );
  }

  setViewsOnTypeBasis(PostFeedModel _selectedItem, BuildContext context) {
    return Column(
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
                  setState(() {
                    if (globalUserId !=
                        _selectedItem.userFirebaseModel.userId) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OtherUserProfile(
                              userID: _selectedItem.userFirebaseModel.userId,
                              userName:
                                  _selectedItem.userFirebaseModel.userName,
                              userImage:
                                  _selectedItem.userFirebaseModel.userImage,
                            ),
                          ));
                    }
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _selectedItem.userFirebaseModel != null &&
                            _selectedItem.userFirebaseModel.userImage != null &&
                            _selectedItem.userFirebaseModel.userImage != ""
                        ? CachedNetworkImage(
                            imageUrl: _selectedItem.userFirebaseModel.userImage,
                            imageBuilder: (context, imageProvider) => Container(
                              width: Dimens.imageSize25(),
                              height: Dimens.imageSize25(),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50.0)),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => Center(
                                child: SizedBox(
                              width: 13.0,
                              height: 13.0,
                              child: new CircularProgressIndicator(),
                            )),
                            errorWidget: (context, url, error) =>
                                Constants().setUserDefaultCircularImage(),
                          )
                        : Container(
                            width: Dimens.imageSize25(),
                            height: Dimens.imageSize25(),
                            child: SvgPicture.asset(
                              'assets/images/ic_male_placeholder.svg',
                              width: Dimens.imageSize25(),
                              height: Dimens.imageSize25(),
                              fit: BoxFit.fill,
                            )),
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.all(ScreenUtil().setSp(12)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                _selectedItem.userFirebaseModel != null
                                    ? " " +
                                        _selectedItem.userFirebaseModel.userName
                                    : "",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: AppColors.titleTextColor,
                                    fontFamily: Constants.boldFont,
                                    fontWeight: FontWeight.w600,
                                    fontSize: ScreenUtil().setSp(28)),
                              ),
                              SizedBox(height: 3),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                      width: 14,
                                      height: 14,
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
                                      _selectedItem.location,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: AppColors.accentColor,
                                          fontFamily: Constants.regularFont,
                                          fontWeight: FontWeight.normal,
                                          fontSize: ScreenUtil().setSp(24)),
                                    ),
                                  ),
                                  Text(
                                    Utilities.timeAgoSinceDate(
                                        _selectedItem.createdAt,
                                        numericDates: true),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: AppColors.titleTextColor,
                                        fontFamily: Constants.mediumFont,
                                        fontSize: ScreenUtil().setSp(22)),
                                  ),
                                  SizedBox(width: 3),
                                  popUpMenu(context, _selectedItem),
                                  // InkWell(
                                  //   onTap: () {
                                  //     Navigator.push(
                                  //         context,
                                  //         MaterialPageRoute(
                                  //             builder: (context) =>
                                  //                 PostFilterNew(
                                  //                   postFeedModel:
                                  //                       _selectedItem,
                                  //                   editFields: false,
                                  //                 )));
                                  //   },
                                  //   child: Container(
                                  //       width: 20,
                                  //       height: 20,
                                  //       child: SvgPicture.asset(
                                  //         'assets/images/ic_filter.svg',
                                  //         alignment: Alignment.center,
                                  //         fit: BoxFit.fill,
                                  //         color: AppColors.accentColor,
                                  //       )),
                                  // ),
                                ],
                              ),
                            ]),
                      ),
                    ),
                  ],
                ),
              ),
            )),
        if (_selectedItem != null)
          Padding(
            padding:
                const EdgeInsets.only(left: 8.0, right: 8.0, top: 5, bottom: 5),
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25))),
              child: Stack(
                children: [
                  Container(
                    height: /*MediaQuery.of(context).size.height / 100 * 23*/ 175,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(25.0),
                      ),
                    ),
                    child: PageView.builder(
                        itemCount: _selectedItem.mediaList != null
                            ? _selectedItem.mediaList.length
                            : 0,
                        controller: pageController,
                        onPageChanged: (pos) {
                          this.imagePageIndex = pos;
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        itemBuilder: (context, indexView) {
                          //imagePageIndex = indexView;
                         return Hero(
                            tag: 'homePageImage' + widget.index.toString(),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: _selectedItem
                                              .mediaList[indexView].mediaType ==
                                          "Image"
                                      ? _selectedItem.mediaList[indexView].url
                                      : _selectedItem
                                          .mediaList[indexView].thumbnail,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      //borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) =>
                                      setPostDefaultImage(context),
                                  errorWidget: (context, url, error) =>
                                      setPostDefaultImage(context),
                                ),
                                Visibility(
                                  child: Icon(
                                    Icons.play_circle_fill_outlined,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  visible: _selectedItem
                                          .mediaList[indexView].mediaType ==
                                      "video",
                                  maintainAnimation: true,
                                  maintainSize: false,
                                  maintainState: true,
                                )
                              ],
                            ),
                          );
                        }),
                  ),
                  Positioned(
                    right: 10,
                    top: 0,
                    bottom: 0,
                    child: imagePageIndex < _selectedItem.mediaList.length - 1
                        ? InkWell(
                            onTap: () {
                              pageController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease);
                            },
                            child: Center(
                              child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  width: 25,
                                  height: 25,
                                  child: SvgPicture.asset(
                                    Constants.rightArrow,
                                    fit: BoxFit.contain,
                                    color: Colors.white30,
                                  )),
                            ),
                          )
                        : Container(),
                  ),
                  Positioned(
                    left: 10,
                    top: 0,
                    bottom: 0,
                    child: imagePageIndex > 0
                        ? InkWell(
                            onTap: () {
                              pageController.previousPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease);
                            },
                            child: Center(
                              child: RotationTransition(
                                turns: new AlwaysStoppedAnimation(180 / 360),
                                child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    width: 25,
                                    height: 25,
                                    child: SvgPicture.asset(
                                      Constants.rightArrow,
                                      fit: BoxFit.contain,
                                      color: Colors.white30,
                                    )),
                              ),
                            ),
                          )
                        : Container(),
                  ),
                ],
              ),
            ),
          ),
        Container(
          margin: EdgeInsets.only(
              top: ScreenUtil().setSp(20),
              bottom: ScreenUtil().setSp(26),
              right: ScreenUtil().setSp(46),
              left: ScreenUtil().setSp(46)),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  _selectedItem.title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColors.titleTextColor,
                      fontFamily: Constants.boldFont,
                      fontWeight: FontWeight.w700,
                      fontSize: ScreenUtil().setSp(30)),
                ),
                SizedBox(height: 6),
                Text(
                  _selectedItem.description,
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      height: 1.2,
                      color: AppColors.titleTextColor,
                      fontFamily: Constants.regularFont,
                      fontWeight: FontWeight.w400,
                      fontSize: ScreenUtil().setSp(25)),
                ),
              ]),
        ),
        SizedBox(
          height: 4,
        ),
        Container(
          margin: EdgeInsets.only(
              right: ScreenUtil().setSp(20),
              left: ScreenUtil().setSp(20),
              bottom: ScreenUtil().setSp(36)),
          child: Row(
            children: [
              InkWell(
                child: Container(
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26.0),
                        color: AppColors.lightSkyBlue),
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
                              fit: BoxFit.contain,
                            )),
                        SizedBox(width: 8),
                        Text(
                          "${_selectedItem.commentCount}",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColors.titleTextColor,
                              fontFamily: Constants.boldFont,
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenUtil().setSp(26)),
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
                onTap: () {
                  setState(() {
                    likeUnLikePost(
                        _selectedItem, isPostLiked, _selectedItem.postId);
                  });
                },
                child: Container(
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1.5, color: AppColors.lightSkyBlue),
                        borderRadius: BorderRadius.circular(26.0)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 18,
                            height: 18,
                            padding: EdgeInsets.all((1)),
                            child: SvgPicture.asset(
                              'assets/images/ic_heart.svg',
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                              color: isPostLiked
                                  ? AppColors.redColor
                                  : AppColors.accentColor,
                            )),
                        SizedBox(width: 8),
                        Text(
                          '${_selectedItem.likeCount}',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColors.titleTextColor,
                              fontFamily: Constants.boldFont,
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenUtil().setSp(26)),
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
              Expanded(flex: 1, child: Container()),
              InkWell(
                onTap: () async {
                  var object = await showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0)),
                      ),
                      builder: (BuildContext context) {
                        return SaveToRoutine();
                      });

                  if (object != null) {
                    routineId = object["routine_id"];
                    addRoutineToPost(context, _selectedItem);
                  }
                },
                child: Container(
                    padding:
                        EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26.0),
                        color: AppColors.lightSkyBlue),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 18,
                            height: 18,
                            padding: EdgeInsets.all((1)),
                            child: SvgPicture.asset(
                              // _selectedItem.isSaved ? 'assets/images/ic_bookmarked.svg':
                              'assets/images/ic_bookmark.svg',
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                            )),
                        SizedBox(width: 7),
                        Text(
                          "Routine",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColors.primaryColor,
                              fontFamily: Constants.boldFont,
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenUtil().setSp(24)),
                        ),
                        SizedBox(width: 3),
                      ],
                    )),
              ),
              SizedBox(width: 8),
              InkWell(
                onTap: () async {
                  var object = await showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0)),
                      ),
                      builder: (BuildContext context) {
                        return SaveToStitch();
                      });

                  if (object != null) {
                    stichId = object["stitch_id"];
                    addStitchToPost(context, _selectedItem);
                  }
                },
                child: Container(
                    padding:
                        EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26.0),
                        color: AppColors.lightSkyBlue),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 18,
                            height: 18,
                            padding: EdgeInsets.all((1)),
                            child: SvgPicture.asset(
                              // _selectedItem.isSaved ? 'assets/images/ic_bookmarked.svg':
                              'assets/images/ic_bookmark.svg',
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                            )),
                        SizedBox(width: 7),
                        Text(
                          "Stitch",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColors.primaryColor,
                              fontFamily: Constants.boldFont,
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenUtil().setSp(24)),
                        ),
                        SizedBox(width: 3),
                      ],
                    )), /*onTap: (){
                setState(() {
                  if(!isSelectedRecent){
                    isSelectedRecent = true;
                  }
                });
              },*/
              ),
            ],
          ),
        )
      ],
    );
  }

  void filterPost() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostFilterNew(
                  postFeedModel: widget.selectedItem,
                  isEditMode: false,
                  editFields: false,
                  postId: widget.selectedItem.postId,
                )));
  }

  Widget popUpMenu(context, PostFeedModel postFeedModel) {
    return Container(
        child: PopupMenuButton<int>(
      onSelected: (int value) {
        setState(() {
          //_selection = value;
          if (value == 1) {
            //updatePost
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreatePost(
                          screenType: "Post",
                          postFeedModel: postFeedModel,
                        )));
          }
          if (value == 2) {
            Utilities.confirmDeleteDialog(context, Constants.deletePost,
                Constants.deletePostConfirmDes, this, 1);
          }
          if (value == 3) {
            filterPost();
          }
        });
      },
      child: Container(
          width: 24,
          height: 24,
          margin: EdgeInsets.only(right: 10, left: 10),
          child: SvgPicture.asset(
            'assets/images/ic_menu.svg',
            alignment: Alignment.center,
            fit: BoxFit.contain,
          )),
      itemBuilder: (c) => [
        if (postFeedModel.createdBy == globalUserId)
          PopupMenuItem(
            value: 1,
            child: Text(
              Constants.updatePost,
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontFamily: Constants.regularFont,
                  color: Colors.black),
            ),
          ),
        if (postFeedModel.createdBy == globalUserId)
          PopupMenuItem(
            value: 2,
            child: Text(
              Constants.deletePost,
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontFamily: Constants.regularFont,
                  color: Colors.black),
            ),
          ),
        PopupMenuItem(
          value: 3,
          child: Text(
            Constants.filterPost,
            style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                fontFamily: Constants.regularFont,
                color: Colors.black),
          ),
        ),
      ],
    ));
  }

  void savePostToRoutine() {}

  void likeUnLikePost(postFeedModel, bool isLiked, String postId) {
    if (!isLiked) {
      FirebaseFirestore.instance
          .collection(Constants.PostLikesFB)
          .doc(Constants.PostLikesFB)
          .collection(postId)
          .doc(widget.appUserId)
          .set({
            "liked_by": widget.appUserId,
          })
          .then((docRef) {
          })
          .timeout(Duration(seconds: 10))
          .catchError((error) {
          });
      FirebaseFirestore.instance
          .collection(Constants.posts)
          .doc(postId)
          .update({"counts.likes": FieldValue.increment(1)});

      getUserTokenFromPost(postFeedModel, "Like");
    } else {
      FirebaseFirestore.instance
          .collection(Constants.PostLikesFB)
          .doc(Constants.PostLikesFB)
          .collection(postId)
          .doc(widget.appUserId)
          .delete();
      FirebaseFirestore.instance
          .collection(Constants.posts)
          .doc(postId)
          .update({"counts.likes": FieldValue.increment(-1)});
    }
  }

  static setPostDefaultImage(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: ScreenUtil().setSp(370),
      decoration: BoxDecoration(
        color: AppColors.viewLineColor,
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
    );
  }

  void addStitchToPost(BuildContext context, _selectedItem) {
    FirebaseFirestore.instance
        .collection(Constants.stitchCollection)
        .doc(stichId)
        .update({
      'post_ids': FieldValue.arrayUnion([_selectedItem.postId])
    }).then((value) =>
            Constants().successToast(context, "Post added to stitch"));

    getUserTokenFromPost(_selectedItem, "Stitch");
  }

  void addRoutineToPost(BuildContext context, _selectedItem) {
    FirebaseFirestore.instance
        .collection(Constants.routineCollection)
        .doc(routineId)
        .collection(Constants.posts)
        .add({'post_id': _selectedItem.postId, 'complete': 0}).then((value) =>
            Constants().successToast(context, "Post added to routine"));

    getUserTokenFromPost(_selectedItem, "Routine");
  }

  void getUserTokenFromPost(PostFeedModel postFeedData, String type) {
    try {
      if (postFeedData.createdBy != globalUserId) {
        FirebaseFirestore.instance
            .collection(Constants.UsersFB)
            .doc(postFeedData.createdBy)
            .snapshots()
            .listen((DocumentSnapshot documentSnapshot) {
          if (mounted) {
            setState(() {
              Map<String, dynamic> mapObject = documentSnapshot.data();
              if (mapObject.containsKey("token")) {
                String createdByToken = documentSnapshot['token'];
                if (type == "Like") {
                  sendNotificationToLike(
                      createdByToken, postFeedData.postId, type);
                } else {
                  sendNotificationToSaveStitchRoutine(
                      createdByToken, postFeedData.postId, type);
                }
              }
            });
          }
        }).onError((e) => print(e));
      }
    } catch (e) {}
  }

  void sendNotificationToLike(
      String createdByToken, String postId, String type) {
    // type is Stitch or Routine
    var dataPayload = jsonEncode({
      'to': createdByToken,
      'data': {
        "type": "likePost",
        "postId": postId,
        "priority": "high",
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "sound": "default",
        'userId': globalUserId,
        'userName': globalUserName,
        'userImage': globaUserProfileImage,
        'image': globaUserProfileImage
      },
      'notification': {
        'title': 'Your post is Liked',
        'body': '$globalUserName liked your post',
        'image': globaUserProfileImage,
        "badge": "1",
        "sound": "default"
      },
    });

    ApiCall.sendPushMessage(createdByToken, dataPayload);
  }

  void sendNotificationToSaveStitchRoutine(
      String createdByToken, String postId, String type) {
    // type is Stitch or Routine
    var dataPayload = jsonEncode({
      'to': createdByToken,
      'data': {
        "type": "savePostToStitchRoutine",
        "postId": postId,
        "priority": "high",
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "sound": "default",
        'userId': globalUserId,
        'userName': globalUserName,
        'userImage': globaUserProfileImage,
        'image': globaUserProfileImage
      },
      'notification': {
        'title': 'Your post is saved to a ' + type,
        'body': '$globalUserName just saved your post to ' + type,
        'image': globaUserProfileImage,
        "badge": "1",
        "sound": "default"
      },
    });

    ApiCall.sendPushMessage(createdByToken, dataPayload);
  }

  @override
  void onOkClick(int code) {
    deletePost();
  }

// Delete Card
  void deletePost() {
    FirebaseFirestore.instance
        .collection(Constants.posts)
        .doc(widget.selectedItem.postId)
        .delete();
    setState(() {});
  }
}
