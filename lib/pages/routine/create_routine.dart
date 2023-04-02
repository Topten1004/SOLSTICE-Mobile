import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/model/numerical_inputs_model/numeric_input_model.dart';
import 'package:solstice/model/routine_section_model.dart';
import 'package:solstice/pages/cards/add_title.dart';
import 'package:solstice/pages/cards/card_camera.dart';
import 'package:solstice/pages/cards/card_item.dart';
import 'package:solstice/pages/cards/choose_human_body_part.dart';
import 'package:solstice/pages/cards/numerical_inputs.dart';
import 'package:solstice/pages/routine/add_to_section.dart';
import 'package:solstice/pages/routine/createsection.dart';
import 'package:solstice/pages/routine/numeric_inputs_with_title.dart';
import 'package:solstice/pages/routine/routine_tags.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/dialog_callback.dart';
import 'package:solstice/utils/utilities.dart';

import 'choose_card.dart';

class CreateRoutine extends StatefulWidget {
  final String routineName;
   String sharedata;
  CreateRoutine({this.routineName, this.sharedata});

  @override
  _CreateRoutineState createState() => _CreateRoutineState();
}

class _CreateRoutineState extends State<CreateRoutine> implements DialogCallBack {
  bool isDescriptionSelected = false;
  List<Asset> images = List<Asset>.empty(growable: true);
  List<File> _files = new List.empty(growable: true);
  List<Media> _mediaList = new List.empty(growable: true);
  File mediaFile;
  String cardType = "";
  List<SetNumbers> setNumbersList = new List.empty(growable: true);
  // List<CardModel> cardList = new List.empty(growable: true);
  List<RoutineSectionModel> sectionList = new List.empty(growable: true);
  TextEditingController titleController = new TextEditingController();
  TextEditingController descController = new TextEditingController();
  List<CardModel> seletedCardList = new List.empty(growable: true);
  List<String> _bodyPartList = new List.empty(growable: true);
  String feedId = "";
  List<HashMap<File, File>> videoFiles = new List.empty(growable: true);
  File imageFile;
  HashMap<File, File> videoFile = new HashMap();
  int cardIndex, sectionIndex;
  int selectedCardsCount = 0;
  int reorderSectionIndex = 0;
  List<NumericalInputsModel> numericalInputsList = new List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    if (widget.sharedata != null && widget.sharedata != "") {
      isDescriptionSelected = true;
      descController.text = widget.sharedata;
      cardType = "Image";
      FirebaseFirestore.instance.collection(Constants.settingsCollec).get().then((value) {
        twitterImage = value.docs.first.data()["twitter_icon"];
        youtubeImage = value.docs.first.data()["youtube_icon"];
        instagramImage = value.docs.first.data()["instagram_icon"];
        tikTokImage = value.docs.first.data()["tiktok_icon"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
        onPressed: () => {Navigator.of(context).pop()},
      ),
      elevation: 0,
      actions: [
        if (sectionList.length > 0)
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              if (actionText == "Back") {
                selectedCardsCount = 0;
                removeEditMode();
                setState(() {});
              } else {
                if (sectionList.length == 0) {
                  Constants().errorToast(context, "Please add a card");
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RoutineTags(
                                cardType: cardType,
                                bodyPartsListIntent: [],
                                description: descController.text,
                                files: _files,
                                sectionList: sectionList,
                                mediaList: videoFiles,
                                numbersList: setNumbersList,
                                title: titleController.text,
                                routineName: widget.routineName,
                                feedId: feedId,
                              )));
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
              child: Center(
                child: Text(
                  actionText,
                  style: TextStyle(
                      fontSize: 14.0,
                      color: AppColors.segmentAppBarColor,
                      fontFamily: Constants.openSauceFont,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          )
      ],
    );
    return Scaffold(
      appBar: appBar,
      backgroundColor: Colors.white,
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Create Routine",
                  style: TextStyle(
                      fontFamily: "open_saucesans_regular",
                      color: Colors.black,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Text(
                    widget.routineName,
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14.0,
                        fontFamily: "open_saucesans_regular",
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        showImportCard();
                      },
                      child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Image.asset(Constants.import, height: 24, width: 24)),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(5, 5, 0, 5),
                                child: Text(
                                  Constants.importK,
                                  style: TextStyle(
                                      fontFamily: "open_saucesans_regular",
                                      color: AppColors.blueColor,
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                              color: AppColors.lightBlue,
                              borderRadius: BorderRadius.all(Radius.circular(53.0)))),
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(2),
                              child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Image.asset('assets/images/menu.png',
                                      color: AppColors.blueColor,
                                      fit: BoxFit.contain,
                                      height: 24,
                                      width: 24)),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.lightBlue,
                        )),
                  ],
                ),
                SizedBox(height: 15),
                Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: Container(
                      // height: 111,
                      padding: EdgeInsets.only(left: 13, right: 13),
                      child: Row(children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: TextField(
                                        autofocus: false,
                                        controller: titleController,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: Constants.addExerciseTitleHint,
                                          hintStyle: TextStyle(
                                            color: Color(0xffA3AFBD),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: "open_saucesans_regular",
                                          ),
                                        ),
                                        onChanged: (text) {
                                          setState(() {});
                                        },
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: "open_saucesans_regular",
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0),
                              Visibility(
                                visible: isDescriptionSelected ? true : false,
                                child: TextField(
                                  controller: descController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Add Description...",
                                      hintStyle: TextStyle(
                                        color: Color(0xffA3AFBD),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "open_saucesans_regular",
                                      )),
                                  onChanged: (text) {
                                    // descController.text = text;
                                  },
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "open_saucesans_regular",
                                  ),
                                ),
                              ),
                              Container(
                                height: 0.8,
                                color: Color(0xffFBF4F4),
                                width: MediaQuery.of(context).size.width,
                              ),
                              SizedBox(height: 20),
                              Container(
                                  child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          var object = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddTitle(Constants.viewTitle)));

                                          if (object != null) {
                                            titleController.text = object;
                                            setState(() {});
                                          }
                                        },
                                        child: Container(
                                            height: 30,
                                            padding: EdgeInsets.only(left: 8, right: 8),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(14),
                                              border: Border.all(color: Color(0xffFBF4F4)),
                                            ),
                                            alignment: Alignment.topCenter,
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Center(
                                                    child: Image.asset(Constants.menu_card,
                                                        height: 14, width: 14),
                                                  ),
                                                  SizedBox(width: 5),
                                                  Center(
                                                    child: Text(
                                                      Constants.chooseTitle,
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
                                      InkWell(
                                        onTap: () async {
                                          setState(() {});
                                          if (isDescriptionSelected) {
                                            var object = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddTitle(Constants.viewDesc)));

                                            if (object != null) {
                                              descController.text = object;
                                            }
                                          }
                                          isDescriptionSelected = true;
                                        },
                                        child: Container(
                                            height: 30,
                                            padding: EdgeInsets.only(left: 8, right: 8),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(14),
                                              border: Border.all(color: Color(0xffFBF4F4)),
                                            ),
                                            alignment: Alignment.topCenter,
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Center(
                                                    child: Image.asset(Constants.menu_card,
                                                        height: 14, width: 14),
                                                  ),
                                                  SizedBox(width: 5),
                                                  Center(
                                                    child: Text(
                                                      isDescriptionSelected
                                                          ? Constants.chooseDescription
                                                          : Constants.describeYourJourney,
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
                                      // SizedBox(width: 10),
                                      Container(
                                          child: Row(
                                        children: [
                                          Visibility(
                                            visible:
                                                widget.sharedata != null && widget.sharedata != ""
                                                    ? false
                                                    : true,
                                            child: InkWell(
                                              onTap: () {
                                                if (checkValids()) {
                                                  showImportBottomSheet();
                                                }
                                              },
                                              child: Container(
                                                  height: 30,
                                                  width: 68,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(14),
                                                    border: Border.all(color: Color(0xffFBF4F4)),
                                                  ),
                                                  alignment: Alignment.topCenter,
                                                  child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Center(
                                                          child: Image.asset(
                                                              "assets/images/Image.png",
                                                              height: 14,
                                                              width: 14),
                                                        ),
                                                        SizedBox(width: 5),
                                                        Center(
                                                          child: Text(
                                                            "Media",
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
                                          ),
                                        ],
                                      )),
                                      // SizedBox(width: 10),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // SizedBox(width: 10),
                                      Container(
                                          child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              if (checkValids()) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => NumericalInputsPage(
                                                              showAppBar: true,
                                                              title: titleController.text,
                                                              description: descController.text,
                                                              numericalInputsList:
                                                                  numericalInputsList,
                                                            ))).then((value) {
                                                  if (value != null) {

                                                    setNumbersList = value["numericInputs"];
                                                    numericalInputsList =
                                                        value["numericalInputsList"];
                                                  }
                                                });
                                              }
                                            },
                                            child: Container(
                                                height: 30,
                                                width: 83,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(14),
                                                  border: Border.all(color: Color(0xffFBF4F4)),
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
                                                          "Numbers",
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
                                      )),
                                      InkWell(
                                        onTap: () async {
                                          var object = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => ChooseHumanBodyPage(
                                                        isEditableFields: true,
                                                      )));

                                          if (object != null) {
                                            _bodyPartList = object["bodyParts"];
                                          }
                                        },
                                        child: Container(
                                            height: 30,
                                            padding: EdgeInsets.only(left: 8, right: 8),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(14),
                                              border: Border.all(color: Color(0xffFBF4F4)),
                                            ),
                                            alignment: Alignment.topCenter,
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Center(
                                                    child: Image.asset(Constants.bodyPartsIcon,
                                                        height: 14,
                                                        color: AppColors.cardTextColor,
                                                        width: 14),
                                                  ),
                                                  SizedBox(width: 5),
                                                  Center(
                                                    child: Text(
                                                      Constants.bodyParts,
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
                                      // SizedBox(width: 10),
                                      // if (titleController.text.toString().trim().isNotEmpty)
                                      Visibility(
                                        visible: titleController.text.toString().trim().isNotEmpty
                                            ? true
                                            : false,
                                        maintainSize: true,
                                        maintainState: true,
                                        maintainAnimation: true,
                                        maintainSemantics: true,
                                        child: Container(
                                          height: 25.0,
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              new BoxShadow(
                                                color: AppColors.blueColor,
                                                blurRadius: 10.0,
                                              ),
                                            ],
                                          ),
                                          margin: EdgeInsets.symmetric(vertical: 0.0),
                                          alignment: Alignment.center,
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            onPressed: () {
                                              numericalInputsList.clear();
                                              if (widget.sharedata != null &&
                                                  widget.sharedata != "") {
                                                if (descController.text
                                                        .contains("https://youtu.be/") ||
                                                    descController.text
                                                        .contains("https://youtube.com/")) {
                                                  _mediaList.clear();
                                                  Media mediaModel = new Media();
                                                  mediaModel.fileUrl = youtubeImage;
                                                  mediaModel.thumbnail = "";
                                                  _mediaList.add(mediaModel);
                                                } else if (descController.text
                                                    .contains("instagram.com")) {
                                                  _mediaList.clear();
                                                  Media mediaModel = new Media();
                                                  mediaModel.fileUrl = instagramImage;
                                                  mediaModel.thumbnail = "";
                                                  _mediaList.add(mediaModel);
                                                } else if (descController.text
                                                        .contains("tiktok.com") ||
                                                    descController.text.contains("tiktok")) {
                                                  _mediaList.clear();
                                                  Media mediaModel = new Media();
                                                  mediaModel.fileUrl = tikTokImage;
                                                  mediaModel.thumbnail = "";
                                                  _mediaList.add(mediaModel);
                                                } else if (descController.text
                                                        .contains("twitter.com") ||
                                                    descController.text.contains("t.co")) {
                                                  _mediaList.clear();
                                                  Media mediaModel = new Media();
                                                  mediaModel.fileUrl = twitterImage;
                                                  mediaModel.thumbnail = "";
                                                  _mediaList.add(mediaModel);
                                                }
                                              }
                                              widget.sharedata ='';
                                              createCardModel();
                                            },
                                            color: AppColors.blueColor.withOpacity(0.8),
                                            textColor: Colors.white,
                                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                                            child: Text(Constants.save.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: "open_saucesans_regular",
                                                )),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8)
                                ],
                              )),
                            ],
                          ),
                        ),
                      ]),
                    )),
                Expanded(
                  child: GestureDetector(
                    onLongPress: () {},
                    child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(top: 10.0),
                        child: ReorderableListView(
                          scrollDirection: Axis.vertical,
                          primary: true,
                          children: <Widget>[
                            for (int i = 0; i < sectionList.length; i++)
                              Container(
                                  color: Colors.white,
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // if (sectionList[i].cardList.length > 1)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 15.0,
                                            height: 15.0,
                                            child: InkWell(
                                                onTap: () {
                                                  showEditSectionPop(i);
                                                },
                                                child: Image.asset(
                                                  Constants.editIcon,
                                                )),
                                          ),
                                          SizedBox(
                                            width: 8.0,
                                          ),
                                          Expanded(
                                            child: Text(
                                              sectionList[i].title,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  fontFamily: "open_saucesans_regular",
                                                  color: Colors.black,
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                          Expanded(
                                              child: Container(
                                            alignment: Alignment.centerRight,
                                            margin: EdgeInsets.all(5.0),
                                            padding: EdgeInsets.all(5.0),
                                            child: Image.asset(
                                              Constants.drag,
                                              height: 15,
                                              width: 15,
                                            ),
                                          ))
                                        ],
                                      ),
                                      Container(
                                        height: ((sectionList[i].cardList.length) * 120).toDouble(),
                                        child: ReorderableListView(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          primary: false,
                                          scrollDirection: Axis.vertical,
                                          children: <Widget>[
                                            for (int j = 0; j < sectionList[i].cardList.length; j++)

                                              // final itemsInner
                                              //   in sectionList[i].cardList)
                                              Container(
                                                  color: Colors.white,
                                                  child: Column(
                                                    children: [
                                                      // SizedBox(height: 10),
                                                      SwipeActionCell(
                                                        key: ObjectKey(j),
                                                        performsFirstActionWithFullSwipe: false,
                                                        trailingActions: <SwipeAction>[
                                                          SwipeAction(
                                                              nestedAction: SwipeNestedAction(
                                                                ///customize your nested action content
                                                                content: Container(
                                                                  decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(30),
                                                                    color: Colors.red,
                                                                  ),
                                                                  width: 100,
                                                                  height: 40,
                                                                  child: OverflowBox(
                                                                    maxWidth: double.infinity,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment.center,
                                                                      children: [
                                                                        Icon(
                                                                          Icons.delete,
                                                                          color: Colors.white,
                                                                        ),
                                                                        Text('Sure?',
                                                                            style: TextStyle(
                                                                                fontFamily: Constants
                                                                                    .openSauceFont,
                                                                                color: Colors.white,
                                                                                fontSize: 14)),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),

                                                              ///you should set the default  bg color to transparent
                                                              color: Colors.transparent,

                                                              ///set content instead of title of icon
                                                              content: _getIconButton(
                                                                  Color(0xffF5FCFF),
                                                                  Icons.delete,
                                                                  Colors.red),
                                                              onTap: (handler) async {
                                                                await handler(false);

                                                                if (sectionList[i].cardList.length >
                                                                    0) {
                                                                  sectionList[i]
                                                                      .cardList
                                                                      .removeAt(j);
                                                                  // setState(() {});
                                                                }
                                                                if (sectionList[i]
                                                                        .cardList
                                                                        .length ==
                                                                    0) {
                                                                  sectionList.removeAt(i);
                                                                  // setState(() {});
                                                                }

                                                                setState(() {});
                                                              }),
                                                          SwipeAction(
                                                              content: _getIconButton(
                                                                  Color(0xffF5FCFF),
                                                                  Icons.edit,
                                                                  AppColors.cardTextColor),
                                                              color: Colors.transparent,
                                                              onTap: (handler) {
                                                                showNumericalInputSheet(
                                                                    sectionList[i].cardList[j],
                                                                    i,
                                                                    j);
                                                              }),
                                                        ],
                                                        child: CardItem(
                                                          viewType: "dragView",
                                                          cardModel: sectionList[i].cardList[j],
                                                          cardList: sectionList[i].cardList.length,
                                                          isEditMode: sectionList[i].isEditMode,
                                                          sectionIndex: i,
                                                          numberValue: (j + 1),
                                                          index: j,
                                                          createMode: true,
                                                          addToSection: addToSection,
                                                          setNumbers: showNumericalInputSheet,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  key: ValueKey(j)),
                                          ],
                                          onReorder: reorderCardData,
                                        ),
                                      )
                                    ],
                                  ),
                                  key: ValueKey(i)),
                          ],
                          onReorder: reorderData,
                        )),
                  ),
                ),
                //add to section bottom viewType
                if (selectedCardsCount > 0)
                  Container(
                      decoration: new BoxDecoration(
                        boxShadow: [
                          new BoxShadow(
                            color: Colors.black,
                            blurRadius: 10.0,
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(30.0),
                          topRight: const Radius.circular(30.0),
                        ),
                      ),
                      height: MediaQuery.of(context).size.height * 0.21,
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Stack(
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 13.0),
                                    child: Text(
                                      '$selectedCardsCount Items(s) selected',
                                      style: TextStyle(
                                          fontSize: 14.0, color: AppColors.lightGreyColor),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(Icons.close, color: Colors.black, size: 20),
                                    onPressed: () => {
                                      setState(() {
                                        selectedCardsCount = 0;
                                        removeEditMode();
                                      })
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            child: Row(
                              children: [
                                Expanded(
                                    child: InkWell(
                                  onTap: () {
                                    this.cardIndex = cardIndex;
                                    this.sectionIndex = sectionIndex;
                                    Utilities.confirmDeleteDialog(context, Constants.deleteCard,
                                        Constants.deleteCardConfirmDes, this, 1);
                                  },
                                  child: Container(
                                      decoration: new BoxDecoration(
                                        border:
                                            Border.all(width: 2.0, color: AppColors.redColorNew),
                                        borderRadius:
                                            new BorderRadius.all(const Radius.circular(8.0)),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 10.0),
                                      child: Text(Constants.delete,
                                          style: TextStyle(
                                              color: AppColors.redColorNew,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w400),
                                          textAlign: TextAlign.center)),
                                )),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Expanded(
                                    child: InkWell(
                                  onTap: () {
                                    showAddToSectionBottomSheet(cardIndex, sectionIndex);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10.0),
                                    decoration: new BoxDecoration(
                                      border: Border.all(
                                          width: 2.0, color: AppColors.segmentAppBarColor),
                                      borderRadius:
                                          new BorderRadius.all(const Radius.circular(8.0)),
                                    ),
                                    child: Text(Constants.addToSection,
                                        style: TextStyle(
                                            color: AppColors.segmentAppBarColor,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w400),
                                        textAlign: TextAlign.center),
                                  ),
                                )),
                              ],
                            ),
                          )
                        ],
                      )),
              ])),
    );
  }

  void calculateSelectedCardsCount() {
    for (int y = 0; y < sectionList.length; y++) {
      for (int z = 0; z < sectionList[y].cardList.length; z++) {
        if (sectionList[y].cardList != null &&
            sectionList[y].cardList[z].isSelectedSection != null &&
            sectionList[y].cardList[z].isSelectedSection) {
          selectedCardsCount += 1;
        }
      }
    }
  }

  // Save Card To section
  void saveCard() {}

  void showImportBottomSheet() {
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
                        "Choose card type",
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
                        cardType = "Image";
                        Navigator.pop(context);
                        // Future.delayed(Duration(milliseconds: 1000),()=> pickImages());
                        pickImages();
                      },
                      child: Container(
                        height: 74,
                        padding: EdgeInsets.only(left: 18, right: 18),
                        child: Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Image",
                                  style: TextStyle(
                                      fontFamily: "open_saucesans_regular",
                                      color: AppColors.darkTextColor,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    "Choose Images",
                                    style: TextStyle(
                                        color: AppColors.greyTextColor,
                                        fontSize: 13.0,
                                        fontFamily: "open_saucesans_regular",
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
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
                              cardType = "Video";
                              Navigator.pop(context);
                              var object = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CardCamera(
                                            mediaType: 2,
                                          )));

                              if (object != null) {
                                videoFiles = object["mediaList"];
                                mediaFile = videoFiles[0].keys.elementAt(0);
                              }
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
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Video",
                                            style: TextStyle(
                                                fontFamily: "open_saucesans_regular",
                                                color: AppColors.darkTextColor,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10.0),
                                            child: Text(
                                              "Choose Video",
                                              style: TextStyle(
                                                  color: AppColors.greyTextColor,
                                                  fontSize: 13.0,
                                                  fontFamily: "open_saucesans_regular",
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ],
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

  void showEditSectionPop(int index) async {
    var object = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
        ),
        builder: (context) {
          return CreateSection(
            sectionName: sectionList[index].title,
            title: 'Edit Section',
          );
        });
    if (object != null) {
      sectionList[index].title = object["sectionName"];
      // sectionList.add(RoutineSectionModel(
      //     timestamp: Timestamp.now(),
      //     title: sectionList[index].title,
      //     cardList: cardList != null ? cardList : [],
      //     createdBy: globalUserId,
      //     importBy: globalUserId));
      setState(() {});
    }
  }

  bool editModebutton = false;
  bool showEditButton = false;
  // TextEditingController textController = new TextEditingController();
  String actionText = Constants.doneText;

  void addToSection(int cardIndex, int sectionIndex, int count) {
    selectedCardsCount = 0;

    for (int k = 0; k < sectionList.length; k++) {
      sectionList[k].isEditMode = true;
      editModebutton = true;
    }
    if (editModebutton) {
      actionText = "Back";
    } else {
      actionText = Constants.doneText;
    }
    // sectionList[sectionIndex].isEditMode = true;

    calculateSelectedCardsCount();
    setState(() {});
  }

