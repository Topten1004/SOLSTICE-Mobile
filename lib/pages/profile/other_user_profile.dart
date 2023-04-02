import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solstice/apiservice/api_call.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/forum_model.dart' hide UserFirebaseModel;
import 'package:solstice/model/forum_model_new.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/model/stitch_routine_model.dart';
import 'package:solstice/model/tabs_models.dart';
import 'package:solstice/pages/buckets_stitch/routine_detail_screen.dart';
import 'package:solstice/pages/chat/firebase_chat_screen.dart';
import 'package:solstice/pages/home/post_detail_screen.dart';
import 'package:solstice/pages/profile/followers_listing_new_screen.dart';
import 'package:solstice/pages/views/bucket_stitch_list_item.dart';
import 'package:solstice/pages/views/forum_list_item.dart';
import 'package:solstice/pages/views/home_post_list_item.dart';
import 'package:solstice/pages/views/routine_tab_list_item.dart';
import 'package:solstice/pages/views/tab_list_item.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/my_navigator.dart';

import '../../utils/constants.dart';

class OtherUserProfile extends StatefulWidget {
  String userID, userName, userImage;

  OtherUserProfile({this.userID, this.userImage, this.userName});
  @override
  _OtherUserProfileState createState() => _OtherUserProfileState();
}

class _OtherUserProfileState extends State<OtherUserProfile> {
  bool isBucketSelected = true;
  var selectedBottomTab = "Posts";
  List<TabsModel> bucketTabsList = new List<TabsModel>.empty(growable: true);
  List<StitchRoutineModel> bucketList =
      new List<StitchRoutineModel>.empty(growable: true);
  int followersCount = 0;
  int followingsCount = 0;

  String userId = "",
      userName = "",
      userImage = "",
      userAddress = "",
      userToken = "";
  bool isFollow = false;

  List<String> _bodyPartList = new List.empty(growable: true);
  List<String> _interestsStrList = new List.empty(growable: true);
  List<String> _sportsStrList = new List.empty(growable: true);
  List<String> _occupationStrList = new List.empty(growable: true);
  List<String> _activeInjuriesStrList = new List.empty(growable: true);
  List<String> _previousInjuriesStrList = new List.empty(growable: true);
  List<String> _certificationsStrList = new List.empty(growable: true);
  List<String> _coachesStrList = new List.empty(growable: true);
  String selectedInputField = "";
  TextEditingController locationTextController = new TextEditingController();

  UserFirebaseModel currentUserDetail = new UserFirebaseModel();

  bool isActiveInjuriesPrivate = true;
  bool isPreviousInjuriesPrivate = true;

  @override
  void initState() {
    super.initState();
    userId = widget.userID;
    userName = widget.userName;
    userImage = widget.userImage;
    bucketTabsList.add(new TabsModel("Posts", true));
    bucketTabsList.add(new TabsModel("Stitch", false));
    bucketTabsList.add(new TabsModel("Routines", false));
    bucketTabsList.add(new TabsModel("Forum", false));
    bucketTabsList.add(new TabsModel("About", false));

    getProfileData();
    getUserDataFromDB();
  }

