import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/forum_model.dart' hide UserFirebaseModel;
import 'package:solstice/model/forum_model_new.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/model/stitch_routine_model.dart';
import 'package:solstice/model/tabs_models.dart';
import 'package:solstice/pages/buckets_stitch/routine_detail_screen.dart';
import 'package:solstice/pages/home/post_detail_screen.dart';
import 'package:solstice/pages/new_login_register/about_you_screen_new.dart';
import 'package:solstice/pages/profile/followers_listing_new_screen.dart';
import 'package:solstice/pages/update_page_data.dart';
import 'package:solstice/pages/views/bucket_stitch_list_item.dart';
import 'package:solstice/pages/views/forum_list_fb_item.dart';
import 'package:solstice/pages/views/home_post_list_item.dart';
import 'package:solstice/pages/views/tab_list_item.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/dialog_callback.dart';
import 'package:solstice/utils/my_navigator.dart';
import 'package:solstice/pages/views/routine_tab_list_item.dart';
import 'package:http/http.dart' as http;
import 'package:solstice/utils/utilities.dart';

import '../../utils/constants.dart';

class ProfileTabScreen extends StatefulWidget {
  String userID, userName, userImage;

  ProfileTabScreen({this.userID, this.userImage, this.userName});
  @override
  _ProfileTabScreenState createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen>
    with AutomaticKeepAliveClientMixin
    implements DialogCallBack {
  @override
  bool get wantKeepAlive => true;

  var selectedBottomTab = "Posts";
  bool isBucketSelected = true;
  List<TabsModel> bucketTabsList = new List<TabsModel>();
  String _profileImage =
      "https://www.bodybuilding.com/fun/images/2015/how-to-make-yourself-the-best-trainer-at-any-gym-facebook-box-960x540.jpg";

  // String _profileImage = "",userName="";
  int followersCount = 0;
  int followingsCount = 0;

  String userId = "", userName = "", userImage = "", userAddress = "";

  int _messageCount = 0;
  String stitchId = "", routineId = "", forumId = "";
  bool isEditMode = false;

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
  }