// add card to section
  Future<void> showAddToSectionBottomSheet(int _cardIndex, int _sectionIndex) async {
    var object = await showModalBottomSheet(
      context: context,
      enableDrag: false,
      useRootNavigator: true,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Container(child: AddToSection());
      },
    );
    if (object != null) {
      if (object["CreateSection"] != null && object["CreateSection"]) {
        createSection(_cardIndex, _sectionIndex);
      } else if (object["selectedSection"] != null) {
        selectedCardsCount = 0;
        FocusScope.of(context).unfocus();
        RoutineSectionModel rs = object["selectedSection"];
        getPostCards(rs);
      }
    }
  }

  void getPostCards(RoutineSectionModel routineModel) {
    List<CardModel> tempCardList = new List.empty(growable: true);
    List<CardModel> selectedSectionCardsList = new List.empty(growable: true);

    //get all cards List
    FirebaseFirestore.instance.collection(Constants.cardsColl).get().then((value) {
      if (value != null) {
        for (int i = 0; i < value.docs.length; i++) {
          CardModel cardModel = CardModel.fromJson(value.docs[i]);
          tempCardList.add(cardModel);
        }
      }
    }).then((value) {
      // add selected cards to list by matching cardIds
      for (int k = 0; k < tempCardList.length; k++) {
        for (int j = 0; j < routineModel.cardIds.length; j++) {
          if (tempCardList[k].cardId == routineModel.cardIds[j]) {
            tempCardList[k].importBy = globalUserId;
            selectedSectionCardsList.add(tempCardList[k]);
          }
        }
      }
      // get all selected cards
      for (int m = 0; m < sectionList.length; m++) {
        for (int n = 0; n < sectionList[m].cardList.length; n++) {
          if (sectionList[m].cardList != null &&
              sectionList[m].cardList[n].isSelectedSection != null &&
              sectionList[m].cardList[n].isSelectedSection) {
            selectedSectionCardsList.add(sectionList[m].cardList[n]);
          }
        }
      }
      // add cards to section
      sectionList.add(RoutineSectionModel(
          timestamp: Timestamp.now(),
          title: routineModel.title,
          cardList: selectedSectionCardsList != null ? selectedSectionCardsList : [],
          createdBy: globalUserId,
          importBy: globalUserId));

      removeEditMode();
      setState(() {});
    });
  }

  removeEditMode() {
    //remove edit mode
    actionText = Constants.doneText;
    for (int x = 0; x < sectionList.length; x++) {
      sectionList[x].isEditMode = false;
      for (int h = 0; h < sectionList[x].cardList.length; h++) {
        sectionList[x].cardList[h].isSelectedSection = false;
      }
    }
  }

  //create new section
  void createSection(int cardIndex2, int sectionIndex2) async {
    var object = await showModalBottomSheet(
      context: context,
      enableDrag: false,
      useRootNavigator: true,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return CreateSection(
          title: Constants.createSection,
          sectionName: '',
        );
      },
    );

    if (object != null) {
      List<CardModel> _cardModelList = new List();
      // get all selected cards
      for (int m = 0; m < sectionList.length; m++) {
        for (int n = 0; n < sectionList[m].cardList.length; n++) {
          if (sectionList[m].cardList != null &&
              sectionList[m].cardList[n].isSelectedSection != null &&
              sectionList[m].cardList[n].isSelectedSection) {
            _cardModelList.add(sectionList[m].cardList[n]);
          }
        }
      }
      sectionList.add(RoutineSectionModel(
        createdBy: globalUserId,
        importBy: "",
        cardList: _cardModelList,
        timestamp: Timestamp.now(),
        title: object["sectionName"],
      ));
      removeEditMode();
      selectedCardsCount = 0;
      setState(() {});
    }
  }

