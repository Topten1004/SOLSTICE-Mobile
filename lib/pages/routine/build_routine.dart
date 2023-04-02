import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_list_pick/selection_list.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/model/feed_model.dart';
import 'package:solstice/model/numerical_inputs_model/numeric_input_model.dart';
import 'package:solstice/model/routine_model.dart';
import 'package:solstice/model/routine_section_model.dart';
import 'package:solstice/model/select_filter_model.dart';
import 'package:solstice/pages/cards/card_item.dart';
import 'package:solstice/pages/home_screen.dart';
import 'package:solstice/pages/routine/choose_card.dart';
import 'package:solstice/pages/cards/create_quick_card.dart';
import 'package:solstice/pages/routine/createsection.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/utilities.dart';

class BuildRoutine extends StatefulWidget {
  final List<SelectFilterModel> selectedCategoryList;
  final List<SelectFilterModel> selectedSubCategoryList;
  final List<SelectFilterModel> selectedToolsList;
  final List<SelectFilterModel> selectedSettingsList;

  final String title;

  BuildRoutine(
      {this.title,
      this.selectedCategoryList,
      this.selectedSubCategoryList,
      this.selectedToolsList,
      this.selectedSettingsList});

  @override
  _BuildRoutineState createState() => _BuildRoutineState();
}

class _BuildRoutineState extends State<BuildRoutine> {
  TextEditingController setEditFieldController = new TextEditingController();
  TextEditingController titleController = new TextEditingController();
  TextEditingController descController = new TextEditingController();

  int listCount = 0;
  List<String> repsUnitList = new List.empty(growable: true);
  List<String> weightsUnitList = new List.empty(growable: true);
  List<SetNumbers> setNumbersList = new List.empty(growable: true);
  List<CardModel> seletedCardList = new List.empty(growable: true);
  List<RoutineSectionModel> sectionList = new List.empty(growable: true);
  List<NumericalInputsModel> numericalInputsList =
      new List.empty(growable: true);
  String selectedRepsUnitCustomDropDown = "Reps";
  String selectedWeightUnitCustomDropDown = "None";
  int selectedWeightBottomSheet;
  String selectedRepsUnitValue = "Reps";
  String selectedWeightUnitValue = "None";
  List<ItemData> _items;
  _BuildRoutineState() {
    _items = [];
    for (int i = 0; i < 500; ++i) {
      String label = "List item $i";
      if (i == 5) {
        label += ". This item has a long label and will be wrapped.";
      }
      _items.add(ItemData(label, ValueKey(i)));
    }
  }

  List<String> item = [
    "Clients",
    "Designer",
    "Developer",
    // "Director",
    // "Employee",
    // "Manager",
    // "Worker",
    // "Owner",
  ];

  List<String> itemInner = [
    "ClientsA",
    "Designer",
    "Developer",
    // "Director",
    // "Employee",
    // "Manager",
    // "Worker",
    // "Owner",
  ];
  @override
  void initState() {
    super.initState();
    repsUnitList.add("Reps");
    repsUnitList.add("Weight (lb)");
    repsUnitList.add("Time (mm:ss)");
    repsUnitList.add("Seconds");
    repsUnitList.add("Miles");
    repsUnitList.add("Yards");
    repsUnitList.add("Meters");
    repsUnitList.add("Feet");
    repsUnitList.add("Watts");
    repsUnitList.add("RPE");
    repsUnitList.add("Calories");
    repsUnitList.add("Inches (Height)");
    repsUnitList.add("Inches (Distance)");
    repsUnitList.add("Velocity (m/s)");
    repsUnitList.add("Other");

    weightsUnitList.add("None");
    weightsUnitList.add("Reps");
    weightsUnitList.add("Weight (lb)");
    weightsUnitList.add("Linear Weight Progression");
    weightsUnitList.add("Seconds");
    weightsUnitList.add("Miles");
    weightsUnitList.add("Yards");
    weightsUnitList.add("Feet");
    weightsUnitList.add("Watts");
    weightsUnitList.add("RPE");
    weightsUnitList.add("Calories");
    weightsUnitList.add("Inches (Height)");
    weightsUnitList.add("Inches (Distance)");
    weightsUnitList.add("Velocity (m/s)");
    weightsUnitList.add("Other");
  }