  // get user profile from user table in firebase db
  Future<String> getProfileData() async {
    FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(userId)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      Map<String, dynamic> mapObject = documentSnapshot.data();
      setState(() {
        /* if (documentSnapshot.exists){
          if(mapObject.containsKey("followers")){
            List<String> followersList = List.from(documentSnapshot['followers']);
            followersCount = followersList != null ? followersList.length : 0;
          }
        }*/

        try {
          userName = documentSnapshot['userName'];
          userImage = documentSnapshot['userImage'];
          if (mapObject.containsKey("location")) {
            userAddress = documentSnapshot['location']['address'];
          }
        } catch (e) {}
      });
    }).onError((e) => print(e));

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
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return SafeArea(
        child: Container(
            color: Colors.white,
            padding: EdgeInsets.only(),
            child: profileUi()));
  }

  // send push notification when user follows
  Future<void> sendPushMessage(String receiverFBToken) async {
    if (receiverFBToken == null || receiverFBToken == "") {
      return;
    }

    try {
      final response =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                "X-Requested-With": "XMLHttpRequest",
                "Content-Type": "application/json",
                "Authorization":
                    "key=AAAAyvtc5r0:APA91bH50voGDGMlayEbcBOKC4AWBmKUjjlr-N4Nt1drYhVYFkt9U6zhgGv3c4ABsC9iQtuCgmOdXqSTIU633Ysaux3M9x1kP5UbFNv9tkrE2U0YT9wlRZI3g3Z8rdz6-ctIUJi8wEAv",
              },
              body: constructFCMPayload(receiverFBToken));

      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON
      } else {
        // If that response was not OK, throw an error.
        throw Exception('Failed to load post');
      }
    } catch (e) {
      print(e);
    }
  }

  // notification payload data
  String constructFCMPayload(String token) {
    _messageCount++;
    return jsonEncode({
      'to': token,
      'data': {
        'via': 'FlutterFire Cloud Messaging!!!',
        'count': _messageCount.toString(),
      },
      'notification': {
        'title': 'Hello FlutterFire!',
        'body': 'This notification (#$_messageCount) was created via FCM!',
      },
    });
  }

  // profile ui
  Widget profileUi() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
                left: ScreenUtil().setSp(36),
                right: ScreenUtil().setSp(36),
                top: ScreenUtil().setSp(36)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                ),
                Expanded(
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
                              child: userImage != null
                                  ? CachedNetworkImage(
                                      imageUrl: (userImage.contains("https:") ||
                                              userImage.contains("http:"))
                                          ? userImage
                                          : UrlConstant.BaseUrlImg +
                                              _profileImage,
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
                                    )
                                  : setUserDefaultCircularImage(),
                            ),
                           
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    MyNavigator.goToProfileSetting(context);
                  },
                  child: Container(
                    width: 22,
                    height: 22,
                    padding: EdgeInsets.all(1.5),
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
                text(userName != null ? userName : "Guest", Constants.boldFont,
                    20.0, FontWeight.bold, Colors.black),
                Spacer(),
              ],
            ),
          ),
          SizedBox(
            height: 12,
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
                text("$userAddress", Constants.regularFont, 13.0,
                    FontWeight.normal, AppColors.lightGreyColor),
                // SizedBox(
                //   height: 8,
                // ),
                // text("User Choice (limit words)", Constants.regularFont, 13.0,
                //     FontWeight.normal, AppColors.lightGreyColor),
              ],
            ),
          ),
          SizedBox(
            height: 30,
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

  // fetch data from firestore with tabs selection
  Stream<dynamic> fetchTabsSnapshots() {
    if (selectedBottomTab == "Posts") {
      return FirebaseFirestore.instance
          .collection(Constants.posts)
          .where('created_by', isEqualTo: globalUserId)
          .snapshots();
    } else if (selectedBottomTab == "Stitch") {
      return FirebaseFirestore.instance
          .collection(Constants.stitchCollection)
          .where('created_by', isEqualTo: globalUserId)
          .snapshots();
    } else if (selectedBottomTab == "Routines") {
      return FirebaseFirestore.instance
          .collection(Constants.routineCollection)
          .where('created_by', isEqualTo: globalUserId)
          .snapshots();
    } else if (selectedBottomTab == "Forum") {
      return FirebaseFirestore.instance
          .collection(Constants.forumsCollection)
          .where('createdBy', isEqualTo: globalUserId)
          .snapshots();
    }
  }

  // tabs layout data
  Widget bottomLayout() {
    return selectedBottomTab != "About"
        ? MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: StreamBuilder(
                // stream: FirebaseFirestore.instance
                //     .collection(Constants.stitchCollection)
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
                        child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'No Data',
                        style: TextStyle(fontSize: 16.0, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ));
                  } else {
                    if (selectedBottomTab == "Posts") {
                      return profileTabListing(context, snapshot);
                    } else if (selectedBottomTab == "Stitch") {
                      return stitchListing(context, snapshot);
                    } else if (selectedBottomTab == "Routines") {
                      return routineListing(context, snapshot);
                    } else {
                      //return profileTabListing(context, snapshot);
                      return forumListing(context, snapshot);
                    }
                  }
                  //return profileTabListing(context, snapshot);
                }))
        : InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return AboutYouNewScreen(isEdit: true);
                  },
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(top: 20),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'About you >>',
                    style: TextStyle(
                        fontSize: 16.0,
                        color: AppColors.primaryColor,
                        fontFamily: Constants.semiBoldFont),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
  }

  // stitching listing
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

        return Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          actions: [
           if (sitchmodel.createdBy == globalUserId)
                Container(
                  margin: EdgeInsets.only(bottom: 30, top: 10.0),
                  child: IconSlideAction(
                    caption: 'Edit',
                    color: Colors.blue,
                    icon: Icons.delete,
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
                            return UpdatePageData(
                              pageType: 'Stitch',
                              description: sitchmodel.description,
                              title: sitchmodel.title,
                              id: sitchmodel.id,
                              locationAddress: '',
                              imageUrl: sitchmodel.image,
                            );
                          });

                      if (object != null) {
                        fetchTabsSnapshots();
                      }
                    },
                  ),
                ),
            ],
          secondaryActions: <Widget>[
            if (sitchmodel.createdBy == globalUserId)
              IconSlideAction(
                  caption: 'Delete',
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () => {
                        stitchId = sitchmodel.id,
                        Utilities.confirmDeleteDialog(
                            context,
                            Constants.deleteStitch,
                            Constants.deleteStitchConfirmDes,
                            this,
                            1),
                      }),
          ],
          child: new BucketStitchListItem(
            sitchmodel,
            index,
            fromPostPage: false,
          ),
        );
      },
    );
  }

  // routine listing
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
          child: Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              actions: [
           if (routineModel.createdBy == globalUserId)
                Container(
                  margin: EdgeInsets.only(bottom: 30, top: 10.0),
                  child: IconSlideAction(
                    caption: 'Edit',
                    color: Colors.blue,
                    icon: Icons.delete,
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
                            return UpdatePageData(
                              pageType: 'Routine',
                              description: routineModel.description,
                              title: routineModel.title,
                              id: routineModel.id,
                              locationAddress: '',
                              imageUrl: routineModel.image,
                            );
                          });

                      if (object != null) {
                        fetchTabsSnapshots();
                      }
                    },
                  ),
                ),
            ],
              secondaryActions: <Widget>[
                if (routineModel.createdBy == globalUserId)
                  IconSlideAction(
                      caption: 'Delete',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () => {
                            routineId = routineModel.id,
                            Utilities.confirmDeleteDialog(
                                context,
                                Constants.deleteRoutine,
                                Constants.deleteRoutineConfirmDes,
                                this,
                                2),
                          }),
              ],
              child: new RoutineTabListItem(routineModel, index)),
        );
      },
    );
  }

  // when user click on routine. user go to routine detail
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

  // forum listing
  Widget forumListing(BuildContext context, snapshots) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: snapshots.data.docs.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        List stitchList = snapshots.data.docs.reversed.toList();
        ForumFireBaseModel forumModel =
            ForumFireBaseModel.fromSnapshot(stitchList[index]);
        return new InkWell(
          //highlightColor: Colors.red,
          splashColor: AppColors.primaryColor,
          onTap: () {
            setState(() {
              //_routineTapped(routineModel.id);
            });
          },
          child: Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            actions: [
              if (forumModel.createdBy == globalUserId)
                Container(
                  margin: EdgeInsets.only(bottom: 30, top: 10.0),
                  child: IconSlideAction(
                    caption: 'Edit',
                    color: Colors.blue,
                    icon: Icons.delete,
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
                            return UpdatePageData(
                              pageType: 'Forum',
                              description: forumModel.description,
                              title: forumModel.title,
                              id: forumModel.id,
                              locationAddress: forumModel.postAddress,
                              imageUrl: '',
                            );
                          });

                      if (object != null) {
                        fetchTabsSnapshots();
                      }
                    },
                  ),
                ),
            ],
            secondaryActions: <Widget>[
              if (forumModel.createdBy == globalUserId)
                IconSlideAction(
                    caption: 'Delete',
                    color: Colors.red,
                    icon: Icons.delete,
                    onTap: () => {
                          forumId = forumModel.id,
                          Utilities.confirmDeleteDialog(
                              context,
                              Constants.deleteForum,
                              Constants.deleteForumConfirmDes,
                              this,
                              3),
                        }),
            ],
            child: new ForumFbItem(
              appUserId: globalUserId,
              forumItem: forumModel,
            ),
          ),
        );
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

  // tabs
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
                return new InkWell(
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
                );
              },
            ),
          )
        : Container();
  }

  // followers count layout
  Widget followersCountLayout() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0),
      margin: EdgeInsets.only(
          left: ScreenUtil().setSp(55), right: ScreenUtil().setSp(55)),
      decoration: BoxDecoration(
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
                  Constants().errorToast(context, "You have no followers");
                }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      width: 24,
                      height: 22,
                      child: SvgPicture.asset(
                        'assets/images/ic_graph.svg',
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
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
                  // MyNavigator.goToFollowersListing(context);
                } else {
                  Constants().errorToast(context, "You have no following");
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 20,
                      height: 20,
                      child: SvgPicture.asset(
                        'assets/images/ic_bookmark.svg',
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
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

  // set user detault placeholder
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

  void deleteForum() {
    FirebaseFirestore.instance
        .collection(Constants.forumsCollection)
        .doc(forumId)
        .delete();
    setState(() {});
  }

  void deleteRoutine() {
    FirebaseFirestore.instance
        .collection(Constants.routineCollection)
        .doc(routineId)
        .delete();
    setState(() {});
  }

  void deleteStitch() {
    FirebaseFirestore.instance
        .collection(Constants.stitchCollection)
        .doc(stitchId)
        .delete();
    setState(() {});
  }

  @override
  void onOkClick(int code) {
    switch (code) {
      case 1:
        deleteStitch();
        break;

      case 2:
        deleteRoutine();
        break;

      case 3:
        deleteForum();
        break;
    }
  }
}
