import 'dart:convert';
import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:solstice/apiservice/api_call.dart';
import 'package:solstice/model/feed_model.dart';
import 'package:solstice/model/forum_model.dart';
import 'package:solstice/model/routine_model.dart';
import 'package:solstice/model/tabs_models.dart';
import 'package:solstice/pages/cards/play_card_video.dart';
import 'package:solstice/pages/chat/firebase_chat_screen.dart';
import 'package:solstice/pages/feeds/save_to_feed_routine.dart';
import 'package:solstice/pages/home/save_to_stitch.dart';
import 'package:solstice/pages/home_screen.dart';
import 'package:solstice/pages/onboardingflow/Profile_user.dart';
import 'package:solstice/pages/profile/other_user_profile.dart';
import 'package:solstice/pages/routine/section_cards.dart';
import 'package:solstice/pages/routine/share_routine.dart';
import 'package:solstice/pages/views/tab_list_item.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/utilities.dart';
import 'package:video_player/video_player.dart';

class RoutineDetail extends StatefulWidget {
  RoutineModel routineModel1;
  FeedModel feedModel1;
  bool fromCat;
  String feedId;
  RoutineDetail(this.routineModel1, this.feedModel1, this.fromCat, this.feedId);

  @override
  _RoutineDetailState createState() => _RoutineDetailState();
}

class _RoutineDetailState extends State<RoutineDetail> {
  VideoPlayerController _controller;
  List<TabsModel> tabsList = new List<TabsModel>();
  var selectedRoutineTab = "About", userToken = "";

  ChewieController chewieController;
  UserFirebaseModel userFirebaseModel;
  bool isFollow = false;
  RoutineModel routineModel;
  FeedModel feedModel;

  @override
  void initState() {
    super.initState();

    if (widget.fromCat) {
      getFeedDetail();
    } else {
      routineModel = widget.routineModel1;
      feedModel = widget.feedModel1;
      if (routineModel.cardType == "Video") {
        initializePlayer();
      }
      saveFeedViewCount();
    }

    // loadUser();
    tabsList.add(new TabsModel("About", true));
    tabsList.add(new TabsModel("Tools & Equipment", false));
    tabsList.add(new TabsModel("Comments", false));
    tabsList.add(new TabsModel("Insights", false));
  }

  void saveFeedViewCount() {
    var viewCount = feedModel.feedViewCount + 1;
    FirebaseFirestore.instance
        .collection(Constants.feedsColl)
        .doc(feedModel.id)
        .update({"feed_view_count": viewCount});
    checkFollowStatus();
  }

  void getFeedDetail() {
    FirebaseFirestore.instance
        .collection(Constants.feedsColl)
        .doc(widget.feedId)
        .get()
        .then((value) async {
      FeedModel feedModelUp = FeedModel.fromJson(value);

      await FirebaseFirestore.instance
          .collection(Constants.UsersFB)
          .doc(feedModelUp.userId)
          .get()
          .then((userValue) {
        UserFirebaseModel firebaseModel = UserFirebaseModel.fromSnapshot(userValue);
        feedModelUp.userFirebaseModel = firebaseModel;
      });

      feedModel = feedModelUp;
      getRoutineDetail(value.data()['item_id']);
    });
  }

  void getRoutineDetail(String itemId) {
    FirebaseFirestore.instance
        .collection(Constants.routineFeedCollection)
        .doc(itemId)
        .get()
        .then((value) {
      RoutineModel routineModelUp = RoutineModel.fromJson(value);
      routineModel = routineModelUp;
      routineModel.expandRoutine=false;
      feedModel.routineModel = routineModel;
      if (routineModel.cardType == "Video") {
        initializePlayer();
      }
      saveFeedViewCount();
      setState(() {});
    });
  }