  void reorderData(int oldindex, int newindex) {
    setState(() {
      if (newindex > oldindex) {
        newindex -= 1;
      }
      final items = item.removeAt(oldindex);
      item.insert(newindex, items);
    });
  }

  void sorting() {
    setState(() {
      item.sort();
    });
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
            onTap: () {
              createRoutine();
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
              child: Text(
                Constants.doneText,
                style: TextStyle(
                    fontSize: 14.0,
                    color: AppColors.segmentAppBarColor,
                    fontFamily: Constants.openSauceFont,
                    fontWeight: FontWeight.w600),
              ),
            ),
          )
      ],
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Daily Mindful Breathing Therapy",
                style: TextStyle(
                    fontFamily: "open_saucesans_regular",
                    color: Colors.black,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                  'Aesthetics . MuscleBuilding',
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14.0,
                      fontFamily: "open_saucesans_regular",
                      fontWeight: FontWeight.w400),
                ),
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () {
                  showImportBottomSheet();
                },
                child: Container(
                    height: 74,
                    padding: EdgeInsets.only(left: 18, right: 18),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
                          child: Align(
                              alignment: Alignment.topCenter,
                              child: Image.asset(Constants.import,
                                  height: 24, width: 24)),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Constants.importWorkout,
                                style: TextStyle(
                                    fontFamily: "open_saucesans_regular",
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  "Import from library or your saved workouts to this routine.",
                                  maxLines: 2,
                                  style: TextStyle(
                                      color: Color(0xff738497),
                                      fontSize: 13.0,
                                      fontFamily: "open_saucesans_regular",
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_right,
                            color: Color(0xff6E6A6A))
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.all(Radius.circular(12.0)))),
              ),
              SizedBox(height: 30),
              Expanded(
                child: GestureDetector(
                  onLongPress: () {},
                  child: Container(
                      child: ReorderableListView(
                    scrollDirection: Axis.vertical,
                    primary: true,
                    children: <Widget>[
                      for (int i = 0; i < sectionList.length; i++)
                        Container(
                            color: Colors.white,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      sectionList[i].title,
                                      style: TextStyle(
                                          fontFamily: "open_saucesans_regular",
                                          color: Colors.black,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          showEditSectionPop(i);
                                        },
                                        icon: Icon(
                                          Icons.edit,
                                          color: AppColors.segmentAppBarColor,
                                          size: 20.0,
                                        ))
                                  ],
                                ),
                                SizedBox(height: 10),
                                Container(
                                  height:
                                      ((sectionList[i].cardList.length) * 120)
                                          .toDouble(),
                                  child: ReorderableListView(
                                    shrinkWrap: true,
                                    primary: false,
                                    scrollDirection: Axis.vertical,
                                    children: <Widget>[
                                      for (int j = 0;
                                          j < sectionList[i].cardList.length;
                                          j++)
                                        // final itemsInner
                                        //   in sectionList[i].cardList)
                                        Container(
                                            color: Colors.white,
                                            child: Column(
                                              children: [
                                                SizedBox(height: 10),
                                                SwipeActionCell(
                                                  key: ObjectKey(j),
                                                  performsFirstActionWithFullSwipe:
                                                      false,
                                                  trailingActions: <
                                                      SwipeAction>[
                                                    SwipeAction(
                                                        nestedAction:
                                                            SwipeNestedAction(
                                                          ///customize your nested action content
                                                          content: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30),
                                                              color: Colors.red,
                                                            ),
                                                            width: 100,
                                                            height: 40,
                                                            child: OverflowBox(
                                                              maxWidth: double
                                                                  .infinity,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .delete,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  Text('Sure?',
                                                                      style: TextStyle(
                                                                          fontFamily: Constants
                                                                              .openSauceFont,
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              14)),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                        ///you should set the default  bg color to transparent
                                                        color:
                                                            Colors.transparent,

                                                        ///set content instead of title of icon
                                                        content: _getIconButton(
                                                            Color(0xffF5FCFF),
                                                            Icons.delete,
                                                            Colors.red),
                                                        onTap: (handler) async {
                                                          // list.removeAt(index);
                                                          await handler(true);
                                                          sectionList[i]
                                                              .cardList
                                                              .removeAt(j);
                                                          if (sectionList[i]
                                                                  .cardList
                                                                  .length ==
                                                              0) {
                                                            sectionList
                                                                .removeAt(i);
                                                          }

                                                          setState(() {});
                                                        }),
                                                    SwipeAction(
                                                        content: _getIconButton(
                                                            Color(0xffF5FCFF),
                                                            Icons.edit,
                                                            AppColors
                                                                .cardTextColor),
                                                        color:
                                                            Colors.transparent,
                                                        onTap: (handler) {
                                                          showNumericalInputSheet(
                                                              sectionList[i]
                                                                  .cardList[j],
                                                              i,
                                                              j,
                                                              setState);
                                                        }),
                                                  ],
                                                  child: CardItem(
                                                    viewType: "dragView",
                                                    cardModel: sectionList[i]
                                                        .cardList[j],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            key: ValueKey(j)),
                                    ],
                                    onReorder: reorderData,
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
              SizedBox(height: 30),
              InkWell(
                onTap: () async {
                  var result = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => QuickCardPage()));
                  if (result != null) {
                    // get quick card data
                    var title, desc;
                    setNumbersList = result['numericInputs'];
                    seletedCardList = result["selectedCards"];
                    title = result["title"];
                    desc = result["desc"];
                    // add quick card data section
                    CardModel cardModel = new CardModel(
                      type: "quickCard",
                      title: title,
                      description: desc,
                      bodyParts: [],
                      media: [],
                      setNumbers: setNumbersList,
                      categoryList: widget.selectedCategoryList,
                      subcategoryList: widget.selectedSubCategoryList,
                      settingsList: widget.selectedSettingsList,
                      createdBy: globalUserId,
                      timestamp: Timestamp.now(),
                      toolsList: widget.selectedToolsList,
                    );
                    if (seletedCardList == null) {
                      seletedCardList =
                          new List<CardModel>.empty(growable: true);
                    }
                    seletedCardList.add(cardModel);
                    if (sectionList != null && sectionList.length == 0) {
                      sectionList.add(RoutineSectionModel(
                          timestamp: Timestamp.now(),
                          title: title,
                          cardList: seletedCardList,
                          createdBy: globalUserId,
                          importBy: globalUserId));
                    } else {
                      sectionList[sectionList.length - 1].cardList =
                          seletedCardList;
                    }
                    setState(() {});
                  }
                },
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: Radius.circular(8),
                  color: AppColors.blueColor,
                  padding: EdgeInsets.all(6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(Constants.createCard,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.blueColor,
                                fontFamily: Constants.openSauceFont)),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          )),
    );
  }

  void showEditSectionPop(int index) async {
    var object = await showModalBottomSheet(
        context: context,
        isScrollControlled: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
        ),
        builder: (context) {
          return CreateSection(
            sectionName: sectionList[index].title,
            title: 'Edit Section',
          );
        });
    if (object != null) {
      sectionList[index].title = object["sectionName"];
      setState(() {});
    }
  }

  void showImportBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
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
                        Constants.importKeyword,
                        style: TextStyle(
                            color: AppColors.greyTextColor,
                            fontSize: 14.0,
                            fontFamily: "open_saucesans_regular",
                            fontWeight: FontWeight.w600),
                      ),
                      Spacer(),
                      Icon(Icons.close, color: AppColors.greyTextColor)
                    ]),
                  ),
                  SizedBox(height: 15),
                  InkWell(
                    onTap: () async {
                      // Navigator.pop(context);
                      showImportCard();
                      // Navigator.push(
                      //     context,
                      //     new MaterialPageRoute(
                      //       builder: (BuildContext context) => new ChooseCard(),
                      //     ));
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
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Constants.card_,
                                  style: TextStyle(
                                      fontFamily: "open_saucesans_regular",
                                      color: AppColors.darkTextColor,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    "A workout from library or other users.",
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
                            Icon(Icons.keyboard_arrow_right,
                                color: Color(0xff6E6A6A))
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
        ]);
      },
    );
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

