import 'dart:collection';
import 'dart:io';
import 'dart:io' as io;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart' hide ReorderableList;
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' hide ReorderableList;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:solstice/model/add_card_model.dart';
import 'package:solstice/model/forum_model_new.dart';
import 'package:solstice/model/post_card_model.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/pages/cards/create_card.dart';
import 'package:solstice/pages/chat/chat_users_history_screen.dart';
import 'package:solstice/pages/explore/explore_screen.dart';
import 'package:solstice/pages/home/card_reorder_item.dart';
import 'package:solstice/pages/home/post_detail_screen.dart';
import 'package:solstice/pages/home/post_filter_new.dart';
import 'package:solstice/pages/home/save_to_routine.dart';
import 'package:solstice/pages/home/save_to_stitch.dart';
import 'package:solstice/pages/home/search_filter.dart';
import 'package:solstice/pages/home/video_trimmer.dart';
import 'package:solstice/pages/search_location.dart';
import 'package:solstice/pages/views/card_detail.dart';
import 'package:solstice/pages/views/home_post_list_item.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/my_navigator.dart';
import 'package:solstice/utils/utilities.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class HomeTabScreen extends StatefulWidget {
  @override
  HomeTabScreenState createState() {
    return HomeTabScreenState();
  }
}

class HomeTabScreenState extends State<HomeTabScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  ScrollController _controller;
  String pinCode = "";
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  List<PostFeedModel> selectedList = new List<PostFeedModel>();

  bool isSelectedRecent = true;

  TextEditingController postTitleController = new TextEditingController();
  TextEditingController postGoalController = new TextEditingController();
  TextEditingController postDescriptionController = new TextEditingController();
  TextEditingController postCardIDController = new TextEditingController();
  TextEditingController postCardNameController = new TextEditingController();
  TextEditingController stitchDescriptionController =
      new TextEditingController();
  TextEditingController stitchTitleController = new TextEditingController();
  final FocusNode _postTitleFocus = new FocusNode();
  final FocusNode _postDescriptionFocus = new FocusNode();
  final FocusNode _postCardIDFocus = new FocusNode();
  final FocusNode _postCardNameFocus = new FocusNode();
  String postTitleErrorMessage = "";
  String postDescriptionErrorMessage = "";
  String postCardIDErrorMessage = "";
  String postCardNameErrorMessage = "";
  bool isPostTitleHaveError = true;
  bool isPostDescriptionHaveError = true;
  bool isPostCardIDHaveError = true;
  bool isPostCardNameHaveError = true;
  bool isBtnEnable = false;
  bool isCardBtnEnable = false;
  var imageFile = null;
  var imageFileStitch = null;
  XFile imageCardFile;
  List imageFileList = new List();
  List<String> mediaFileList = new List();
  List<HashMap<String, dynamic>> mediaMapList = new List();
  HashMap<String, dynamic> mediaMap = new HashMap();
  bool isCardImage = false, isFromPost = false;
  String location = Constants.selectLocation;
  double latitude;
  double longitude;
  List<AddCardModel> cardModelList = new List();
  List<PostCardModel> cardList = new List();
  PageController pageController = new PageController();
  int imagePageIndex = 0;
  String postId;
  final _formKey = GlobalKey<FormState>();
  String _selectedImageUrl = "";
  String stichId = "", stitchTitle = "";
  String routineId = "", routineTitle = "";
  bool showCreate = false;
  String userIDPref = "";
  bool isPublic = true;
  String postType = "Public";
  XFile videoFile;
  bool isThumbnail = false;
  bool isPublicStitch = true;
  String stitchTye = "Public";
  File _thumbFile;
  int limitRecent = 10;
  int limitTrending = 10;
  int _limitIncrement = 10;
  final ScrollController listScrollController = ScrollController();

  final ScrollController listScrollRecentController = ScrollController();
  final ScrollController listScrollTrendingController = ScrollController();
  MediaPostModel mediaPostModel = new MediaPostModel();

  LatLng currentLatLng;
  Position currentLocation;
  Map<File, File> postVideoFilesMap = new HashMap();

  @override
  void initState() {
    super.initState();
    // _controller = ScrollController();

    // listScrollController.addListener(scrollListenerRecent);

    _controller = ScrollController();
    listScrollRecentController.addListener(_scrollListenerRecent);
    listScrollTrendingController.addListener(_scrollListenerTrending);

    getUserLocation();
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  getUserLocation() async {

    currentLocation = await locateUser();
    currentLatLng = LatLng(currentLocation.latitude, currentLocation.longitude);
    //globals.currentLatLng = currentLatLng;
    try {
      latitude = currentLatLng.latitude;
      longitude = currentLatLng.longitude;
      List<Placemark> placemarks = await placemarkFromCoordinates(
          currentLocation.latitude, currentLocation.longitude);

      Placemark place = placemarks[0];
      location = "${place.locality}, ${place.country}";
    } catch (e) {
    }

    if (globalUserId != null && globalUserId != "") {
      if (globalUserFBToken != null && globalUserId != "") {
        updateFBToken();
      }
    }
  }

  Future<void> updateFBToken() async {
    var a = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(globalUserId)
        .get();
    if (a.exists) {
      FirebaseFirestore.instance
          .collection(Constants.UsersFB)
          .doc(globalUserId)
          .update({'token': globalUserFBToken});
      //return a;
    }

    if (mounted) setState(() {});
  }

  // for initialize scroll for recent tab

  _scrollListenerRecent() {
    if (listScrollRecentController.offset >=
            listScrollRecentController.position.maxScrollExtent &&
        !listScrollRecentController.position.outOfRange) {
      setState(() {
        limitRecent += _limitIncrement;
      });
    }
  }

  // for initialize scroll for Trending tab

  _scrollListenerTrending() {
    if (listScrollTrendingController.offset >=
            listScrollTrendingController.position.maxScrollExtent &&
        !listScrollTrendingController.position.outOfRange) {
      setState(() {
        limitTrending += _limitIncrement;
      });
    }
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).padding.top,
              ),
              Expanded(
                flex: 0,
                child: Container(
                  padding: EdgeInsets.only(
                      left: ScreenUtil().setSp(36),
                      right: ScreenUtil().setSp(36),
                      top: ScreenUtil().setSp(26),
                      bottom: ScreenUtil().setSp(26)),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Text(
                            Constants.feed,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: ScreenUtil().setSp(42),
                                fontFamily: Constants.boldFont),
                          ),
                        ),
                      ),

                      InkWell(
                          child: Container(
                            child: Stack(
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  padding: EdgeInsets.all(2.0),
                                  margin: EdgeInsets.only(right: 5),
                                  child: Image.asset(
                                    'assets/images/ic_chat_unactive.png',
                                    width: ScreenUtil().setSp(32),
                                    height: ScreenUtil().setSp(32),
                                  ),
                                ),
                                Positioned(
                                  right: 1,
                                  child: globalUserUnSeenChats != null &&
                                          globalUserUnSeenChats > 0
                                      ? Container(
                                          padding: EdgeInsets.only(
                                              top: 2,
                                              bottom: 2,
                                              right: 7,
                                              left: 7),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            color: AppColors.primaryColor,
                                          ),
                                          child: Text(
                                            globalUserUnSeenChats > 99
                                                ? "99+"
                                                : globalUserUnSeenChats
                                                    .toString(),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'rubikregular',
                                                fontSize: 10),
                                          ),
                                        )
                                      : Container(),
                                )
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return ChatUsersHistoryScreen();
                            }));
                          }),

                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) {
                            return SearchFilter(screenType: 'Home');
                          }));
                        },
                        child: Container(
                          width: 26,
                          height: 26,
                          padding: EdgeInsets.all(2.5),
                          margin: EdgeInsets.only(left: 5, right: 5),
                          child: SvgPicture.asset(
                            'assets/images/ic_search.svg',
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // InkWell(
                      //   onTap: () {
                      //     Navigator.of(context).push(MaterialPageRoute(
                      //         builder: (BuildContext context) {
                      //       return FilterPost();
                      //     }));
                      //   },
                      //   child: Container(
                      //     width: 23,
                      //     height: 23,
                      //     padding: EdgeInsets.all(2.5),
                      //     margin: EdgeInsets.only(right: 5),
                      //     child: SvgPicture.asset(
                      //       'assets/images/ic_filter.svg',
                      //       alignment: Alignment.center,
                      //       fit: BoxFit.contain,
                      //     ),
                      //   ),
                      // ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) {
                            return ExploreScreen();
                          }));
                        },
                        child: Container(
                            width: 26,
                            height: 26,
                            margin: EdgeInsets.only(left: 5),
                            padding: EdgeInsets.all(2.5),
                            child: SvgPicture.asset(
                              'assets/images/ic_marker.svg',
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    left: ScreenUtil().setSp(36),
                    right: ScreenUtil().setSp(36),
                    bottom: ScreenUtil().setSp(16)),
                height: ScreenUtil().setSp(54),
                child: Row(
                  children: [
                    InkWell(
                      child: Container(
                        width: ScreenUtil().setSp(145),
                        height: ScreenUtil().setSp(50),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26.0),
                          color: isSelectedRecent == true
                              ? AppColors.primaryColor
                              : Colors.transparent,
                        ),
                        child: Text(
                          Constants.recent,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: isSelectedRecent == true
                                  ? Colors.white
                                  : AppColors.accentColor,
                              fontFamily: Constants.semiBoldFont,
                              fontSize: ScreenUtil().setSp(22)),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          if (!isSelectedRecent) {
                            isSelectedRecent = true;
                          }
                        });
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      child: Container(
                        width: ScreenUtil().setSp(145),
                        height: ScreenUtil().setSp(50),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26.0),
                          color: isSelectedRecent == false
                              ? AppColors.primaryColor
                              : Colors.transparent,
                        ),
                        child: Text(
                          Constants.trending,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: isSelectedRecent == false
                                  ? Colors.white
                                  : AppColors.accentColor,
                              fontFamily: Constants.mediumFont,
                              fontSize: ScreenUtil().setSp(22)),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          if (isSelectedRecent) {
                            isSelectedRecent = false;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),

              Visibility(
                visible: isSelectedRecent == true ? true : false,
                child: RecentsListing(),
              ),
              Visibility(
                visible: isSelectedRecent == true ? false : true,
                child: TrendingListing(),
              ),

              //   Expanded(
              //     flex: 1,
              //     child: SingleChildScrollView(
              //       controller: listScrollController,
              //       child: Column(
              //         children: <Widget>[
              //           MediaQuery.removePadding(
              //               context: context,
              //               removeTop: true,
              //               removeBottom: true,
              //               child: StreamBuilder(
              //                   stream: isSelectedRecent
              //                       ? FirebaseFirestore.instance
              //                           .collection(Constants.posts)
              //                           .orderBy("updated_at", descending: true)
              //                           .where("active", isEqualTo: 1)
              //                           .where("is_card_post", isEqualTo: false)
              //                           .where("is_public", isEqualTo: true)
              //                           .limit(limitRecent)
              //                           .snapshots()
              //                       : FirebaseFirestore.instance
              //                           .collection(Constants.posts)
              //                           .orderBy("counts.likes", descending: true)
              //                           .where("active", isEqualTo: 1)
              //                           .where("is_card_post", isEqualTo: false)
              //                           .where("is_public", isEqualTo: true)
              //                           .limit(limitRecent)
              //                           .snapshots(),
              //                   builder: (context, snapshot) {
              //                     if (!snapshot.hasData) {
              //                       return Center(
              //                         child: CircularProgressIndicator(
              //                             valueColor:
              //                                 AlwaysStoppedAnimation<Color>(
              //                                     AppColors.primaryColor)),
              //                       );
              //                     }
              //                     if (snapshot.data.docs.length == 0) {
              //                       return Center(
              //                           child: Card(
              //                               elevation: 4.0,
              //                               child: Text(
              //                                 'No Feeds',
              //                                 style: TextStyle(
              //                                     fontSize: 14.0,
              //                                     color: Colors.black),
              //                                 textAlign: TextAlign.center,
              //                               )));
              //                     }
              //                     return feedsListUI(context, snapshot);
              //                   })),
              //           SizedBox(height: ScreenUtil().setSp(100)),
              //         ],
              //       ),
              //     ),
              //   ),
            ],
          ),
          Positioned(
              bottom: 16,
              left: 20,
              right: 20,
              child: Container(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    setState(() {
                      // createNewPostBottomSheet(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateCardPage()));
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    padding: EdgeInsets.all(3.5),
                    child: SvgPicture.asset(
                      'assets/images/ic_plus.svg',
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                    ),
                  ),
                  backgroundColor: AppColors.primaryColor,
                ),
              ))
        ],
      ),
    );
  }

  // for getting user detail
  Future<UserFirebaseModel> loadUser(userId) async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(userId)
        .get();
    if (ds != null)

      // return ds;

      return Future.delayed(Duration(milliseconds: 100),
          () => UserFirebaseModel.fromSnapshot(ds));
  }

  // Recents Listing process
  Widget RecentsListing() {
    return Flexible(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(Constants.posts)
            .orderBy("updated_at", descending: true)
            .where("active", isEqualTo: 1)
            .where("is_card_post", isEqualTo: false)
            .where("is_public", isEqualTo: true)
            .limit(limitRecent)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryColor)),
            );
          } else {
            return snapshot.data.docs.isNotEmpty
                ? ListView(
                    padding: EdgeInsets.only(bottom: 50),
                    controller: listScrollRecentController,
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
                            PostFeedModel message =
                                PostFeedModel.fromSnapshot(rev[index]);

                            return FutureBuilder(
                                future:
                                    loadUser(rev[index].data()["created_by"]),
                                builder: (BuildContext context,
                                    AsyncSnapshot<UserFirebaseModel>
                                        userFirebase) {
                                  message.userFirebaseModel = userFirebase.data;
                                  return new InkWell(
                                    splashColor: AppColors.primaryColor,
                                    onTap: () {
                                      setState(() {
                                        _postDetailTapped(message.postId);
                                      });
                                    },
                                    child: new HomePostListItem(
                                        key: ValueKey(message.postId),
                                        selectedItem: message,
                                        index: index,
                                        appUserId: globalUserId),
                                  );
                                });
                          },
                          itemCount: snapshot.data.docs.length,
                          //controller: listScrollController,
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Container(
                      child: Text(
                        "No Feed",
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(26),
                            fontFamily: Constants.regularFont,
                            height: 1.3,
                            letterSpacing: 0.8),
                      ),
                    ),
                  );
          }
        },
      ),
    );
  }

  // Trending listing process
  Widget TrendingListing() {
    return Flexible(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(Constants.posts)
            .orderBy("counts.likes", descending: true)
            .where("active", isEqualTo: 1)
            .where("is_card_post", isEqualTo: false)
            .where("is_public", isEqualTo: true)
            .limit(limitRecent)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryColor)),
            );
          } else {
            return snapshot.data.docs.isNotEmpty
                ? ListView(
                    padding: EdgeInsets.only(bottom: 50),
                    controller: listScrollRecentController,
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
                            PostFeedModel message =
                                PostFeedModel.fromSnapshot(rev[index]);

                            return FutureBuilder(
                                future:
                                    loadUser(rev[index].data()["created_by"]),
                                builder: (BuildContext context,
                                    AsyncSnapshot<UserFirebaseModel>
                                        userFirebase) {
                                  message.userFirebaseModel = userFirebase.data;
                                  return new InkWell(
                                    splashColor: AppColors.primaryColor,
                                    onTap: () {
                                      setState(() {
                                        _postDetailTapped(message.postId);
                                      });
                                    },
                                    child: new HomePostListItem(
                                        key: ValueKey(message.postId),
                                        selectedItem: message,
                                        index: index,
                                        appUserId: globalUserId),
                                  );
                                });
                          },
                          itemCount: snapshot.data.docs.length,
                          //controller: listScrollController,
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Container(
                      child: Text(
                        "No Feed",
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(26),
                            fontFamily: Constants.regularFont,
                            height: 1.3,
                            letterSpacing: 0.8),
                      ),
                    ),
                  );
          }
        },
      ),
    );
  }

  Widget feedsListUI(BuildContext context, snapshots) {
    return ListView.builder(
      shrinkWrap: true,
      // controller: listScrollController,
      reverse: true,
      primary: false,
      physics: NeverScrollableScrollPhysics(),
      itemCount: snapshots.data.docs.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        List rev = snapshots.data.docs.reversed.toList();

        PostFeedModel message = PostFeedModel.fromSnapshot(rev[index]);

        return FutureBuilder(
            future: loadUser(rev[index].data()["created_by"]),
            builder: (BuildContext context,
                AsyncSnapshot<UserFirebaseModel> userFirebase) {
              message.userFirebaseModel = userFirebase.data;
              return new InkWell(
                splashColor: AppColors.primaryColor,
                onTap: () {
                  setState(() {
                    _postDetailTapped(message.postId);
                  });
                },
                child: new HomePostListItem(
                    key: ValueKey(message.postId),
                    selectedItem: message,
                    index: index,
                    appUserId: globalUserId),
              );
            });
      },
    );
  }

  // on post click open post detail page.
  Future _postDetailTapped(String postId) async {
    Map results = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return PostDetailScreen(postIdIntent: postId);
    }));

    if (results != null && results.containsKey('update')) {
      var _isUpdate = "";
      setState(() {
        _isUpdate = results['update'];
        if (_isUpdate == "yes") {
          //getDataFromApi(true);
        }
      });
    }
  }

  void showSnackBar(String msg) {
    final snackBarContent = SnackBar(
      content: Text(msg),
      action: SnackBarAction(
          label: 'OK',
          onPressed: _scaffoldkey.currentState.hideCurrentSnackBar,
          textColor: AppColors.primaryColor),
    );
    _scaffoldkey.currentState.showSnackBar(snackBarContent);
  }

  // create new post bottom sheet
  void createNewPostBottomSheet(BuildContext context) {
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
                                      Constants.postJourney,
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
                                        postTitleController.text = "";
                                        postDescriptionController.text = "";
                                        imageFileList.clear();
                                        mediaFileList.clear();
                                        mediaMap.clear();
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
                            Text(
                              Constants.uploadPhoto,
                              style: TextStyle(
                                  color: AppColors.accentColor,
                                  fontFamily: Constants.semiBoldFont,
                                  fontSize: ScreenUtil().setSp(24)),
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 80,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: imageFileList.length + 1,
                                itemBuilder: (BuildContext context, int index) {
                                  return imageListUi(context, index, setState);
                                },
                              ),
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              maxLength: 200,
                              focusNode: _postTitleFocus,
                              cursorColor: AppColors.primaryColor,
                              controller: postTitleController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (v) {
                                FocusScope.of(context)
                                    .requestFocus(_postDescriptionFocus);
                              },
                              onChanged: (v) {
                                setState(() {
                                  if (postTitleController.value.text
                                      .trim()
                                      .isEmpty) {
                                    // isPostTitleHaveError = true;
                                    isBtnEnable = false;
                                    // postTitleErrorMessage = Constants.enterTitleError;
                                  } else if (postTitleController.value.text
                                          .trim()
                                          .length <
                                      3) {
                                    isBtnEnable = false;
                                    // isPostTitleHaveError = true;
                                    // postTitleErrorMessage = Constants.minimum4Character;
                                  } else {
                                    if (postDescriptionController.text.length >
                                        0) {
                                      isBtnEnable = true;
                                    }

                                    // isPostTitleHaveError = false;
                                    // postTitleErrorMessage = "";
                                  }
                                });
                              },
                              decoration: InputDecoration(
                                counterText: "",
                                labelText: Constants.title,
                                labelStyle: TextStyle(
                                    color: AppColors.accentColor,
                                    fontFamily: Constants.semiBoldFont,
                                    fontSize: ScreenUtil().setSp(24)),
                                /* contentPadding:
                                  EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),*/
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.only(left: 10),
                                alignment: Alignment.topRight,
                                margin: const EdgeInsets.only(
                                    top: 4.0, left: 30.0, bottom: 3),
                                child: Text(
                                  postTitleErrorMessage,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.red,
                                      fontFamily: Constants.mediumFont),
                                )),
                            TextFormField(
                              maxLength: 2000,
                              focusNode: _postDescriptionFocus,
                              cursorColor: AppColors.primaryColor,
                              controller: postDescriptionController,
                              keyboardType: TextInputType.multiline,
                              maxLines: 5,
                              minLines: 1,
                              onChanged: (v) {
                                setState(() {
                                  if (postDescriptionController.value.text
                                      .trim()
                                      .isEmpty) {
                                    // isPostDescriptionHaveError = true;
                                    isBtnEnable = false;
                                    // postDescriptionErrorMessage = Constants.enterJourneyError;
                                  } else if (postDescriptionController
                                          .value.text
                                          .trim()
                                          .length <
                                      3) {
                                    // isPostDescriptionHaveError = true;
                                    isBtnEnable = false;
                                    // postDescriptionErrorMessage = Constants.minimum4Character;
                                  } else {
                                    if (postDescriptionController.text.length >
                                        0) {
                                      isBtnEnable = true;
                                    }
                                    // isPostDescriptionHaveError = false;
                                    // postDescriptionErrorMessage = "";
                                  }
                                });
                              },
                              decoration: InputDecoration(
                                counterText: "",
                                labelText: Constants.describeYourJourney,
                                labelStyle: TextStyle(
                                    color: AppColors.accentColor,
                                    fontFamily: Constants.semiBoldFont,
                                    fontSize: ScreenUtil().setSp(24)),
                                /* contentPadding:
                                  EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),*/
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.only(left: 10),
                                alignment: Alignment.topRight,
                                margin: const EdgeInsets.only(
                                    top: 4.0, left: 30.0, bottom: 16),
                                child: Text(
                                  postDescriptionErrorMessage,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.red,
                                      fontFamily: Constants.mediumFont),
                                )),
                            Text(
                              Constants.locationOptional,
                              style: TextStyle(
                                  color: AppColors.accentColor,
                                  fontFamily: Constants.semiBoldFont,
                                  fontSize: ScreenUtil().setSp(24)),
                            ),
                            SizedBox(height: 10),
                            InkWell(
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                var object = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SearchLocation()));

                                if (object != null) {
                                  SearchedLocationModel searchedLocationModel =
                                      object['returnData'];
                                  location = searchedLocationModel.title;
                                  latitude = searchedLocationModel.latitude;
                                  longitude = searchedLocationModel.longitude;
                                  setState(() {});
                                }
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      location,
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(28),
                                          color: AppColors.accentColor,
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
                              height: 1,
                              color: AppColors.lightGreyColor,
                            ),
                            SizedBox(height: 15),
                            Text(
                              Constants.privacyType,
                              style: TextStyle(
                                  color: AppColors.accentColor,
                                  fontFamily: Constants.semiBoldFont,
                                  fontSize: ScreenUtil().setSp(24)),
                            ),
                            InkWell(
                              onTap: () {
                                if (isPublic) {
                                  postType = 'Private';
                                } else {
                                  postType = 'Public';
                                }
                                isPublic = !isPublic;
                                setState(() {});
                              },
                              child: Container(
                                width: 100.0,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 10.0),
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                    border: Border.all(
                                        color: AppColors.appGreyColor[500],
                                        width: 1)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      isPublic
                                          ? Constants.publicIcon
                                          : Constants.privateIcon,
                                      color: AppColors.accentColor,
                                      height: 15.0,
                                      width: 15.0,
                                    ),
                                    SizedBox(
                                      width: 4.0,
                                    ),
                                    Text(
                                      '$postType',
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(28),
                                          color: AppColors.accentColor,
                                          fontFamily: Constants.mediumFont),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                            ),
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
                                  setState(() {
                                    var title =
                                        postTitleController.value.text.trim();
                                    var description = postDescriptionController
                                        .value.text
                                        .trim();
                                    if (title.isEmpty) {
                                      Constants().errorToast(
                                          context, Constants.enterTitleError);
                                      // postTitleErrorMessage = Constants.enterTitleError;
                                    } else if (description.isEmpty) {
                                      Constants().errorToast(
                                          context, Constants.enterJourneyError);
                                    } else if (title.length < 4) {
                                      Constants().errorToast(context,
                                          Constants.titleMust4Characters);
                                    } else if (description.length < 4) {
                                      Constants().errorToast(context,
                                          Constants.journeyMust4Characters);
                                    } else {
                                      // if (imageFile == null) {
                                      //   Constants().errorToast(
                                      //       context, Constants.imageFileError);
                                      // } else
                                      if (isBtnEnable == true) {
                                        Utilities.show(context);
                                        createPost(
                                            postTitleController.text,
                                            postDescriptionController.text,
                                            postGoalController.text);
                                        // Navigator.of(context).pop();
                                        // uploadImages(
                                        //     postTitleController.text,
                                        //     postDescriptionController.text,
                                        //     postGoalController.text,
                                        //     imageFileList);
                                      }
                                    }
                                  });
                                },
                                color: isBtnEnable == true
                                    ? AppColors.primaryColor
                                    : AppColors.accentColor,
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
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Create and save post to DB without card
  void createPost(String title, String description, String goal) {
    postId = DateTime.now().millisecondsSinceEpoch.toString();
    var documentReference =
        FirebaseFirestore.instance.collection(Constants.posts).doc(postId);
    if (mediaMapList.length == 0) {
      HashMap<String, dynamic> map = new HashMap();
      map["thumbnail"] = "";
      map["url"] = defaultPostImage;
      map["type"] = "Image";
      mediaMapList.add(map);
      mediaFileList.add(defaultPostImage);
    }

    PostFeedModel postFeedModel = new PostFeedModel(
        active: 0,
        createdAt: Timestamp.now(),
        commentCount: 0,
        description: description,
        title: title,
        postId: postId,
        isCardPost: false,
        createdBy: globalUserId,
        mediaMapList: mediaMapList,
        latitude: latitude.toString(),
        isPublic: isPublic,
        longitude: longitude.toString(),
        location: location,
        likeCount: 0,
        upatedAt: Timestamp.now());

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(documentReference, postFeedModel.toMap());
    }).then((value) {
      postTitleController.text = "";
      postDescriptionController.text = "";
      location = "";
      postGoalController.text = "";
      mediaMap.clear();
      Navigator.pop(context);

      addPostFilter(context, postId, title, description, goal, mediaFileList);
    }).catchError((exc) {
    });
    Utilities.hide();
  }

  // add post filter on submit post
  Future<void> addPostFilter(context, postId, String title, String description,
      String goal, List imageList) async {
    var object = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostFilterNew(
                  postId: postId,
                  editFields: true,
                  isEditMode: false,
                )));
    if (object != null) {
      if (object['goToNext']) {
        addCardBottomSheetUI(
            context, postId, title, description, goal, imageList);
      }

      setState(() {});
    }
  }

  // Gallery and camera image bottom sheet
  void _settingModalBottomSheet(context, state, bool fromStitch) {
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
                      "Select from",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: Constants.mediumFont,
                          fontSize: 18.0),
                    ),
                  ),
                  new ListTile(
                    title: new Text('Photo Camera',
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: Constants.regularFont,
                            fontSize: 16.0)),
                    onTap: () => {
                      FocusScope.of(context).unfocus(),
                      imageSelector(context, "camera", state, fromStitch),
                      Navigator.pop(context)
                    },
                  ),
                  new ListTile(
                      title: new Text('Photo Gallery',
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: Constants.regularFont,
                              fontSize: 16.0)),
                      onTap: () => {
                            FocusScope.of(context).unfocus(),
                            imageSelector(
                                context, "gallery", state, fromStitch),
                            Navigator.pop(context),
                          }),
                  if (isFromPost)
                    new ListTile(
                        title: new Text('Video Camera',
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: Constants.regularFont,
                                fontSize: 16.0)),
                        onTap: () => {
                              FocusScope.of(context).unfocus(),
                              imageSelector(
                                  context, "video_camera", state, fromStitch),
                              Navigator.pop(context),
                            }),
                  if (isFromPost)
                    new ListTile(
                        title: new Text('Video Gallery',
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: Constants.regularFont,
                                fontSize: 16.0)),
                        onTap: () => {
                              FocusScope.of(context).unfocus(),
                              imageSelector(
                                  context, "video", state, fromStitch),
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

  // image selection process
  Future imageSelector(BuildContext context1, String pickerType,
      StateSetter state, bool fromStitch) async {
    switch (pickerType) {
      case "video":
        videoFile = await ImagePicker().pickVideo(
            source: ImageSource.gallery, maxDuration: Duration(seconds: 30));
        break;

      case "video_camera":
        videoFile = await ImagePicker().pickVideo(
            source: ImageSource.camera, maxDuration: Duration(seconds: 30));
        break;

      case "gallery":
        videoFile = null;
        isThumbnail = false;

        /// GALLERY IMAGE PICKER
        if (fromStitch) {
          imageFileStitch = await ImagePicker()
              .pickImage(source: ImageSource.gallery, imageQuality: 90);
        } else if (isCardImage) {
          imageCardFile = await ImagePicker()
              .pickImage(source: ImageSource.gallery, imageQuality: 90);
        } else {
          imageFile = await ImagePicker()
              .pickImage(source: ImageSource.gallery, imageQuality: 90);
        }
        break;

      case "camera":
        videoFile = null;
        isThumbnail = false;

        /// CAMERA CAPTURE CODE
        if (fromStitch) {
          imageFileStitch = await ImagePicker()
              .pickImage(source: ImageSource.camera, imageQuality: 90);
        } else if (isCardImage) {
          imageCardFile = await ImagePicker()
              .pickImage(source: ImageSource.camera, imageQuality: 90);
        } else {
          imageFile = await ImagePicker()
              .pickImage(source: ImageSource.camera, imageQuality: 90);
        }
        break;
    }

    if (isCardImage) {
      if (imageCardFile != null) {
        updated(state, imageCardFile);
      } else {
      }
    } else {
      if (imageFile != null) {
        imageFileList.add(imageFile);
        updated(state, imageFile);
      } else {
      }
      if (videoFile != null) {
        isThumbnail = true;

        getThumbnail(videoFile, state).then((value) async {
          Directory tempDir = await getTemporaryDirectory();
          String tempPath = tempDir.path;
          var filePath = tempPath +
              '/${DateTime.now().millisecondsSinceEpoch.toString()}.jpeg';
          // file_01.tmp is dump file, can be anything
          await File(filePath).writeAsBytes(value).then((thumbFile) {
            imageFileList.add(thumbFile);
            _thumbFile = thumbFile;
            updated(state, thumbFile);
          });
        });

        showTrimmerBottomSheet(File(videoFile.path), state);
        // updatedVideo(state, videoFile);
        setState(() {});
      }
    }
  }

  showTrimmerBottomSheet(File videoFile1, state) async {
    // var object = await showModalBottomSheet(
    //     isScrollControlled: true,
    //     context: context,
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.only(
    //           topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
    //     ),
    //     builder: (context) {
    //       return VideoTrimmer(videoFile: videoFile1);
    //     });

    var object = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VideoTrimmer(videoFile: videoFile1)));
    if (object != null) {
      Utilities.show(context);

      videoFile = XFile(object['videoPath']);
      File newVideoFile = new File(videoFile.path);

      final bytes = newVideoFile.lengthSync();
      final kb = bytes / 1024;
      final mb = kb / 1024;


      if (mb <= 15) {
        updatedVideo(state, videoFile);
      } else {
        Utilities.hide();
        mediaFileList.removeAt(mediaFileList.length - 1);
        imageFileList.removeAt(imageFileList.length - 1);
        mediaMapList.removeAt(mediaMapList.length - 1);

        Constants().errorToast(context, "Please select video below 15 MB.");
        state(() {});
      }

      // getThumbnail(videoFile, state).then((value) async {
      //   Directory tempDir = await getTemporaryDirectory();
      //   String tempPath = tempDir.path;
      //   var filePath = tempPath +
      //       '/${DateTime.now().millisecondsSinceEpoch.toString()}.jpeg';
      //   // file_01.tmp is dump file, can be anything
      //   await File(filePath).writeAsBytes(value).then((thumbFile) {
      //     imageFileList.add(thumbFile);
      //     updated(state, thumbFile);
      //   });
      // });
    }
  }

  // upload file(image) to firebase storage
  Future<Null> updated(StateSetter updateState, imageFile) async {
    FocusScope.of(context).unfocus();

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var firebaseStorageRef =
        FirebaseStorage.instance.ref().child('postsImages/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(io.File(imageFile.path));
    uploadTask.whenComplete(() {
      firebaseStorageRef.getDownloadURL().then((value) {
        if (isThumbnail) {
          mediaPostModel.thumbnail = value;
          mediaMap["thumbnail"] = value;
          //  updatedVideo(updateState, videoFile);

        } else {
          mediaPostModel.mediaType = "Image";
          mediaMap["thumbnail"] = "";
          mediaMap["type"] = "Image";
          mediaMap["url"] = value;
          mediaPostModel.url = value;
        }

        mediaFileList.add(value);
        mediaMapList.add(mediaMap);

      }).catchError((error) {
      });
    });

    if (imageFileList.length > 0) {
      if (postTitleController.text.length > 0 &&
          postDescriptionController.text.length > 0) {
        isBtnEnable = true;
      }
    } else {
      isBtnEnable = false;
    }
    updateState(() {});
  }

  // get video thumbnail
  getThumbnail(videofile, StateSetter updateState) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: videofile.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 384,
      // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 100,
    );
    return uint8list;
  }

  // upload file(video) to firebase storage
  Future<Null> updatedVideo(StateSetter updateState, imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var firebaseStorageRef =
        FirebaseStorage.instance.ref().child('postsImages/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(io.File(imageFile.path));
    uploadTask.whenComplete(() {
      firebaseStorageRef.getDownloadURL().then((value1) async {
        if (isThumbnail) {
          Utilities.hide();

          postVideoFilesMap[_thumbFile] = imageFile;

          // getThumbnail(videoFile, updateState).then((value) async {
          //   Directory tempDir = await getTemporaryDirectory();
          //   String tempPath = tempDir.path;
          //   var filePath = tempPath +
          //       '/${DateTime.now().millisecondsSinceEpoch.toString()}.jpeg';
          //   // file_01.tmp is dump file, can be anything
          //   await File(filePath).writeAsBytes(value).then((thumbFile) {
          //     imageFileList.add(thumbFile);
          //
          //     updated(updateState, thumbFile);
          //   });
          // });
        }
        mediaMap["type"] = "video";
        mediaMap["url"] = value1;
        mediaPostModel.mediaType = "video";
        mediaPostModel.url = value1;
      }).catchError((error) {
      });
    });
    updateState(() {});
  }

  // Create file path in phone
  Future<File> writeToFile(var uint8list) async {
    // final buffer = data.buffer;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var filePath =
        tempPath + '/${DateTime.now().millisecondsSinceEpoch.toString()}.jpeg';
    // file_01.tmp is dump file, can be anything
    await File(filePath).writeAsBytes(uint8list);
    // return new File(filePath).writeAsBytes(
    //     buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(
      () {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final PostCardModel item = cardList.removeAt(oldIndex);
        cardList.insert(newIndex, item);
      },
    );
  }

  bool _reorderCallback(Key item, Key newPosition) {
    int draggingIndex = _indexOfKey(item);
    int newPositionIndex = _indexOfKey(newPosition);

    // Uncomment to allow only even target reorder possition
    // if (newPositionIndex % 2 == 1)
    //   return false;

    final draggedItem = cardList[draggingIndex];
    setState(() {
      cardList.removeAt(draggingIndex);
      cardList.insert(newPositionIndex, draggedItem);
    });
    return true;
  }

  void _reorderDone(Key item) {
    final draggedItem = cardList[_indexOfKey(item)];
  }

  // Returns index of item with given key
  int _indexOfKey(Key key) {
    return cardList.indexWhere((PostCardModel d) => d.key == key);
  }

  // post cards list process
  Future<Null> updatedCardList(
      StateSetter updateState, int position, bool isDelete) async {
    updateState(() {
      if (isDelete == true) {
        cardModelList.removeAt(position);
        if (cardModelList.length > 0) {
          if (postCardIDController.text.trim().length > 0 &&
              postCardNameController.text.trim().length > 0) {
            isCardBtnEnable = true;
          } else {
            isCardBtnEnable = false;
          }
        } else {
          if (imageCardFile != null &&
              postCardIDController.text.trim().length > 0 &&
              postCardNameController.text.trim().length > 0) {
            isCardBtnEnable = true;
          } else {
            isCardBtnEnable = false;
          }
        }
      } else {
        postCardIDController.text = cardModelList[position].cardId;
        postCardNameController.text = cardModelList[position].cardName;
        imageCardFile = cardModelList[position].cardImage;
      }
    });
  }

  // add post cards bottom sheet
  void addCardBottomSheetUI(context, postId, String title, String description,
      String goal, List<String> imageList) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          child: SafeArea(
            // child: SingleChildScrollView(
            // controller: _controller,
            child: StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return Padding(
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
                                child: Text(
                                  Constants.postJourney,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: AppColors.titleTextColor,
                                      fontFamily: Constants.boldFont,
                                      fontSize: ScreenUtil().setSp(28)),
                                ),
                              ),
                              SizedBox(height: ScreenUtil().setSp(12)),
                              Card(
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25))),
                                child: Stack(
                                  children: [
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              100 *
                                              25,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(25.0),
                                        ),
                                      ),
                                      child: PageView.builder(
                                          itemCount: imageList.length,
                                          controller: pageController,
                                          onPageChanged: (pos) {
                                            this.imagePageIndex = pos;
                                          },
                                          itemBuilder: (context, indexView) {
                                            imagePageIndex = indexView;

                                            return Hero(
                                              tag: 'homePageImage' +
                                                  indexView.toString(),
                                              child: CachedNetworkImage(
                                                imageUrl: imageList[indexView],
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
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
                                                    setPostDefaultImage(
                                                        context),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        setPostDefaultImage(
                                                            context),
                                              ),
                                            );
                                          }),
                                    ),
                                    Positioned(
                                      right: 10,
                                      top: 0,
                                      bottom: 0,
                                      child: Visibility(
                                        visible: imagePageIndex <=
                                                imageList.length - 1 &&
                                            imageList.length > 1,
                                        maintainAnimation: true,
                                        maintainSize: false,
                                        maintainState: true,
                                        child: InkWell(
                                          onTap: () {
                                            imagePageIndex += 1;
                                            if (imagePageIndex <
                                                    imageList.length - 1 &&
                                                imageList.length > 1) {
                                            }
                                            pageController.nextPage(
                                                duration:
                                                    Duration(milliseconds: 100),
                                                curve: Curves.ease);
                                            setState(() {});
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
                                                  color: Colors.black,
                                                )),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 10,
                                      top: 0,
                                      bottom: 0,
                                      child: Visibility(
                                        visible: imagePageIndex > 0,
                                        maintainAnimation: true,
                                        maintainSize: false,
                                        maintainState: true,
                                        child: InkWell(
                                          onTap: () {
                                            imagePageIndex -= 1;
                                            pageController.previousPage(
                                                duration:
                                                    Duration(milliseconds: 100),
                                                curve: Curves.ease);
                                          },
                                          child: Center(
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                ),
                                                width: 25,
                                                height: 25,
                                                child: Transform.rotate(
                                                  angle: 90,
                                                  child: SvgPicture.asset(
                                                    Constants.rightArrow,
                                                    fit: BoxFit.contain,
                                                    color: Colors.black,
                                                  ),
                                                )),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                title,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: AppColors.titleTextColor,
                                    fontFamily: Constants.boldFont,
                                    fontSize: ScreenUtil().setSp(27)),
                              ),
                              SizedBox(height: 6),
                              Text(
                                description,
                                maxLines: 2,
                                style: TextStyle(
                                    color: AppColors.titleTextColor,
                                    fontFamily: Constants.regularFont,
                                    fontSize: ScreenUtil().setSp(23)),
                              ),
                              SizedBox(height: 6),
                              Text(
                                goal,
                                maxLines: 2,
                                style: TextStyle(
                                    color: AppColors.titleTextColor,
                                    fontFamily: Constants.regularFont,
                                    fontSize: ScreenUtil().setSp(23)),
                              ),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      Constants.addACard,
                                      style: TextStyle(
                                          color: AppColors.blackColor[500],
                                          fontFamily: Constants.semiBoldFont,
                                          fontSize: ScreenUtil().setSp(24)),
                                    ),
                                    Expanded(
                                      child: Container(),
                                    ),
                                    InkWell(
                                        onTap: () async {
                                          if (cardList.length <= 6) {
                                            var object = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CardDetail(
                                                          postId: postId,
                                                          indexKey:
                                                              cardList.length,
                                                          postVideoFilesMap:
                                                              postVideoFilesMap,
                                                        )));

                                            if (object != null) {
                                              PostCardModel cardModel =
                                                  object["cardObject"];
                                              cardList.add(cardModel);
                                              isCardBtnEnable = true;
                                              setState(() {});
                                            }
                                          } else {
                                            Constants().errorToast(context,
                                                'You can select maximum 6 cards');
                                          }
                                        },
                                        child: Container(
                                            height: ScreenUtil().setSp(80),
                                            child: DottedBorder(
                                                borderType: BorderType.RRect,
                                                color: AppColors.primaryColor,
                                                radius: Radius.circular(40),
                                                dashPattern: [3, 3, 3, 3],
                                                strokeWidth: 1.2,
                                                child: Center(
                                                    child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                      SizedBox(
                                                        width: 10.0,
                                                      ),
                                                      Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width: 18,
                                                        height: 18,
                                                        padding:
                                                            EdgeInsets.all(1.5),
                                                        child: SvgPicture.asset(
                                                          'assets/images/ic_plus.svg',
                                                          alignment:
                                                              Alignment.center,
                                                          color: AppColors
                                                              .primaryColor,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        Constants.addCard,
                                                        style: TextStyle(
                                                          fontSize: ScreenUtil()
                                                              .setSp(24),
                                                          color: AppColors
                                                              .primaryColor,
                                                          fontFamily: Constants
                                                              .semiBoldFont,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10.0,
                                                      ),
                                                    ]))))),
                                  ]),
                              // ReorderableListView(
                              //   onReorder: _onReorder,
                              //   children: <Widget>[
                              //     for (int i = 0;
                              //         i < cardList.length - 1;
                              //         i++)
                              //       CardReorderItem(
                              //         isFirst: i == 0,
                              //         isLast: i == cardList.length - 1,
                              //         postCardModel: cardList[i],
                              //         index: i,
                              //       ),
                              //   ],
                              //   // itemCount: cardList.length,
                              //   // itemBuilder: (context, index) {
                              //   //   return CardReorderItem(
                              //   //     isFirst: index == 0,
                              //   //     isLast: index == cardList.length - 1,
                              //   //     postCardModel: cardList[index],
                              //   //     index: index,
                              //   //   );
                              //   // },
                              // ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Container(
                                  child: cardList.length > 0
                                      ? ListView.builder(
                                          itemCount: cardList.length,
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemBuilder: (BuildContext context,
                                              int positon) {
                                            return CardReorderItem(
                                              isFirst: positon == 0,
                                              isLast: positon ==
                                                  cardList.length - 1,
                                              postCardModel: cardList[positon],
                                              index: positon,
                                            );
                                          })
                                      : Container()),
                              SizedBox(height: ScreenUtil().setSp(32)),
                              Visibility(
                                visible: showCreate,
                                maintainAnimation: true,
                                maintainSize: false,
                                maintainState: true,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Save to Stitch',
                                      style: TextStyle(
                                          color: AppColors.titleTextColor,
                                          fontFamily: Constants.regularFont,
                                          fontSize: ScreenUtil().setSp(23)),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        createStitch(setState,
                                            Constants.stitchCollection, true);
                                      },
                                      child: Text(
                                        'Create Stitch',
                                        style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontFamily: Constants.regularFont,
                                            fontSize: ScreenUtil().setSp(23)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: showCreate,
                                maintainAnimation: true,
                                maintainSize: false,
                                maintainState: true,
                                child: TextFormField(
                                  cursorColor: AppColors.primaryColor,
                                  readOnly: true,
                                  textInputAction: TextInputAction.none,
                                  maxLines: 1,
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
                                      stitchTitle = object["stitch_title"];
                                      setState(() {
                                      });
                                    }
                                  },
                                  controller: TextEditingController(
                                      text: stitchTitle.isNotEmpty
                                          ? stitchTitle
                                          : ''),
                                  decoration: InputDecoration(
                                    counterText: "",
                                    hintText: 'SOLS Recommendations(Default)',
                                    hintStyle: TextStyle(
                                        fontSize: ScreenUtil().setSp(22),
                                        color: Colors.black87),
                                    suffixIcon: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 19, horizontal: 17),
                                      width: 17,
                                      height: 17,
                                      child: SvgPicture.asset(
                                        'assets/images/ic_down_arrow.svg',
                                        fit: BoxFit.contain,
                                        color: AppColors.accentColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                  visible: showCreate,
                                  maintainAnimation: true,
                                  maintainSize: false,
                                  maintainState: true,
                                  child:
                                      SizedBox(height: ScreenUtil().setSp(32))),

                              Visibility(
                                visible: showCreate,
                                maintainAnimation: true,
                                maintainSize: false,
                                maintainState: true,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Save to Routine',
                                      style: TextStyle(
                                          color: AppColors.titleTextColor,
                                          fontFamily: Constants.regularFont,
                                          fontSize: ScreenUtil().setSp(23)),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        createStitch(setState,
                                            Constants.routineCollection, false);
                                      },
                                      child: Text(
                                        'Create Routine',
                                        style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontFamily: Constants.regularFont,
                                            fontSize: ScreenUtil().setSp(23)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: showCreate,
                                maintainAnimation: true,
                                maintainSize: false,
                                maintainState: true,
                                child: TextFormField(
                                  cursorColor: AppColors.primaryColor,
                                  readOnly: true,
                                  textInputAction: TextInputAction.none,
                                  maxLines: 1,
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
                                      routineTitle = object["routine_title"];
                                      setState(() {
                                      });
                                    }
                                  },
                                  controller: TextEditingController(
                                      text: routineTitle.isNotEmpty
                                          ? routineTitle
                                          : ''),
                                  decoration: InputDecoration(
                                    counterText: "",
                                    hintText: 'SOLS Recommendations(Default)',
                                    hintStyle: TextStyle(
                                        fontSize: ScreenUtil().setSp(22),
                                        color: Colors.black87),
                                    suffixIcon: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 19, horizontal: 17),
                                      width: 17,
                                      height: 17,
                                      child: SvgPicture.asset(
                                        'assets/images/ic_down_arrow.svg',
                                        fit: BoxFit.contain,
                                        color: AppColors.accentColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                  visible: showCreate,
                                  maintainAnimation: true,
                                  maintainSize: false,
                                  maintainState: true,
                                  child:
                                      SizedBox(height: ScreenUtil().setSp(32))),

                              Container(
                                color: Colors.transparent,
                                margin: EdgeInsets.only(top: 20),
                                width: MediaQuery.of(context).size.width,
                                height: ScreenUtil().setSp(100),
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40.0),
                                      side: BorderSide(
                                          color: isCardBtnEnable == true
                                              ? AppColors.primaryColor
                                              : AppColors.accentColor)),
                                  onPressed: () {
                                    setState(() {
                                      if (!showCreate) {
                                        showCreate = true;
                                        isCardBtnEnable = true;
                                        setState(() {});
                                        continueCretePost();
                                      } else {
                                        createPostFinal();
                                      }
                                    });
                                  },
                                  color: isCardBtnEnable == true
                                      ? AppColors.primaryColor
                                      : AppColors.accentColor,
                                  textColor: Colors.white,
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                      showCreate
                                          ? 'Create Post'
                                          : Constants.continueTxt,
                                      style: TextStyle(
                                        fontSize: ScreenUtil().setSp(28),
                                        fontFamily: Constants.semiBoldFont,
                                      )),
                                ),
                              ),
                              SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ],
                    ));
              },
              // ),
            ),
          ),
        );
      },
    );
  }

  // add post cards bottom sheet
  void addCardBottomSheet(context) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          child: SafeArea(
            child: SingleChildScrollView(
              controller: _controller,
              child: StatefulBuilder(
                builder: (BuildContext context,
                    void Function(void Function()) setState) {
                  return Padding(
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
                                  child: Text(
                                    Constants.addACard,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: AppColors.titleTextColor,
                                        fontFamily: Constants.boldFont,
                                        fontSize: ScreenUtil().setSp(28)),
                                  ),
                                ),
                                SizedBox(height: ScreenUtil().setSp(12)),
                                Text(
                                  Constants.uploadPhoto,
                                  style: TextStyle(
                                      color: AppColors.accentColor,
                                      fontFamily: Constants.semiBoldFont,
                                      fontSize: ScreenUtil().setSp(24)),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      Constants.addACard,
                                      style: TextStyle(
                                          color: AppColors.blackColor[500],
                                          fontFamily: Constants.semiBoldFont,
                                          fontSize: ScreenUtil().setSp(24)),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (postCardIDController
                                            .text.isNotEmpty) {
                                          if (postCardNameController
                                              .text.isNotEmpty) {
                                            setState(() {
                                              AddCardModel cardModel =
                                                  new AddCardModel(
                                                      imageCardFile,
                                                      postCardIDController.text,
                                                      postCardNameController
                                                          .text);
                                              cardModelList.add(cardModel);
                                              postCardIDController.text = "";
                                              postCardNameController.text = "";
                                              imageCardFile = null;
                                            });
                                            WidgetsBinding.instance
                                                .addPostFrameCallback(
                                              (_) {
                                                _controller
                                                    .animateTo(
                                                        _controller.position
                                                            .maxScrollExtent,
                                                        duration: Duration(
                                                            seconds: 1),
                                                        curve: Curves.ease)
                                                    .then((value) async {});
                                              },
                                            );
                                          }
                                        }
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: ScreenUtil().setSp(100),
                                        child: DottedBorder(
                                          borderType: BorderType.RRect,
                                          color: AppColors.primaryColor,
                                          radius: Radius.circular(40),
                                          dashPattern: [3, 3, 3, 3],
                                          strokeWidth: 1.2,
                                          child: Center(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  alignment: Alignment.center,
                                                  width: 18,
                                                  height: 18,
                                                  padding: EdgeInsets.all(1.5),
                                                  child: SvgPicture.asset(
                                                    'assets/images/ic_plus.svg',
                                                    alignment: Alignment.center,
                                                    color:
                                                        AppColors.primaryColor,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  Constants.addMoreCards,
                                                  style: TextStyle(
                                                    fontSize:
                                                        ScreenUtil().setSp(28),
                                                    color:
                                                        AppColors.primaryColor,
                                                    fontFamily:
                                                        Constants.semiBoldFont,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                    child: cardModelList.length > 0
                                        ? ListView.builder(
                                            itemCount: cardModelList.length,
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemBuilder: (BuildContext context,
                                                int positon) {
                                              return cardListUi(
                                                  positon, setState);
                                            })
                                        : Container()),
                                SizedBox(height: ScreenUtil().setSp(32)),
                                Container(
                                  color: Colors.transparent,
                                  margin: EdgeInsets.only(top: 20),
                                  width: MediaQuery.of(context).size.width,
                                  height: ScreenUtil().setSp(100),
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(40.0),
                                        side: BorderSide(
                                            color: AppColors.primaryColor)),
                                    onPressed: () {
                                      setState(() {
                                        cardModelList.length > 0
                                            ? Navigator.of(context).pop()
                                            : imageCardFile == null
                                                ? Constants().errorToast(
                                                    context,
                                                    Constants.imageFileError)
                                                : postCardIDController.text
                                                            .trim()
                                                            .length ==
                                                        0
                                                    ? Constants().errorToast(
                                                        context, "Add card id")
                                                    : postCardNameController
                                                                .text
                                                                .trim()
                                                                .length ==
                                                            0
                                                        ? Constants()
                                                            .errorToast(context,
                                                                "Add card name")
                                                        : Navigator.of(context)
                                                            .pop();
                                      });
                                    },
                                    color: isCardBtnEnable == true
                                        ? AppColors.primaryColor
                                        : AppColors.accentColor,
                                    textColor: Colors.white,
                                    padding: EdgeInsets.all(10.0),
                                    child: Text(Constants.postJourney,
                                        style: TextStyle(
                                          fontSize: ScreenUtil().setSp(28),
                                          fontFamily: Constants.semiBoldFont,
                                        )),
                                  ),
                                ),
                                SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ],
                      ));
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // image Listing

  Widget imageListUi(BuildContext context, int index,
      void Function(void Function() p1) setState) {
    return imageFileList.length == 0
        ? Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: InkWell(
              onTap: () {
                isCardImage = false;
                isFromPost = true;
                FocusScope.of(context).unfocus();
                _settingModalBottomSheet(context, setState, false);
              },
              child: Container(
                width: 80,
                height: 75,
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  color: AppColors.primaryColor,
                  radius: Radius.circular(6),
                  dashPattern: [3, 3, 3, 3],
                  strokeWidth: 1.2,
                  child: Center(
                    child: Container(
                      alignment: Alignment.center,
                      width: 24,
                      height: 24,
                      padding: EdgeInsets.all(2.5),
                      child: SvgPicture.asset(
                        'assets/images/ic_plus.svg',
                        alignment: Alignment.center,
                        color: AppColors.primaryColor,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        : index < imageFileList.length
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 0.0),
                child: Stack(
                  children: [
                    Container(
                      child: PhysicalModel(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.viewLineColor,
                        elevation: 5,
                        shadowColor: AppColors.shadowColor,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            imageFileList[index],
                            fit: BoxFit.cover,
                            height: 85,
                            width: 80,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            postVideoFilesMap.forEach((key, value) {
                              if (key == imageFileList[index]) {
                                postVideoFilesMap.remove(key);
                              }
                            });
                            imageFileList.removeAt(index);
                          });
                        },
                        child: Container(
                          width: 22,
                          height: 22,
                          padding: EdgeInsets.all(2.0),
                          child: SvgPicture.asset(
                            Constants.redCrossIcon,
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: InkWell(
                  onTap: () {
                    isCardImage = false;
                    isFromPost = true;
                    FocusScope.of(context).unfocus();
                    _settingModalBottomSheet(context, setState, false);
                  },
                  child: Container(
                    width: 80,
                    height: 75,
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      color: AppColors.primaryColor,
                      radius: Radius.circular(6),
                      dashPattern: [3, 3, 3, 3],
                      strokeWidth: 1.2,
                      child: Center(
                        child: Container(
                          alignment: Alignment.center,
                          width: 24,
                          height: 24,
                          padding: EdgeInsets.all(2.5),
                          child: SvgPicture.asset(
                            'assets/images/ic_plus.svg',
                            alignment: Alignment.center,
                            color: AppColors.primaryColor,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
  }

  Widget cardListUi(int position, state) {
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17.0),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: PhysicalModel(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue,
                  elevation: 5,
                  shadowColor: Colors.green[400],
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      cardModelList[position].cardImage,
                      fit: BoxFit.cover,
                      height: 50,
                      width: 50,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: ScreenUtil().setSp(25),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      cardModelList[position].cardName,
                      style: TextStyle(
                          fontFamily: 'epilogue_semibold',
                          fontSize: ScreenUtil().setSp(30),
                          color: Colors.black),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setSp(10),
                  ),
                  Text(
                    'ID . ' + cardModelList[position].cardId,
                    style: TextStyle(
                        fontFamily: 'epilogue_regular',
                        fontSize: ScreenUtil().setSp(30),
                        color: Color(0xFF727272)),
                  ),
                ],
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  updatedCardList(state, position, false);
                },
                child: Container(
                  width: 30,
                  height: 30,
                  padding: EdgeInsets.all(2.5),
                  margin: EdgeInsets.only(right: 5),
                  child: SvgPicture.asset(
                    'assets/images/ic_edit_card.svg',
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  updatedCardList(state, position, true);
                },
                child: Container(
                  width: 30,
                  height: 30,
                  padding: EdgeInsets.all(2.5),
                  margin: EdgeInsets.only(right: 5),
                  child: SvgPicture.asset(
                    'assets/images/ic_delete_group.svg',
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void createPostFinal() {
    showCreate = false;
    imageFileList.clear();
    mediaFileList.clear();
    if (stichId.isNotEmpty || routineId.isNotEmpty) {
      FocusScope.of(context).unfocus();
      Utilities.show(context);

      FirebaseFirestore.instance
          .collection(Constants.posts)
          .doc(postId)
          .update({
        "active": 1,
        "stitch_id": stichId,
        "routine_id": routineId,
        "updated_at": Timestamp.now()
      }).then((value) {
        if (stichId.isNotEmpty) {
          savePostToStitch();
        }
        if (routineId.isNotEmpty) {
          savePostToRoutine();
        }
      }).catchError((err) {
        Utilities.hide();
      });
    } else {
      if (cardList.length == 0) {
        FirebaseFirestore.instance
            .collection(Constants.posts)
            .doc(postId)
            .update({"active": 1, "updated_at": Timestamp.now()});
      }
      Constants().successToast(context, "Post is created successfully");
      MyNavigator.goToHome(context);
    }
  }

  // save post into stitch
  void savePostToStitch() {
    Utilities.hide();

    FirebaseFirestore.instance
        .collection(Constants.stitchCollection)
        .doc(stichId)
        .update({
      'post_ids': FieldValue.arrayUnion([postId])
    }).then((value) {
      Constants().successToast(context, "Post is created successfully");
      setState(() {});
      MyNavigator.goToHome(context);
    });
  }

  // save post into Routine
  void savePostToRoutine() {
    Utilities.hide();
    FirebaseFirestore.instance
        .collection(Constants.routineCollection)
        .doc(routineId)
        .collection(Constants.posts)
        .add({'post_id': postId, 'complete': 0}).then((value) {
      Constants().successToast(context, "Post is created successfully");
      setState(() {});
      MyNavigator.goToHome(context);
    }).onError((error, stackTrace) {
    }).catchError((onError) {
    });
  }

  void continueCretePost() {
    if (cardList.length > 0) {
      FocusScope.of(context).unfocus();
      Utilities.show(context);

      FirebaseFirestore.instance
          .collection(Constants.posts)
          .doc(postId)
          .update({"active": 1, "updated_at": Timestamp.now()});

      for (int i = 0; i < cardList.length; i++) {
        FirebaseFirestore.instance
            .collection(Constants.posts)
            .doc(postId)
            .collection(Constants.cardsColl)
            .get()
            .then((value) {
          value.docs.forEach((element) {
            if (cardList[i].cardId == element.id) {
              FirebaseFirestore.instance
                  .collection(Constants.posts)
                  .doc(postId)
                  .collection(Constants.cardsColl)
                  .doc(element.id)
                  .update({"position": i, "updated_at": Timestamp.now()});
            }
            if (i == cardList.length - 1) {
              Utilities.hide();
            }
          });
        });
      }
    }
  }

  // Upload image to firebase storage
  void uploadImageToFirebase(
      String storageName, String collectionName, setState1, isStitch) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var reference =
        FirebaseStorage.instance.ref().child(storageName).child(fileName);
    UploadTask uploadTask = reference.putFile(imageFileStitch);

    uploadTask.whenComplete(() {
      reference.getDownloadURL().then((downloadUrl) {
        _selectedImageUrl = downloadUrl;

        createStitchEntry(collectionName, setState1, isStitch);
      }).catchError((onError) {
        Utilities.hide();
        Constants().errorToast(context, "$onError , please upload image again");
      });
    });
  }

  // Create stitch

  void createStitchEntry(collectionName, setState1, isStitch) {
    FirebaseFirestore.instance.collection(collectionName).add({
      "created_at": Timestamp.now(),
      "created_by": globalUserId,
      "description": stitchDescriptionController.text.trim(),
      "image": _selectedImageUrl,
      "is_public": isPublicStitch,
      "title": stitchTitleController.text.trim(),
      "updated_at": Timestamp.now()
    }).then((value) {
      // _formKey.currentState?.reset();
      String title = stitchTitleController.text.trim();
      Constants.showSnackBarWithMessage(
          isStitch
              ? "Stitch created successfully!"
              : "Routine created successfully",
          _scaffoldkey,
          context,
          AppColors.greenColor);
      Utilities.hide();
      Future.delayed(const Duration(milliseconds: 1000), () {
        isPublicStitch = true;
        stitchTye = "Public";
        if (isStitch) {
          Navigator.of(context)
              .pop({"stitch_id": value.id, "stitch_title": title});
        } else {
          Navigator.of(context)
              .pop({"routine_id": value.id, "routine_title": title});
        }

        imageFileStitch = null;
        stitchDescriptionController.clear();
        stitchTitleController.clear();
      });
    }).catchError((error) {
      Utilities.hide();
    });
  }

  // check validations
  checkValids(BuildContext context, String collectionName, String storageName,
      setState1, isStitch) {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState.validate()) {
      Utilities.show(context);
      if (imageFileStitch == null) {
        _selectedImageUrl = defaultPostImage;
        createStitchEntry(collectionName, setState1, isStitch);
      } else {
        uploadImageToFirebase(storageName, collectionName, setState1, isStitch);
      }
    } else {
      Constants().errorToast(context, "Please fill all the fields");
    }
  }

  // Create stitch bottom sheet

  void createStitch(setState1, collectionName, isStitch) async {
    var object = await showModalBottomSheet(
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
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: new Container(
                  color: Colors.transparent,
                  child: new Container(
                    /*  */
                    padding: EdgeInsets.all(ScreenUtil().setSp(40)),
                    decoration: new BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(25.0),
                            topRight: const Radius.circular(25.0))),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 1.0, top: 10.0),
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
                              isStitch
                                  ? 'Create a new Stitch'
                                  : 'Create a new Routine',
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
                              isStitch
                                  ? 'Upload Stitch Thumbnail'
                                  : 'Upload Routine Thumbnail',
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
                        // isBucketSelected == true?
                        InkWell(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            _settingModalBottomSheet(context, setState, true);
                            // imageSelector(context, "gallery",setState);
                          },
                          child: imageFileStitch == null
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    DottedBorder(
                                      padding: EdgeInsets.all(
                                        ScreenUtil().setSp(40),
                                      ),
                                      borderType: BorderType.RRect,
                                      color: Color(0xFF1A58E7).withOpacity(0.7),
                                      radius: Radius.circular(10),
                                      dashPattern: [2.5, 4, 2, 4],
                                      strokeWidth: 1.5,
                                      child: SvgPicture.asset(
                                        'assets/images/ic_media_image.svg',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  child: PhysicalModel(
                                    borderRadius: BorderRadius.circular(10),
                                    color: AppColors.viewLineColor,
                                    elevation: 5,
                                    shadowColor: AppColors.shadowColor,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        imageFileStitch,
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
                          isStitch ? 'Stitch Name' : 'Routine Name',
                          style: TextStyle(
                              fontFamily: 'epilogue_semibold',
                              fontSize: ScreenUtil().setSp(25),
                              color: Color(0xFF727272)),
                        ),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: stitchTitleController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return isStitch
                                  ? 'Enter stitch title!'
                                  : 'Enter routine title';
                            }
                            return null;
                          },
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(30),
                              fontFamily: 'epilogue_regular'),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          isStitch
                              ? 'Stitch Description'
                              : 'Routine Description',
                          style: TextStyle(
                              fontFamily: 'epilogue_semibold',
                              fontSize: ScreenUtil().setSp(25),
                              color: Color(0xFF727272)),
                        ),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: stitchDescriptionController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return isStitch
                                  ? 'Enter stitch description!'
                                  : 'Enter routine description';
                            }
                            return null;
                          },
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(30),
                              fontFamily: 'epilogue_regular'),
                        ),

                        SizedBox(height: 15),
                        Text(
                          Constants.privacyType,
                          style: TextStyle(
                              color: AppColors.accentColor,
                              fontFamily: Constants.semiBoldFont,
                              fontSize: ScreenUtil().setSp(24)),
                        ),
                        InkWell(
                          onTap: () {
                            if (isPublicStitch) {
                              stitchTye = 'Private';
                            } else {
                              stitchTye = 'Public';
                            }
                            isPublicStitch = !isPublicStitch;
                            setState(() {});
                          },
                          child: Container(
                            width: 100.0,
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 10.0),
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0)),
                                border: Border.all(
                                    color: AppColors.appGreyColor[500],
                                    width: 1)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  isPublicStitch
                                      ? Constants.publicIcon
                                      : Constants.privateIcon,
                                  color: AppColors.accentColor,
                                  height: 15.0,
                                  width: 15.0,
                                ),
                                SizedBox(
                                  width: 4.0,
                                ),
                                Text(
                                  '$stitchTye',
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(28),
                                      color: AppColors.accentColor,
                                      fontFamily: Constants.mediumFont),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: ScreenUtil().setSp(95),
                          width: MediaQuery.of(context).size.width,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40.0),
                              side: BorderSide(color: AppColors.primaryColor),
                            ),
                            color: AppColors.primaryColor,
                            onPressed: () {
                              // createStitch();
                              checkValids(
                                  context,
                                  collectionName,
                                  isStitch
                                      ? Constants.stitchImagesFolder
                                      : Constants.routineImagesFolder,
                                  setState1,
                                  isStitch);
                            },
                            child: Text(
                              isStitch ? 'Create Stitch' : 'Create Routine',
                              style: TextStyle(
                                  fontFamily: 'epilogue_semibold',
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
              ),
            );
          },
        );
      },
    );
    if (object != null) {
      if (isStitch) {
        stichId = object['stitch_id'];
        stitchTitle = object['stitch_title'];
      } else {
        routineId = object['routine_id'];
        routineTitle = object['routine_title'];
      }

      setState1(() {});
    }
  }

  // set post default placeholder
  static setPostDefaultImage(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: ScreenUtil().setSp(370),
        decoration: BoxDecoration(
          color: AppColors.viewLineColor,
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ));
  }
}
