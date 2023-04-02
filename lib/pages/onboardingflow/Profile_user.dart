import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:solstice/apiservice/api_call.dart';
import 'package:solstice/main.dart';
import 'package:solstice/model/forum_model_new.dart';
import 'package:solstice/model/routine_model.dart';
import 'package:solstice/pages/chat/firebase_chat_screen.dart';
import 'package:solstice/pages/feeds/routine_detail.dart';
import 'package:solstice/pages/onboardingflow/profile_users_brand.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/pages/onboardingflow/welcomeScreen.dart';
import 'package:solstice/pages/profile/followers_listing_new_screen.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/shared_preferences.dart';
import 'package:solstice/utils/size_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:solstice/pages/onboardingflow/ChangePasswordForm.dart' ;
import 'package:solstice/pages/uploads/UploadFileForm.dart';

class Profile_User_Screen extends StatefulWidget {
  String userID, userName, userImage, viewType;

  Profile_User_Screen({this.userID, this.userImage, this.userName, this.viewType});

  @override
  _Profile_User_ScreenState createState() => _Profile_User_ScreenState();
}

class _Profile_User_ScreenState extends State<Profile_User_Screen> {
  int followersCount = 0;
  int followingsCount = 0;
  String userType = "", descritption = "", productLink = "";
  bool showFitness = false;
  List<RoutineModel> routinesList = new List.empty(growable: true);
  List<String> _bodyPartList = new List.empty(growable: true);
  List<String> _interestsStrList = new List.empty(growable: true);
  List<String> _sportsStrList = new List.empty(growable: true);
  List<String> _occupationStrList = new List.empty(growable: true);
  List<String> _activeInjuriesStrList = new List.empty(growable: true);
  List<String> _previousInjuriesStrList = new List.empty(growable: true);
  List<String> _certificationsStrList = new List.empty(growable: true);
  List<String> _coachesStrList = new List.empty(growable: true);
  TextEditingController locationTextController = new TextEditingController();
  bool isActiveInjuriesPrivate = true;
  bool isPreviousInjuriesPrivate = true;
  String userId = "", userName = "", userImage = "", userAddress = "", userToken = "";
  bool isFollow = false;

  @override
  void initState() {
    super.initState();
    userId = widget.userID;
    userName = widget.userName;
    userImage = widget.userImage;

    getProfileData();
    getUserDataFromDB();
    getRoutinesCount();
    checkFollowStatus();
  }