// Save Routine to DB
  void createRoutine() {
    //  RoutineSectionModel routineSectionModel = new RoutineSectionModel(cardList: );
    Utilities.show(context);
    List<String> sectionIds = new List.empty(growable: true);

    for (int i = 0; i < sectionList.length; i++) {
      List<String> cardIds = new List.empty(growable: true);
      for (int j = 0; j < sectionList[i].cardList.length; j++) {
        FirebaseFirestore.instance
            .collection(Constants.cardsColl)
            .add(sectionList[i].cardList[j].toJson())
            .then((value) => cardIds.add(value.id))
            .catchError((onError) {
          Utilities.hide();
        });
      }
      RoutineSectionModel routineSectionModel = new RoutineSectionModel(
        createdBy: globalUserId,
        cardIds: cardIds,
        timestamp: Timestamp.now(),
        title: sectionList[i].title,
        importBy: globalUserId,
      );

      FirebaseFirestore.instance
          .collection(Constants.sectionColl)
          .add(routineSectionModel.toJson())
          .then((value) => sectionIds.add(value.id))
          .catchError((onError) {
        Utilities.hide();
      });
    }

    RoutineModel routineModel = new RoutineModel(
        categoryList: widget.selectedCategoryList,
        subcategoryList: widget.selectedSubCategoryList,
        createdBy: globalUserId,
        settingsList: widget.selectedSettingsList,
        toolsList: widget.selectedToolsList,
        title: widget.title,
        timestamp: Timestamp.now(),
        sectionIds: sectionIds,
        setNumbers: setNumbersList);
    FirebaseFirestore.instance
        .collection(Constants.routineFeedCollection)
        .add(routineModel.toJson())
        .then((value) => {
              createFeed(value.id),
              Constants()
                  .successToast(context, "Routine Created Successfully!"),
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(currentIndex: 0,)),
                  (route) => false)
            })
        .catchError((onError) {
      Utilities.hide();
    });
  }

  void createFeed(String routineId) {
    FeedModel feedModel = new FeedModel(
      itemId: routineId,
      saveCount: 0,
      type: "Routine",
      timestamp: Timestamp.now(),
      userId: globalUserId,
      viewCount: [],
    );
    FirebaseFirestore.instance
        .collection(Constants.feedsColl)
        .add(feedModel.toJson())
        .then((value) => {
              Utilities.hide(),
              Constants()
                  .successToast(context, "Routine is created successfully"),
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(currentIndex: 0)),
                  (route) => false)
            })
        .catchError((onError) {
      Utilities.hide();
    });
  }

