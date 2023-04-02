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

class ProfileVideoItem extends StatefulWidget {
  final FeedModel feedModel;
  final bool isInView;
  Function filterCategory;
  ProfileVideoItem({this.feedModel, this.isInView, this.filterCategory});
  @override
  _ProfileVideoItemState createState() => _ProfileVideoItemState();
}

class _ProfileVideoItemState extends State<ProfileVideoItem>

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
  void didUpdateWidget(ProfileVideoItem oldWidget) {
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
      looping: true,
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
    return widget.feedModel.userFirebaseModel != null ? cardDetailWidget(context) : Container();
  }

  Widget cardDetailWidget(context) {
    return Container(
      width : 100,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          widget.feedModel.type == "Card" ? cardInfo() : routineInfo(widget.feedModel.routineModel),
          SizedBox(
            height: 10,
          ),
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
                        width: 25.0,
                        height: 25.0,
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

  _displayDialog(BuildContext context) async {
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(context)
            .modalBarrierDismissLabel,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext,
            Animation animation,
            Animation secondaryAnimation) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState)
          {
            return Center(
              child: Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: MediaQuery
                    .of(context)
                    .size
                    .width,
                padding: EdgeInsets.all(0),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
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
                            width: MediaQuery
                                .of(buildContext)
                                .size
                                .width,
                            child: Container(
                              // fit: BoxFit.fitWidth,
                              child: ClipRRect(
                                child: Container(
                                  width: double.infinity,
                                  child: Stack(
                                    children: [
                                      AspectRatio(
                                        aspectRatio:
                                        _controller.value.size.height >
                                            _controller.value.size.width
                                            ? 1
                                            : 1.5,
                                        child: Container(
                                          // height: _controller.value.size.height >
                                          //         _controller.value.size.width
                                          //     ? MediaQuery.of(context).size.width
                                          //     : (MediaQuery.of(context).size.width / 1.5),
                                          color: Colors.black,
                                          child: FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: VisibilityDetector(
                                                  key: ObjectKey(
                                                      chewieController),
                                                  onVisibilityChanged: (
                                                      visibility) {
                                                    if (visibility
                                                        .visibleFraction == 0 &&
                                                        this.mounted) {
                                                      chewieController
                                                          ?.pause(); //pausing  functionality
                                                    }
                                                    if ((visibility
                                                        .visibleFraction *
                                                        100) < 50.0) {
                                                      chewieController
                                                          ?.pause(); //pausing  functionality
                                                    }
                                                  },
                                                  child: Chewie(
                                                      controller: chewieController))),
                                        ),
                                      ),
                                      if (!chewieController?.isPlaying)
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          top: 0,
                                          bottom: 0,
                                          child: Container(
                                              alignment: Alignment.center,
                                              width: 45.0,
                                              height: 45.0,
                                              child: SvgPicture.asset(
                                                  Constants.playIcon)),
                                        )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        }).then((exit) {
          if(exit == null) {
            print("5555555555555555");
            if(chewieController?.isPlaying) {
              chewieController?.pause();
            }
          }
          if(exit) {
            print("6666666666666");
            if(chewieController?.isPlaying) {
              chewieController?.pause();
            }
          } else {
            print("4444444444444444");
            if(chewieController?.isPlaying) {
              chewieController?.pause();
            }
          }
    });
}

  Widget videoWidget() {
    return InkWell(
      onTap: () {
        if (chewieController.isPlaying) {
          chewieController.pause();
        } else {
          chewieController.play();
        }
        _displayDialog(context);
        setState(() {});
      },
      child: Column(
        children: [
          Container(
            // height: _controller.value.size.height > _controller.value.size.width
            //     ? MediaQuery.of(context).size.width
            //     : (MediaQuery.of(context).size.width / 1.5),

            width : 100,
            height : 100,
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
                              width: 10.0,
                              height: 10.0,
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