  Future<void> checkFollowStatus() async {
    // for check is me followd
    var isFollowSnapShot = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(widget.userID)
        .collection(Constants.FollowersFB)
        .where("userId", isEqualTo: globalUserId)
        .snapshots();

    isFollowSnapShot.listen((querySnapshot) {
      isFollow = querySnapshot.docs.length > 0 ? true : false;
      if (mounted) {
        setState(() {});
      }
    });

    FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(widget.userID)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      Map<String, dynamic> mapObject = documentSnapshot.data();
      if (mounted) {
        setState(() {
          try {
            if (mapObject.containsKey("token")) {
              userToken = documentSnapshot['token'];
            }
          } catch (e) {}
        });
      }
    }).onError((e) => print(e));
  }

  Future<void> getUserDataFromDB() async {
    DocumentSnapshot ds =
        await FirebaseFirestore.instance.collection(Constants.UsersFB).doc(globalUserId).get();
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
        _previousInjuriesStrList = mapObject.containsKey("previousInjuriesArray")
            ? mapObject['previousInjuriesArray'].cast<String>()
            : List.empty(growable: true);
        _certificationsStrList = mapObject.containsKey("achievementsArray")
            ? mapObject['achievementsArray'].cast<String>()
            : List.empty(growable: true);
        _coachesStrList = mapObject.containsKey("coachesArray")
            ? mapObject['coachesArray'].cast<String>()
            : List.empty(growable: true);

        isActiveInjuriesPrivate = mapObject.containsKey("isActiveInjuriesPublic")
            ? !mapObject["isActiveInjuriesPublic"]
            : true;

        isPreviousInjuriesPrivate = mapObject.containsKey("isPreviousInjuriesPublic")
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

            if (mapObject.containsKey("address")) {
              userAddress = documentSnapshot['address'];
            }
            if (mapObject.containsKey("token")) {
              userToken = documentSnapshot['token'];
            }
            if (mapObject.containsKey("userType")) {
              userType = documentSnapshot['userType'];
              if (userType == "Business") {
                showFitness = false;
                BusinessProducts bs =
                    BusinessProducts.fromJson(documentSnapshot['businessProducts']);
                if (bs.productLinks != null && bs.productLinks.length > 0) {
                  productLink = bs.productLinks[0];
                }
              } else if (userType == "Individual") {
                showFitness = true;
                descritption = documentSnapshot['livingDesc'];
              }
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
    return Scaffold(
      backgroundColor: Color(0XFFFFFFFF),
      body: SafeArea(
        top: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 60,
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    // visible: widget.viewType != null && widget.viewType.isNotEmpty ? true : false,
                    child: InkWell(
                        onTap: () {
                          widget.viewType = "";
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back_ios)),
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => Profile_User_brand_Screen()));
                      },
                      child: ImageIcon(AssetImage(Utils.shareIcon))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 34, left: 24),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Utils.buttonColor.withOpacity(0.09),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ], shape: BoxShape.circle, color: Utils.buttonColor),
                child: widget.userImage.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.userImage,
                        imageBuilder: (context, imageProvider) => Container(
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(50.0)),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // placeholder: (context, url) => setPostDefaultImage(context),
                        // errorWidget: (context, url, error) => setPostDefaultImage(context),
                      )
                    : Constants().setUserDefaultCircularImage(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: Text(widget.userName,
                              style: TextStyle(
                                  fontFamily: Utils.fontfamily,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0XFF283646))),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => UploadFileForm()));
                          },

                          child: Container(
                            margin: EdgeInsets.only(left : 15),
                            padding: const EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                              color: Color(0XFF338BEF).withOpacity(0.10),
                            ),
                            height: 21,
                            width: 73,
                            child: Center(
                              child: Text(
                                showFitness ? 'Fitness Pro' : 'Brand',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: Utils.fontfamilyInter,
                                    color: Color(0XFF338BEF)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: userAddress != null && userAddress.isNotEmpty ? true : false,
                      child: Container(
                        margin: EdgeInsets.only(top: 7, left: 25),
                        alignment: Alignment.topLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_pin,
                              size: 15,
                            ),
                            SizedBox(width: 5),
                            Text(userAddress,
                                style: TextStyle(
                                    fontFamily: Utils.fontfamily,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Color(0xFF797980))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Spacer(),
                if (widget.userID != globalUserId)
                  Container(
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.white,
                      child: Row(
                        children: [
                          SizedBox(
                              height: 40,
                              width: 40,
                              child: FloatingActionButton(
                                heroTag: null,
                                backgroundColor: Colors.white,
                                onPressed: () {
                                  followUnfollowCount(widget.userID);
                                },
                                child: Icon(
                                  isFollow ? Icons.check : Icons.add,
                                  color: isFollow ? AppColors.blueColor : Color(0XFFDADADA),
                                ),
                              )),
                          SizedBox(width: 8),
                          if (userId != globalUserId)
                            SizedBox(
                                height: 40,
                                width: 40,
                                child: FloatingActionButton(
                                  heroTag: null,
                                  backgroundColor: Colors.white,
                                  onPressed: () {
                                    // if (userId != globalUserId) {
                                    String chatRoomId =
                                        Constants.getChatRoomId(globalUserId, userId);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ChatFirebase(
                                                  receiverIdIntent: userId,
                                                  chatRoomIdIntent: chatRoomId,
                                                )));
                                    // }
                                  },
                                  child: Image.asset(
                                    Constants.chatIcon,
                                    color: AppColors.blueColor,
                                    height: 25,
                                    width: 25,
                                  ),
                                )),
                        ],
                      )),
              ],
            ),

            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Container(
                height: 1,
                width: 40,
                color: AppColors.greyTextColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 30, right: 23),
              child: Text(
                descritption ?? "",
                style: TextStyle(
                    fontFamily: Utils.fontfamily,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF797980)),
              ),
            ),
            Visibility(
              visible: productLink != null && productLink.isNotEmpty ? true : false,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 30, right: 5),
                    child: SizedBox(
                        height: 8.5,
                        width: 8.5,
                        child: ImageIcon(
                          AssetImage(Utils.unionIcon),
                          color: Color(0xFF338BEF),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 0),
                    child: InkWell(
                      onTap: () {
                        _launchURL(productLink);
                      },
                      child: Text(productLink,
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: Utils.fontfamily,
                              fontSize: 12,
                              color: Color(0xFF338BEF))),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Divider(
                thickness: 1.5,
                color: Color(0xFFD5D5E0),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: () {
                      if (followersCount > 0) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FollowersListingNewScreen(
                                      userId: userId,
                                      type: "followers",
                                    )));
                        // MyNavigator.goToFollowersListing(context);
                      } else {
                        Constants().errorToast(context, "You have no followers");
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          followersCount.toString() ?? "0",
                          style: TextStyle(
                              fontFamily: Utils.fontfamily,
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              color: Color(0xFF283646)),
                        ),
                        Text(
                          'Followers',
                          style: TextStyle(
                              fontFamily: Utils.fontfamily,
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0XFF797980)),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
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
                        // MyNavigator.goToFollowersListing(context);
                      } else {
                        Constants().errorToast(context, "You have no following");
                      }
                    },
                    child: Column(
                      children: [
                        Text(
                          followingsCount.toString() ?? "0",
                          style: TextStyle(
                              fontFamily: Utils.fontfamily,
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              color: Color(0xFF283646)),
                        ),
                        Text(
                          'Following',
                          style: TextStyle(
                              fontFamily: Utils.fontfamily,
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0XFF797980)),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        routinesList.length.toString() ?? "0",
                        style: TextStyle(
                            fontFamily: Utils.fontfamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                            color: Color(0xFF283646)),
                      ),
                      Text(
                        'Routines',
                        style: TextStyle(
                            fontFamily: Utils.fontfamily,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Color(0XFF797980)),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Icon(
                    Icons.more_vert,
                    size: 30,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Divider(
                thickness: 1.5,
                color: Color(0xFFD5D5E0),
              ),
            ),
            Visibility(
              child: Container(
                  padding: const EdgeInsets.only(left: 15),
                  height: MediaQuery.of(context).size.height * 0.05,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      SizedBox(width: 20),
                      Visibility(
                        visible: routinesList.length > 0 ? true : false,
                        child: Text(
                          'Routines',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: Utils.fontfamily,
                              color: Color(0XFF338BEF)),
                        ),
                      ),
                      // Spacer(),
                      Visibility(
                        visible: false,
                        child: Text(
                          'See all',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              fontFamily: Utils.fontfamily,
                              color: Color(0XFF338BEF)),
                        ),
                      ),
                      SizedBox(width: 20),
                    ],
                  )),
            ),
            Visibility(
              child: Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(top: 10, left: 30),
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, index) => Container(
                          child: InkWell(
                            onTap: () {
                              if (routinesList[index].id != null &&
                                  routinesList[index].id.isNotEmpty) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RoutineDetail(
                                            null, null, true, routinesList[index].feedId)));
                              }
                            },
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(boxShadow: [
                                    BoxShadow(
                                      color: Utils.buttonColor.withOpacity(0.09),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: Offset(0, 3), // changes position of shadow
                                    ),
                                  ], shape: BoxShape.circle, color: Utils.buttonColor),
                                  child: CachedNetworkImage(
                                    imageUrl: routinesList[index].fileUrl,
                                    imageBuilder: (context, imageProvider) => Container(
                                      width: Dimens.imageSize25(),
                                      height: Dimens.imageSize25(),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                                        // image: DecorationImage(
                                        //   image: imageProvider,
                                        //   fit: BoxFit.cover,
                                        // ),
                                      ),
                                    ),
                                    placeholder: (context, url) =>
                                        Constants().setUserDefaultCircularImage(),
                                    errorWidget: (context, url, error) =>
                                        Constants().setUserDefaultCircularImage(),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 20),
                                  child: Text(
                                    routinesList[index].title,
                                    style: TextStyle(
                                        fontFamily: Constants.fontSfPro,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        width: 20,
                      );
                    },
                    itemCount: routinesList.length),
              )),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                setState(() {
                  _logoutFromFireStore();
                });
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 20, bottom: 50),
                child: Text(
                  Constants.logOut,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColors.redColor,
                      fontFamily: Constants.mediumFont,
                      fontSize: ScreenUtil().setSp(30)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  setPostDefaultImage(BuildContext context) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: AppColors.viewLineColor,
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
    );
  }

  void getRoutinesCount() async {
    var collectionReference = FirebaseFirestore.instance
        .collection(Constants.feedsColl)
        .where("user_id", isEqualTo: globalUserId)
        .get();
    collectionReference.then((value) {
      final List<DocumentSnapshot> docs = value.docs;
      docs.forEach((data) {
        final Map<String, dynamic> dataMap = data.data();
        getRoutineData(dataMap['item_id'], data.id);
        if (data.id == value.docs[value.docs.length - 1].id) {
          setState(() {});
        }
      });
    }).catchError((onError) {
    });
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

  _launchURL(String link) async {
    if (await canLaunch(link)) {
      await launch(link);
    } else {
      throw 'Could not launch $link';
    }
  }

  Future<void> _logoutFromFireStore() async {
    /// Method to Logout the `FirebaseUser` (`_firebaseUser`)
    try {
      // signout code

      FirebaseFirestore.instance
          .collection(Constants.UsersFB)
          .doc(globalUserId)
          .update({
            'token': "",
          })
          .then((docRef) {
            setState(() async {
              await FirebaseAuth.instance.signOut();
              _cancelAllNotifications();

              SharedPref.saveBooleanInPrefs(Constants.LOGINSTATUS, false);
              SharedPref.clear();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => (WelcomeScreen())),
                  (route) => false);
            });
          })
          .timeout(Duration(seconds: 10))
          .catchError((error) {

            setState(() async {
              await FirebaseAuth.instance.signOut();
              _cancelAllNotifications();

              SharedPref.saveBooleanInPrefs(Constants.LOGINSTATUS, false);
              SharedPref.clear();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => (WelcomeScreen())),
                  (route) => false);
            });
          });
    } catch (e) {}
  }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  void getRoutineData(String itemId, String feedId) async {
    await FirebaseFirestore.instance
        .collection(Constants.routineFeedCollection)
        .doc(itemId)
        .get()
        .then((value) {

      final Map<String, dynamic> dataMap = value.data();

      RoutineModel routineModel = RoutineModel.fromJson(value);
      routineModel.id = value.id;
      routineModel.feedId = feedId;

      routinesList.add(routineModel);
      setState(() {});
    });
  }
}