// Show bottom sheet dialog to import card
  Future<void> showImportCard() async {
    var object = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
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
      sectionList.add(RoutineSectionModel(
          timestamp: Timestamp.now(),
          title: seletedCardList.first.title,
          cardList: seletedCardList,
          createdBy: globalUserId,
          importBy: globalUserId));

      setState(() {});
    }
  }

  void showNumericalInputSheet(
      CardModel cardData, int selectedSection, int selectedCard, setStates) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        //
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        titleController.text = cardData.title;
        descController.text = cardData.description;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateBottomSheet) {
            return Container(
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(30.0),
                  topRight: const Radius.circular(30.0),
                ),
              ),
              height: MediaQuery.of(context).size.height * 0.95,
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            setStates(() {
                              sectionList[selectedSection]
                                  .cardList[selectedCard]
                                  .title = titleController.text;

                              sectionList[selectedSection]
                                  .cardList[selectedCard]
                                  .description = descController.text;

                              sectionList[selectedSection]
                                  .cardList[selectedCard]
                                  .setNumbers = cardData.setNumbers;
                            });
                            Navigator.pop(context);
                          },
                          child: Text("Done",
                              style: TextStyle(
                                  color: AppColors.cardTextColor,
                                  fontFamily: "open_saucesans_regular",
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17)),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: TextField(
                        textAlign: TextAlign.center,
                        controller: titleController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            labelText: titleController.text),

                        // controller: ,
                        style: TextStyle(
                            color: AppColors.darkTextColor,
                            fontFamily: "open_saucesans_regular",
                            fontWeight: FontWeight.w700,
                            fontSize: 17)),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: TextField(
                        textAlign: TextAlign.center,
                        controller: descController,
                        decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            labelText: descController.text),
                        maxLines: 2,
                        style: TextStyle(
                            color: AppColors.greyTextColor,
                            fontFamily: "open_saucesans_regular",
                            fontWeight: FontWeight.w400,
                            fontSize: 13)),
                  ),
                  Container(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 70,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 7.0),
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {},
                              child: Container(
                                  height: 85,
                                  width: 85,
                                  margin: EdgeInsets.symmetric(horizontal: 0.0),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        height: 80,
                                        width: 60,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                            border: Border.all(
                                                width: 2.0,
                                                color:
                                                    AppColors.cardTextColor)),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          child: Image.asset(
                                            Constants.demoPic,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Image.asset(Constants.cardVideo,
                                          height: 20, width: 20),
                                      Positioned(
                                        child: InkWell(
                                            onTap: () {
                                              // videoFiles.removeAt(index);
                                              setState(() {});
                                            },
                                            child: SvgPicture.asset(
                                                Constants.iconCross,
                                                height: 20,
                                                width: 20)),
                                        top: 0,
                                        right: 3,
                                      )
                                    ],
                                  )),
                            );
                          },
                          itemCount: 2,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                        ),
                      ),
                    ],
                  )),
                  SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.only(left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: Text(Constants.numberOfSets,
                              style: TextStyle(
                                  color: AppColors.darkTextColor,
                                  fontFamily: "open_saucesans_regular",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16)),
                        ),
                        Container(
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (cardData.setNumbers.length != 0) {
                                    cardData.setNumbers.remove(
                                        cardData.setNumbers[
                                            cardData.setNumbers.length - 1]);
                                    setStateBottomSheet(() {});
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: AppColors.segmentAppBarColor,
                                    border: Border.all(
                                        color: AppColors.segmentAppBarColor),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                      "assets/images/fi_minus.png",
                                      height: 20,
                                      width: 20),
                                ),
                              ),
                              SizedBox(width: 20),
                              Container(
                                  height: 30,
                                  padding: EdgeInsets.only(left: 18, right: 18),
                                  child: Center(
                                    child: Text(
                                      cardData.setNumbers.length.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: "roboto_regular",
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                      color: AppColors.lightBlue,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)))),
                              SizedBox(width: 20),
                              InkWell(
                                onTap: () {
                                  cardData.setNumbers.add(new SetNumbers(
                                    unit: selectedRepsUnitValue,
                                    unitInput: "0",
                                    weight: selectedWeightUnitValue,
                                    weightInput: "0",
                                    // "0",
                                    // selectedRepsUnitValue,
                                    // "0",
                                    // selectedWeightUnitValue,
                                    // "",
                                    // selectedRepsUnitCustomDropDown,
                                    // selectedWeightUnitCustomDropDown,
                                  ));
                                  setStateBottomSheet(() {});
                                },
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: AppColors.segmentAppBarColor,
                                    border: Border.all(
                                        color: AppColors.segmentAppBarColor),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                      "assets/images/fi_plus.png",
                                      height: 20,
                                      width: 20),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                          margin: EdgeInsets.only(top: 30, left: 10, right: 10),
                          child: setsList(cardData.setNumbers)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      listCount++;
                      setStateBottomSheet(() {});
                    },
                    child: InkWell(
                      onTap: () {
                        cardData.setNumbers.add(new SetNumbers(
                          unit: selectedRepsUnitValue,
                          unitInput: "0",
                          weight: selectedWeightUnitValue,
                          weightInput: "0",
                        )
                            // numericalInputsList.add(new NumericalInputsModel(
                            //   "0",
                            //   selectedRepsUnitValue,
                            //   "0",
                            //   selectedWeightUnitValue,
                            //   "",
                            //   selectedRepsUnitCustomDropDown,
                            //   selectedWeightUnitCustomDropDown,
                            // )
                            );
                        setStateBottomSheet(() {});
                      },
                      child: Container(
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 20, right: 0),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: AppColors.lightGreyColor),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                  child: Text("+",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: "open_saucesans_regular",
                                          fontWeight: FontWeight.w500))),
                            ),
                            Container(
                                margin: EdgeInsets.only(left: 20, right: 0),
                                child: Text(Constants.addSet,
                                    style: TextStyle(
                                        color: AppColors.cardTextColor,
                                        fontSize: 16,
                                        fontFamily: "roboto_regular",
                                        fontWeight: FontWeight.w500))),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget setsList(List<SetNumbers> setList) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Container(
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.lightGreyColor),
                            shape: BoxShape.circle,
                          ),
                          child: Text((index + 1).toString(),
                              style: TextStyle(
                                  fontFamily: "roboto_regular",
                                  fontWeight: FontWeight.w500)),
                        ),
                        Container(
                          height: 40,
                          child: DottedLine(
                              direction: Axis.vertical,
                              lineThickness: 1.0,
                              dashLength: 4.0,
                              dashColor: AppColors.lightGreyColor),
                        ),
                      ],
                    ),
                    Container(
                        height: 40,
                        width: 40,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                            setList[index].unitInput = v;
                          },
                          maxLength: 2,
                          controller: TextEditingController(
                              text: setList[index].unitInput),
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.send,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                              counterStyle: TextStyle(
                                height: double.minPositive,
                              ),
                              counterText: ""),
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontFamily: "roboto_regular",
                              fontSize: 20),
                        ),
                        decoration: BoxDecoration(
                            color: AppColors.viewsBg,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)))),
                    InkWell(
                      onTap: () {
                        showBottomSheet(index, setState, setList);
                      },
                      child: Container(
                          // width: 90,
                          padding: EdgeInsets.only(left: 0),
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              Text(
                                setList[index].unit.toString().length > 4
                                    ? setList[index].unit.substring(0, 4) + '..'
                                    : setList[index].unit,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: "open_saucesans_regular",
                                    color: AppColors.darkTextColor,
                                    fontWeight: FontWeight.w500),
                              ),
                              IconButton(
                                icon: Icon(Icons.keyboard_arrow_down,
                                    color: AppColors.darkTextColor),
                                onPressed: () {
                                  showBottomSheet(index, setState, setList);
                                },
                              ),
                            ],
                          )),
                    ),
                    Container(
                        padding: EdgeInsets.only(bottom: 1),
                        height: 40,
                        width: 40,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(
                              text: setList[index].weightInput),
                          onChanged: (v) {
                            setList[index].weightInput = v;
                          },
                          maxLength: 2,
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              counterStyle: TextStyle(
                                height: double.minPositive,
                              ),
                              counterText: ""),
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "roboto_regular",
                              fontWeight: FontWeight.w700,
                              fontSize: 20),
                        ),
                        decoration: BoxDecoration(
                            color: AppColors.viewsBg,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)))),
                    InkWell(
                      onTap: () {
                        showBottomSheetWeight(index, setState, setList);
                      },
                      child: Container(
                          // width: 90,

                          color: Colors.transparent,
                          child: Row(
                            children: [
                              Text(
                                setList[index].weight.toString().length > 4
                                    ? setList[index].weight.substring(0, 4) +
                                        '..'
                                    : setList[index].weight,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: "open_saucesans_regular",
                                    color: AppColors.darkTextColor,
                                    fontWeight: FontWeight.w500),
                              ),
                              IconButton(
                                icon: Icon(Icons.keyboard_arrow_down,
                                    color: AppColors.darkTextColor),
                                onPressed: () {
                                  showBottomSheetWeight(
                                      index, setState, setList);
                                },
                              ),
                            ],
                          )),
                    ),
                  ],
                ));
          },
          itemCount: setList.length,
        ),
      );
    });
  }

  void showBottomSheet(sIndex, setState, List<SetNumbers> setList) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              selectedRepsUnitCustomDropDown =
                                  repsUnitList[index].toString();
                              setList[sIndex].unit = repsUnitList[index];
                              Navigator.pop(context);
                              setState(() {});
                            },
                            child: Container(
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Center(
                                  child: Text(repsUnitList[index].toString(),
                                      style: TextStyle(
                                        color: AppColors.darkTextColor,
                                        fontSize: 16,
                                        fontFamily: "epilogue_medium",
                                      )),
                                ),
                              ),
                            ),
                          ),
                          Container(
                              padding: EdgeInsets.only(left: 30, right: 30),
                              child: Divider(
                                color: AppColors.darkTextColor,
                              ))
                        ],
                      );
                    },
                    itemCount: repsUnitList.length,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showBottomSheetWeight(swIndex, setState, List<SetNumbers> setList) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter st) {
            return Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  selectedWeightUnitCustomDropDown =
                                      weightsUnitList[index].toString();
                                  setList[swIndex].weight =
                                      weightsUnitList[index];
                                  Navigator.pop(context);
                                  setState(() {});
                                },
                                child: Container(
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Center(
                                      child: Text(
                                          weightsUnitList[index].toString(),
                                          style: TextStyle(
                                            color: AppColors.darkTextColor,
                                            fontSize: 16,
                                            fontFamily: "epilogue_medium",
                                          )),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                  padding: EdgeInsets.only(left: 30, right: 30),
                                  child: Divider(
                                    color: AppColors.darkTextColor,
                                  ))
                            ],
                          );
                        },
                        itemCount: weightsUnitList.length,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ItemData {
  ItemData(this.title, this.key);

  final String title;

  // Each item in reorderable list needs stable and unique key
  final Key key;
}

