import 'package:flutter/material.dart';
import 'package:solstice/pages/onboardingflow/profiletypescreen.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/pages/profile/profile_own_item.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chewie/chewie.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/model/feed_model.dart';
import 'package:solstice/model/routine_model.dart';
import 'package:solstice/model/tabs_models.dart';

import 'package:solstice/pages/feeds/card_feed_item.dart';
import 'package:solstice/pages/onboardingflow/Profile_user.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:solstice/model/forum_model.dart';


class Profile_User_brand_Screen extends StatefulWidget {

  String userID, userName, userImage, viewType;

  Profile_User_brand_Screen({this.userID, this.userImage, this.userName, this.viewType});

  @override
  _Profile_User_brand_ScreenState createState() => _Profile_User_brand_ScreenState();
}

class _Profile_User_brand_ScreenState extends State<Profile_User_brand_Screen> {

  int followersCount = 0;
  int followingsCount = 0;
  String userType = "", descritption = "", productLink = "";
  bool showFitness = false;

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

  List<RoutineModel> routinesList = new List.empty(growable: true);

  List<TabsModel> categoriesList = new List<TabsModel>.empty(growable: true);
  String selectedTab = "All";
  String categoryId = "";

  void initState() {
    super.initState();

    categoriesList.add(TabsModel("All", true));

    userId = widget.userID;
    userName = widget.userName;
    userImage = widget.userImage;

    getProfileData();
    getUserDataFromDB();
    getRoutinesCount();
    checkFollowStatus();

    getCategories();
    // addCategoriesToFeed();
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
        .doc(globalUserId)
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
        .doc(globalUserId)
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

  addCategoriesToFeed() {
    FirebaseFirestore.instance.collection(Constants.feedsColl).get().then((value) {
      value.docs.forEach((element) {
        FirebaseFirestore.instance
            .collection(Constants.routineFeedCollection)
            .doc(element.data()["item_id"])
            .get()
            .then((value) {
          RoutineModel routineModel = RoutineModel.fromJson(value);
          List<String> categoriesList = new List.empty(growable: true);
          categoriesList.clear();
          for (int i = 0; i < routineModel.categoryList.length - 1; i++) {
            categoriesList.add(routineModel.categoryList[i].title);
            if (i == routineModel.categoryList.length - 1) {
              FirebaseFirestore.instance.collection(Constants.feedsColl).doc("1fOADKmRwnZv2r0KXhmu")
              // .doc(element.id)
                  .set({"category_list": categoriesList}, SetOptions(merge: true));

            }
          }
        });
      });
    });
  }

  void getCategories() async {
    var collectionReference =
    FirebaseFirestore.instance.collection(Constants.trainingCategories).get();
    collectionReference.then((value) {
      final List<DocumentSnapshot> docs = value.docs;
      docs.forEach((data) {
        final Map<String, dynamic> dataMap = data.data();
        categoriesList.add(TabsModel(dataMap["title"], false, id: data.id));
        if (data.id == value.docs[value.docs.length - 1].id) {
          setState(() {});
        }
      });
    }).catchError((onError) {
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);

    return Scaffold(
      backgroundColor: Color(0XFFFFFFFF),
      body: SingleChildScrollView(
        child: Container(
        height: MediaQuery.of(context).size.height ,
        padding : EdgeInsets.only(top : 30),
        child : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 60,
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop() ;
                    },
                    child : Icon(Icons.arrow_back_ios)
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => Profile_User_Screen()));
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Container(
                  width: MediaQuery.of(context).size.height * 0.60,
                  height: MediaQuery.of(context).size.height * 0.10,
                  color: Colors.white,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text('BulletBars',
                            style: TextStyle(
                                fontFamily: Utils.fontfamily,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0XFF283646))),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 150, top: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            color: Color(0XFF338BEF).withOpacity(0.10),
                          ),
                          height: 21,
                          width: 73,
                          child: Center(
                            child: Text(
                              'Brand',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: Utils.fontfamilyInter,
                                  color: Color(0XFF338BEF)),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                          top: 0,
                          left: 310,
                          child: SizedBox(
                              height: 40,
                              width: 40,
                              child: FloatingActionButton(
                                backgroundColor: Colors.white,
                                onPressed: () {},
                                child: Icon(
                                  Icons.add,
                                  color: Color(0XFFDADADA),
                                ),
                              ))),
                      Positioned(
                          top: 30,
                          left: 20,
                          child: Icon(
                            Icons.location_pin,
                            size: 15,
                          )),
                      Positioned(
                          top: 30,
                          left: 40,
                          child: Text('New York, NY',
                              style: TextStyle(
                                  fontFamily: Utils.fontfamily,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(0xFF797980))))
                    ],
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 23),
              child: Container(
                height: 1.5,
                width: 40,
                color: Color(0XFF131314),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 20, right: 23),
              child: Text(
                'Bullet is a food company based in New York City, \nNew York. It was founded in 2004 and the\n company manufactures eight product lines.',
                style: TextStyle(
                    fontFamily: Utils.fontfamily,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF797980)),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 15),
                  child: SizedBox(
                      height: 8.5,
                      width: 8.5,
                      child: ImageIcon(
                        AssetImage(Utils.unionIcon),
                        color: Color(0xFF338BEF),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 5),
                  child: Text('www.bulletbars.com',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: Utils.fontfamily,
                          fontSize: 9,
                          color: Color(0xFF338BEF))),
                )
              ],
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
                Expanded(
                  flex: 2,
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
                        'Products',
                        style: TextStyle(
                            fontFamily: Utils.fontfamily,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Color(0XFF797980)),
                      ),
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
            Expanded(
                child: Container(
                  child: videoWidget(),
                  // color: Colors.grey[100],
                )
            )
          ],
        )),
      ),
    );
  }

  Widget videoWidget() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(Constants.feedsColl)
            .where("user_id", isEqualTo: globalUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor)),
            );
          }
          if (snapshot.data.docs.length == 0) {
            return Center(
                child: Card(
                    elevation: 4.0,
                    child: Text(
                      'No Feeds',
                      style: TextStyle(fontSize: 14.0, color: Colors.black),
                      textAlign: TextAlign.center,
                    )));
          } else {
            print("3333333333333333");
            print(snapshot.data.docs) ;
          }

          return videoWidgetItem(snapshot);
          // return Container();
        });
  }

  Widget videoWidgetItem(var snapshot) {

    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: snapshot.data.docs.length,
      itemBuilder: (BuildContext context, int index) {
        List rev = snapshot.data.docs.toList();
        FeedModel feedModel = FeedModel.fromJson(rev[index]);

        return FutureBuilder(
            future: loadRoutine(rev[index].data()["item_id"]),
            builder: (BuildContext context,
                AsyncSnapshot<RoutineModel> routineModel) {
              feedModel.routineModel = routineModel.data;

              if (feedModel.routineModel == null) {
                return Container();
              }

              return FutureBuilder(
                future: loadUser(rev[index].data()["user_id"]),
                builder: (BuildContext context,
                    AsyncSnapshot<UserFirebaseModel> userModel) {
                  feedModel.userFirebaseModel = userModel.data;
                  return Container(
                      color: Colors.grey[100],
                      padding: EdgeInsets.only(bottom: 1.2),
                      child:
                      ProfileVideoItem(
                        feedModel: feedModel,
                        isInView: false,
                        filterCategory: refreshFilters,
                      )
                  );
                },
              );
            });
      },
    );
  }

  Future<UserFirebaseModel> loadUser(userId) async {
    DocumentSnapshot ds =
    await FirebaseFirestore.instance.collection(Constants.UsersFB).doc(userId).get();
    if (ds != null)

      // return ds;

      return Future.delayed(Duration(milliseconds: 100), () => UserFirebaseModel.fromSnapshot(ds));
  }

  Future<RoutineModel> loadRoutine(String routineId) async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection(Constants.routineFeedCollection)
        .doc(routineId)
        .get();
    if (ds != null)

      // return ds;

      return Future.delayed(Duration(milliseconds: 100), () => RoutineModel.fromJson(ds));
  }

  void refreshFilters(categoryTitle) {
    for (int i = 0; i < categoriesList.length; i++) {
      categoriesList[i].isSelected = false;
      if (categoriesList[i].tabTitle.toLowerCase() == categoryTitle.toString().toLowerCase()) {
        categoriesList[i].isSelected = true;
        selectedTab = categoriesList[i].tabTitle;
        categoryId = categoriesList[i].id;
      }
    }
    videoWidgetWithCategory(categoryTitle);
    setState(() {});
  }

  Widget videoWidgetWithCategory(categoryTitle) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(Constants.feedsColl)
        // .orderBy("timestamp", descending: true)
            .where("category_list", arrayContains: categoryTitle)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor)),
            );
          }
          if (snapshot.data.docs.length == 0) {
            return Center(
                child: Card(
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                      child: Text(
                        'No Feeds',
                        style: TextStyle(fontSize: 14.0, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    )));
          }

          return videoWidgetItem(snapshot);
          // return inViewListWidget(snapshot);
        });
  }
}
