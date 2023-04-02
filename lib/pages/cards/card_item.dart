import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/model/feed_model.dart';
import 'package:solstice/pages/cards/play_card_video.dart';
import 'package:solstice/pages/feeds/routine_detail.dart';
import 'package:solstice/pages/feeds/save_to_feed_routine.dart';
import 'package:solstice/pages/home/save_to_stitch.dart';
import 'package:solstice/pages/home_screen.dart';
import 'package:solstice/pages/onboardingflow/Profile_user.dart';
import 'package:solstice/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class CardItem extends StatelessWidget {
  final File cardFile;
  final String viewType;
  final CardModel cardModel;
  final int index;
  final int numberValue;
  String userName;
  final int cardList;
  FeedModel feedModel;
  Function selectCard;
  int sectionIndex;
  Function setNumbers;
  Function addToSection;
  bool createMode = false;
  bool isEditMode = false;
  CardItem(
      {this.cardFile,
      this.userName,
      this.viewType,
      this.cardModel,
      this.selectCard,
      this.numberValue,
      this.sectionIndex,
      this.feedModel,
      this.setNumbers,
      this.cardList,
      this.isEditMode,
      this.index,
      this.addToSection,
      this.createMode});
  var setStateVar;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        setStateVar = setState;
        return Container(
          color: Colors.white,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (createMode)
                    Container(
                      height: 45,
                      alignment: Alignment.center,
                      width: 2.0,
                      color: (index != 0) ? AppColors.viewColor : Colors.white,
                    ),
                  createMode
                      ? (cardModel.isSelectedSection
                          ? Container(
                              child: Icon(
                                Icons.check_circle,
                                color: AppColors.greenColor,
                                size: 20,
                              ),
                            )
                          : Container(
                              width: 20.0,
                              height: 20.0,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.bordergrey, width: 1),
                                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                  color: Colors.white),
                              child: Text(
                                '$numberValue',
                                style: TextStyle(fontSize: 12, color: AppColors.darkTextColor),
                                textAlign: TextAlign.center,
                              ),
                            ))
                      : Container(
                          width: 5,
                        ),
                  if (createMode)
                    Container(
                      height: 45.0,
                      alignment: Alignment.center,
                      width: 2.0,
                      color: (index < cardList - 1) ? AppColors.viewColor : Colors.white,
                    ),
                ],
              ),
              Expanded(
                  child: GestureDetector(
                onLongPress: () {
                  if (!isEditMode) {
                    cardModel.isSelectedSection = !cardModel.isSelectedSection;
                    isEditMode = true;
                    setState(() {});
                    addToSection(index, sectionIndex, cardList);
                  }
                },
                onTap: () {
                  if (createMode) {
                    if (isEditMode) {
                      cardModel.isSelectedSection = !cardModel.isSelectedSection;
                      setState(() {});
                      addToSection(index, sectionIndex, cardList);
                    }
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                RoutineDetail(null, null, true, cardModel.feedId)));
                  }
                },
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                  elevation: 1.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            if (cardModel.type == "Video") {
                              showPartVideoPlay(
                                  context, cardModel.media[0].fileUrl, cardModel.title);
                            }
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            margin: EdgeInsets.symmetric(
                              horizontal: 5.0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(7.0)),
                            ),
                            child: Stack(alignment: Alignment.center, children: [
                              Container(
                                height: 50,
                                width: 50,
                                child: cardModel.media.length > 0
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(7.0)),
                                        child: CachedNetworkImage(
                                          imageUrl: cardModel.type == "Video"
                                              ? cardModel.media[0].thumbnail
                                              : cardModel.media[0].fileUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(
                                            child: SizedBox(
                                              width: 13.0,
                                              height: 13.0,
                                              child: new CircularProgressIndicator(),
                                            ),
                                          ),
                                        ),
                                      )
                                    : (cardModel.type == "Text"
                                        ? Card(
                                            elevation: 0.8,
                                            borderOnForeground: true,
                                            child: Center(
                                              child: Text(
                                                cardModel.title.substring(0, 1),
                                                style:
                                                    TextStyle(fontSize: 18.0, color: Colors.black),
                                                textAlign: TextAlign.center,
                                              ),
                                            ))
                                        : !createMode
                                            ? Card(
                                                elevation: 0.8,
                                                borderOnForeground: true,
                                                child: Center(
                                                  child: Text(
                                                    cardModel.title.substring(0, 1),
                                                    style: TextStyle(
                                                        fontSize: 18.0, color: Colors.black),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ))
                                            : (cardModel.cardId != null
                                                ? Card(
                                                    elevation: 0.8,
                                                    borderOnForeground: true,
                                                    child: Center(
                                                      child: Text(
                                                        cardModel.title.substring(0, 1),
                                                        style: TextStyle(
                                                            fontSize: 18.0, color: Colors.black),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ))
                                                : ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.all(Radius.circular(7.0)),
                                                    child: Image.file(
                                                      cardModel.type == "Video"
                                                          ? cardModel.videoFiles.keys.elementAt(0)
                                                          : cardModel.imageFiles[0],
                                                      fit: BoxFit.cover,
                                                    )))),
                              ),
                              if (cardModel.type == "Video")
                                Container(
                                  height: 20,
                                  width: 20,
                                  child: Image.asset(
                                    Constants.videoIcon,
                                    height: 20,
                                    width: 20,
                                  ),
                                )
                            ]),
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              cardModel.title,
                              style: TextStyle(
                                  fontSize: 14.0,
                                  color: AppColors.darkTextColor,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: Constants.openSauceFont),
                            ),
                            //
                            if (cardModel.description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0),
                                child: InkWell(
                                  onTap:(){
                                    if(checkValidUrl(cardModel.description)){
                                      _launchURL(cardModel.description);
                                    }
                                  },
                                  child: Text(
                                    cardModel.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 13.0,
                                        color: checkValidUrl(cardModel.description)?AppColors.blueColor: AppColors.lightGreyColor,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: Constants.openSauceFont),
                                  ),
                                ),
                              ),
                            SizedBox(
                              height: 3.0,
                            ),
                            if (createMode)
                              Row(
                                children: [
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      setNumbers(cardModel, sectionIndex, index);
                                    },
                                    child: Container(
                                        height: 30,
                                        width: 90,
                                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: AppColors.blueColor),
                                        ),
                                        alignment: Alignment.topCenter,
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Center(
                                                child: Image.asset(Constants.numbers,
                                                    height: 14, width: 14),
                                              ),
                                              SizedBox(width: 5),
                                              Center(
                                                child: Text(
                                                  Constants.numberK,
                                                  style: TextStyle(
                                                    color: AppColors.blueColor,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: "open_saucesans_regular",
                                                  ),
                                                ),
                                              )
                                            ])),
                                  ),
                                ],
                              ),
                            if (!createMode)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (cardModel.userFirebaseModel.id != globalUserId) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Profile_User_Screen(
                                                      userID: cardModel.userFirebaseModel.id,
                                                      userImage:
                                                          cardModel.userFirebaseModel.userImage,
                                                      userName:
                                                          cardModel.userFirebaseModel.userName,
                                                      viewType: "card",
                                                    )));

                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) =>
                                        //             OtherUserProfile(
                                        //               userID: cardModel
                                        //                   .userFirebaseModel.id,
                                        //               userImage: cardModel
                                        //                   .userFirebaseModel
                                        //                   .userImage,
                                        //               userName: cardModel
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
                                    child: Text(
                                      '@$userName',
                                      style: TextStyle(
                                          fontSize: 13.0,
                                          color: AppColors.lightGreyColor,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: Constants.openSauceFont,
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      saveCardToRoutineAndStitch(context);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.0),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(30.0),
                                          ),
                                          color: AppColors.downloadBgColor),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            Constants.icDownload,
                                            height: 16.0,
                                            width: 16.0,
                                          ),
                                          Text(
                                            '${cardModel.saveCount}',
                                            style: TextStyle(
                                                fontSize: 11.0, color: AppColors.lightGreyColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            SizedBox(
                              height: 10.0,
                            )
                          ],
                        ))
                      ],
                    ),
                  ),
                ),
              )),
              !createMode && !isEditMode
                  ? Container(
                      width: 15.0,
                    )
                  : InkWell(
                      onTap: () {
                        selectCard(cardModel, index);
                      },
                      child: Container(
                        margin: EdgeInsets.all(5.0),
                        padding: EdgeInsets.all(viewType != null && viewType != "" ? 5.0 : 1.0),
                        child: Image.asset(
                          viewType != null && viewType != ""
                              ? Constants.drag
                              : (!cardModel.isSelected
                                  ? Constants.addCircleIcon
                                  : Constants.circleCheckIcon),
                          height: viewType != null && viewType != "" ? 15 : 24.0,
                          width: viewType != null && viewType != "" ? 15 : 24.0,
                        ),
                      ),
                    )
            ],
          ),
        );
      },
    );
  }

  showPartVideoPlay(context, String videoUrl, String title) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          child: PlayCardVideo(
            videoFile: videoUrl,
            title: title,
          ),
        );
      },
    );
  }

  void saveCardToRoutineAndStitch(context) {
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

                        saveCardToRoutine(context);
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
                              saveCardToStitch(context);
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

  Future<void> saveCardToRoutine(context) async {
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
      String sectionId = object["sectionId"];
      if (routineId.isNotEmpty) {
        addCardToRoutine(routineId, sectionId, context);
      }
    }
  }

  Future<void> saveCardToStitch(context) async {
    var object = await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
        ),
        builder: (BuildContext context) {
          return SaveToStitch(
            feedId: cardModel.feedId,
          );
        });

    if (object != null) {
      String stichId = object["stitch_id"];
      if (stichId.isNotEmpty) {
        addStitchToPost(stichId, context);
      }
    }
  }

  void addStitchToPost(String stitchId, BuildContext context1) {
    FirebaseFirestore.instance.collection(Constants.stitchCollection).doc(stitchId).update({
      'card_ids': FieldValue.arrayUnion([cardModel.cardId])
    }).then((value) {
      saveFeedCount(context1);
    });
  }

  void saveFeedCount(context1) {
    var saveCount = cardModel.saveCount + 1;
    FirebaseFirestore.instance
        .collection(Constants.cardsColl)
        .doc(cardModel.cardId)
        .update({"save_count": saveCount}).then((value) {
      cardModel.saveCount = saveCount;
      setStateVar(() {});
      //  Constants().successToast(context1, "Card added to stitch");
    });
  }

  void addCardToRoutine(String routineId, String sectionId, context) {
    FirebaseFirestore.instance.collection(Constants.sectionColl).doc(sectionId).update({
      "card_ids": FieldValue.arrayUnion([cardModel.cardId])
    }).then((value) {
      Constants().successToast(context, "Card added to Routine");
      saveFeedCount(context);
    });
  }

  bool checkValidUrl(String link){
return Uri.parse(link).isAbsolute;

  }
_launchURL(String link) async {
    if (await canLaunch(link)) {
      await launch(link);
    } else {
      throw 'Could not launch $link';
    }
  }
}
