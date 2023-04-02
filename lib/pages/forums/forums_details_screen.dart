import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:solstice/apiservice/api_call.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/forum_model.dart';
import 'package:solstice/pages/profile/other_user_profile.dart';
import 'package:solstice/pages/search_location.dart';
import 'package:solstice/pages/views/forum_comments_fb_item.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/shared_preferences.dart';
import 'package:solstice/utils/size_utils.dart';

class ForumsDetailsScreen extends StatefulWidget {
  final String forumIdIntent;

  const ForumsDetailsScreen({Key key, @required this.forumIdIntent})
      : super(key: key);

  @override
  _ForumsDetailsScreenState createState() => _ForumsDetailsScreenState();
}

class _ForumsDetailsScreenState extends State<ForumsDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  ForumFireBaseModel _forumDetailItem = new ForumFireBaseModel();
  int forumLikesCount = 0;
  int forumCommentsCount = 0;
  bool isForumLiked = false;
  String userIDPref = "";
  String userNamePref = "";
  String userImagePref = "";
  String forumUserImage = "";
  String forumUserName = "";
  String forumIdIntent = "";
  UserFirebaseModel forumCreatedUserItem;
  TextEditingController commentEtController = new TextEditingController();
  FocusNode _commentEtFocus = new FocusNode();
  bool isShowEmojiPicker = false;
  final ScrollController listScrollController = ScrollController();
  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  int _limit = 10;
  int _limitIncrement = 10;
  bool _isForumCreatedByMe = false;
  TextEditingController formTitleController = new TextEditingController();
  TextEditingController formDescriptionController = new TextEditingController();
  final FocusNode _formTitleFocus = new FocusNode();
  final FocusNode _formDescriptionFocus = new FocusNode();
  String _currentAddress = "",
      _currentLatitude = "",
      _currentLongitude = "",
      _postCreatedTimeStamp = "",
      commentWantToSend = "",
      createdByToken = "";

  @override
  void initState() {
    super.initState();
    listScrollController.addListener(_scrollListener);
    _commentEtFocus.addListener(_commentEtListner);

    // get data from previous page
    setIntentData();

    // get user data from local storage(SharedPref)
    getPrefData();

    // get user data from firestore
  }

  // get data from previous page
  setIntentData() {
    forumIdIntent = widget.forumIdIntent;
    userIDPref = globalUserId;
    getForumDetail(forumIdIntent);

    if (mounted) {
      setState(() {});
    }
  }

  // get user data from local storage(SharedPref)
  getPrefData() {
    Future<String> userId = SharedPref.getStringFromPrefs(Constants.USER_ID);
    userId.then(
        (value) => {
              userIDPref = value,
            }, onError: (err) {
    });

    Future<String> userName =
        SharedPref.getStringFromPrefs(Constants.USER_NAME);
    userName.then(
        (value) => {
              userNamePref = value,
            },
        onError: (err) {});
    Future<String> userImage =
        SharedPref.getStringFromPrefs(Constants.PROFILE_IMAGE);
    userImage.then(
        (value) => {
              userImagePref = value,
            },
        onError: (err) {});

    if (mounted) setState(() {});
  }

  // initilize Scroll listner
  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void _commentEtListner() {
    setState(() {
      if (_commentEtFocus.hasFocus) {
        // keyboard appeared
        isShowEmojiPicker = false;
      } else {
        // keyboard dismissed
      }
    });
  }

  //load data from firestore
  Future<void> loadUser(String createdBy) async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(createdBy)
        .get();
    if (ds != null) {
      forumCreatedUserItem = UserFirebaseModel.fromSnapshot(ds);
      Map<String, dynamic> mapObject = ds.data();
      forumUserImage = forumCreatedUserItem.userImage;
      forumUserName = forumCreatedUserItem.userName;

      if (mapObject.containsKey("token")) {
        createdByToken = ds['token'];
      }
      if (mounted) setState(() {});
    }
  }

  // like unlike forum post and store to firestore
  void likeUnLikeForum(
      ForumFireBaseModel forumModel, bool isLiked, String forumId) {
    if (!isLiked) {
      FirebaseFirestore.instance
          .collection(Constants.ForumsLikesFB)
          .doc(Constants.ForumsLikesFB)
          .collection(forumId)
          .doc(userIDPref)
          .set({
            "likedBy": userIDPref,
          })
          .then((docRef) {
          })
          .timeout(Duration(seconds: 10))
          .catchError((error) {
          });

      try {
        if (_forumDetailItem.createdBy != globalUserId) {
          sendNotificationToLikeAndComment(
              createdByToken, _forumDetailItem.id, "Like");
        }
      } catch (e) {}
    } else {
      FirebaseFirestore.instance
          .collection(Constants.ForumsLikesFB)
          .doc(Constants.ForumsLikesFB)
          .collection(forumId)
          .doc(userIDPref)
          .delete();
    }
  }

  void sendNotificationToLikeAndComment(
      String createdByToken, String forumId, String type) {
    var dataPayload = jsonEncode({
      'to': createdByToken,
      'data': {
        "type": type == "Like" ? "likeForum" : "commentForum",
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
        'title': type == "Like"
            ? 'Your forum is Liked'
            : 'New comment on your forum',
        'body': type == "Like"
            ? '$globalUserName liked your forum'
            : '$globalUserName commented in your forum (' +
                commentWantToSend +
                ')',
        'image': globaUserProfileImage,
        "badge": "1",
        "sound": "default"
      },
    });

    ApiCall.sendPushMessage(createdByToken, dataPayload);
  }

  // get Forum detail
  Future<String> getForumDetail(String forumId) async {
    FirebaseFirestore.instance
        .collection(Constants.ForumsFB)
        .doc(forumId)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      if (mounted) {
        setState(() {
          if (documentSnapshot.exists)
            _forumDetailItem =
                ForumFireBaseModel.fromSnapshot(documentSnapshot);

          if (_forumDetailItem != null) {
            _isForumCreatedByMe =
                (userIDPref == _forumDetailItem.createdBy) ? true : false;
            loadUser(_forumDetailItem.createdBy);
            _postCreatedTimeStamp = _forumDetailItem.timestamp;
            _currentAddress = _forumDetailItem.postAddress;
            // formTitleController.text = _forumDetailItem.title;
            formDescriptionController.text = _forumDetailItem.description;
            _currentLatitude = _forumDetailItem.postLatitude;
            _currentLongitude = _forumDetailItem.postLongitude;
          }
        });
      }
    }).onError((e) => print(e));

    // get comments count

    var commentsCountSnapshot = await FirebaseFirestore.instance
        .collection(Constants.ForumsCommentsFB)
        .doc(forumId)
        .collection(forumId)
        .snapshots();
    commentsCountSnapshot.listen((querySnapshot) {
      forumCommentsCount = querySnapshot.docs.length;
      if (mounted) {
        setState(() {});
      }
    });

    // likes count

    var snapshots = await FirebaseFirestore.instance
        .collection(Constants.ForumsLikesFB)
        .doc(Constants.ForumsLikesFB)
        .collection(forumId)
        .snapshots();
    snapshots.listen((querySnapshot) {
      forumLikesCount = querySnapshot.docs.length;
      if (mounted) {
        setState(() {});
      }
    });

    // check forum is liked or not
    var isForumLikedSnapshot = await FirebaseFirestore.instance
        .collection(Constants.ForumsLikesFB)
        .doc(Constants.ForumsLikesFB)
        .collection(forumId)
        .where("likedBy", isEqualTo: userIDPref)
        .snapshots();


    isForumLikedSnapshot.listen((querySnapshot) {
      isForumLiked = querySnapshot.docs.length > 0 ? true : false;

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
      key: _scaffoldkey,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.white),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).padding.top,
              ),
              Expanded(
                flex: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.all(ScreenUtil().setSp(16)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                            width: 22,
                            height: 22,
                            padding: EdgeInsets.all(2.5),
                            margin: EdgeInsets.only(left: 10, right: 18),
                            child: SvgPicture.asset(
                              'assets/images/ic_back.svg',
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                            )),
                      ),
                      InkWell(
                        onTap: () {
                          if (globalUserId != forumCreatedUserItem.userId) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtherUserProfile(
                                    userID: forumCreatedUserItem.userId,
                                    userName: forumUserName,
                                    userImage: forumUserImage,
                                  ),
                                ));
                          }
                        },
                        child: Container(
                            child: (forumUserImage != null &&
                                    forumUserImage != "null" &&
                                    forumUserImage != "")
                                ? setUserImage(forumUserImage)
                                : _forumDetailItem != null &&
                                        _forumDetailItem.createdByImage != null
                                    ? setUserImage(
                                        _forumDetailItem.createdByImage)
                                    : setUserDefaultCircularImage()),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtherUserProfile(
                                    userID: forumCreatedUserItem.userId,
                                    userName: forumUserName,
                                    userImage: forumUserImage,
                                  ),
                                ));
                          },
                          child: Container(
                            margin: EdgeInsets.all(ScreenUtil().setSp(20)),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    forumUserName != null && forumUserName != ""
                                        ? " " + forumUserName.toString()
                                        : _forumDetailItem != null &&
                                                _forumDetailItem
                                                        .createdByName !=
                                                    null
                                            ? " " +
                                                _forumDetailItem.createdByName
                                                    .toString()
                                            : "",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: AppColors.titleTextColor,
                                        fontFamily: Constants.boldFont,
                                        fontSize: ScreenUtil().setSp(28)),
                                  ),
                                  SizedBox(height: 3),
                                  if (_forumDetailItem != null)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                            width: 15,
                                            height: 15,
                                            child: SvgPicture.asset(
                                              'assets/images/ic_marker.svg',
                                              alignment: Alignment.center,
                                              fit: BoxFit.contain,
                                              color: AppColors.accentColor,
                                            )),
                                        SizedBox(width: 3),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            _forumDetailItem.postAddress
                                                .toString(),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: AppColors.accentColor,
                                                fontFamily:
                                                    Constants.regularFont,
                                                fontSize:
                                                    ScreenUtil().setSp(22)),
                                          ),
                                        ),
                                      ],
                                    ),
                                ]),
                          ),
                        ),
                      ),
                      if (_isForumCreatedByMe)
                        Container(
                            child: PopupMenuButton<int>(
                          onSelected: (int value) {
                            setState(() {
                              //_selection = value;
                              if (value == 1) {
                                // _groupMenusClick(widget.groupIntent.id);
                                _updateForumBottomSheet(context);
                              }
                              if (value == 2) {
                                ConfirmDeleteDialog(
                                    Constants.deleteForumConfirmTitle,
                                    Constants.deleteForumConfirmDes);
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
                            PopupMenuItem(
                              value: 1,
                              child: Text(
                                Constants.updateForum,
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(28),
                                    fontFamily: Constants.regularFont,
                                    color: Colors.black),
                              ),
                            ),
                            PopupMenuItem(
                              value: 2,
                              child: Text(
                                Constants.deleteForum,
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(28),
                                    fontFamily: Constants.regularFont,
                                    color: AppColors.redColor),
                              ),
                            ),
                          ],
                        )),
                    ],
                  ),
                ),
              ),
              Flexible(
                  child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(Constants.ForumsCommentsFB)
                    .doc(forumIdIntent)
                    .collection(forumIdIntent)
                    .orderBy('timestamp', descending: true)
                    .limit(_limit)
                    .snapshots(),
                builder: (context, snapshot) {
                  return ListView(
                    padding: EdgeInsets.zero,
                    controller: listScrollController,
                    children: <Widget>[
                      forumView(),
                      (!snapshot.hasData)
                          ? Container(
                              margin: EdgeInsets.only(top: 160),
                              child: Center(
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primaryColor)),
                              ),
                            )
                          : /*MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: ListView.builder(
                                  reverse: false,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index) {
                                    List rev = snapshot.data.docs.toList();
                                    ForumCommentsFireBaseModel commentItem = ForumCommentsFireBaseModel.fromSnapshot(rev[index]);
                                    return InkWell(onTap: (){

                                    },child: ForumCommentsItem(key: ValueKey(commentItem.id),forumCommentItem : commentItem,appUserId : userIDPref));
                                  },
                                  itemCount: snapshot.data.docs.length,
                                  //controller: listScrollController,
                                ),
                              ),*/

                          snapshot.data.docs.isNotEmpty
                              ? MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  child: ListView.builder(
                                    reverse: false,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    itemBuilder: (context, index) {
                                      List rev = snapshot.data.docs.toList();
                                      ForumCommentsFireBaseModel commentItem =
                                          ForumCommentsFireBaseModel
                                              .fromSnapshot(rev[index]);
                                      return InkWell(
                                          onTap: () {},
                                          child: ForumCommentsItem(
                                              key: ValueKey(commentItem.id),
                                              forumCommentItem: commentItem,
                                              appUserId: userIDPref,
                                              forumId: forumIdIntent));
                                    },
                                    itemCount: snapshot.data.docs.length,
                                    //controller: listScrollController,
                                  ),
                                )
                              : Center(
                                  child: Container(
                                    margin: EdgeInsets.only(top: 150),
                                    child: Center(
                                      child: Column(
                                        children: <Widget>[
                                          Image.asset(
                                            'assets/images/ic_chat_unactive.png',
                                            width: ScreenUtil().setSp(100),
                                            height: ScreenUtil().setSp(100),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            Constants.noCommentFound.toString(),
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(26),
                                                color: AppColors.accentColor,
                                                fontFamily:
                                                    Constants.regularFont,
                                                height: 1.3,
                                                letterSpacing: 0.8),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                    ],
                  );
                },
              )),
              Expanded(
                flex: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(
                      left: ScreenUtil().setSp(16),
                      right: ScreenUtil().setSp(16),
                      top: ScreenUtil().setSp(10),
                      bottom: ScreenUtil().setSp(10)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        offset: Offset(1.0, 0.0), //(x,y)
                        blurRadius: 5.0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(width: ScreenUtil().setSp(20)),
                          Expanded(
                            flex: 1,
                            child: Container(
                              constraints: BoxConstraints(maxHeight: 200),
                              child: TextFormField(
                                maxLength: 1200,
                                focusNode: _commentEtFocus,
                                cursorColor: AppColors.primaryColor,
                                controller: commentEtController,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                decoration: InputDecoration(
                                  counterText: "",
                                  hintText: Constants.addAComment,
                                  hintStyle: TextStyle(
                                      color: AppColors.accentColor,
                                      fontFamily: Constants.mediumFont,
                                      fontSize: ScreenUtil().setSp(24)),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          /*InkWell(
                            onTap: () {
                              setState(() {
                                //isShowEmojiPicker = isShowEmojiPicker == true ? isShowEmojiPicker = false : isShowEmojiPicker = true;

                                //if(isShowEmojiPicker){
                                  //FocusScope.of(context).unfocus();
                                //}
                              });
                            },
                            child: Container(
                              width: 22,
                              height: 22,
                              padding: EdgeInsets.all(1.0),
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: SvgPicture.asset(
                                isShowEmojiPicker
                                    ? 'assets/images/ic_send.svg'
                                    : 'assets/images/ic_emoji.svg',
                                alignment: Alignment.center,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),*/
                          InkWell(
                            onTap: () {
                              var comment =
                                  commentEtController.value.text.trim();
                              if (comment.isEmpty) {
                                Constants().errorToast(
                                    context, Constants.enterCommentError);
                              } else {
                                addForumCommentToDb(comment);
                              }

                              if (mounted) {
                                setState(() {});
                              }
                            },
                            child: Container(
                              width: 22,
                              height: 22,
                              padding: EdgeInsets.all(1.0),
                              margin: EdgeInsets.only(right: 10, left: 10),
                              child: SvgPicture.asset(
                                'assets/images/ic_send.svg',
                                alignment: Alignment.center,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isShowEmojiPicker)
                        Column(
                          children: <Widget>[
                            Container(
                              height: 1.0,
                              color: AppColors.viewLineColor,
                            ),
                            EmojiPicker(
                              bgColor: Colors.white,
                              rows: 4,
                              columns: 7,
                              recommendKeywords: ["racing", "horse"],
                              numRecommended: 10,
                              onEmojiSelected: (emoji, category) {
                                setState(() {
                                  String emoj = emoji.emoji;
                                  //commentEtController.text = commentEtController.value.text.toString()+emoji.emoji;
                                });

                              },
                            ),
                          ],
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // add forum comment to firestore db
  void addForumCommentToDb(String commentTxt) {
    //_isShowLoader = true;
    FocusScope.of(context).unfocus();
    commentEtController.text = "";
    commentWantToSend = commentTxt;

    Constants.showSnackBarWithMessage(
        "Comment sending...", _scaffoldkey, context, AppColors.primaryColor);
    FirebaseFirestore.instance
        .collection(Constants.ForumsCommentsFB)
        .doc(forumIdIntent)
        .collection(forumIdIntent)
        .add({
          "comment": commentTxt,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'commentBy': userIDPref,
          'createdByName': userNamePref,
          'createdByImage': userImagePref,
        })
        .then((docRef) {
          Constants.showSnackBarWithMessage("Comment sent successfully!",
              _scaffoldkey, context, AppColors.greenColor);

          try {
            if (_forumDetailItem.createdBy != globalUserId) {
              sendNotificationToLikeAndComment(
                  createdByToken, _forumDetailItem.id, "Comment");
            }
          } catch (e) {}
          /*setState(() {
        _isShowLoader = false;
      });*/
        })
        .timeout(Duration(seconds: 10))
        .catchError((error) {
          /* setState(() {
        _isShowLoader = false;
      });*/
        });
  }

  // set user default placeholder
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

  // forum detail view ui
  Widget forumView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (_forumDetailItem != null)
          Container(
            margin: EdgeInsets.only(
                right: ScreenUtil().setSp(20),
                left: ScreenUtil().setSp(20),
                top: ScreenUtil().setSp(12)),
            child: Text(
              _forumDetailItem.description.toString(),
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  fontFamily: Constants.regularFont,
                  height: 1.45),
            ),
          ),
        SizedBox(
          height: ScreenUtil().setSp(25),
        ),
        Container(
          margin: EdgeInsets.only(
              right: ScreenUtil().setSp(30),
              left: ScreenUtil().setSp(30),
              bottom: ScreenUtil().setSp(36)),
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
                            forumCommentsCount.toString()),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: AppColors.titleTextColor,
                            fontFamily: Constants.mediumFont,
                            fontSize: ScreenUtil().setSp(24)),
                      ),
                      SizedBox(width: 3),
                      Text(
                        forumCommentsCount > 1
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
                  ),
                ),
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
                        forumLikesCount > 1 ? Constants.likes : Constants.like,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: AppColors.titleTextColor,
                            fontFamily: Constants.lightFont,
                            fontSize: ScreenUtil().setSp(24)),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  setState(() {
                    likeUnLikeForum(
                        _forumDetailItem, isForumLiked, _forumDetailItem.id);
                  });
                },
              ),
              Expanded(flex: 1, child: Container()),
            ],
          ),
        ),
        Container(
          height: 1.0,
          color: AppColors.viewLineColor,
        ),
      ],
    );
  }

  // update forum bottom sheet
  void _updateForumBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Wrap(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(left: 20, right: 20),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(
                              top: ScreenUtil().setSp(25),
                              bottom: ScreenUtil().setSp(15)),
                          height: ScreenUtil().setSp(45),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                padding: EdgeInsets.all(2.5),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  Constants.updateForum,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: AppColors.titleTextColor,
                                      fontFamily: Constants.boldFont,
                                      fontSize: ScreenUtil().setSp(28)),
                                ),
                              ),
                              RotationTransition(
                                turns: new AlwaysStoppedAnimation(45 / 360),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    padding: EdgeInsets.all(2.5),
                                    child: SvgPicture.asset(
                                      'assets/images/ic_plus.svg',
                                      alignment: Alignment.center,
                                      color: AppColors.darkRedColor,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: ScreenUtil().setSp(32)),
                        SizedBox(height: 10),
                        /*TextFormField(
                          maxLength: 200,
                          focusNode: _formTitleFocus,
                          cursorColor: AppColors.primaryColor,
                          controller: formTitleController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (v) {
                            FocusScope.of(context)
                                .requestFocus(_formDescriptionFocus);
                          },
                          onChanged: (v) {},
                          decoration: InputDecoration(
                            counterText: "",
                            labelText: 'Name',
                            labelStyle: TextStyle(
                                color: AppColors.accentColor,
                                fontFamily: Constants.semiBoldFont,
                                fontSize: ScreenUtil().setSp(24)),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          alignment: Alignment.topRight,
                          margin: const EdgeInsets.only(
                              top: 4.0, left: 30.0, bottom: 3),
                          child: Text(
                            '',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.red,
                                fontFamily: Constants.mediumFont),
                          ),
                        ),*/
                        TextFormField(
                          maxLength: 2000,
                          focusNode: _formDescriptionFocus,
                          cursorColor: AppColors.primaryColor,
                          controller: formDescriptionController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          onChanged: (v) {},
                          decoration: InputDecoration(
                            counterText: "",
                            labelText: "Describe your forum",
                            labelStyle: TextStyle(
                                color: AppColors.accentColor,
                                fontFamily: Constants.semiBoldFont,
                                fontSize: ScreenUtil().setSp(24)),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          alignment: Alignment.topRight,
                          margin: const EdgeInsets.only(
                              top: 4.0, left: 30.0, bottom: 16),
                          child: Text(
                            "",
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.red,
                                fontFamily: Constants.mediumFont),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          Constants.locationOptional,
                          style: TextStyle(
                              color: AppColors.accentColor,
                              fontFamily: Constants.semiBoldFont,
                              fontSize: ScreenUtil().setSp(24)),
                        ),
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            setState(() {
                              selectLocation();
                            });
                          },
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  (_currentAddress != null &&
                                          _currentAddress != "")
                                      ? _currentAddress
                                      : Constants.selectLocation,
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(28),
                                      color: (_currentAddress != null &&
                                              _currentAddress != "")
                                          ? Colors.black
                                          : AppColors.accentColor,
                                      fontFamily: Constants.mediumFont),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.accentColor,
                                // size: Dimens.iconSize06(),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 1.0,
                          color: AppColors.accentColor,
                        ),
                        SizedBox(height: 8),
                        Container(
                          color: Colors.transparent,
                          margin: EdgeInsets.only(top: 12),
                          width: MediaQuery.of(context).size.width,
                          height: ScreenUtil().setSp(100),
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40.0),
                            ),
                            onPressed: () {
                              //var title = formTitleController.value.text.trim();
                              var title = "";
                              var description =
                                  formDescriptionController.value.text.trim();
                              /*if (title.isEmpty) {
                                Constants().errorToast(
                                    context, Constants.enterNameError);
                              } else */
                              if (description.isEmpty) {
                                Constants().errorToast(
                                    context, Constants.enterDescriptionError);
                              } else /*if (title.length < 4) {
                                Constants().errorToast(
                                    context, Constants.nameMust4Characters);
                              } else*/
                              if (description.length < 4) {
                                Constants().errorToast(
                                    context, Constants.gDesMust4Characters);
                              } else {
                                Navigator.of(context).pop();
                                updateForumToDb(title, description);
                              }

                              if (mounted) {
                                setState(() {});
                              }
                            },
                            color: AppColors.primaryColor,
                            textColor: Colors.white,
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              Constants.continueTxt,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(28),
                                fontFamily: Constants.semiBoldFont,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                ],
              )),
        );
      },
    );
  }

  // select location from location selection screen
  Future selectLocation() async {
    Map results = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return SearchLocation();
    }));

    if (results != null && results.containsKey('update')) {
      var _isUpdate = "";

      setState(() {
        _isUpdate = results['update'];
        if (_isUpdate == "yes") {
          try {
            SearchedLocationModel searchedLocationModel = results['returnData'];
            if (searchedLocationModel != null) {
              _currentAddress = searchedLocationModel.title;
              _currentLatitude = searchedLocationModel.latitude.toString();
              _currentLongitude = searchedLocationModel.longitude.toString();
            }
          } catch (e) {
          }
        }
      });
    }
  }

  // delete forum confirmation dialog
  void ConfirmDeleteDialog(String title, String message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            child: Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 30),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: AppColors.viewLineColor)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        margin: EdgeInsets.only(top: 62, right: 30, left: 30),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: Constants.mediumFont,
                              fontSize: ScreenUtil().setSp(36)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 12, right: 30, left: 30),
                        alignment: Alignment.center,
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.blackColor[100],
                              fontFamily: Constants.regularFont,
                              fontSize: ScreenUtil().setSp(28)),
                        ),
                      ),
                      SizedBox(
                        height: 100.0,
                        width: 200,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                                child: GestureDetector(
                              onTap: () {
                                // Navigator.pop(context, true);
                              },
                              child: Container(
                                color: Colors.transparent,
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: 42,
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(
                                          color: AppColors.redColor)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    // Navigator.pop(context);
                                  },
                                  color: AppColors.redColor,
                                  textColor: Colors.white,
                                  padding: EdgeInsets.all(4.0),
                                  child: Text("No",
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontFamily: 'rubikregular')),
                                ),
                              ),
                            )),
                            SizedBox(
                              width: 40,
                            ),
                            Expanded(
                                child: GestureDetector(
                              onTap: () {
                                // Navigator.pop(context, true);
                              },
                              child: Container(
                                color: Colors.transparent,
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: 42,
                                child: FlatButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(
                                          color: AppColors.redColor)),
                                  color: Colors.white,
                                  textColor: AppColors.redColor,
                                  padding: EdgeInsets.all(4.0),
                                  onPressed: () {
                                    Navigator.of(context).pop();

                                    deleteForumFromDb();
                                  },
                                  child: Text(
                                    "Yes",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: 'rubikregular',
                                    ),
                                  ),
                                ),
                              ),
                            )),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.topCenter,
                  height: 100,
                  child: Container(
                    alignment: Alignment.center,
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: new Image.asset(
                      'assets/images/ic_question_green.png',
                      width: 45.0,
                      color: AppColors.redColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  // delete forum from db process
  void deleteForumFromDb() {
    FirebaseFirestore.instance
        .collection(Constants.ForumsFB)
        .doc(forumIdIntent)
        .delete()
        .then((docRef) {
          Constants.showSnackBarWithMessage("Forum deleted successfully!",
              _scaffoldkey, context, AppColors.greenColor);
          Navigator.of(context).pop();

          /*setState(() {
        _isShowLoader = false;
      });*/
        })
        .timeout(Duration(seconds: 10))
        .catchError((error) {
          /* setState(() {
        _isShowLoader = false;
      });*/
        });
  }

  // update forum to db process
  void updateForumToDb(String title, String description) {
    //_isShowLoader = true;
    formTitleController.text = "";
    formDescriptionController.text = "";
    Constants.showSnackBarWithMessage(
        "Forum updating...", _scaffoldkey, context, AppColors.primaryColor);

    FirebaseFirestore.instance
        .collection(Constants.ForumsFB)
        .doc(forumIdIntent)
        .update({
          "title": title,
          "description": description,
          "postLatitude": _currentLatitude.toString(),
          "postLongitude": _currentLongitude.toString(),
          "postAddress": _currentAddress.toString(),
          'timestamp': _postCreatedTimeStamp.toString(),
          'createdBy': userIDPref,
          'createdByName': userNamePref,
          'createdByImage': userImagePref,
        })
        .then((docRef) {
          Constants.showSnackBarWithMessage("Forum updated successfully!",
              _scaffoldkey, context, AppColors.greenColor);
          /*setState(() {
        _isShowLoader = false;
      });*/
        })
        .timeout(Duration(seconds: 10))
        .catchError((error) {
          /* setState(() {
        _isShowLoader = false;
      });*/
        });
  }

  // set user default image
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
