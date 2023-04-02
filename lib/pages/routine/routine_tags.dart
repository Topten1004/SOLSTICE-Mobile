import 'dart:collection';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/model/feed_model.dart';
import 'package:solstice/model/routine_model.dart';
import 'package:solstice/model/routine_section_model.dart';
import 'package:solstice/model/select_filter_model.dart';
import 'package:solstice/pages/filters/select_filters.dart';
import 'package:solstice/pages/routine/build_routine.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/utilities.dart';

import '../home_screen.dart';

class RoutineTags extends StatefulWidget {
  final String routineName;
  final List<String> bodyPartsListIntent;
  final String cardType, title, description;
  final List<HashMap<File, File>> mediaList;
  final List<SetNumbers> numbersList;
  final List<RoutineSectionModel> sectionList;
  final List<File> files;
  final String feedId;
  final String viewType;

  RoutineTags(
      {this.routineName,
      this.bodyPartsListIntent,
      this.cardType,
      this.title,
      this.description,
      this.mediaList,
      this.sectionList,
      this.numbersList,
      this.files,
      this.feedId,
      this.viewType});

  @override
  _RoutineTagsState createState() => _RoutineTagsState();
}

class _RoutineTagsState extends State<RoutineTags> {
  List<SelectFilterModel> categoryList = new List.empty(growable: true);
  List<String> selectedCatText = new List.empty(growable: true);
  List<SelectFilterModel> selectedCategoryList = new List.empty(growable: true);

  List<SelectFilterModel> subcategoryList = new List.empty(growable: true);
  List<String> selectedSubCatText = new List.empty(growable: true);
  List<SelectFilterModel> selectedSubCategoryList =
      new List.empty(growable: true);

  List<SelectFilterModel> toolsList = new List.empty(growable: true);
  List<String> selectedToolsText = new List.empty(growable: true);
  List<SelectFilterModel> selectedToolsList = new List.empty(growable: true);

  List<SelectFilterModel> settingsList = new List.empty(growable: true);
  List<String> selectedSettingsText = new List.empty(growable: true);
  List<SelectFilterModel> selectedSettingssList =
      new List.empty(growable: true);
  List<Media> mediaFiles = new List.empty(growable: true);
  List<String> cardIds = new List.empty(growable: true);

  String image = "Image";
  String video = "Video";
  String text = "Text";
  Media mediaModel = new Media();
  String fileUrl = "", thumbnail = "", cardType = "Text";
  bool addData = false;
  List<String> sectionIds = new List.empty(growable: true);
  int indexSectionForRoutine = 0;