// enum DraggingMode {
//   iOS,
//   Android,
// }

// class Item extends StatelessWidget {
//   Item({
//     this.data,
//     this.isFirst,
//     this.isLast,
//     this.draggingMode,
//   });

//   final ItemData data;
//   final bool isFirst;
//   final bool isLast;
//   final DraggingMode draggingMode;

//   Widget _buildChild(BuildContext context, ReorderableItemState state) {
//     BoxDecoration decoration;

//     if (state == ReorderableItemState.dragProxy ||
//         state == ReorderableItemState.dragProxyFinished) {
//       // slightly transparent background white dragging (just like on iOS)
//       decoration = BoxDecoration(color: Color(0xD0FFFFFF));
//     } else {
//       bool placeholder = state == ReorderableItemState.placeholder;
//       decoration = BoxDecoration(
//           border: Border(
//               top: isFirst && !placeholder
//                   ? Divider.createBorderSide(context) //
//                   : BorderSide.none,
//               bottom: isLast && placeholder
//                   ? BorderSide.none //
//                   : Divider.createBorderSide(context)),
//           color: placeholder ? null : Colors.white);
//     }

//     // For iOS dragging mode, there will be drag handle on the right that triggers
//     // reordering; For android mode it will be just an empty container
//     Widget dragHandle = draggingMode == DraggingMode.iOS
//         ? ReorderableListener(
//             child: Container(
//               padding: EdgeInsets.only(right: 18.0, left: 18.0),
//               color: Color(0x08000000),
//               child: Center(
//                 child: Icon(Icons.reorder, color: Color(0xFF888888)),
//               ),
//             ),
//           )
//         : Container();

//     Widget content = Container(
//       decoration: decoration,
//       child: SafeArea(
//           top: false,
//           bottom: false,
//           child: Opacity(
//             // hide content for placeholder
//             opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
//             child: IntrinsicHeight(
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: <Widget>[
//                   Expanded(
//                       child: Padding(
//                     padding:
//                         EdgeInsets.symmetric(vertical: 14.0, horizontal: 14.0),
//                     child: Text(data.title,
//                         style: Theme.of(context).textTheme.subtitle1),
//                   )),
//                   // Triggers the reordering
//                   dragHandle,
//                 ],
//               ),
//             ),
//           )),
//     );

//     // For android dragging mode, wrap the entire content in DelayedReorderableListener
//     if (draggingMode == DraggingMode.Android) {
//       content = DelayedReorderableListener(
//         child: content,
//       );
//     }

//     return content;
//   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   return ReorderableItem(
//   //       key: data.key, //
//   //       childBuilder: _buildChild);
//   // }
// }