// Edit CArd Data
  void showNumericalInputSheet(CardModel cardData, int selectedSection, int selctedCard) async {
    var object = await showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(30.0),
              topRight: const Radius.circular(30.0),
            ),
          ),
          height: MediaQuery.of(context).size.height * 0.95,
          child: NumericInputsWithTitle(
              fileList: cardData.imageFiles,
              title: cardData.title,
              cardType: cardType,
              description: cardData.description,
              setNumbersList: cardData.setNumbers,
              videoFiles: cardData.videoFiles),
        );
      },
    );

    if (object != null) {
      setNumbersList = object["numericInputs"];
      sectionList[selectedSection].cardList[selctedCard].setNumbers = setNumbersList;
      sectionList[selectedSection].cardList[selctedCard].title = object["title"].toString();
      sectionList[selectedSection].cardList[selctedCard].description = object["desc"].toString();
      setState(() {});
    }
  }

  void reorderData(int oldindex, int newindex) {
    setState(() {
      if (newindex > oldindex) {
        newindex -= 1;
      }
      final items = sectionList.removeAt(oldindex);
      sectionList.insert(newindex, items);
    });
  }

  void reorderCardData(int oldindex, int newindex) {
    setState(() {
      if (newindex > oldindex) {
        newindex -= 1;
      }
      final items = sectionList[reorderSectionIndex].cardList.removeAt(oldindex);
      sectionList[reorderSectionIndex].cardList.insert(newindex, items);
    });
  }

  Future<void> pickImages() async {
    List<Asset> resultList = List<Asset>();

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: false,
        selectedAssets: images,
        materialOptions: MaterialOptions(
          actionBarTitle: "Select Images",
        ),
      );
    } on Exception catch (e) {
    }

    // setState(() {
    images = resultList;
    getAbsolutePath();
    // });
  }

  Widget _getIconButton(color, icon, iconColor) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),

        ///set you real bg color in your content
        color: color,
      ),
      child: Icon(
        icon,
        color: iconColor,
      ),
    );
  }

  void createCardModel() {
    String sectionTitle = "";
    if (feedId.isEmpty) {
      feedId = DateTime.now().millisecondsSinceEpoch.toString();
    }
    FocusScope.of(context).unfocus();
    List<CardModel> tempCardList = new List.empty(growable: true);

    if (sectionList.length > 0) {
      tempCardList.clear();
    }
    if (_files.length == 0 && videoFiles.length == 0 && _mediaList.length == 0) {
      cardType = "Text";
    }
    if (cardType != "Video") {
      // image and text
      CardModel cardModel = new CardModel(
          type: cardType,
          title: titleController.text.toString(),
          description: descController.text.toString(),
          bodyParts: _bodyPartList,
          media: _mediaList,
          setNumbers: setNumbersList,
          categoryList: [],
          subcategoryList: [],
          settingsList: [],
          isSelectedSection: false,
          createdBy: globalUserId,
          timestamp: Timestamp.now(),
          toolsList: [],
          importBy: "",
          saveCount: 0,
          imageFiles: _files,
          videoFiles: videoFile,
          feedId: feedId);

      tempCardList.add(cardModel);
    } else {
      //video
      if (videoFiles.length > 1) {
        for (int i = 0; i < videoFiles.length; i++) {
          int index = i + 1;
          if (i == 0) {
            sectionTitle = titleController.text.toString();
          }
          CardModel cardModel = new CardModel(
              type: cardType,
              title: "${titleController.text.toString()} - $index ",
              description: descController.text.toString(),
              bodyParts: _bodyPartList,
              media: [],
              setNumbers: setNumbersList,
              categoryList: [],
              subcategoryList: [],
              settingsList: [],
              isSelectedSection: false,
              createdBy: globalUserId,
              timestamp: Timestamp.now(),
              toolsList: [],
              importBy: "",
              saveCount: 0,
              imageFiles: [],
              videoFiles: videoFiles[i],
              feedId: feedId);
          tempCardList.add(cardModel);
        }
      } else {
        //video
        CardModel cardModel = new CardModel(
            type: cardType,
            title: titleController.text.toString(),
            description: descController.text.toString(),
            bodyParts: _bodyPartList,
            media: [],
            setNumbers: setNumbersList,
            categoryList: [],
            subcategoryList: [],
            settingsList: [],
            createdBy: globalUserId,
            timestamp: Timestamp.now(),
            toolsList: [],
            importBy: "",
            saveCount: 0,
            isSelectedSection: false,
            imageFiles: [],
            videoFiles: videoFiles[0],
            feedId: feedId);
        tempCardList.add(cardModel);
      }
    }
    if (sectionList.length == 0) {
      sectionList.add(RoutineSectionModel(
          cardList: tempCardList,
          createdBy: globalUserId,
          importBy: "",
          isEditMode: false,
          timestamp: Timestamp.now(),
          title: sectionTitle == "" ? tempCardList.first.title : sectionTitle));
    } else {
      List<CardModel> newCardList = new List.empty(growable: true);

      newCardList.clear();
      newCardList.addAll(sectionList[sectionList.length - 1].cardList);
      newCardList.addAll(tempCardList);
      sectionList[sectionList.length - 1].cardList = newCardList;
    }

    clearData();

    setState(() {});
  }

  clearData() {
    titleController.text = "";
    isDescriptionSelected = false;
    descController.text = "";
    _files = [];
    videoFiles = [];
    videoFile = new HashMap();
    setNumbersList = [];
    _mediaList = [];
  }

  Future<File> getImageFileFromAssets(Asset asset) async {
    final byteData = await asset.getByteData();

    final tempFile = File("${(await getTemporaryDirectory()).path}/${asset.name}");
    final file = await tempFile.writeAsBytes(
      byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );

    return file;
  }

  getAbsolutePath() async {
    List<File> files = [];
    for (Asset asset in images) {
      final filePath = await getImageFileFromAssets(asset);
      files.add(filePath);
    }
    // Navigator.pop(context);
    if (!mounted) return;
    setState(() {
      _files = files;
      // mediaFile = files[0];
      if (_files != null && _files.length > 0) {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => EditSegmentPage(
        //               imageFiles: _files,
        //               viewType: "Image",
        //               videoFiles: [],
        //             ))).then((value) {
        //   if (value != null) {
        //     setNumbersList = value["numberList"];
        //     // numericalInputsList = value;
        //   }
        // });
        ;
      }
    });
  }

  bool checkValids() {
    if (titleController.text.toString().trim().isEmpty) {
      Constants().errorToast(context, "Please add title");
      return false;
    }
    return true;
  }

  // Show bottom sheet dialog to import card
  Future<void> showImportCard() async {
    var object = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          child: ChooseCard(),
          decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(30.0),
              topRight: const Radius.circular(30.0),
            ),
          ),
          height: MediaQuery.of(context).size.height * 0.95,
        );
      },
    );
    if (object != null) {
      seletedCardList = object["selectedCards"];
      if (sectionList.length == 0) {
        sectionList.add(RoutineSectionModel(
            timestamp: Timestamp.now(),
            title: seletedCardList.first.title,
            cardList: seletedCardList,
            isEditMode: false,
            createdBy: globalUserId,
            importBy: globalUserId));
      } else {
        sectionList[sectionList.length - 1].cardList.addAll(seletedCardList);
      }

      setState(() {});
    }
  }

  @override
  void onOkClick(int code) {}
}
