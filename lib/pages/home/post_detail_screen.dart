import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solstice/apiservice/api_call.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/Posts/post_comments_model.dart';
import 'package:solstice/model/cards_fb_model.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/model/commments_model.dart';
import 'package:solstice/model/forum_model.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/model/recent_posts_model.dart';
import 'package:solstice/pages/chat/full_image_screen.dart';
import 'package:solstice/pages/home/play_video.dart';
import 'package:solstice/pages/home/post_filter.dart';
import 'package:solstice/pages/home/post_filter_new.dart';
import 'package:solstice/pages/home/save_to_routine.dart';
import 'package:solstice/pages/profile/other_user_profile.dart';
import 'package:solstice/pages/profile/profile_tab_screen.dart';
import 'package:solstice/pages/views/forum_list_fb_item.dart';
import 'package:solstice/pages/views/post_cards_list_item.dart';
import 'package:solstice/pages/views/post_comments_fb_item.dart';
import 'package:solstice/pages/views/post_comments_list_item.dart';
import 'package:solstice/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/utils/shared_preferences.dart';

import '../../model/post_model.dart';
import 'save_to_stitch.dart';

class PostDetailScreen extends StatefulWidget {
  final String postIdIntent;

  const PostDetailScreen({Key key, @required this.postIdIntent})
      : super(key: key);

  @override
  PostDetailScreenState createState() {
    return PostDetailScreenState();
  }
}

