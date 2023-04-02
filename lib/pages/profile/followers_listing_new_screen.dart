import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/model/forum_model_new.dart';
import 'package:solstice/pages/groups/group_details_screen.dart';
import 'package:solstice/pages/views/followers_list_item_new.dart';
import 'package:solstice/utils/constants.dart';

class FollowersListingNewScreen extends StatefulWidget {
  final String userId;
  final String type;
  FollowersListingNewScreen({this.userId, this.type});

  @override
  _FollowersListingNewScreenState createState() =>
      _FollowersListingNewScreenState();
}

class _FollowersListingNewScreenState extends State<FollowersListingNewScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  final ScrollController listScrollController = ScrollController();
  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  int _limit = 20;
  String userID = "";
  String layoutType = "";

  bool isLoading = false;
  int selectedPosts = 0;
  var _nomore = false;
  var _isFetching = false;
  DocumentSnapshot _lastDocument;
  List<UserFirebaseModel> followersList = new List();
  List<UserFirebaseModel> followersSearchList = new List();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    userID = widget.userId;
    layoutType = widget.type;
    //getFollowersListing(userID);
    _fetchDocuments(userID);
    listScrollController.addListener(_scrollListener);
  }

  void _fetchDocuments(String userId) async {
    isLoading = true;

    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(userId)
        .collection(layoutType == "following"
            ? Constants.FollowingsFB
            : Constants.FollowersFB)
        .orderBy('userId')
        .limit(_limit)
        .get();
    _lastDocument = querySnapshot.docs.last;

    if (querySnapshot.docs.length > 0) {
      isLoading = false;

      for (final DocumentSnapshot snapshot in querySnapshot.docs) {
        UserFirebaseModel userFirebaseModel = new UserFirebaseModel();
        Map<String, dynamic> mapObject = snapshot.data();
        userFirebaseModel.id = snapshot.id;
        userFirebaseModel.userId = mapObject["userId"];
        loadUser(mapObject["userId"]).then((value) {
          userFirebaseModel.userName = value.userName;
          userFirebaseModel.userImage = value.userImage;
          followersList.add(userFirebaseModel);

          if (_lastDocument.id == snapshot.id) {
            isLoading = false;
            setState(() {});
          }
        });
      }
    } else {
      isLoading = false;
      setState(() {});
    }

    // your logic here
  }

  Future<Null> _fetchFromLast() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(userID)
        .collection(layoutType == "following"
            ? Constants.FollowingsFB
            : Constants.FollowersFB)
        .orderBy('userId')
        .startAfter([_lastDocument['userId']])
        .limit(_limit)
        .get();
    if (querySnapshot.docs.length < 1) {
      _nomore = true;
      return;
    }
    _lastDocument = querySnapshot.docs.last;
    for (final DocumentSnapshot snapshot in querySnapshot.docs) {
      UserFirebaseModel userFirebaseModel = new UserFirebaseModel();
       Map<String, dynamic> mapObject = snapshot.data();
      userFirebaseModel.id = snapshot.id;
      userFirebaseModel.userId = mapObject["userId"];

      followersList.add(userFirebaseModel);
    }
    setState(() {});
  }

  void _scrollListener() async {
    if (_nomore) return;
    if (listScrollController.position.pixels ==
            listScrollController.position.maxScrollExtent &&
        _isFetching == false) {
      _isFetching = true;
      await _fetchFromLast();
      _isFetching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
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
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(
                      left: ScreenUtil().setSp(20),
                      right: ScreenUtil().setSp(20),
                      top: ScreenUtil().setSp(26),
                      bottom: ScreenUtil().setSp(26)),
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
                          margin: EdgeInsets.only(left: 6),
                          child: SvgPicture.asset(
                            'assets/images/ic_back.svg',
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: !isSearching
                              ? EdgeInsets.all(ScreenUtil().setSp(12))
                              : EdgeInsets.all(0),
                          child: !isSearching
                              ? Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    layoutType == "following"
                                        ? Constants.FollowingsFB
                                        : Constants.FollowersFB,
                                    style: TextStyle(
                                      color: AppColors.titleTextColor,
                                      fontFamily: Constants.boldFont,
                                      fontSize: ScreenUtil().setSp(32),
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 42,
                                  margin: EdgeInsets.only(left: 12, right: 12),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: "Search by keyword",
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(
                                        fontFamily: "epilogue_medium",
                                        fontSize: 14,
                                        color: Colors.black),
                                    textAlignVertical: TextAlignVertical.center,
                                    onChanged: (text) {
                                      filterList(text);
                                    },
                                  ),
                                ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          isSearching = !isSearching;
                          setState(() {});
                          // Navigator.of(context).push(MaterialPageRoute(
                          //     builder: (BuildContext context) {
                          //   return SearchFilter(screenType: 'User');
                          // }));
                        },
                        child: Container(
                          width: 26,
                          height: 26,
                          padding: EdgeInsets.all(2.5),
                          margin: EdgeInsets.only(right: 5),
                          child: SvgPicture.asset(
                            'assets/images/ic_search.svg',
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // Container(
                      //   width: 22,
                      //   height: 22,
                      //   padding: EdgeInsets.all(2.5),
                      //   margin: EdgeInsets.only(right: 8),
                      // ),
                    ],
                  ),
                ),
              ),
              Expanded(
                  flex: 1,
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryColor)),
                        )
                      : followersList.length > 0
                          ? followerListing(
                              context,
                              followersSearchList.length > 0
                                  ? followersSearchList
                                  : followersList)
                          : Center(
                              child: Container(
                                child: Text(
                                  layoutType == "following"
                                      ? "No following found"
                                      : "No follower found",
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(26),
                                      fontFamily: Constants.regularFont,
                                      height: 1.3,
                                      letterSpacing: 0.8),
                                ),
                              ),
                            )),
            ],
          ),
        ],
      ),
    );
  }

  Widget followerListing(
      BuildContext context, List<UserFirebaseModel> followersList) {
    return ListView(
      padding: EdgeInsets.zero,
      controller: listScrollController,
      children: <Widget>[
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: followersList.length,
            primary: false,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return new InkWell(
                //highlightColor: Colors.red,
                splashColor: AppColors.primaryColor,
                onTap: () {
                  setState(() {});
                },
                child: new FollowersListItemNew(followersList[index]),
              );

              return FutureBuilder(
                  future: loadUser(followersList[index].userId),
                  builder: (BuildContext context,
                      AsyncSnapshot<UserFirebaseModel> userFirebase) {
                    UserFirebaseModel userModel = userFirebase.data;
                    /*if (userFirebase != null) {
                                                          if (userModel != null && userModel.followers != null)
                                                            for (int i = 0; i < userModel.followers.length; i++) {
                                                              if (userModel.followers[i] == globalUserId) {
                                                                userModel.isFollow = true;
                                                                break;
                                                              }
                                                            }
                                                        }*/
                    followersList[index].userName = userModel.userName;
                    return userFirebase != null
                        ? new InkWell(
                            //highlightColor: Colors.red,
                            splashColor: AppColors.primaryColor,
                            onTap: () {
                              setState(() {});
                            },
                            child: new FollowersListItemNew(userModel),
                          )
                        : Container(); /*  */
                  });
            },
          ),
        ),
      ],
    );
  }

  Future<UserFirebaseModel> loadUser(userId) async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(userId)
        .get();
    if (ds != null)
      return Future.delayed(
          Duration(milliseconds: 50), () => UserFirebaseModel.fromSnapshot(ds));
  }

  Future _OnGoToGroupDetail(String groupId) async {
    Map results = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return GroupDetailsScreen(groupIdIntent: groupId);
    }));

    if (results != null && results.containsKey('update')) {
      var _isUpdate = "";
      setState(() {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ));
      });
    }
  }

  void filterList(String text) {
    followersSearchList.clear();
    followersList.forEach((element) {
      if (element.userName.toString().contains(text)) {
        followersSearchList.add(element);
      }
    });
    setState(() {});
  }
}
