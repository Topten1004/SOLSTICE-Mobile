import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share/share.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/model/feed_model.dart';
import 'package:solstice/model/routine_model.dart';
import 'package:solstice/pages/cards/card_parts_item.dart';
import 'package:solstice/pages/cards/tags_item.dart';
import 'package:solstice/pages/feeds/feed_detail.dart';
import 'package:solstice/pages/feeds/save_to_feed_routine.dart';
import 'package:solstice/pages/home/save_to_stitch.dart';
import 'package:solstice/pages/home_screen.dart';
import 'package:solstice/pages/onboardingflow/Profile_user.dart';
import 'package:solstice/pages/onboardingflow/profiletypescreen.dart';
import 'package:solstice/pages/profile/other_user_profile.dart';
import 'package:solstice/pages/routine/section_cards.dart';
import 'package:solstice/pages/routine/share_routine.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/utilities.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'routine_detail.dart';

class CardFeedItem extends StatefulWidget {
  final FeedModel feedModel;
  final bool isInView;
  Function filterCategory;
  CardFeedItem({this.feedModel, this.isInView, this.filterCategory});
  @override
  _CardFeedItemState createState() => _CardFeedItemState();
}

class _CardFeedItemState extends State<CardFeedItem>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  bool showParts = false;
  CardModel cardModel;

  VideoPlayerController _controller;
  ChewieController chewieController;
  Future<void> _initializeVideoPlayerFuture;
  double videoContainerRatio = 0.5;

  bool keepAlive = true;
  @override
  bool get wantKeepAlive => keepAlive;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.feedModel.routineModel.cardType == "Video") {
      if (chewieController == null) {
        initializePlayer(widget.feedModel.routineModel.fileUrl);
      }
    }
    // if (widget.feedModel.cardData.type == "Video") {
    // initializePlayer(widget.feedModel.cardData.media[0].fileUrl);
    // }
  }

  double getScale() {
    double videoRatio = _controller.value.aspectRatio;

    if (videoRatio < videoContainerRatio) {
      ///for tall videos, we just return the inverse of the controller aspect ratio
      return videoContainerRatio / videoRatio;
    } else {
      ///for wide videos, divide the video AR by the fixed container AR
      ///so that the video does not over scale

      return videoRatio / videoContainerRatio;
    }
  }

  @override
  void didUpdateWidget(CardFeedItem oldWidget) {
    if (oldWidget.isInView != widget.isInView) {
      if (chewieController != null) {
        if (widget.isInView) {
          // chewieController.play();
        } else {
          chewieController.pause();
        }
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive) {
      if (_controller != null) {
        // _controller.dispose();
      }
    }
    // disposeController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    disposeController();
  }

  void disposeController() {
    if (_controller != null) {
      _controller.pause();
    }
    if (chewieController != null) {
      chewieController.pause();
    }
  }

  Future<void> initializePlayer(String videoUrl) async {
    _controller = VideoPlayerController.network(videoUrl);
    await _controller.initialize();
    chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: false,
      looping: false,
      allowMuting: false,
      allowFullScreen: false,
      allowPlaybackSpeedChanging: false,
      showControls: false,
      fullScreenByDefault: false,
    );
    if (widget.isInView) {
      // _controller.play();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.feedModel.userFirebaseModel != null ? cardDetailWidget() : Container();
  }

  Widget cardDetailWidget() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          if (widget.feedModel.sharedBy.isNotEmpty)
            Container(
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                  ),
                  Image.asset(
                    Constants.reSharedIcon,
                    height: 17.0,
                    width: 17.0,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 13.0),
                      child: Text.rich(TextSpan(
                          text: widget.feedModel.sharedByUsernName,
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.darkTextColor,
                              fontWeight: FontWeight.w700),
                          children: <InlineSpan>[
                            TextSpan(
                              text: ' has shared this routine',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.greyTextColor,
                                  fontWeight: FontWeight.w500),
                            )
                          ])),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                widget.feedModel.userFirebaseModel != null &&
                        widget.feedModel.userFirebaseModel.userImage != null &&
                        widget.feedModel.userFirebaseModel.userImage != ""
                    ? InkWell(
                        onTap: () {
                          if (widget.feedModel.userFirebaseModel.id != globalUserId) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Profile_User_Screen(
                                          userID: widget.feedModel.userFirebaseModel.id,
                                          userImage: widget.feedModel.userFirebaseModel.userImage,
                                          userName: widget.feedModel.userFirebaseModel.userName,
                                          viewType: "card_feed",
                                        )));

                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => OtherUserProfile(
                            //               userID: widget
                            //                   .feedModel.userFirebaseModel.id,
                            //               userImage: widget.feedModel
                            //                   .userFirebaseModel.userImage,
                            //               userName: widget.feedModel
                            //                   .userFirebaseModel.userName,
                            //             )));

                          }

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen(
                                        currentIndex: 4,
                                      )));
                        },
                        child: CachedNetworkImage(
                          imageUrl: widget.feedModel.userFirebaseModel.userImage,
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
                      )
                    : Container(
                        width: 33.0,
                        height: 33.0,
                        child: SvgPicture.asset(
                          'assets/images/ic_male_placeholder.svg',
                          width: 33.0,
                          height: 33.0,
                          fit: BoxFit.fill,
                        )),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: InkWell(
                  onTap: () {
                    if (widget.feedModel.userFirebaseModel.id != globalUserId) {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => OtherUserProfile(
                      //               userID: widget.feedModel.userFirebaseModel.id,
                      //               userImage: widget.feedModel.userFirebaseModel.userImage,
                      //               userName: widget.feedModel.userFirebaseModel.userName,
                      //             )));

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Profile_User_Screen(
                                    userID: widget.feedModel.userFirebaseModel.id,
                                    userImage: widget.feedModel.userFirebaseModel.userImage,
                                    userName: widget.feedModel.userFirebaseModel.userName,
                                    viewType: "card_feed",
                                  )));
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          widget.feedModel.userFirebaseModel.userName,
                          style: TextStyle(
                              fontSize: 14.0,
                              color: AppColors.darkTextColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          Utilities.timeAgoSinceDate(widget.feedModel.timestamp,
                              numericDates: true),
                          style: TextStyle(
                              fontSize: 10.0,
                              color: AppColors.lightGreyColor,
                              fontWeight: FontWeight.w400),
                        ),
                      )
                    ],
                  ),
                )),
                InkWell(
                  onTap: () {
                    disposeController();
                    if (widget.feedModel.type == "Card") {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  FeedDetailPage(widget.feedModel, widget.feedModel.cardData)));
                    } else if (widget.feedModel.type == "Routine") {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RoutineDetail(
                                  widget.feedModel.routineModel, widget.feedModel, false, "")));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.feedModel.type == "Card" ? Constants.card : Constants.routine,
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.w600, color: AppColors.blueColor),
                    ),
                  ),
                ),
                SvgPicture.asset(
                  Constants.rightArrowIcon,
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              widget.feedModel.type == "Card"
                  ? widget.feedModel.cardData.title
                  : widget.feedModel.routineModel.title,
              style: TextStyle(
                  fontSize: 14, color: AppColors.darkTextColor, fontWeight: FontWeight.w700),
            ),
          ),
          if (widget.feedModel.type == "Card")
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
              child: Text(
                widget.feedModel.type == "Card" ? widget.feedModel.cardData.description : "",
                style: TextStyle(
                    fontSize: 13, color: AppColors.darkTextColor, fontWeight: FontWeight.w400),
              ),
            ),
          SizedBox(
            height: 7,
          ),
          Container(
            height: 43,
            margin: EdgeInsets.symmetric(horizontal: 7.0),
            child: tagsList(),
          ),
          SizedBox(
            height: 10,
          ),
          widget.feedModel.type == "Card" ? cardInfo() : routineInfo(widget.feedModel.routineModel),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 45,
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Row(
                  children: [
                    SvgPicture.asset(Constants.eyeIcon),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "${widget.feedModel.feedViewCount}",
                        style: TextStyle(
                            fontSize: 14.0,
                            color: AppColors.greyTextColor,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                )),
                InkWell(
                  onTap: () {
                    shareFeedToRoutine();
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(Constants.shareIcon),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 5.0),
                        child: Text(
                          Constants.share,
                          style: TextStyle(
                              fontSize: 14.0,
                              color: AppColors.blueColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 2.0,
                  color: AppColors.viewColor,
                  margin: EdgeInsets.symmetric(horizontal: 13.0),
                  height: 16,
                ),
                InkWell(
                  onTap: () {
                    saveThisRoutine();
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(Constants.saveIcon),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 5.0),
                        child: Text(
                          '${Constants.save} (${widget.feedModel.saveCount})',
                          style: TextStyle(
                              fontSize: 14.0,
                              color: AppColors.blueColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Stack(children: [
            Column(
              children: [
                Container(
                  child: widget.feedModel.type == "Card"
                      ? cardPartsList()
                      : SectionCards(
                          sectionList: widget.feedModel.routineModel.sectionIds,
                          feedModel: widget.feedModel,
                          fromFeed: true,
                          expandFeed: false,
                          userName: widget.feedModel.userFirebaseModel.userName),
                ),
                Container(
                  height: 20,
                  color: Colors.white,
                ),
                if (widget.feedModel.type == "Routine")
                  if (widget.feedModel.routineModel.sectionIds.length > 1)
                    IgnorePointer(
                      ignoring: true,
                      child: Container(
                        height: 30.0,
                        color: Colors.grey[100],
                      ),
                    )
              ],
            ),
            if (widget.feedModel.type == "Routine" &&
                widget.feedModel.routineModel.sectionIds.length > 1)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  ignoring: true,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 85,
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.7),
                        spreadRadius: 2,
                        blurRadius: 13,
                        offset: Offset(0, 15), // changes position of shadow
                      ),
                    ]),
                  ),
                ),
              ),
            if (widget.feedModel.type == "Routine" &&
                widget.feedModel.routineModel.sectionIds.length > 1)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: InkWell(
                    onTap: () {
                      widget.feedModel.routineModel.expandRoutine =
                          !widget.feedModel.routineModel.expandRoutine;
                      setState(() {});
                    },
                    child: Container(
                      height: 55.0,
                      width: 55.0,
                      color: Colors.transparent,
                      child: Image.asset(
                        widget.feedModel.routineModel.expandRoutine
                            ? Constants.collapseIcon
                            : Constants.expandIcon,
                        height: 55.0,
                        width: 55.0,
                      ),
                    )),
              ),
          ]),
        ],
      ),
    );
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
        addRotuineToFeed(routineId, context, widget.feedModel);
      }
    }
  }

  void addRotuineToFeed(routineId, context, FeedModel feedModel) {
    FirebaseFirestore.instance.collection(Constants.routineFeedCollection).doc(routineId).update(
        {"section_ids": FieldValue.arrayUnion(feedModel.routineModel.sectionIds)}).then((value) {
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
            feedId: widget.feedModel.id,
          );
        });

    if (object != null) {
      String stichId = object["stitch_id"];
      if (stichId.isNotEmpty) {
        addStitchToPost(stichId, context, widget.feedModel);
      }
    }
  }

  void saveFeedCount() {
    var saveCount = widget.feedModel.saveCount + 1;
    FirebaseFirestore.instance
        .collection(Constants.feedsColl)
        .doc(widget.feedModel.id)
        .update({"save_count": saveCount}).then((value) {
      setState(() {
        keepAlive = false;
      });
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
            feedId: widget.feedModel.id,
            feedModel: widget.feedModel,
          ),
          height: MediaQuery.of(context).size.height * 0.64,
        );
      },
    );
  }

  Widget cardInfo() {
    return Container(
        child: widget.feedModel.cardData.type != "Text"
            ? Container(
                margin: EdgeInsets.symmetric(horizontal: 13.0),
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12))),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  child: (widget.feedModel.cardData.type == "Image")
                      ? Container(
                          height: 200,
                          margin: EdgeInsets.symmetric(horizontal: 13.0),
                          child: PageView.builder(
                            itemBuilder: (itemBuilder, index2) {
                              return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 13.0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(12))),
                                  child: imageView(context,
                                      widget.feedModel.cardData.media[index2].fileUrl, 200, 0.0));
                            },
                            itemCount: widget.feedModel.cardData.media.length,
                            scrollDirection: Axis.horizontal,
                            onPageChanged: (index) {
                            },
                          ),
                        )
                      : chewieController != null
                          ? InkWell(
                              onTap: () {
                                if (chewieController.isPlaying) {
                                  chewieController.pause();
                                } else {
                                  chewieController.play();
                                }
                              },
                              child: AspectRatio(
                                  aspectRatio: chewieController.aspectRatio,
                                  child: Chewie(
                                    controller: chewieController,
                                    // ),
                                  )))
                          : InkWell(
                              onTap: () {
                                if (chewieController.isPlaying) {
                                  chewieController.pause();
                                } else {
                                  chewieController.play();
                                }
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: 13.0),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(12))),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                      child: imageView(context,
                                          widget.feedModel.cardData.media[0].thumbnail, 200, 0.0),
                                    ),
                                  ),
                                  Container(
                                      width: 45.0,
                                      height: 45.0,
                                      child: SvgPicture.asset(Constants.playIcon))
                                ],
                              ),
                            ),
                ))
            : Container());
  }

  Widget routineInfo(RoutineModel routineModel) {
    return Container(
        child: routineModel.cardType != "Text"
            ? Container(
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12))),
                child: (routineModel.cardType == "Image")
                    ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 10.0),
                        decoration:
                            BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12))),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          child: imageView(context, routineModel.fileUrl, 200, 0.0),
                        ))
                    : chewieController != null
                        ? videoWidget()
                        : InkWell(
                            onTap: () {
                              // if (chewieController == null) {
                              //   initializePlayer(routineModel.fileUrl);
                              // }
                              if (chewieController != null) {
                                if (chewieController.isPlaying) {
                                  chewieController.pause();
                                } else {
                                  chewieController.play();
                                }
                              } else {
                              }
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AspectRatio(
                                  aspectRatio:
                                      _controller.value.size.height > _controller.value.size.width
                                          ? 1
                                          : 1.5,
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 10.0),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(12))),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                      child: imageView(
                                          context,
                                          routineModel.thumbnail,
                                          _controller.value.size.height >
                                                  _controller.value.size.width
                                              ? MediaQuery.of(context).size.width
                                              : (MediaQuery.of(context).size.width / 1.5),
                                          0.0),
                                    ),
                                  ),
                                ),
                                Container(
                                    width: 45.0,
                                    height: 45.0,
                                    child: SvgPicture.asset(Constants.playIcon))
                              ],
                            ),
                            // ),
                          ))
            : Container());
  }

  Widget videoWidget() {
    return InkWell(
      onTap: () {

        if (chewieController.isPlaying) {
          chewieController.pause();
        } else {
          chewieController.play();
        }
        setState(() {});
      },
      child: Column(
        children: [
          Container(
            height: _controller.value.size.height > _controller.value.size.width
                ? MediaQuery.of(context).size.width
                : (MediaQuery.of(context).size.width / 1.5),
            child: Container(
              // fit: BoxFit.fitWidth,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                child: Container(
                  width: double.infinity,
                  //      height: _controller.value.size.height > _controller.value.size.width
                  // ? MediaQuery.of(context).size.width
                  // : (MediaQuery.of(context).size.width / 1.5),
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12))),
                  // margin: EdgeInsets.symmetric(horizontal: 15.0) ,
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio:
                            _controller.value.size.height > _controller.value.size.width ? 1 : 1.5,
                        child: Container(
                          // height: _controller.value.size.height >
                          //         _controller.value.size.width
                          //     ? MediaQuery.of(context).size.width
                          //     : (MediaQuery.of(context).size.width / 1.5),
                          color: Colors.black,
                          child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: VisibilityDetector(
                                  key: ObjectKey(chewieController),
                                  onVisibilityChanged: (visibility) {
                                    if (visibility.visibleFraction == 0 && this.mounted) {
                                      chewieController?.pause(); //pausing  functionality
                                    }
                                    if ((visibility.visibleFraction * 100) < 50.0) {
                                      chewieController?.pause(); //pausing  functionality
                                    }
                                  },
                                  child: Chewie(controller: chewieController))),
                        ),
                      ),
                      if (!chewieController.isPlaying)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                              alignment: Alignment.center,
                              width: 45.0,
                              height: 45.0,
                              child: SvgPicture.asset(Constants.playIcon)),
                        )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget videoPlayWidget() {
    return Container(
      child: InkWell(
        onTap: () {
          if (chewieController.isPlaying) {
            chewieController.pause();
          } else {
            chewieController.play();
          }
        },
        child: Column(
          children: [
            Container(
              child: Stack(fit: StackFit.loose, children: [
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    child: Container(
                      //      height: _controller.value.size.height > _controller.value.size.width
                      // ? MediaQuery.of(context).size.width
                      // : (MediaQuery.of(context).size.width / 1.5),
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12))),
                      // margin: EdgeInsets.symmetric(horizontal: 15.0) ,
                      child: Stack(
                        // fit: StackFit.loose,
                        children: [
                          Container(
                            color: Colors.black,
                            child: Chewie(controller: chewieController),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }

// Card Parts List
  Widget cardPartsList() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return CardPartsItem(
          index: index,
          numberValue: index + 1,
          title: widget.feedModel.cardData.title,
          listSize: widget.feedModel.cardData.media.length,
          media: widget.feedModel.cardData.media[index],
        );
      },
      itemCount: (widget.feedModel.cardData.media.length > 2 && !showParts)
          ? 2
          : widget.feedModel.cardData.media.length,
      primary: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
    );
  }

  Widget tagsList() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            if (widget.feedModel.type == "Card") {
              widget.filterCategory(widget.feedModel.cardData.categoryList[index].title);
            } else {
              widget.filterCategory(widget.feedModel.routineModel.categoryList[index].title);
            }
          },
          child: TagsItem(
            filterModel: widget.feedModel.type == "Card"
                ? widget.feedModel.cardData.categoryList[index]
                : widget.feedModel.routineModel.categoryList[index],
          ),
        );
      },
      itemCount: widget.feedModel.type == "Card"
          ? widget.feedModel.cardData.categoryList.length
          : widget.feedModel.routineModel.categoryList.length,
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
    );
  }
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