  Future<void> loadUser() async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(routineModel.createdBy)
        .get();
    if (ds != null)
      // return ds;
      this.userFirebaseModel = UserFirebaseModel.fromSnapshot(ds);
  }

  Future<void> initializePlayer() async {
    _controller = VideoPlayerController.network(routineModel.fileUrl);
    await _controller.initialize();
    chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: false,
      allowMuting: true,
      allowFullScreen: false,
      allowPlaybackSpeedChanging: false,
      showControls: true,
      fullScreenByDefault: false,
    );
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (_controller != null) {
      _controller.dispose();
    }
    if (chewieController != null) {
      chewieController.dispose();
    }
  }

  Future<void> checkFollowStatus() async {
    // for check is me followd
    var isFollowSnapShot = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(routineModel.createdBy)
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
        .doc(routineModel.createdBy)
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

  showPartVideoPlay(String filePath) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return PlayCardVideo(
          videoFile: filePath,
        );
      },
    );
  }

  Widget toolsList() {
    return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: NeverScrollableScrollPhysics(),
        // padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {},
            child: Column(
              children: [
                Container(
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(routineModel.toolsList[index].title,
                              style: TextStyle(
                                  fontFamily: Constants.openSauceFont,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    )),
                SizedBox(height: 10),
                Container(
                  height: 0.4,
                  color: Colors.black12,
                ),
                SizedBox(height: 15),
              ],
            ),
          );
        },
        itemCount: routineModel.toolsList.length);
  }

  Widget image(BuildContext context) {
    return Container(
      height: 250,
      child: PageView.builder(
        itemBuilder: (itemBuilder, index2) {
          return Container(child: imageView(context, routineModel.fileUrl, 200, 0.0));
        },
        itemCount: 1,
        scrollDirection: Axis.horizontal,
        onPageChanged: (index) {
        },
      ),
    );
  }

  Widget imageView(context, String imageUrl, double height, radius) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(radius)),
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
      errorWidget: (context, url, error) => Constants().setUserDefaultCircularImage(),
    );
  }

  Widget setPostDefaultImage(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.viewLineColor,
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: routineModel == null
            ? Container()
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Stack(
                          children: [
                            routineModel.cardType == "Video"
                                ? Container(
                                    height: 258,
                                    child: Container(
                                        child: (chewieController != null)
                                            ? Stack(
                                                children: [
                                                  Container(
                                                      color: Colors.black,
                                                      child: Chewie(
                                                        controller: chewieController,
                                                      )),
                                                ],
                                              )
                                            : Container(
                                                color: Colors.black,
                                                alignment: Alignment.center,
                                                height: MediaQuery.of(context).size.height - 130,
                                                child: SizedBox(
                                                  width: 30.0,
                                                  height: 30.0,
                                                  child: CircularProgressIndicator(
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                        AppColors.primaryColor),
                                                  ),
                                                ),
                                              )),
                                  )
                                : routineModel.cardType == "Image"
                                    ? image(context)
                                    : Container(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  margin: EdgeInsets.only(left: 20, top: 20),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: AssetImage("assets/images/grey_bg.png"))),
                                  child: IconButton(
                                    icon: Icon(Icons.arrow_back, color: Colors.white),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                                Container(
                                    height: 40,
                                    width: 40,
                                    margin: EdgeInsets.only(right: 20, top: 20),
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: AssetImage("assets/images/grey_bg.png"))),
                                    child: Image.asset(
                                      "assets/images/menu.png",
                                    )),
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 20),
                        //

                        SingleChildScrollView(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Container(
                            //     width: 70,
                            //     height: 25,
                            //     margin: EdgeInsets.only(left: 10),
                            //     decoration: BoxDecoration(
                            //         color: Color(0xffEFEFEF),
                            //         borderRadius:
                            //             BorderRadius.all(Radius.circular(4))),
                            //     child: Center(
                            //       child: Text(routineModel.cardType ?? "",
                            //           style: TextStyle(
                            //               fontWeight: FontWeight.w600,
                            //               fontSize: 12,
                            //               fontFamily: Constants.openSauceFont)),
                            //     )),
                            Container(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(routineModel.title ?? "",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: AppColors.darkTextColor,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: Constants.openSauceFont,
                                          fontSize: 18)),
                                  Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) =>
                                          //             AppHumanAnatomy(
                                          //               bodyPartsListIntent: widget
                                          //                   .routineModel
                                          //                   .cardData
                                          //                   .bodyParts,
                                          //               isEditableFields: false,
                                          //             )));
                                        },
                                        child:
                                            Image.asset(Constants.bodyImage, height: 45, width: 45),
                                      ),
                                      // SizedBox(height: 10),
                                      // Text("ARMS",
                                      //     style: TextStyle(
                                      //         color: Colors.black,
                                      //         fontWeight: FontWeight.w400,
                                      //         fontFamily: Constants.openSauceFont,
                                      //         fontSize: 10))
                                    ],
                                  )
                                ],
                              ),
                            ),
                            // Container(
                            //   padding: EdgeInsets.only(left: 10, right: 10),
                            //   alignment: Alignment.topLeft,
                            //   child: Text(routineModel.title,
                            //       style: TextStyle(
                            //           color: Color(0xff738497),
                            //           fontWeight: FontWeight.w400,
                            //           fontFamily: Constants.openSauceFont,
                            //           fontSize: 13)),
                            // ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    shareFeedToRoutine();
                                  },
                                  child: Row(
                                    children: [
                                      Image.asset("assets/images/share.png",
                                          height: 16,
                                          width: 16,
                                          color: AppColors.segmentAppBarColor),
                                      SizedBox(width: 10),
                                      Text("Share",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: Constants.openSauceFont,
                                              color: AppColors.segmentAppBarColor,
                                              fontWeight: FontWeight.w600))
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 23,
                                  color: AppColors.lineColor1,
                                  margin: EdgeInsets.symmetric(horizontal: 13.0),
                                ),
                                InkWell(
                                  onTap: () {
                                    saveThisRoutine();
                                  },
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        "assets/images/download.png",
                                        color: AppColors.segmentAppBarColor,
                                        height: 16,
                                        width: 16,
                                      ),
                                      SizedBox(width: 10),
                                      Text("Save",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: AppColors.segmentAppBarColor,
                                              fontWeight: FontWeight.w600)),
                                      SizedBox(width: 10),
                                      Text("(${feedModel.saveCount})",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: AppColors.segmentAppBarColor,
                                              fontWeight: FontWeight.w400))
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 15.0,
                                )
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              alignment: Alignment.topLeft,
                              child: Text("",
                                  style: TextStyle(
                                      color: AppColors.darkTextColor,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: Constants.openSauceFont,
                                      fontSize: 14)),
                            ),
                            Container(
                              child: Column(children: [
                                SizedBox(height: 20),
                                Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 1,
                                    color: AppColors.lineColor1),
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                                  child: Row(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        height: 40,
                                        width: 40,
                                        child: CachedNetworkImage(
                                          imageUrl: feedModel.userFirebaseModel.userImage,
                                          imageBuilder: (context, imageProvider) => Container(
                                            width: 35,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(Radius.circular(50.0)),
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
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (feedModel.userFirebaseModel.id != globalUserId) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => Profile_User_Screen(
                                                          userID: feedModel.userFirebaseModel.id,
                                                          userImage:
                                                              feedModel.userFirebaseModel.userImage,
                                                          userName:
                                                              feedModel.userFirebaseModel.userName,
                                                        )));

                                            // Navigator.push(
                                            //     context,
                                            //     MaterialPageRoute(
                                            //         builder: (context) =>
                                            //             OtherUserProfile(
                                            //               userID: feedModel
                                            //                   .userFirebaseModel
                                            //                   .id,
                                            //               userImage: feedModel
                                            //                   .userFirebaseModel
                                            //                   .userImage,
                                            //               userName: feedModel
                                            //                   .userFirebaseModel
                                            //                   .userName,
                                            //             )));
                                          } else {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => HomeScreen(
                                                          currentIndex: 4,
                                                        )));
                                          }
                                        },
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(left: 10),
                                              child: Text(
                                                  feedModel.userFirebaseModel != null
                                                      ? feedModel.userFirebaseModel.userName
                                                      : "",
                                                  style: TextStyle(
                                                      color: AppColors.darkTextColor,
                                                      fontWeight: FontWeight.w600,
                                                      fontFamily: Constants.openSauceFont,
                                                      fontSize: 14)),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: 10, top: 2.0),
                                              child: Text(
                                                  Utilities.timeAgoSinceDate(routineModel.timestamp,
                                                      numericDates: true),
                                                  style: TextStyle(
                                                      color: AppColors.greyTextColor,
                                                      fontWeight: FontWeight.w400,
                                                      fontFamily: Constants.openSauceFont,
                                                      fontSize: 10)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      if (routineModel.createdBy != globalUserId)
                                        InkWell(
                                          onTap: () {
                                            String chatRoomId = Constants.getChatRoomId(
                                                globalUserId, routineModel.createdBy);

                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => ChatFirebase(
                                                          receiverIdIntent: routineModel.createdBy,
                                                          chatRoomIdIntent: chatRoomId,
                                                        )));
                                          },
                                          child: Text("Message",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: Constants.openSauceFont,
                                                  color: AppColors.segmentAppBarColor,
                                                  fontWeight: FontWeight.w400)),
                                        ),
                                      if (routineModel.createdBy != globalUserId)
                                        SizedBox(width: 30),
                                      if (routineModel.createdBy != globalUserId)
                                        InkWell(
                                          onTap: () {
                                            followUnfollowCount(routineModel.createdBy);
                                          },
                                          child: Text(isFollow ? "Followed" : "Follow",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: Constants.openSauceFont,
                                                  color: AppColors.segmentAppBarColor,
                                                  fontWeight: FontWeight.w400)),
                                        )
                                    ],
                                  ),
                                ),
                                Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 1,
                                    color: AppColors.lineColor1),
                              ]),
                            ),
                            SizedBox(height: 20),
                            Container(
                              height: 40,
                              margin: EdgeInsets.symmetric(horizontal: 15.0),
                              child: ListView.builder(
                                itemCount: tabsList.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  return new InkWell(
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    onTap: () {
                                      setState(() {
                                        tabsList.forEach((element) => element.isSelected = false);
                                        tabsList[index].isSelected = true;
                                        selectedRoutineTab = tabsList[index].tabTitle;
                                      });
                                    },
                                    child: TabListItem(
                                      tabsList[index],
                                      blackText: true,
                                    ),
                                  );
                                },
                              ),
                            ),
                            tabWidgets()
                          ],
                        ))
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Widget tabWidgets() {
    switch (selectedRoutineTab) {
      case "Tools & Equipment":
        return toolsList();
        break;
      case "About":
        return Column(
          children: [
            SectionCards(
              feedModel: feedModel,
              fromFeed: false,
              expandFeed: false,
              userName: feedModel.userFirebaseModel.userName,
              sectionList: routineModel.sectionIds,
              
            ),
            toolsList()
          ],
        );
        break;
      default:
        return Container();
    }
  }

  void saveThisRoutine() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Wrap(children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(15, 20, 10, 15),
            child: Center(
              child: Column(
                children: [
                  Container(
                    child: Row(children: [
                      Spacer(),
                      Text(
                        "Save Routine to",
                        style: TextStyle(
                            color: AppColors.greyTextColor,
                            fontSize: 14.0,
                            fontFamily: "open_saucesans_regular",
                            fontWeight: FontWeight.w600),
                      ),
                      Spacer(),
                      InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Icon(Icons.close, color: AppColors.greyTextColor),
                          ))
                    ]),
                  ),
                  SizedBox(height: 15),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);

                        saveRoutineToRoutine();
                      },
                      child: Container(
                        height: 74,
                        padding: EdgeInsets.only(left: 18, right: 18),
                        child: Row(
                          children: [
                            Text(
                              "Routine",
                              style: TextStyle(
                                  fontFamily: "open_saucesans_regular",
                                  color: AppColors.darkTextColor,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600),
                            ),
                            Spacer(),
                            Icon(Icons.keyboard_arrow_right, color: Color(0xff6E6A6A))
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    child: Center(
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              saveRoutine();
                            },
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Container(
                                height: 74,
                                padding: EdgeInsets.only(left: 18, right: 18),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Stitch",
                                        style: TextStyle(
                                            fontFamily: "open_saucesans_regular",
                                            color: AppColors.darkTextColor,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Icon(Icons.keyboard_arrow_right, color: Color(0xff6E6A6A))
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]);
      },
    );
  }

  Future<void> saveRoutineToRoutine() async {
    var object = await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
        ),
        builder: (BuildContext context) {
          return SaveToFeedRoutine();
        });

    if (object != null) {
      String routineId = object["routine_id"];
      if (routineId.isNotEmpty) {
        addRotuineToFeed(routineId, context, feedModel);
      }
    }
  }

  void addRotuineToFeed(routineId, context, FeedModel feedModel) {
    FirebaseFirestore.instance
        .collection(Constants.routineFeedCollection)
        .doc(routineId)
        .update({"section_ids": feedModel.routineModel.sectionIds}).then((value) {
      Constants().successToast(context, "Routine added to Routine");
      saveFeedCount();
    });
  }

