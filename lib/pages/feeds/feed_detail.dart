import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:solstice/apiservice/api_call.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/model/feed_model.dart';
import 'package:solstice/model/forum_model.dart';
import 'package:solstice/model/tabs_models.dart';
import 'package:solstice/pages/cards/play_card_video.dart';
import 'package:solstice/pages/chat/firebase_chat_screen.dart';
import 'package:solstice/pages/humanBody/app_human_anatomy.dart';
import 'package:solstice/pages/views/tab_list_item.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/utilities.dart';
import 'package:video_player/video_player.dart';

class FeedDetailPage extends StatefulWidget {
  final FeedModel feedModel;
  final CardModel cardModel;
  FeedDetailPage(this.feedModel, this.cardModel);

  @override
  _FeedDetailPageState createState() => _FeedDetailPageState();
}

class _FeedDetailPageState extends State<FeedDetailPage> {
  VideoPlayerController _controller;
  List<TabsModel> tabsList = new List<TabsModel>();
  var selectedRoutineTab = "Tools & Equipment", userToken = "";

  ChewieController chewieController;
  UserFirebaseModel userFirebaseModel;
  bool isFollow = false;

  @override
  void initState() {
    super.initState();
   
    if (widget.cardModel != null && widget.cardModel.type == "Video") {
      initializePlayer();
    } else if (widget.cardModel != null && widget.cardModel.type == "Image") {}
    loadUser();
    checkFollowStatus();
    // tabsList.add(new TabsModel("About", true));
    tabsList.add(new TabsModel("Tools & Equipment", true));
    tabsList.add(new TabsModel("Comments", false));
    tabsList.add(new TabsModel("Insights", false));
    saveFeedViewCount();
  }

  void saveFeedViewCount(){
    FirebaseFirestore.instance.collection(Constants.feed).doc(widget.feedModel.id);
  }