  Future<String> getProfileData() async {
    FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(userId)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      Map<String, dynamic> mapObject = documentSnapshot.data();
      if (mounted) {
        setState(() {
     
          try {
            userName = documentSnapshot['userName'];
            userImage = documentSnapshot['userImage'];

            if (mapObject.containsKey("location")) {
              userAddress = documentSnapshot['location']['address'];
            }
            if (mapObject.containsKey("token")) {
              userToken = documentSnapshot['token'];
            }
          } catch (e) {}
        });
      }
    }).onError((e) => print(e));

    // for followers count
    var snapshots = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(userId)
        .collection(Constants.FollowersFB)
        .snapshots();
    snapshots.listen((querySnapshot) {
      followersCount = querySnapshot.docs.length;
      if (mounted) {
        setState(() {});
      }
    });

    // for followings count
    var followingsSnapshot = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(userId)
        .collection(Constants.FollowingsFB)
        .snapshots();

    followingsSnapshot.listen((querySnapshot) {
      followingsCount = querySnapshot.docs.length;
      if (mounted) {
        setState(() {});
      }
    });

    // for check is me followd
    var isFollowSnapShot = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(userId)
        .collection(Constants.FollowersFB)
        .where("userId", isEqualTo: globalUserId)
        .snapshots();

    isFollowSnapShot.listen((querySnapshot) {
      isFollow = querySnapshot.docs.length > 0 ? true : false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(color: Colors.white),
        ),
        Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).padding.top,
            ),
            Expanded(
              flex: 1,
              child: Container(color: Colors.white, child: profileUi()),
            ),
          ],
        ),
      ],
    ));
  }

  Widget profileUi() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
                left: ScreenUtil().setSp(16),
                right: ScreenUtil().setSp(16),
                top: ScreenUtil().setSp(16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 22,
                    height: 22,
                    padding: EdgeInsets.all(2.5),
                    margin: EdgeInsets.only(left: 8, top: 8),
                    child: SvgPicture.asset(
                      'assets/images/ic_back.svg',
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: ScreenUtil().setSp(20)),
                    child: Stack(
                      children: [
                        Container(
                          height: 100,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              Container(
                                height: 90,
                                width: 90,
                                child: CachedNetworkImage(
                                  imageUrl: (userImage.contains("https:") ||
                                          userImage.contains("http:"))
                                      ? userImage
                                      : UrlConstant.BaseUrlImg + userImage,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(90.0)),
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) => Center(
                                      child: SizedBox(
                                    width: 15.0,
                                    height: 15.0,
                                    child: new CircularProgressIndicator(),
                                  )),
                                  errorWidget: (context, url, error) =>
                                      setUserDefaultCircularImage(),
                                ),
                              ),
                              /*RotationTransition(
                                turns: new AlwaysStoppedAnimation(90 / 360),
                                child: Container(
                                  height: 90,
                                  width: 90,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(90.0)),
                                    gradient: LinearGradient(
                                      colors: [
                                        userImage != "null" && userImage != ""
                                            ? Colors.transparent
                                            : Colors.white10,
                                        Colors.white,
                                      ],
                                    ),
                                  ),
                                ),
                              )*/
                            ],
                          ),
                        ),
                        /*Container(
                          height: 120,
                          alignment: Alignment.bottomCenter,
                          child: new Text(
                            userName,
                            style: TextStyle(
                                fontSize: 45,
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontFamily: "tahu"),
                          ),
                        ),*/
                      ],
                    ),
                  ),
                ),
                (userId != globalUserId)
                    ? Container(
                        width: 22,
                        height: 22,
                      )
                    : InkWell(
                        onTap: () {
                          MyNavigator.goToProfileSetting(context);
                        },
                        child: Container(
                          width: 22,
                          height: 22,
                          padding: EdgeInsets.all(1.5),
                          margin: EdgeInsets.only(right: 8, top: 8),
                          child: SvgPicture.asset(
                            'assets/images/ic_settings.svg',
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            margin: EdgeInsets.only(
                left: ScreenUtil().setSp(36), right: ScreenUtil().setSp(36)),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    child: text(userName, Constants.boldFont, 20.0,
                        FontWeight.bold, Colors.black),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      followUnfollowCount(userId);
                    });
                  },
                  child: Container(
                    width: 90,
                    height: 30,
                    child: new Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            isFollow ? Icons.check : Icons.add,
                            color: isFollow
                                ? Colors.white
                                : AppColors.primaryColor,
                            size: 16,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 2),
                            child: Text(isFollow ? "Followed" : "Follow",
                                style: new TextStyle(
                                    color: isFollow
                                        ? Colors.white
                                        : AppColors.primaryColor,
                                    fontFamily: Constants.mediumFont,
                                    //fontWeight: FontWeight.bold,
                                    fontSize: 12.0)),
                          ),
                        ],
                      ),
                    ),
                    decoration: new BoxDecoration(
                      color: isFollow
                          ? AppColors.primaryColor
                          : Color.fromRGBO(235, 241, 255, 1),
                      border: new Border.all(
                          width: 1.0, color: AppColors.primaryColor),
                      borderRadius:
                          const BorderRadius.all(const Radius.circular(26.0)),
                    ),
                  ),
                ),
                SizedBox(
                  width: 6,
                ),
                if (userId != globalUserId)
                  InkWell(
                    onTap: () {
                      //followUnfollowCount(userId);

                      String chatRoomId =
                          Constants.getChatRoomId(globalUserId, userId);

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatFirebase(
                                    receiverIdIntent: userId,
                                    chatRoomIdIntent: chatRoomId,
                                  )));
                    },
                    child: Container(
                      width: 90,
                      height: 30,
                      child: new Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'assets/images/ic_chat_unactive.png',
                              width: ScreenUtil().setSp(32),
                              height: ScreenUtil().setSp(32),
                              color: AppColors.primaryColor,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 2),
                              child: Text("Chat",
                                  style: new TextStyle(
                                      color: AppColors.primaryColor,
                                      fontFamily: Constants.mediumFont,
                                      //fontWeight: FontWeight.bold,
                                      fontSize: 12.0)),
                            ),
                          ],
                        ),
                      ),
                      decoration: new BoxDecoration(
                        color: Color.fromRGBO(235, 241, 255, 1),
                        border: new Border.all(
                            width: 1.0, color: AppColors.primaryColor),
                        borderRadius:
                            const BorderRadius.all(const Radius.circular(26.0)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 13,
          ),
          Container(
            margin: EdgeInsets.only(
                left: ScreenUtil().setSp(36), right: ScreenUtil().setSp(36)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userAddress != null && userAddress != "")
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          width: 16,
                          height: 16,
                          child: SvgPicture.asset(
                            'assets/images/ic_marker.svg',
                            alignment: Alignment.center,
                            fit: BoxFit.fill,
                            color: AppColors.lightGreyColor,
                          )),
                      text(userAddress, Constants.regularFont, 13.0,
                          FontWeight.normal, AppColors.lightGreyColor)
                    ],
                  ),
                if (userAddress != null && userAddress != "")
                  SizedBox(
                    height: 8,
                  ),
                text(
                    "Trinity College, Boston Boxing Club",
                    Constants.regularFont,
                    13.0,
                    FontWeight.normal,
                    AppColors.lightGreyColor),
                SizedBox(
                  height: 8,
                ),
                text("User Choice (limit words)", Constants.regularFont, 13.0,
                    FontWeight.normal, AppColors.lightGreyColor),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          followersCountLayout(),
          SizedBox(
            height: 30,
          ),
          tabLayout(),
          SizedBox(
            height: 20,
          ),
          bottomLayout()
        ],
      ),
    );
  }

  void followUnfollowCount(String followUserId) {
    if (isFollow) {
      FirebaseFirestore.instance
          .collection(Constants.UsersFB)
          .doc(followUserId)
          .collection(Constants.FollowersFB)
          .doc(globalUserId)
          .delete();

      FirebaseFirestore.instance
          .collection(Constants.UsersFB)
          .doc(globalUserId)
          .collection(Constants.FollowingsFB)
          .doc(followUserId)
          .delete();
    } else {
      FirebaseFirestore.instance
          .collection(Constants.UsersFB)
          .doc(followUserId)
          .collection(Constants.FollowersFB)
          .doc(globalUserId)
          .set({'userId': globalUserId});

      FirebaseFirestore.instance
          .collection(Constants.UsersFB)
          .doc(globalUserId)
          .collection(Constants.FollowingsFB)
          .doc(followUserId)
          .set({'userId': followUserId});

      if (followUserId != globalUserId) {
        sendNotification();
      }
    }
  }

  Future<void> getUserDataFromDB() async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(globalUserId)
        .get();
    if (ds != null) {
      Map<String, dynamic> mapObject = ds.data();
      try {
        _interestsStrList = mapObject.containsKey("interestArray")
            ? mapObject['interestArray'].cast<String>()
            : List.empty(growable: true);
        _sportsStrList = mapObject.containsKey("sportsArray")
            ? mapObject['sportsArray'].cast<String>()
            : List.empty(growable: true);
        _occupationStrList = mapObject.containsKey("occupationArray")
            ? mapObject['occupationArray'].cast<String>()
            : List.empty(growable: true);
        _activeInjuriesStrList = mapObject.containsKey("activeInjuriesArray")
            ? mapObject['activeInjuriesArray'].cast<String>()
            : List.empty(growable: true);
        _previousInjuriesStrList =
            mapObject.containsKey("previousInjuriesArray")
                ? mapObject['previousInjuriesArray'].cast<String>()
                : List.empty(growable: true);
        _certificationsStrList = mapObject.containsKey("achievementsArray")
            ? mapObject['achievementsArray'].cast<String>()
            : List.empty(growable: true);
        _coachesStrList = mapObject.containsKey("coachesArray")
            ? mapObject['coachesArray'].cast<String>()
            : List.empty(growable: true);

        isActiveInjuriesPrivate =
            mapObject.containsKey("isActiveInjuriesPublic")
                ? !mapObject["isActiveInjuriesPublic"]
                : true;

        isPreviousInjuriesPrivate =
            mapObject.containsKey("isPreviousInjuriesPublic")
                ? !mapObject["isPreviousInjuriesPublic"]
                : true;

        if (mapObject.containsKey("location")) {
          var currentAddress = ds['location']['address'];

          locationTextController.text = currentAddress;
        }
      } catch (e) {}

      if (mounted) setState(() {});
    }
  }

  void sendNotification() {
    var dataPayload = jsonEncode({
      'to': userToken,
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

    ApiCall.sendPushMessage(userToken, dataPayload);
  }

  Stream<dynamic> fetchTabsSnapshots() {
    if (selectedBottomTab == "Posts") {
      return FirebaseFirestore.instance
          .collection(Constants.posts)
          .where('created_by', isEqualTo: userId)
          .snapshots();
    } else if (selectedBottomTab == "Stitch") {
      return FirebaseFirestore.instance
          .collection(Constants.stitchCollection)
          .where('created_by', isEqualTo: userId)
          .where("is_public", isEqualTo: true)
          .snapshots();
    } else if (selectedBottomTab == "Routines") {
      return FirebaseFirestore.instance
          .collection(Constants.routineCollection)
          .where('created_by', isEqualTo: userId)
          .where("is_public", isEqualTo: true)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection(Constants.forumsCollection)
          .where('created_by', isEqualTo: userId)
          .snapshots();
    }
  }

  Widget bottomLayout() {
    return selectedBottomTab != "About"
        ? MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: StreamBuilder(
                // stream: FirebaseFirestore.instance
                //     .collection(Constants.stitchCollection)
                //     .where('created_by', isEqualTo: userId)
                //     .snapshots(),
                stream: fetchTabsSnapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor)),
                    );
                  }
                  if (snapshot.data.docs.length == 0) {
                    return Center(
                        child: Text(
                      'No Data',
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                      textAlign: TextAlign.center,
                    ));
                  } else {
                    if (selectedBottomTab == "Posts") {
                      return profileTabListing(context, snapshot);
                    } else if (selectedBottomTab == "Stitch") {
                      return stitchListing(context, snapshot);
                    } else if (selectedBottomTab == "Routines") {
                      return routineListing(context, snapshot);
                    } else if (selectedBottomTab == "Forum") {
                      //return profileTabListing(context, snapshot);
                      return forumListing(context, snapshot);
                    }
                  }
                }))
        : Container(child: aboutYouPage());
  }

  Widget aboutYouPage() {
    return Container(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(36),
              right: ScreenUtil().setWidth(36),
              bottom: ScreenUtil().setHeight(26)),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_interestsStrList != null && _interestsStrList.length > 0)
                  lable("Goals/Interest"),
                if (_interestsStrList != null && _interestsStrList.length > 0)
                  Container(
                    margin: EdgeInsets.only(
                        top: ScreenUtil().setSp(20),
                        bottom: ScreenUtil().setSp(10),
                        right: ScreenUtil().setSp(20)),
                    child: Wrap(
                      children: [
                        for (int i = 0; i < _interestsStrList.length; i++)
                          Container(
                              margin: EdgeInsets.all(2),
                              child: setTags(
                                  _interestsStrList[i], _interestsStrList))
                      ],
                    ),
                  ),
                if (_interestsStrList != null && _interestsStrList.length > 0)
                  Container(
                    height: 0.8,
                    color: AppColors.accentColor,
                  ),
                if (locationTextController.text.isNotEmpty)
                  lable(Constants.location),
                if (locationTextController.text.isNotEmpty)
                  Container(
                    child: TextFormField(
                      enabled: false,
                      controller: locationTextController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: /*"Enter your "+Constants.location*/ "User Input",
                        suffixIcon: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 13),
                          width: 19,
                          height: 19,
                          child: SvgPicture.asset(
                            'assets/images/ic_marker.svg',
                            fit: BoxFit.contain,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        hintStyle: TextStyle(
                            color: Color(0xFF727272),
                            fontFamily: Constants.regularFont,
                            fontSize: ScreenUtil().setSp(25)),
                      ),
                    ),
                  ),
                if (locationTextController.text.isNotEmpty)
                  Container(
                    height: 0.8,
                    color: AppColors.accentColor,
                  ),
                if (_sportsStrList != null && _sportsStrList.length > 0)
                  lable(Constants.sportActivity),
                if (_sportsStrList != null && _sportsStrList.length > 0)
                  Container(
                    margin: EdgeInsets.only(
                        top: ScreenUtil().setSp(20),
                        bottom: ScreenUtil().setSp(10),
                        right: ScreenUtil().setSp(20)),
                    child: Wrap(
                      children: [
                        for (int i = 0; i < _sportsStrList.length; i++)
                          Container(
                              margin: EdgeInsets.all(2),
                              child: setTags(_sportsStrList[i], _sportsStrList))
                      ],
                    ),
                  ),
                if (_sportsStrList != null && _sportsStrList.length > 0)
                  Container(
                    height: 0.8,
                    color: AppColors.accentColor,
                  ),
                if (_occupationStrList != null && _occupationStrList.length > 0)
                  lable(Constants.occupation),
                if (_occupationStrList != null && _occupationStrList.length > 0)
                  Container(
                    margin: EdgeInsets.only(
                        top: ScreenUtil().setSp(20),
                        bottom: ScreenUtil().setSp(10),
                        right: ScreenUtil().setSp(20)),
                    child: Wrap(
                      children: [
                        for (int i = 0; i < _occupationStrList.length; i++)
                          Container(
                              margin: EdgeInsets.all(2),
                              child: setTags(
                                  _occupationStrList[i], _occupationStrList))
                      ],
                    ),
                  ),
                if (_occupationStrList != null && _occupationStrList.length > 0)
                  Container(
                    height: 0.8,
                    color: AppColors.accentColor,
                  ),
                if (_activeInjuriesStrList != null &&
                    _activeInjuriesStrList.length > 0 &&
                    !isActiveInjuriesPrivate)
                  lable(Constants.activeInjuries),
                if (_activeInjuriesStrList != null &&
                    _activeInjuriesStrList.length > 0 &&
                    !isActiveInjuriesPrivate)
                  Container(
                    margin: EdgeInsets.only(
                        top: ScreenUtil().setSp(20),
                        bottom: ScreenUtil().setSp(10),
                        right: ScreenUtil().setSp(20)),
                    child: Wrap(
                      children: [
                        for (int i = 0; i < _activeInjuriesStrList.length; i++)
                          Container(
                              margin: EdgeInsets.all(2),
                              child: setTags(_activeInjuriesStrList[i],
                                  _activeInjuriesStrList))
                      ],
                    ),
                  ),
                if (_activeInjuriesStrList != null &&
                    _activeInjuriesStrList.length > 0 &&
                    !isActiveInjuriesPrivate)
                  Container(
                    height: 0.8,
                    color: AppColors.accentColor,
                  ),
                if (_previousInjuriesStrList != null &&
                    _previousInjuriesStrList.length > 0 &&
                    !isPreviousInjuriesPrivate)
                  lable(Constants.previousInjuries),
                if (_previousInjuriesStrList != null &&
                    _previousInjuriesStrList.length > 0 &&
                    !isPreviousInjuriesPrivate)
                  Container(
                    margin: EdgeInsets.only(
                        top: ScreenUtil().setSp(20),
                        bottom: ScreenUtil().setSp(10),
                        right: ScreenUtil().setSp(20)),
                    child: Wrap(
                      children: [
                        for (int i = 0;
                            i < _previousInjuriesStrList.length;
                            i++)
                          Container(
                              margin: EdgeInsets.all(2),
                              child: setTags(_previousInjuriesStrList[i],
                                  _previousInjuriesStrList))
                      ],
                    ),
                  ),
                if (_previousInjuriesStrList != null &&
                    _previousInjuriesStrList.length > 0)
                  Container(
                    height: 0.8,
                    color: AppColors.accentColor,
                  ),
                if (_certificationsStrList != null &&
                    _certificationsStrList.length > 0)
                  lable(Constants.achievementsCertifications),
                if (_certificationsStrList != null &&
                    _certificationsStrList.length > 0)
                  Container(
                    margin: EdgeInsets.only(
                        top: ScreenUtil().setSp(20),
                        bottom: ScreenUtil().setSp(10),
                        right: ScreenUtil().setSp(20)),
                    child: Wrap(
                      children: [
                        for (int i = 0; i < _certificationsStrList.length; i++)
                          Container(
                              margin: EdgeInsets.all(2),
                              child: setTags(_certificationsStrList[i],
                                  _certificationsStrList))
                      ],
                    ),
                  ),
                if (_certificationsStrList != null &&
                    _certificationsStrList.length > 0)
                  Container(
                    height: 0.8,
                    color: AppColors.accentColor,
                  ),
                if (_coachesStrList != null && _coachesStrList.length > 0)
                  lable(Constants.coachesInstructors),
                if (_coachesStrList != null && _coachesStrList.length > 0)
                  Container(
                    margin: EdgeInsets.only(
                        top: ScreenUtil().setSp(20),
                        bottom: ScreenUtil().setSp(10),
                        right: ScreenUtil().setSp(20)),
                    child: Wrap(
                      children: [
                        for (int i = 0; i < _coachesStrList.length; i++)
                          Container(
                              margin: EdgeInsets.all(2),
                              child:
                                  setTags(_coachesStrList[i], _coachesStrList))
                      ],
                    ),
                  ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  setTags(bodyPartName, List<String> tagsList) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.0),
        color: AppColors.primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 6.0, bottom: 5, right: 7, left: 11),
        child: Text(
          bodyPartName,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Colors.white,
              fontFamily: Constants.regularFont,
              fontSize: ScreenUtil().setSp(23)),
        ),
      ),
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
                fontFamily: Constants.boldFont,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
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

  // profile tab listing
  Widget profileTabListing(BuildContext context, snapshots) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: snapshots.data.docs.length,
      itemBuilder: (BuildContext context, int index) {
        List rev = snapshots.data.docs.reversed.toList();

        PostFeedModel message = PostFeedModel.fromSnapshot(rev[index]);

        return FutureBuilder(
            future: loadUser(rev[index].data()["created_by"]),
            builder: (BuildContext context,
                AsyncSnapshot<UserFirebaseModel> userFirebase2) {
              message.userFirebaseModel = userFirebase2.data;
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

  Widget stitchListing(BuildContext context, snapshots) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: snapshots.data.docs.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        List stitchList = snapshots.data.docs.reversed.toList();
        StitchRoutineModel sitchmodel =
            StitchRoutineModel.fromSnapshot(stitchList[index]);

        return new InkWell(
          //highlightColor: Colors.red,
          splashColor: AppColors.primaryColor,
          // onTap: () {
          //   setState(() {
          //     _postDetailTapped(bucketList[index], index);
          //   });
          // },
          child: new BucketStitchListItem(
            sitchmodel,
            index,
            fromPostPage: false,
          ),
        );
      },
    );
  }

  Widget routineListing(BuildContext context, snapshots) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: snapshots.data.docs.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        List stitchList = snapshots.data.docs.reversed.toList();
        StitchRoutineModel routineModel =
            StitchRoutineModel.fromSnapshot(stitchList[index]);
        return new InkWell(
          //highlightColor: Colors.red,
          splashColor: AppColors.primaryColor,
          onTap: () {
            setState(() {
              routineDetail(routineModel.id);
            });
          },
          child: new RoutineTabListItem(routineModel, index),
        );
      },
    );
  }

  void routineDetail(routineId) async {
    Map results = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return RoutineDetailScreen(
            routineIDIntent: routineId,
          );
        },
      ),
    );
  }

  Widget forumListing(BuildContext context, snapshots) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: snapshots.data.docs.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        List forumList = snapshots.data.docs.reversed.toList();
        ForumFireBaseModel forumModel =
            ForumFireBaseModel.fromSnapshot(forumList[index]);
        if (forumModel == null) {
          return Container();
        }
        return new InkWell(
          //highlightColor: Colors.red,
          splashColor: AppColors.primaryColor,
          onTap: () {
            setState(() {
              //_routineTapped(routineModel.id);
            });
          },
          child: new ForumListItem(forumModel),
        );
      },
    );
  }

  Widget tabLayout() {
    return isBucketSelected
        ? Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(
              left: ScreenUtil().setSp(36),
              right: ScreenUtil().setSp(12),
            ),
            height: ScreenUtil().setSp(54),
            child: ListView.builder(
              itemCount: bucketTabsList == null ? 0 : bucketTabsList.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return Material(
                  child: new InkWell(
                    //highlightColor: Colors.red,
                    splashColor: AppColors.primaryColor,
                    onTap: () {
                      setState(() {
                        bucketTabsList
                            .forEach((element) => element.isSelected = false);
                        bucketTabsList[index].isSelected = true;
                        selectedBottomTab = bucketTabsList[index].tabTitle;
                        //selectedLevel = levelDataList[index].type;
                      });
                    },
                    child: new TabListItem(bucketTabsList[index]),
                  ),
                );
              },
            ),
          )
        : Container();
  }

  Widget followersCountLayout() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0),
      margin: EdgeInsets.only(
          left: ScreenUtil().setSp(55), right: ScreenUtil().setSp(55)),
      decoration: BoxDecoration(
        //color: Colors.grey[850],

        gradient: new LinearGradient(
            colors: [Color(0xFF4C5062), Color(0xFF383B46)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter),
        borderRadius: BorderRadius.all(Radius.circular(30.0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 0.6,
            spreadRadius: 0.6,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            child: InkWell(
              onTap: () {
                if (followersCount > 0) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FollowersListingNewScreen(
                                userId: userId,
                                type: "follower",
                              )));
                  // MyNavigator.goToFollowersListing(context);
                } else {
                  Constants().errorToast(context, "No follower available");
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      width: 24,
                      height: 22,
                      child: SvgPicture.asset(
                        'assets/images/ic_graph.svg',
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        color: Colors.white,
                      )),
                  text(
                      "  ${Constants.changeToFormatedNumber(followersCount.toString())}  ",
                      Constants.boldFont,
                      ScreenUtil().setSp(26),
                      FontWeight.normal,
                      Colors.white),
                  SizedBox(
                    width: 2,
                  ),
                  text(
                      followersCount > 1 ? "FOLLOWERS" : "FOLLOWER",
                      Constants.mediumFont,
                      ScreenUtil().setSp(26),
                      FontWeight.normal,
                      Colors.white),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.only(left: 8, right: 8),
              height: 20,
              width: 1.5,
              color: Colors.black,
            ),
          ),
          Flexible(
            flex: 1,
            child: InkWell(
              onTap: () {
                if (followingsCount > 0) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FollowersListingNewScreen(
                                userId: userId,
                                type: "following",
                              )));
                } else {
                  Constants().errorToast(context, "No following available");
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 20,
                      height: 18,
                      child: SvgPicture.asset(
                        'assets/images/ic_bookmark.svg',
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        color: Colors.white,
                      )),
                  text(
                      "  ${Constants.changeToFormatedNumber(followingsCount.toString())}  ",
                      Constants.boldFont,
                      ScreenUtil().setSp(26),
                      FontWeight.normal,
                      Colors.white),
                  SizedBox(width: 2),
                  text(
                      followingsCount > 1 ? "FOLLOWINGS" : "FOLLOWING",
                      Constants.mediumFont,
                      ScreenUtil().setSp(26),
                      FontWeight.normal,
                      Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget text(String textData, String fontFamily, double fontSize,
      FontWeight fontWeight, Color fontColor) {
    return Text(
      textData,
      style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: fontColor),
    );
  }

  setUserDefaultCircularImage() {
    return Container(
      width: 90,
      height: 90,
      child: SvgPicture.asset(
        'assets/images/ic_male_placeholder.svg',
        width: 90,
        height: 90,
        fit: BoxFit.fill,
      ),
      /*decoration: BoxDecoration(
        color: AppColors.viewLineColor,
        borderRadius:
        BorderRadius.all(Radius.circular(50.0)),
        border: Border.all(
          color: AppColors.yellowColor,
          width: 1.0,
        ),
      ),*/
    );
  }
}