class PostDetailScreenState extends State<PostDetailScreen>
    with TickerProviderStateMixin {
  String pinCode = "";
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  bool isBtnEnable = false;

  PostFeedModel postFeedModel = new PostFeedModel();
  int imagePageIndex = 0;
  UserFirebaseModel postCreatedUserItem;
  UserFirebaseModel myUserItem;
  String postUserImage = "";
  String postUserName = "";

  String userIDPref = "";
  String userNamePref = "";
  String userImagePref = "";

  List<CommentsModel> commentsList = new List<CommentsModel>();
  bool isShowCards = true;
  var imageFile = null;
  PageController pageController = new PageController();

  TextEditingController commentEtController = new TextEditingController();
  FocusNode _commentEtFocus = new FocusNode();

  final ScrollController listScrollController = ScrollController();
  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  int _limit = 10;
  int _limitIncrement = 10;

  bool isPostLiked = false;
  String stichId = "", routineId = "";
  bool isShowCommentsSheet = false;
  AnimationController sliderCommentsController;
  Animation<Offset> offsetCommentsSheet;
  bool isShowCommentBottomSheetOpacity = false;

  String commentWantToSend = "";

  TextEditingController cardNameTextController = new TextEditingController();
  TextEditingController cardDescriptionTextController =
      new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listScrollController.addListener(_scrollListener);
    sliderCommentsController =
        AnimationController(duration: Duration(milliseconds: 350), vsync: this);
    offsetCommentsSheet =
        Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1.0))
            .animate(sliderCommentsController);

    getPrefData();
  }

  Future<bool> _onBackPressed() async {
    if (isShowCommentsSheet) {
      isShowCommentsSheet = false;
      isShowCommentBottomSheetOpacity = false;
      sliderCommentsController.forward();
    } else {
      Navigator.pop(context);
    }

    if (mounted) setState(() {});
  }

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  getPrefData() {
    Future<String> userId = SharedPref.getStringFromPrefs(Constants.USER_ID);
    userId.then(
        (value) => {
              userIDPref = value,
              getPostDetail(widget.postIdIntent),
              loadMyUser(userIDPref)
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

  Future<String> getPostDetail(String postId) async {
    FirebaseFirestore.instance
        .collection(Constants.posts)
        .doc(postId)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      if (mounted) {
        setState(() {
          if (documentSnapshot.exists) {
            postFeedModel = PostFeedModel.fromSnapshot(documentSnapshot);

            if (postFeedModel != null) {
              saveRecentsData();

              loadUser(postFeedModel.createdBy);
            }
          } else {
            Navigator.of(context).pop({'update': "yes"});
          }
        });
      }
    }).onError((e) => print(e));

    var isLikedSnapShot = await FirebaseFirestore.instance
        .collection(Constants.PostLikesFB)
        .doc(Constants.PostLikesFB)
        .collection(widget.postIdIntent)
        .where("liked_by", isEqualTo: userIDPref)
        .snapshots();

    isLikedSnapShot.listen((querySnapshot) {
      isPostLiked = querySnapshot.docs.length > 0 ? true : false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> loadMyUser(String userID) async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(userID)
        .get();
    if (ds != null) {
      try {
        myUserItem = UserFirebaseModel.fromSnapshot(ds);

        userImagePref = myUserItem.userImage;
        userNamePref = myUserItem.userName;
        if (mounted) setState(() {});
      } catch (e) {}
    }
  }

  Future<void> loadUser(String createdBy) async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(createdBy)
        .get();
    if (ds != null) {
      try {
        postCreatedUserItem = UserFirebaseModel.fromSnapshot(ds);

        postUserImage = postCreatedUserItem.userImage;
        postUserName = postCreatedUserItem.userName;
        if (mounted) setState(() {});
      } catch (e) {}
    }
  }

  void commentsBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(child: StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(
                            top: ScreenUtil().setSp(50),
                            bottom: ScreenUtil().setSp(15)),
                        height: ScreenUtil().setSp(45),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    Constants.comments,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: AppColors.titleTextColor,
                                        fontFamily: Constants.boldFont,
                                        fontSize: ScreenUtil().setSp(28)),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  if (postFeedModel != null)
                                    Text(
                                      Constants.changeToFormatedNumber(
                                          postFeedModel.commentCount
                                              .toString()),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: AppColors.accentColor,
                                          fontFamily: Constants.mediumFont,
                                          fontSize: ScreenUtil().setSp(28)),
                                    ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  Navigator.of(context).pop();
                                });
                              },
                              child: Container(
                                width: 24,
                                height: 24,
                                padding: EdgeInsets.all(1.5),
                                child: SvgPicture.asset(
                                  Constants.crossIcon,
                                  alignment: Alignment.center,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setSp(12)),
                      Container(
                        height: 1.0,
                        color: AppColors.viewLineColor,
                      ),
                      SizedBox(height: ScreenUtil().setSp(12)),
                      Flexible(
                          child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection(Constants.PostCommentsFB)
                            .where("post_id", isEqualTo: widget.postIdIntent)
                            .orderBy('timestamp', descending: true)
                            .limit(_limit)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryColor)),
                            );
                          } else {
                            listMessage.clear();
                            listMessage.addAll(snapshot.data.docs);
                            //updateChatCount();
                            return snapshot.data.docs.isNotEmpty
                                ? ListView(
                                    padding: EdgeInsets.zero,
                                    controller: listScrollController,
                                    children: <Widget>[
                                      MediaQuery.removePadding(
                                        context: context,
                                        removeTop: true,
                                        child: ListView.builder(
                                          reverse: false,
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.vertical,
                                          itemBuilder: (context, index) {
                                            List rev =
                                                snapshot.data.docs.toList();
                                            PostCommentsFireBaseModel
                                                postCommentItem =
                                                PostCommentsFireBaseModel
                                                    .fromSnapshot(rev[index]);
                                            return InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    //_OnGoToForumDetail(message);
                                                  });
                                                },
                                                child: PostCommentsFbItem(
                                                    key: ValueKey(
                                                        postCommentItem.id),
                                                    postCommentItem:
                                                        postCommentItem));
                                          },
                                          itemCount: snapshot.data.docs.length,
                                          //controller: listScrollController,
                                        ),
                                      ),
                                    ],
                                  )
                                : Center(
                                    child: Container(
                                      margin: EdgeInsets.only(top: 200),
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
                                              Constants.noCommentFound
                                                  .toString(),
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
                                  );
                          }
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
                                  CachedNetworkImage(
                                    imageUrl:
                                        (userImagePref.contains("https:") ||
                                                userImagePref.contains("http:"))
                                            ? userImagePref
                                            : UrlConstant.BaseUrlImg +
                                                userImagePref,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      width: ScreenUtil().setSp(70),
                                      height: ScreenUtil().setSp(70),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50.0)),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) =>
                                        setUserDefaultCircularImage(),
                                    errorWidget: (context, url, error) =>
                                        setUserDefaultCircularImage(),
                                  ),
                                  Container(width: ScreenUtil().setSp(20)),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      constraints:
                                          BoxConstraints(maxHeight: 200),
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
                                  InkWell(
                                    onTap: () {
                                      var comment =
                                          commentEtController.value.text.trim();
                                      if (comment.isEmpty) {
                                        Constants().errorToast(context,
                                            Constants.enterCommentError);
                                      } else {
                                        addPostCommentToDb(comment);
                                      }

                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      padding: EdgeInsets.all(1.0),
                                      margin:
                                          EdgeInsets.only(right: 10, left: 10),
                                      child: SvgPicture.asset(
                                        'assets/images/ic_send.svg',
                                        alignment: Alignment.center,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ));
          },
        ));
      },
    );
  }

  void addPostCommentToDb(String commentTxt) {
    //_isShowLoader = true;
    FocusScope.of(context).unfocus();
    commentEtController.text = "";
    commentWantToSend = commentTxt;
    //Constants.showSnackBarWithMessage("Comment sending...", _scaffoldkey,context, AppColors.primaryColor);
    FirebaseFirestore.instance
        .collection(Constants.PostCommentsFB)
        .add({
          "comment": commentTxt,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'post_id': widget.postIdIntent,
          'uid': userIDPref,
        })
        .then((docRef) {
          //Constants.showSnackBarWithMessage("Comment sent successfully!", _scaffoldkey,context, AppColors.greenColor);
          /*setState(() {
            _isShowLoader = false;
          });*/

          FirebaseFirestore.instance
              .collection(Constants.posts)
              .doc(widget.postIdIntent)
              .update({"counts.comments": FieldValue.increment(1)});

          getUserTokenFromPost(postFeedModel, "Comment");
        })
        .timeout(Duration(seconds: 10))
        .catchError((error) {
          /* setState(() {
            _isShowLoader = false;
          });*/
        });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: _scaffoldkey,
        body: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color: isShowCommentBottomSheetOpacity
                      ? Colors.black12
                      : Colors.white),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).padding.top,
                ),
                Expanded(
                  flex: 0,
                  child: InkWell(
                    onTap: () {
                      if (globalUserId != postCreatedUserItem.userId) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtherUserProfile(
                                userID: postCreatedUserItem.userId,
                                userName: postCreatedUserItem.userName,
                                userImage: postCreatedUserItem.userImage,
                              ),
                            ));
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.all(ScreenUtil().setSp(16)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              setState(() {
                                _onBackPressed();
                              });
                            },
                            child: Container(
                                width: 25,
                                height: 25,
                                padding: EdgeInsets.all(5),
                                margin: EdgeInsets.only(left: 10, right: 18),
                                child: SvgPicture.asset(
                                  'assets/images/ic_back.svg',
                                  alignment: Alignment.center,
                                  fit: BoxFit.contain,
                                )),
                          ),
                          CachedNetworkImage(
                            imageUrl: (postUserImage.contains("https:") ||
                                    postUserImage.contains("http:"))
                                ? postUserImage
                                : UrlConstant.BaseUrlImg + postUserImage,
                            imageBuilder: (context, imageProvider) => Container(
                              width: ScreenUtil().setSp(70),
                              height: ScreenUtil().setSp(70),
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
                            placeholder: (context, url) =>
                                setUserDefaultCircularImage(),
                            errorWidget: (context, url, error) =>
                                setUserDefaultCircularImage(),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin: EdgeInsets.all(ScreenUtil().setSp(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    postUserName != null &&
                                            postUserName != "null"
                                        ? " " + postUserName
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          width: 17,
                                          height: 17,
                                          child: SvgPicture.asset(
                                            'assets/images/ic_marker.svg',
                                            alignment: Alignment.center,
                                            fit: BoxFit.contain,
                                            color: AppColors.accentColor,
                                          )),
                                      SizedBox(width: 3),
                                      if (postFeedModel != null)
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            postFeedModel.location.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: AppColors.accentColor,
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    Constants.regularFont,
                                                fontSize:
                                                    ScreenUtil().setSp(22)),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PostFilterNew(
                                            postFeedModel: postFeedModel,
                                            editFields: false,
                                          )));
                            },
                            child: Container(
                                width: 20,
                                height: 20,
                                margin: EdgeInsets.only(left: 5, right: 18),
                                child: SvgPicture.asset(
                                  'assets/images/ic_filter.svg',
                                  alignment: Alignment.center,
                                  fit: BoxFit.fill,
                                  color: AppColors.accentColor,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                    child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(Constants.posts)
                      .doc(widget.postIdIntent)
                      .collection(Constants.cardsColl)
                      .orderBy('created_at', descending: false)
                      .limit(20)
                      .snapshots(),
                  builder: (context, snapshot) {
                    return ListView(
                      padding: EdgeInsets.zero,
                      //controller: listScrollController,
                      children: <Widget>[
                        if (postFeedModel != null) postView(),
                        (!snapshot.hasData)
                            ? Container(
                                margin: EdgeInsets.only(top: 160),
                                child: Center(
                                  child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.primaryColor)),
                                ),
                              )
                            : snapshot.data.docs.isNotEmpty
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
                                        CardsFbModel message =
                                            CardsFbModel.fromSnapshot(
                                                rev[index]);
                                        return InkWell(
                                            onTap: () {
                                              setState(() {
                                                cardNameTextController.text =
                                                    message.title;
                                                cardDescriptionTextController
                                                    .text = message.description;
                                                cardDetailBottomSheet(
                                                    message, context);
                                              });
                                            },
                                            child: PostCardsListItem(
                                              cardItem: message,
                                              createdBy:
                                                  postFeedModel.createdBy,
                                              postId: postFeedModel.postId,
                                              postFeedModel: postFeedModel,
                                            ));
                                      },
                                      itemCount: snapshot.data.docs.length,
                                    ),
                                  )
                                : Center(
                                    child: Container(
                                        // margin: EdgeInsets.only(top: 150),
                                        // child: Center(
                                        //   child: Column(
                                        //     children: <Widget>[
                                        //       Image.asset(
                                        //         'assets/images/ic_chat_unactive.png',
                                        //         width: ScreenUtil().setSp(100),
                                        //         height: ScreenUtil().setSp(100),
                                        //       ),
                                        //       SizedBox(
                                        //         height: 10,
                                        //       ),
                                        //       Text(
                                        //         Constants.noCommentFound
                                        //             .toString(),
                                        //         style: TextStyle(
                                        //             fontSize:
                                        //                 ScreenUtil().setSp(26),
                                        //             color: AppColors.accentColor,
                                        //             fontFamily:
                                        //                 Constants.regularFont,
                                        //             height: 1.3,
                                        //             letterSpacing: 0.8),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                        ),
                                  )
                      ],
                    );
                  },
                )),
              ],
            ),
            if (isShowCommentsSheet)
              Align(
                alignment: Alignment.bottomCenter,
                child: SlideTransition(
                  position: offsetCommentsSheet,
                  child: CommentsCustomBottomView(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void cardDetailBottomSheet(CardsFbModel cardModel, BuildContext context) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
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
                                      "Card Details",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: AppColors.titleTextColor,
                                          fontFamily: Constants.boldFont,
                                          fontSize: ScreenUtil().setSp(28)),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      padding: EdgeInsets.all(2.5),
                                      child: SvgPicture.asset(
                                        Constants.crossIcon,
                                        alignment: Alignment.center,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: ScreenUtil().setSp(32)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0.0, vertical: 9.0),
                              child: Text(
                                cardModel.mediaType == 1
                                    ? 'Card Photo'
                                    : 'Card Video',
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(24),
                                    fontFamily: Constants.regularFont,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (cardModel.mediaType == 2) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PlayVideo(
                                              videoUrl: cardModel.videoUrl)));
                                } else {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              fullImageScreenView(
                                                  messageFromName: "",
                                                  messageTime: "",
                                                  imageIntent:
                                                      cardModel.image)));
                                }
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 2.0, right: 8.0),
                                    child: CachedNetworkImage(
                                      imageUrl: (cardModel.image
                                                  .contains("https:") ||
                                              cardModel.image.contains("http:"))
                                          ? cardModel.image
                                          : UrlConstant.BaseUrlImg +
                                              cardModel.image,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        width: ScreenUtil().setSp(120),
                                        height: ScreenUtil().setSp(120),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12.0)),
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          setCardDefaultImage(context),
                                      errorWidget: (context, url, error) =>
                                          setCardDefaultImage(context),
                                    ),
                                  ),
                                  if (cardModel.mediaType == 2)
                                    Icon(Icons.play_circle_fill_outlined,
                                        color: Colors.white)
                                ],
                              ),
                            ),
                            lable('Name'),
                            TextFormField(
                              maxLength: 200,
                              cursorColor: AppColors.primaryColor,
                              controller: cardNameTextController,
                              keyboardType: TextInputType.text,
                              enabled: false,
                              textInputAction: TextInputAction.next,
                              maxLines: 1,
                              onChanged: (v) {},
                              decoration: InputDecoration(
                                counterText: "",
                              ),
                            ),
                            lable('Description'),
                            TextFormField(
                              maxLength: 2000,
                              cursorColor: AppColors.primaryColor,
                              controller: cardDescriptionTextController,
                              keyboardType: TextInputType.multiline,
                              maxLines: 5,
                              minLines: 1,
                              enabled: false,
                              onChanged: (v) {},
                              decoration: InputDecoration(
                                counterText: "",
                                // labelText: Constants.describeYourJourney,
                                // labelStyle: TextStyle(
                                //     color: AppColors.accentColor,
                                //     fontFamily: Constants.semiBoldFont,
                                //     fontSize: ScreenUtil().setSp(24)),
                                /* contentPadding:
                                        EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),*/
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget lable(String lable) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20,
        ),
        Container(
          child: Text(
            lable,
            style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                fontFamily: Constants.regularFont,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget CommentsCustomBottomView() {
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      child: Container(
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(
                  top: ScreenUtil().setSp(30), bottom: ScreenUtil().setSp(15)),
              height: ScreenUtil().setSp(45),
              alignment: Alignment.center,
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        Text(
                          Constants.comments,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.titleTextColor,
                              fontFamily: Constants.boldFont,
                              fontSize: ScreenUtil().setSp(28)),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        if (postFeedModel != null)
                          Text(
                            Constants.changeToFormatedNumber(
                                postFeedModel.commentCount.toString()),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.accentColor,
                                fontFamily: Constants.mediumFont,
                                fontSize: ScreenUtil().setSp(28)),
                          ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        //Navigator.of(context).pop();
                        _onBackPressed();
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      padding: EdgeInsets.all(1.5),
                      child: SvgPicture.asset(
                        Constants.crossIcon,
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),
            ),
            SizedBox(height: ScreenUtil().setSp(12)),
            Container(
              height: 1.0,
              color: AppColors.viewLineColor,
            ),
            Flexible(
                child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(Constants.PostCommentsFB)
                  .where("post_id", isEqualTo: widget.postIdIntent)
                  .orderBy('timestamp', descending: true)
                  .limit(_limit)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor)),
                  );
                } else {
                  listMessage.clear();
                  listMessage.addAll(snapshot.data.docs);
                  //updateChatCount();
                  return snapshot.data.docs.isNotEmpty
                      ? ListView(
                          padding: EdgeInsets.zero,
                          controller: listScrollController,
                          children: <Widget>[
                            MediaQuery.removePadding(
                              context: context,
                              removeTop: true,
                              child: ListView.builder(
                                reverse: false,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                itemBuilder: (context, index) {
                                  List rev = snapshot.data.docs.toList();
                                  PostCommentsFireBaseModel postCommentItem =
                                      PostCommentsFireBaseModel.fromSnapshot(
                                          rev[index]);
                                  return InkWell(
                                      onTap: () {
                                        setState(() {
                                          //_OnGoToForumDetail(message);
                                        });
                                      },
                                      child: PostCommentsFbItem(
                                          key: ValueKey(postCommentItem.id),
                                          postCommentItem: postCommentItem));
                                },
                                itemCount: snapshot.data.docs.length,
                                //controller: listScrollController,
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Container(
                            margin: EdgeInsets.only(top: 200),
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
                                        fontSize: ScreenUtil().setSp(26),
                                        color: AppColors.accentColor,
                                        fontFamily: Constants.regularFont,
                                        height: 1.3,
                                        letterSpacing: 0.8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                }
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
                        CachedNetworkImage(
                          imageUrl: (userImagePref.contains("https:") ||
                                  userImagePref.contains("http:"))
                              ? userImagePref
                              : UrlConstant.BaseUrlImg + userImagePref,
                          imageBuilder: (context, imageProvider) => Container(
                            width: ScreenUtil().setSp(70),
                            height: ScreenUtil().setSp(70),
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
                          placeholder: (context, url) =>
                              setUserDefaultCircularImage(),
                          errorWidget: (context, url, error) =>
                              setUserDefaultCircularImage(),
                        ),
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
                        InkWell(
                          onTap: () {
                            var comment = commentEtController.value.text.trim();
                            if (comment.isEmpty) {
                              Constants().errorToast(
                                  context, Constants.enterCommentError);
                            } else {
                              addPostCommentToDb(comment);
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget postView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(ScreenUtil().setSp(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          if (postFeedModel != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
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
                          itemCount: postFeedModel.mediaList != null
                              ? postFeedModel.mediaList.length
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
                              tag: 'homePageImage' + indexView.toString(),
                              child: InkWell(
                                onTap: () {
                                  if (postFeedModel
                                          .mediaList[indexView].mediaType ==
                                      "video") {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PlayVideo(
                                                  videoUrl: postFeedModel
                                                      .mediaList[indexView].url,
                                                )));
                                  }
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: postFeedModel
                                                  .mediaList[indexView]
                                                  .mediaType ==
                                              "Image"
                                          ? postFeedModel
                                              .mediaList[indexView].url
                                          : postFeedModel
                                              .mediaList[indexView].thumbnail,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        width:
                                            MediaQuery.of(context).size.width,
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
                                      visible: postFeedModel
                                              .mediaList[indexView].mediaType ==
                                          "video",
                                      maintainAnimation: true,
                                      maintainSize: false,
                                      maintainState: true,
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                    postFeedModel.mediaList != null
                        ? Positioned(
                            right: 10,
                            top: 0,
                            bottom: 0,
                            child: imagePageIndex <
                                    postFeedModel.mediaList.length - 1
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
                          )
                        : Container(),
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
                top: ScreenUtil().setSp(26),
                bottom: ScreenUtil().setSp(26),
                right: ScreenUtil().setSp(46),
                left: ScreenUtil().setSp(36)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  postFeedModel != null ? postFeedModel.title.toString() : "",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColors.titleTextColor,
                      fontFamily: Constants.boldFont,
                      fontWeight: FontWeight.w700,
                      fontSize: ScreenUtil().setSp(30)),
                ),
                SizedBox(height: 6),
                Text(
                  postFeedModel != null
                      ? postFeedModel.description.toString()
                      : "",
                  maxLines: 20,
                  style: TextStyle(
                      color: AppColors.titleTextColor,
                      height: 1.2,
                      fontFamily: Constants.regularFont,
                      fontWeight: FontWeight.w400,
                      fontSize: ScreenUtil().setSp(25)),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                right: ScreenUtil().setSp(20),
                left: ScreenUtil().setSp(20),
                bottom: ScreenUtil().setSp(20)),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      setState(() {
                        isShowCommentsSheet = true;
                        sliderCommentsController.reverse();

                        Future.delayed(const Duration(milliseconds: 250), () {
                          setState(() {
                            // Here you can write your code for open new view
                            isShowCommentBottomSheetOpacity = true;
                          });
                        });
                        //commentsBottomSheet(context);
                      });
                    });
                  },
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
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          Constants.changeToFormatedNumber(
                              postFeedModel.commentCount.toString()),
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
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      likeUnLikePost(
                          postFeedModel, isPostLiked, widget.postIdIntent);
                    });
                  },
                  child: Container(
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border:
                            Border.all(width: 2, color: AppColors.lightSkyBlue),
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
                          Constants.changeToFormatedNumber(
                              postFeedModel.likeCount.toString()),
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
                    ),
                  ),
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
                      addRoutineToPost(context, postFeedModel);
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
                                // postFeedModel.isSaved ? 'assets/images/ic_bookmarked.svg':
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
                SizedBox(
                  width: 8,
                ),
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
                      if (stichId.isNotEmpty) {
                        addStitchToPost(context, postFeedModel);
                      }
                    }
                    // _saveBottomSheet(context);
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
                        SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(
                top: ScreenUtil().setSp(15), bottom: ScreenUtil().setSp(15)),
            color: AppColors.viewLineColor,
            height: 0.8,
          ),
        ],
      ),
    );
  }

  void addRoutineToPost(BuildContext context, postFeedModel) {
    FirebaseFirestore.instance
        .collection(Constants.routineCollection)
        .doc(routineId)
        .collection(Constants.posts)
        .add({'post_id': postFeedModel.postId, 'complete': 0}).then((value) =>
            Constants().successToast(context, "Post added to routine"));

    getUserTokenFromPost(postFeedModel, "Routine");
  }

  void getUserTokenFromPost(PostFeedModel postFeedData, String type) {
    try {
      if (postFeedData.createdBy != globalUserId) {
        FirebaseFirestore.instance
            .collection(Constants.UsersFB)
            .doc(postFeedData.createdBy)
            .snapshots()
            .listen((DocumentSnapshot documentSnapshot) {
          Map<String, dynamic> mapObject = documentSnapshot.data();
          if (mounted) {
            setState(() {
              if (mapObject.containsKey("token")) {
                String createdByToken = documentSnapshot['token'];

                if (type == "Like" || type == "Comment") {
                  sendNotificationToLikeComment(
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

  void likeUnLikePost(postFeedModel, bool isLiked, String postId) {
    if (!isLiked) {
      FirebaseFirestore.instance
          .collection(Constants.PostLikesFB)
          .doc(Constants.PostLikesFB)
          .collection(postId)
          .doc(userIDPref)
          .set({
            "liked_by": userIDPref,
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
          .doc(userIDPref)
          .delete();
      FirebaseFirestore.instance
          .collection(Constants.posts)
          .doc(postId)
          .update({"counts.likes": FieldValue.increment(-1)});
    }
  }

  void sendNotificationToLikeComment(
      String createdByToken, String postId, String type) {
    // type is Stitch or Routine
    var dataPayload = jsonEncode({
      'to': createdByToken,
      'data': {
        "type": type == "Like" ? "likePost" : "commentPost",
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
        'title':
            type == "Like" ? 'Your post is Liked' : 'New comment on your post',
        'body': type == "Like"
            ? '$globalUserName liked your post'
            : '$globalUserName commented in your post (' +
                commentWantToSend +
                ')',
        'image': globaUserProfileImage,
        "badge": "1",
        "sound": "default"
      },
    });

    ApiCall.sendPushMessage(createdByToken, dataPayload);
  }

  setPostDefaultImage(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: ScreenUtil().setSp(370),
      decoration: BoxDecoration(
        color: AppColors.viewLineColor,
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
    );
  }

  setCardDefaultImage(BuildContext context) {
    return Container(
      width: ScreenUtil().setSp(120),
      height: ScreenUtil().setSp(120),
      decoration: BoxDecoration(
        color: AppColors.viewLineColor,
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
    );
  }

  void _saveBottomSheet(context) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return SafeArea(
              child: SingleChildScrollView(
                child: new Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: new Container(
                    decoration: new BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(25.0),
                            topRight: const Radius.circular(25.0))),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20.0, top: 10.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 1.0, top: 10.0),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        padding: EdgeInsets.all(2.5),
                                        margin: EdgeInsets.only(right: 5),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            'assets/images/ic_cross_bottom.svg',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Save to',
                                    style: TextStyle(
                                        fontFamily: 'epilogue_semibold',
                                        fontSize: ScreenUtil().setSp(30),
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Select bucket',
                                    style: TextStyle(
                                        fontFamily: 'epilogue_semibold',
                                        fontSize: ScreenUtil().setSp(25),
                                        color: Color(0xFF727272)),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 150,
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0),
                                    child: Container(
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 120,
                                            width: 120,
                                            child: PhysicalModel(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.grey,
                                              elevation: 5,
                                              shadowColor: Colors.white,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.network(
                                                  'https://1.bp.blogspot.com/-ITDeKbpwTbk/XJePd5D2nyI/AAAAAAAAAkQ/JGEzWJ0uGCsLjo09hjNTeP7Cwndrp9x5ACEwYBhgL/s640/gym-trainer-1.jpg',
                                                  fit: BoxFit.cover,
                                                  height: 120,
                                                  width: 120,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            'Bucket only',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontFamily:
                                                    Constants.regularFont,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            'or',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: Constants.regularFont,
                                color: Color(0xFFAAAAAA)),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {
                            showModalBottomSheet<void>(
                              context: context,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0)),
                              ),
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                  builder: (BuildContext context,
                                      void Function(void Function()) setState) {
                                    return SingleChildScrollView(
                                      child: new Container(
                                        color: Colors.transparent,
                                        padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom),
                                        child: new Container(
                                          padding: EdgeInsets.all(
                                              ScreenUtil().setSp(40)),
                                          decoration: new BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  new BorderRadius.only(
                                                      topLeft:
                                                          const Radius.circular(
                                                              25.0),
                                                      topRight:
                                                          const Radius.circular(
                                                              25.0))),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 1.0,
                                                            top: 10.0),
                                                    child: InkWell(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Container(
                                                        width: 16,
                                                        height: 16,
                                                        padding:
                                                            EdgeInsets.all(2.5),
                                                        margin: EdgeInsets.only(
                                                            right: 5),
                                                        child: Center(
                                                          child:
                                                              SvgPicture.asset(
                                                            'assets/images/ic_cross_bottom.svg',
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Create a new bucket',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'epilogue_semibold',
                                                        fontSize: ScreenUtil()
                                                            .setSp(30),
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Upload Bucket Thumbnail',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'epilogue_semibold',
                                                        fontSize: ScreenUtil()
                                                            .setSp(25),
                                                        color:
                                                            Color(0xFF727272)),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  _settingModalBottomSheet(
                                                      context, setState);
                                                  // imageSelector(context, "gallery",setState);
                                                },
                                                child: imageFile == null
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          DottedBorder(
                                                            padding:
                                                                EdgeInsets.all(
                                                              ScreenUtil()
                                                                  .setSp(40),
                                                            ),
                                                            borderType:
                                                                BorderType
                                                                    .RRect,
                                                            color: Color(
                                                                    0xFF1A58E7)
                                                                .withOpacity(
                                                                    0.7),
                                                            radius:
                                                                Radius.circular(
                                                                    10),
                                                            dashPattern: [
                                                              2.5,
                                                              4,
                                                              2,
                                                              4
                                                            ],
                                                            strokeWidth: 1.5,
                                                            child: SvgPicture
                                                                .asset(
                                                              'assets/images/ic_media_image.svg',
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : Container(
                                                        child: PhysicalModel(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color: AppColors
                                                              .viewLineColor,
                                                          elevation: 5,
                                                          shadowColor: AppColors
                                                              .shadowColor,
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            child: Image.file(
                                                              imageFile,
                                                              fit: BoxFit.cover,
                                                              height: 75,
                                                              width: 75,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                              SizedBox(
                                                height: 30,
                                              ),
                                              Text(
                                                'Bucket Name',
                                                style: TextStyle(
                                                    fontFamily:
                                                        'epilogue_semibold',
                                                    fontSize:
                                                        ScreenUtil().setSp(25),
                                                    color: Color(0xFF727272)),
                                              ),
                                              TextField(
                                                keyboardType:
                                                    TextInputType.text,
                                                style: TextStyle(
                                                    fontSize:
                                                        ScreenUtil().setSp(30),
                                                    fontFamily:
                                                        'epilogue_regular'),
                                              ),
                                              SizedBox(
                                                height: 30,
                                              ),
                                              Text(
                                                'Bucket Type',
                                                style: TextStyle(
                                                    fontFamily:
                                                        'epilogue_semibold',
                                                    fontSize:
                                                        ScreenUtil().setSp(25),
                                                    color: Color(0xFF727272)),
                                              ),
                                              TextField(
                                                style: TextStyle(
                                                    fontSize:
                                                        ScreenUtil().setSp(30),
                                                    fontFamily:
                                                        'epilogue_regular'),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Container(
                                                height: ScreenUtil().setSp(95),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: RaisedButton(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40.0),
                                                    side: BorderSide(
                                                        color: AppColors
                                                            .primaryColor),
                                                  ),
                                                  color: AppColors.primaryColor,
                                                  onPressed: () {},
                                                  child: Text(
                                                    'Create Bucket',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'epilogue_semibold',
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              'Create New Bucket',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: Constants.regularFont,
                                  color: AppColors.primaryColor),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          color: Colors.transparent,
                          margin: EdgeInsets.only(top: 3, right: 20, left: 20),
                          width: MediaQuery.of(context).size.width,
                          height: ScreenUtil().setSp(100),
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40.0),
                                side: BorderSide(
                                    color: isBtnEnable == false
                                        ? AppColors.accentColor
                                        : AppColors.primaryColor)),
                            onPressed: () {},
                            color: isBtnEnable == false
                                ? AppColors.accentColor
                                : AppColors.primaryColor,
                            textColor: Colors.white,
                            padding: EdgeInsets.all(10.0),
                            child: Text(Constants.save,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(28),
                                  fontFamily: Constants.semiBoldFont,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void addStitchToPost(BuildContext context, PostFeedModel postFeedModel) {
    FirebaseFirestore.instance
        .collection(Constants.stitchCollection)
        .doc(stichId)
        .update({
      'post_ids': FieldValue.arrayUnion([postFeedModel.postId])
    }).then((value) =>
            Constants().successToast(context, "Stitch added to post"));

    getUserTokenFromPost(postFeedModel, "Stitch");
  }

  void _settingModalBottomSheet(context, state) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Container(
              child: new Wrap(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      "Select From",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: Constants.mediumFont,
                          fontSize: 18.0),
                    ),
                  ),
                  new ListTile(
                    title: new Text('Camera',
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: Constants.regularFont,
                            fontSize: 16.0)),
                    onTap: () => {
                      FocusScope.of(context).unfocus(),
                      imageSelector(context, "camera", state),
                      Navigator.pop(context)
                    },
                  ),
                  new ListTile(
                      title: new Text('Gallery',
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: Constants.regularFont,
                              fontSize: 16.0)),
                      onTap: () => {
                            FocusScope.of(context).unfocus(),
                            imageSelector(context, "gallery", state),
                            Navigator.pop(context),
                          }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future imageSelector(
      BuildContext context, String pickerType, StateSetter state) async {
    switch (pickerType) {
      case "gallery":

        /// GALLERY IMAGE PICKER
        imageFile = await ImagePicker()
            .pickImage(source: ImageSource.gallery, imageQuality: 90);
        break;

      case "camera": // CAMERA CAPTURE CODE
        imageFile = await ImagePicker()
            .pickImage(source: ImageSource.camera, imageQuality: 90);
        break;
    }

    if (imageFile != null) {
      updated(state);
    } else {
    }
  }

  Future<Null> updated(StateSetter updateState) async {
    updateState(() {});
  }

  void saveRecentsData() {
    RecentPostsModel recentPostsModel = new RecentPostsModel(
        title: postFeedModel.title, description: postFeedModel.description);
    FirebaseFirestore.instance
        .collection(Constants.recentPosts)
        .add(recentPostsModel.toMap())
        .then((value) {
    });
  }
}