// Save Routine
  void saveRoutine() async {
    var object = await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
        ),
        builder: (BuildContext context) {
          return SaveToStitch(
            feedId: feedModel.id,
          );
        });

    if (object != null) {
      String stichId = object["stitch_id"];
      if (stichId.isNotEmpty) {
        addStitchToPost(stichId, context, feedModel);
      }
    }
  }

  void saveFeedCount() {
    var saveCount = feedModel.saveCount + 1;
    FirebaseFirestore.instance
        .collection(Constants.feedsColl)
        .doc(feedModel.id)
        .update({"save_count": saveCount}).then((value) {
      feedModel.saveCount = saveCount;
      setState(() {});
    });
  }

  void addStitchToPost(String stitchId, BuildContext context, FeedModel postFeedModel) {
    FirebaseFirestore.instance.collection(Constants.stitchCollection).doc(stitchId).update({
      'feed_ids': FieldValue.arrayUnion([postFeedModel.id])
    }).then((value) {
      Constants().successToast(context, "Routine added to stitch");
      saveFeedCount();
    });
  }

  Future<void> shareFeedToRoutine() async {
    var object = await showModalBottomSheet(
      context: context,
      enableDrag: false,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          child: ShareRoutine(
            feedId: feedModel.id,
            feedModel: feedModel,
          ),
          height: MediaQuery.of(context).size.height * 0.62,
        );
      },
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
}