  @override
  void initState() {
    super.initState();
    getCategory(Constants.trainingCategories);

    getTools(Constants.tools);
    getSettings(Constants.settings);
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
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Constants.addTagsToRoutine,
                    style: TextStyle(
                        fontFamily: "open_saucesans_regular",
                        color: Colors.black,
                        fontSize: 24.0,
                        fontWeight: FontWeight.w600),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Text(
                      'Tags help add more information to your routine for enhanced suggestion of its building blocks.',
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14.0,
                          fontFamily: "open_saucesans_regular",
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    Constants.category,
                    style: TextStyle(
                        fontFamily: "open_saucesans_regular",
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 15),
                  Column(children: [
                    InkWell(
                      onTap: () async {
                        var result = await Navigator.push(
                            context,
                            new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new SelectFilterPage(
                                Constants.category,
                                Constants.trainingCategories,
                                selectedFiltersList: selectedCatText,
                              ),
                            ));
                        if (result != null) {
                          selectedCategoryList.clear();
                          selectedCatText.clear();
                          selectedCategoryList = result["categoryList"];

                          for (int i = 0; i < categoryList.length; i++) {
                            categoryList[i].isSelected = false;
                            for (int j = 0;
                                j < selectedCategoryList.length;
                                j++) {
                              if (categoryList[i].id ==
                                  selectedCategoryList[j].id) {
                                categoryList[i].isSelected = true;
                                selectedCatText.add(categoryList[i].title);
                              }
                            }
                          }
                        } else {
                          // selectedCategoryList.clear();
                        }

                        subcategoryList.clear();
                        for (int i = 0; i < selectedCategoryList.length; i++) {
                          getSubCategory(Constants.trainingSubCategories,
                              selectedCategoryList[i].id);
                        }

                        setState(() {});
                      },
                      child: Container(
                          height: 20,
                          child: selectedCatText.length > 0
                              ? ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: selectedCatText.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      child: Text(selectedCatText[index] + ","),
                                    );
                                  })
                              : Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'Search a category...',
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 15.0,
                                        fontFamily: "open_saucesans_regular",
                                        fontWeight: FontWeight.w400),
                                  ))),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 0.5,
                      width: MediaQuery.of(context).size.width,
                      color: AppColors.lightGreyColor,
                    )
                  ]),
                  SizedBox(height: 20),
                  Container(
                    height: 30,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categoryList.length,
                        itemBuilder: (BuildContext context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (categoryList[index].isSelected) {
                                  categoryList[index].isSelected = false;
                                  for (int j = 0;
                                      j < selectedCatText.length;
                                      j++) {
                                    if (selectedCatText[j] ==
                                        categoryList[index].title) {
                                      selectedCatText.removeAt(j);
                                      selectedCategoryList
                                          .remove(categoryList[index]);
                                    }
                                  }
                                } else {
                                  categoryList[index].isSelected = true;
                                  selectedCategoryList.add(categoryList[index]);
                                  selectedCatText
                                      .add(categoryList[index].title);
                                }

                                subcategoryList.clear();
                                selectedSubCatText.clear();
                                for (int i = 0;
                                    i < selectedCategoryList.length;
                                    i++) {
                                  getSubCategory(
                                      Constants.trainingSubCategories,
                                      selectedCategoryList[i].id);
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 8.0, right: 8.0),
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                  color: categoryList[index].isSelected
                                      ? AppColors.blueColor
                                      : Colors.white,
                                  border:
                                      Border.all(color: AppColors.blueColor),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(48))),
                              child: Row(
                                children: [
                                  Icon(
                                    categoryList[index].isSelected
                                        ? Icons.check
                                        : Icons.add,
                                    size: 14,
                                    color: categoryList[index].isSelected
                                        ? Colors.white
                                        : AppColors.blueColor,
                                  ),
                                  SizedBox(width: 3),
                                  Text(categoryList[index].title,
                                      style: TextStyle(
                                        color: categoryList[index].isSelected
                                            ? Colors.white
                                            : AppColors.blueColor,
                                        fontFamily: Constants.openSauceFont,
                                        fontSize: 11,
                                      ))
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                  SizedBox(height: 30),
                  Text(
                    Constants.subCategory,
                    style: TextStyle(
                        fontFamily: "open_saucesans_regular",
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 15),
                  Column(children: [
                    InkWell(
                      onTap: () async {
                        if (selectedCategoryList.length > 0) {
                          var result = await Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      new SelectFilterPage(
                                        Constants.subCategory,
                                        Constants.trainingSubCategories,
                                        categoryList: categoryList,
                                        selectedFiltersList: selectedSubCatText,
                                      )));
                          if (result != null) {
                            selectedSubCategoryList.clear();
                            selectedSubCatText.clear();
                            selectedSubCategoryList = result["subCategoryList"];

                            for (int i = 0; i < subcategoryList.length; i++) {
                              subcategoryList[i].isSelected = false;
                              for (int j = 0;
                                  j < selectedSubCategoryList.length;
                                  j++) {
                                if (subcategoryList[i].id ==
                                    selectedSubCategoryList[j].id) {
                                  subcategoryList[i].isSelected = true;
                                  selectedSubCatText
                                      .add(subcategoryList[i].title);
                                }
                              }
                            }
                          } else {
                            selectedSubCategoryList.clear();
                          }
                        } else {
                          Constants().errorToast(
                              context, "Please select category first");
                        }
                        setState(() {});
                      },
                      child: Container(
                          height: 20,
                          child: selectedSubCatText.length > 0
                              ? ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: selectedSubCatText.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      child:
                                          Text(selectedSubCatText[index] + ","),
                                    );
                                  })
                              : Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'Search a sub category...',
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 15.0,
                                        fontFamily: "open_saucesans_regular",
                                        fontWeight: FontWeight.w400),
                                  ))),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 0.5,
                      width: MediaQuery.of(context).size.width,
                      color: AppColors.lightGreyColor,
                    )
                  ]),
                  SizedBox(height: 20),
                  Container(
                    height: 30,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: subcategoryList.length,
                        itemBuilder: (BuildContext context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (subcategoryList[index].isSelected) {
                                  subcategoryList[index].isSelected = false;
                                  for (int j = 0;
                                      j < selectedSubCatText.length;
                                      j++) {
                                    if (selectedSubCatText[j] ==
                                        subcategoryList[index].title) {
                                      selectedSubCatText.removeAt(j);
                                      selectedSubCategoryList
                                          .remove(subcategoryList[index]);
                                    }
                                  }
                                } else {
                                  subcategoryList[index].isSelected = true;
                                  selectedSubCategoryList
                                      .add(subcategoryList[index]);
                                  selectedSubCatText
                                      .add(subcategoryList[index].title);
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 8.0, right: 8.0),
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                  color: subcategoryList[index].isSelected
                                      ? AppColors.blueColor
                                      : Colors.white,
                                  border:
                                      Border.all(color: AppColors.blueColor),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(48))),
                              child: Row(
                                children: [
                                  Icon(
                                    subcategoryList[index].isSelected
                                        ? Icons.check
                                        : Icons.add,
                                    size: 14,
                                    color: subcategoryList[index].isSelected
                                        ? Colors.white
                                        : AppColors.blueColor,
                                  ),
                                  SizedBox(width: 3),
                                  Text(subcategoryList[index].title,
                                      style: TextStyle(
                                        color: subcategoryList[index].isSelected
                                            ? Colors.white
                                            : AppColors.blueColor,
                                        fontFamily: Constants.openSauceFont,
                                        fontSize: 11,
                                      ))
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                  SizedBox(height: 30),
                  Text(
                    Constants.tools,
                    style: TextStyle(
                        fontFamily: "open_saucesans_regular",
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 15),
                  Column(children: [
                    InkWell(
                      onTap: () async {
                        var result = await Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    new SelectFilterPage(
                                      Constants.tools,
                                      Constants.tools,
                                      selectedFiltersList: selectedToolsText,
                                    )));
                        if (result != null) {
                          selectedToolsList.clear();
                          selectedToolsText.clear();
                          selectedToolsList = result["toolsList"];

                          for (int i = 0; i < toolsList.length; i++) {
                            toolsList[i].isSelected = false;
                            for (int j = 0; j < selectedToolsList.length; j++) {
                              if (toolsList[i].id == selectedToolsList[j].id) {
                                toolsList[i].isSelected = true;
                                selectedToolsText.add(toolsList[i].title);
                              }
                            }
                          }
                        } else {
                          selectedToolsList.clear();
                        }
                        setState(() {});
                      },
                      child: Container(
                          height: 20,
                          child: selectedToolsText.length > 0
                              ? ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: selectedToolsText.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      child:
                                          Text(selectedToolsText[index] + ","),
                                    );
                                  })
                              : Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'Search tools...',
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 15.0,
                                        fontFamily: "open_saucesans_regular",
                                        fontWeight: FontWeight.w400),
                                  ))),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 0.5,
                      width: MediaQuery.of(context).size.width,
                      color: AppColors.lightGreyColor,
                    )
                  ]),
                  SizedBox(height: 20),
                  Container(
                    height: 30,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: toolsList.length,
                        itemBuilder: (BuildContext context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (toolsList[index].isSelected) {
                                  toolsList[index].isSelected = false;
                                  for (int j = 0;
                                      j < selectedToolsText.length;
                                      j++) {
                                    if (selectedToolsText[j] ==
                                        toolsList[index].title) {
                                      selectedToolsText.removeAt(j);
                                      selectedToolsList
                                          .remove(toolsList[index]);
                                    }
                                  }
                                } else {
                                  toolsList[index].isSelected = true;
                                  selectedToolsList.add(toolsList[index]);

                                  selectedToolsText.add(toolsList[index].title);
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 8.0, right: 8.0),
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                  color: toolsList[index].isSelected
                                      ? AppColors.blueColor
                                      : Colors.white,
                                  border:
                                      Border.all(color: AppColors.blueColor),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(48))),
                              child: Row(
                                children: [
                                  Icon(
                                    toolsList[index].isSelected
                                        ? Icons.check
                                        : Icons.add,
                                    size: 14,
                                    color: toolsList[index].isSelected
                                        ? Colors.white
                                        : AppColors.blueColor,
                                  ),
                                  SizedBox(width: 3),
                                  Text(toolsList[index].title,
                                      style: TextStyle(
                                        color: toolsList[index].isSelected
                                            ? Colors.white
                                            : AppColors.blueColor,
                                        fontFamily: Constants.openSauceFont,
                                        fontSize: 11,
                                      ))
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                  SizedBox(height: 30),
                  Text(
                    Constants.settings,
                    style: TextStyle(
                        fontFamily: "open_saucesans_regular",
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 15),
                  Column(children: [
                    InkWell(
                      onTap: () async {
                        var result = await Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    new SelectFilterPage(
                                        Constants.settings, Constants.settings,
                                        selectedFiltersList:
                                            selectedSettingsText)));
                        if (result != null) {
                          selectedSettingssList.clear();
                          selectedSettingsText.clear();
                          selectedSettingssList = result["settingsList"];

                          for (int i = 0; i < settingsList.length; i++) {
                            settingsList[i].isSelected = false;
                            for (int j = 0;
                                j < selectedSettingssList.length;
                                j++) {
                              if (settingsList[i].id ==
                                  selectedSettingssList[j].id) {
                                settingsList[i].isSelected = true;
                                selectedSettingsText.add(settingsList[i].title);
                              }
                            }
                          }
                        } else {
                          selectedSettingsText.clear();
                        }
                        setState(() {});
                      },
                      child: Container(
                          height: 20,
                          child: selectedSettingsText.length > 0
                              ? ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: selectedSettingsText.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      child: Text(
                                          selectedSettingsText[index] + ","),
                                    );
                                  })
                              : Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'Select settings...',
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 15.0,
                                        fontFamily: "open_saucesans_regular",
                                        fontWeight: FontWeight.w400),
                                  ))),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 0.5,
                      width: MediaQuery.of(context).size.width,
                      color: AppColors.lightGreyColor,
                    )
                  ]),
                  SizedBox(height: 20),
                  Container(
                    height: 30,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: settingsList.length,
                        itemBuilder: (BuildContext context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (settingsList[index].isSelected) {
                                  settingsList[index].isSelected = false;
                                  for (int j = 0;
                                      j < selectedSettingsText.length;
                                      j++) {
                                    if (selectedSettingsText[j] ==
                                        settingsList[index].title) {
                                      selectedSettingsText.removeAt(j);
                                      selectedSettingssList
                                          .remove(settingsList[index]);
                                    }
                                  }
                                } else {
                                  settingsList[index].isSelected = true;
                                  selectedSettingssList
                                      .add(settingsList[index]);
                                  selectedSettingsText
                                      .add(settingsList[index].title);
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 8.0, right: 8.0),
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                  color: settingsList[index].isSelected
                                      ? AppColors.blueColor
                                      : Colors.white,
                                  border:
                                      Border.all(color: AppColors.blueColor),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(48))),
                              child: Row(
                                children: [
                                  Icon(
                                    settingsList[index].isSelected
                                        ? Icons.check
                                        : Icons.add,
                                    size: 14,
                                    color: settingsList[index].isSelected
                                        ? Colors.white
                                        : AppColors.blueColor,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    settingsList[index].title,
                                    style: TextStyle(
                                      color: settingsList[index].isSelected
                                          ? Colors.white
                                          : AppColors.blueColor,
                                      fontFamily: Constants.openSauceFont,
                                      fontSize: 11,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                  )
                ],
              ),
            )),
            Container(
              color: Colors.transparent,
              margin: EdgeInsets.symmetric(vertical: 20.0),
              width: MediaQuery.of(context).size.width,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onPressed: () {
                  if (widget.viewType != null && widget.viewType.isNotEmpty) {
                    Navigator.pop(context, {
                      "selectedCatText": selectedCatText,
                      "selectedSubCatText": selectedSubCatText,
                      "selectedToolsText": selectedToolsText,
                      "selectedSettingssList": selectedSettingsText,
                    });
                  } else if (checkValidation()) {
                    createRoutine(indexSectionForRoutine);
                  }
                  // nextToBuildRoutine();
                },
                color: AppColors.darkTextColor,
                textColor: Colors.white,
                padding: EdgeInsets.all(12.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      widget.viewType != null && widget.viewType.isNotEmpty
                          ? "Add Filters".toUpperCase()
                          : "Post".toUpperCase(),
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        fontFamily: "open_saucesans_regular",
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void createCardWithTextOnly() {
    CardModel cardModel = new CardModel(
        type: widget.cardType,
        title: widget.title,
        description: widget.description,
        bodyParts: widget.bodyPartsListIntent,
        media: mediaFiles,
        setNumbers: widget.numbersList,
        categoryList: categoryList,
        subcategoryList: subcategoryList,
        settingsList: settingsList,
        createdBy: globalUserId,
        timestamp: Timestamp.now(),
        toolsList: toolsList);
    FirebaseFirestore.instance
        .collection(Constants.cardsColl)
        .add(cardModel.toJson())
        .then((value) => {
              // createFeed(value.id)
            })
        .catchError((onError) {
      Utilities.hide();
    });
  }

  Future<void> addCards(int i1, int j1, int size) {
    // widget.sectionList[i1].cardList[j1].media = mediaFiles;
    FirebaseFirestore.instance
        .collection(Constants.cardsColl)
        .add(widget.sectionList[i1].cardList[j1].toJson())
        .then((value) {
      cardIds.add(value.id);
      addData = true;

      if (cardIds.length == widget.sectionList[i1].cardList.length) {
        uploadSection(i1, j1);
      }
    }).catchError((onError) {
      Utilities.hide();
    });
  }

// Save Routine to DB
  Future<void> createRoutine(int sectionIndexValue) async {
    //  RoutineSectionModel routineSectionModel = new RoutineSectionModel(cardList: );
    Utilities.show(context);

    // for (int i = sectionIndexValue; i < widget.sectionList.length; i++) {
    cardIds.clear();
    for (int j = 0;
        j < widget.sectionList[sectionIndexValue].cardList.length;
        j++) {
      widget.sectionList[sectionIndexValue].cardList[j].categoryList =
          selectedCategoryList;
      widget.sectionList[sectionIndexValue].cardList[j].subcategoryList =
          selectedSubCategoryList;
      widget.sectionList[sectionIndexValue].cardList[j].settingsList =
          selectedSettingssList;
      widget.sectionList[sectionIndexValue].cardList[j].toolsList =
          selectedToolsList;
      widget.sectionList[sectionIndexValue].cardList[j].categoryListTitle =
          selectedCatText;
      widget.sectionList[sectionIndexValue].cardList[j].subcategoryListTitle =
          selectedSubCatText;
      widget.sectionList[sectionIndexValue].cardList[j].settingsListTitle =
          selectedSettingsText;
      widget.sectionList[sectionIndexValue].cardList[j].toolsListTitle =
          selectedToolsText;

      if (widget.sectionList[sectionIndexValue].cardList[j].type == "Image") {
        if (widget.sectionList[sectionIndexValue].cardList[j].media.length >
            0) {
          await addCards(sectionIndexValue, j,
              widget.sectionList[sectionIndexValue].cardList.length);
        } else {
          var imageFileList =
              widget.sectionList[sectionIndexValue].cardList[j].imageFiles;
          for (int k = 0; k < imageFileList.length; k++) {
            addData = false;

            await uploadFiles(imageFileList[k], k, imageFileList.length,
                sectionIndexValue, j);
          }
        }
      } else if (widget.sectionList[sectionIndexValue].cardList[j].type ==
          "Video") {
        if (widget.sectionList[sectionIndexValue].cardList[j].media.length >
            0) {
          await addCards(sectionIndexValue, j,
              widget.sectionList[sectionIndexValue].cardList.length);
        } else {
          addData = false;
          HashMap<File, File> videoFile =
              widget.sectionList[sectionIndexValue].cardList[j].videoFiles;

          await uploadThumbnail(
              videoFile.keys.elementAt(0),
              videoFile[videoFile.keys.elementAt(0)],
              sectionIndexValue,
              j,
              widget.sectionList[sectionIndexValue].cardList.length);
        }
      } else {
        await addCards(sectionIndexValue, j,
            widget.sectionList[sectionIndexValue].cardList.length);
      }
    }
  }

  void createRoutineFeed() {
    if (addData) {
      RoutineModel routineModel = new RoutineModel(
          categoryList: selectedCategoryList,
          subcategoryList: selectedSubCategoryList,
          createdBy: globalUserId,
          settingsList: selectedSettingssList,
          toolsList: selectedToolsList,
          title: widget.routineName,
          timestamp: Timestamp.now(),
          fileUrl: fileUrl,
          thumbnail: thumbnail,
          cardType: cardType,
          sectionIds: sectionIds,
          setNumbers: widget.numbersList);
      FirebaseFirestore.instance
          .collection(Constants.routineFeedCollection)
          .add(routineModel.toJson())
          .then((value) => {
                createFeed(value.id),
                Constants()
                    .successToast(context, "Routine Created Successfully!"),
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomeScreen(currentIndex: 0)),
                    (route) => false)
              })
          .catchError((onError) {
        Utilities.hide();
      });
    }
  }

  void uploadSection(int indexSection, int cardIndex) {
    RoutineSectionModel routineSectionModel = new RoutineSectionModel(
        createdBy: globalUserId,
        cardIds: cardIds,
        timestamp: Timestamp.now(),
        title: widget.sectionList[indexSection].title,
        importBy: globalUserId);
    FirebaseFirestore.instance
        .collection(Constants.sectionColl)
        .add(routineSectionModel.toJson())
        .then((value) {
      sectionIds.add(value.id);

      if (indexSection == widget.sectionList.length - 1) {
        if (sectionIds.length == widget.sectionList.length) {
          createRoutineFeed();
        }
      } else {
        indexSectionForRoutine += 1;
        createRoutine(indexSectionForRoutine);
      }
    }).catchError((onError) {
      Utilities.hide();
    });
  }

  void createFeed(String routineId) {

    String feedIdReal = widget.feedId.isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : widget.feedId;
    List<String> _categoryTitles = new List.empty(growable: true);
    selectedCategoryList.forEach((element) {
      _categoryTitles.add(element.title);
    });

    FeedModel feedModel = new FeedModel(
      itemId: routineId,
      saveCount: 0,
      type: "Routine",
      timestamp: Timestamp.now(),
      userId: globalUserId,
      categoryList: _categoryTitles,
      feedViewCount: 0,
      viewCount: [],
      sharedBy: '',
      sharedByUsernName: ''
    );
    FirebaseFirestore.instance
        .collection(Constants.feedsColl)
        .doc(feedIdReal)
        .set(feedModel.toJson())
        .then((value) => {
              Utilities.hide(),
              Constants()
                  .successToast(context, "Routine is created successfully"),
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomeScreen(currentIndex: 0)),
                  (route) => false)
            })
        .catchError((onError) {
      Utilities.hide();
    });
  }

  void creatCardWithFile() {
    // if (widget.cardType == image) {
    //   for (int i = 0; i < widget.files.length; i++) {
    //     uploadFiles(widget.files[i], i);
    //   }
    // } else {
    //   for (int i = 0; i < widget.mediaList.length; i++) {
    //     uploadThumbnail(widget.mediaList[i].keys.elementAt(0), i);
    //   }
    // }
  }

  Future<void> uploadThumbnail(File file, File videoFile, int sectionIndex,
      int cardIndex, int size) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var reference = FirebaseStorage.instance
        .ref()
        .child(Constants.cardVideos)
        .child(fileName);
    UploadTask uploadTask = reference.putFile(File(file.path));
    uploadTask.whenComplete(() {
      reference.getDownloadURL().then((downloadUrl) {
        mediaModel.thumbnail = downloadUrl;
        uploadVideo(videoFile, sectionIndex, cardIndex, size);
      }).catchError((onError) {
        Utilities.hide();
        Constants().errorToast(context, "$onError , please upload image again");
      });
    });
  }

  uploadVideo(File file, int sectionIndex1, int cardIndex1, int size) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var reference = FirebaseStorage.instance
        .ref()
        .child(Constants.cardVideos)
        .child(fileName);
    UploadTask uploadTask = reference.putFile(file);
    uploadTask.whenComplete(() {
      reference.getDownloadURL().then((downloadUrl) {
        mediaFiles.clear();
        mediaModel.fileUrl = downloadUrl;
        mediaFiles.add(mediaModel);
        widget.sectionList[sectionIndex1].cardList[cardIndex1].media =
            mediaFiles;
        if (fileUrl == "" || cardType == "Text" || cardType == "Image") {
          fileUrl = downloadUrl;
          thumbnail = mediaModel.thumbnail;
          cardType = "Video";
        }

        // createCardWithTextOnly();
    widget.sectionList[sectionIndex1].cardList[cardIndex1].media = mediaFiles;

        addCards(sectionIndex1, cardIndex1, size);
      }).catchError((onError) {
        Utilities.hide();
        Constants().errorToast(context, "$onError , please upload video again");
      });
    });
  }

  uploadFiles(
      File file, int index, int size, int sectionIndex, int cardIndex) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance
        .ref()
        .child(Constants.cardImages)
        .child(fileName);
    UploadTask uploadTask = reference.putFile(file);
    uploadTask.whenComplete(() {
      reference.getDownloadURL().then((downloadUrl) {
        mediaFiles.add(Media(fileUrl: downloadUrl, thumbnail: ""));
        if (fileUrl == "") {
          fileUrl = downloadUrl;
          thumbnail = "";
          cardType = "Image";
        }
        if (index == size - 1) {
          // createCardWithTextOnly();
          
widget.sectionList[sectionIndex].cardList[cardIndex].media = mediaFiles;
          addCards(sectionIndex, cardIndex, size);
        }
      }).catchError((onError) {
        Utilities.hide();

        Constants().errorToast(context, "$onError , please upload image again");
      });
    });
  }

  // check validation message
  bool checkValidation() {
    if (selectedCategoryList.length == 0) {
      Constants().errorToast(context, "Please select categories");
      return false;
    }
    // else if (selectedToolsList.length == 0) {
    //   Constants().errorToast(context, "Please select tools");
    //   return false;
    // } else if (selectedSettingssList.length == 0) {
    //   Constants().errorToast(context, "Please select settings");
    //   return false;
    // }
    return true;
  }

  // send to next screen
  void nextToBuildRoutine() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BuildRoutine(
                  title: widget.routineName,
                  selectedCategoryList: selectedCategoryList,
                  selectedSubCategoryList: selectedSubCategoryList,
                  selectedToolsList: selectedToolsList,
                  selectedSettingsList: selectedSettingssList,
                )));
  }

  void getCategory(String collCategory) {
    var collectionReference =
        FirebaseFirestore.instance.collection(collCategory).get();
    collectionReference.then((value) {
      final List<DocumentSnapshot> docs = value.docs;
      docs.forEach((data) {
        SelectFilterModel selectFilterModel =
            SelectFilterModel.fromJson(data.data());
        selectFilterModel.id = data.id;
        categoryList.add(selectFilterModel);
        if (data.id == value.docs[value.docs.length - 1].id) {
          setState(() {});
        }
      });
    }).catchError((onError) {
    });
  }

  void getTools(String collTools) {
    var collectionReference =
        FirebaseFirestore.instance.collection(collTools).get();
    collectionReference.then((value) {
      final List<DocumentSnapshot> docs = value.docs;
      docs.forEach((data) {
        SelectFilterModel selectFilterModel =
            SelectFilterModel.fromJson(data.data());
        selectFilterModel.id = data.id;
        toolsList.add(selectFilterModel);
        if (data.id == value.docs[value.docs.length - 1].id) {
          setState(() {});
        }
      });
    }).catchError((onError) {
    });
  }

  void getSettings(String collsSettings) {
    var collectionReference =
        FirebaseFirestore.instance.collection(collsSettings).get();
    collectionReference.then((value) {
      final List<DocumentSnapshot> docs = value.docs;
      docs.forEach((data) {
        SelectFilterModel selectFilterModel =
            SelectFilterModel.fromJson(data.data());
        selectFilterModel.id = data.id;
        settingsList.add(selectFilterModel);
        if (data.id == value.docs[value.docs.length - 1].id) {
          setState(() {});
        }
      });
    }).catchError((onError) {
    });
  }

  void getSubCategory(String trainingSubCategories, categoryId) {
    var collectionReference = FirebaseFirestore.instance
        .collection(trainingSubCategories)
        .where("training_category_id", isEqualTo: categoryId)
        .get();
    collectionReference.then((value) {
      final List<DocumentSnapshot> docs = value.docs;
      docs.forEach((data) {
        SelectFilterModel selectFilterModel =
            SelectFilterModel.fromJson(data.data());
        selectFilterModel.id = data.id;
        subcategoryList.add(selectFilterModel);
        if (data.id == value.docs[value.docs.length - 1].id) {
          setState(() {});
        }
      });
    }).catchError((onError) {
    });
  }
}