  Future<void> loadUser() async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(widget.feedModel.userId)
        .get();
    if (ds != null)
      // return ds;
      this.userFirebaseModel = UserFirebaseModel.fromSnapshot(ds);
  }

  Future<void> initializePlayer() async {
    _controller =
        VideoPlayerController.network(widget.cardModel.media[0].fileUrl);
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
        .doc(widget.feedModel.userId)
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
        .doc(widget.feedModel.userId)
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
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
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
                          child: Text(widget.cardModel.toolsList[index].title,
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
        itemCount: widget.cardModel.toolsList.length);
  }

  Widget image(BuildContext context) {
    return Container(
      height: 250,
      child: PageView.builder(
        itemBuilder: (itemBuilder, index2) {
          return Container(
              child: imageView(
                  context, widget.cardModel.media[index2].fileUrl, 200, 0.0));
        },
        itemCount: widget.cardModel.media.length,
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
      errorWidget: (context, url, error) => setPostDefaultImage(context),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      widget.cardModel.type == "Video"
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
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              130,
                                          child: SizedBox(
                                            width: 30.0,
                                            height: 30.0,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      AppColors.primaryColor),
                                            ),
                                          ),
                                        )),
                            )
                          : widget.cardModel.type == "Image"
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
                                    image: AssetImage(
                                        "assets/images/grey_bg.png"))),
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
                                      image: AssetImage(
                                          "assets/images/grey_bg.png"))),
                              child: Image.asset(
                                "assets/images/menu.png",
                              )),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Image.asset("assets/images/share.png",
                              height: 16,
                              width: 16,
                              color: AppColors.cardTextColor),
                          SizedBox(width: 10),
                          Text("Share",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: Constants.openSauceFont,
                                  color: AppColors.cardTextColor,
                                  fontWeight: FontWeight.w600))
                        ],
                      ),
                      Container(width: 1, height: 20, color: Color(0xffEDEEF0)),
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/download.png",
                            color: AppColors.cardTextColor,
                            height: 16,
                            width: 16,
                          ),
                          SizedBox(width: 10),
                          Text("Save",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.cardTextColor,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(width: 10),
                          Text("(1.2k)",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.cardTextColor,
                                  fontWeight: FontWeight.w400))
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: 70,
                          height: 25,
                          margin: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                              color: Color(0xffEFEFEF),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4))),
                          child: Center(
                            child: Text(widget.feedModel.type ?? "",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    fontFamily: Constants.openSauceFont)),
                          )),
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.cardModel.title ?? "",
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
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AppHumanAnatomy(
                                                  bodyPartsListIntent: widget
                                                      .feedModel
                                                      .cardData
                                                      .bodyParts,
                                                  isEditableFields: false,
                                                )));
                                  },
                                  child: Image.asset("assets/images/body.png",
                                      height: 45, width: 45),
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
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        alignment: Alignment.topLeft,
                        child: Text("www.bodybuilding.com",
                            style: TextStyle(
                                color: Color(0xff738497),
                                fontWeight: FontWeight.w400,
                                fontFamily: Constants.openSauceFont,
                                fontSize: 13)),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        alignment: Alignment.topLeft,
                        child: Text(widget.cardModel.description ?? "",
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
                              height: 2,
                              color: Color(0xffEDEEF0)),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 10),
                            child: Row(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  height: 40,
                                  width: 40,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    radius: 40,
                                    backgroundImage: NetworkImage(
                                      userFirebaseModel != null
                                          ? userFirebaseModel.userImage
                                          : "https://www.bodybuilding.com/fun/images/2015/how-to-make-yourself-the-best-trainer-at-any-gym-facebook-box-960x540.jpg",
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                          userFirebaseModel != null
                                              ? userFirebaseModel.userName
                                              : "",
                                          style: TextStyle(
                                              color: AppColors.darkTextColor,
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  Constants.openSauceFont,
                                              fontSize: 14)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                          Utilities.timeAgoSinceDate(
                                              widget.feedModel.timestamp,
                                              numericDates: true),
                                          style: TextStyle(
                                              color: AppColors.greyTextColor,
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  Constants.openSauceFont,
                                              fontSize: 10)),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                if (widget.cardModel.createdBy != globalUserId)
                                  InkWell(
                                    onTap: () {
                                      String chatRoomId =
                                          Constants.getChatRoomId(globalUserId,
                                              widget.cardModel.createdBy);

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ChatFirebase(
                                                    receiverIdIntent: widget
                                                        .feedModel
                                                        .cardData
                                                        .createdBy,
                                                    chatRoomIdIntent:
                                                        chatRoomId,
                                                  )));
                                    },
                                    child: Text("Message",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: Constants.openSauceFont,
                                            color: AppColors.cardTextColor,
                                            fontWeight: FontWeight.w400)),
                                  ),
                                if (widget.cardModel.createdBy != globalUserId)
                                  SizedBox(width: 30),
                                if (widget.cardModel.createdBy != globalUserId)
                                  InkWell(
                                    onTap: () {
                                      followUnfollowCount(
                                          widget.cardModel.createdBy);
                                    },
                                    child: Text(
                                        isFollow ? "Followed" : "Follow",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: Constants.openSauceFont,
                                            color: AppColors.cardTextColor,
                                            fontWeight: FontWeight.w400)),
                                  )
                              ],
                            ),
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              height: 2,
                              color: Color(0xffEDEEF0)),
                        ]),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 40,
                        child: ListView.builder(
                          itemCount: tabsList.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            return new InkWell(
                              //highlightColor: Colors.red,
                              splashColor: AppColors.primaryColor,
                              onTap: () {
                                setState(() {
                                  tabsList.forEach(
                                      (element) => element.isSelected = false);
                                  tabsList[index].isSelected = true;
                                  selectedRoutineTab = tabsList[index].tabTitle;
                                });
                              },
                              child: TabListItem(
                                tabsList[index],
                              ),
                            );
                          },
                        ),
                      ),
                      selectedRoutineTab == "Tools & Equipment" &&  widget.cardModel.toolsList!=null
                          ? Container(child: toolsList())
                          : Container()
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
