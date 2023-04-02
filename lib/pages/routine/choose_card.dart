import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/model/forum_model.dart';
import 'package:solstice/model/tabs_models.dart';
import 'package:solstice/pages/cards/card_item.dart';
import 'package:solstice/pages/routine/routine_tags.dart';
import 'package:solstice/utils/constants.dart';

class ChooseCard extends StatefulWidget {
  @override
  _ChooseCardState createState() => _ChooseCardState();
}

class _ChooseCardState extends State<ChooseCard> {
  int selectedTab = 0;
  List<TabsModel> _tabModelList = new List.empty(growable: true);
  List<CardModel> _cardsList = new List.empty(growable: true);
  List<CardModel> selectedCards = new List.empty(growable: true);
  var setCardState;
  @override
  void initState() {
    super.initState();
    tabListData();
    getSuggestedCards();
  }

//get Suggested Cards
  getSuggestedCards() {
    FirebaseFirestore.instance
        .collection(Constants.cardsColl)
        .where("import_by", isEqualTo: '')
        .get()
        .then((value) {
      if (value.docs.length > 0) {
        value.docs.forEach((element) {
          CardModel cardModel = CardModel.fromJson(element);
          cardModel.cardId = element.id;
          loadUser(cardModel.createdBy).then((value2) {
            cardModel.userFirebaseModel = value2;
            _cardsList.add(cardModel);

            if (element.id == value.docs[value.docs.length - 1].id) {
              setState(() {});
            }
          });
        });
      }
    });
  }

  // for getting user detail
  Future<UserFirebaseModel> loadUser(userId) async {
    DocumentSnapshot ds =
        await FirebaseFirestore.instance.collection(Constants.UsersFB).doc(userId).get();
    if (ds != null)

      // return ds;

      return Future.delayed(Duration(milliseconds: 100), () => UserFirebaseModel.fromSnapshot(ds));
  }

// add Tabs List
  void tabListData() {
    _tabModelList.add(TabsModel(Constants.suggested, true));
    _tabModelList.add(TabsModel(Constants.recents, false));
    _tabModelList.add(TabsModel(Constants.saved, false));
    _tabModelList.add(TabsModel(Constants.library, false));
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      setCardState = setState;
      return Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.black, size: 28),
                    onPressed: () => {Navigator.of(context).pop()},
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      Constants.chooseCards,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.greyTextColor,
                        fontFamily: Constants.openSauceFont,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context, {"selectedCards": selectedCards});
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
            ),
            tabWidget(),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20, top: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 65,
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 25,
                              height: 25,
                              padding: EdgeInsets.all(2.5),
                              margin: EdgeInsets.only(left: 20, right: 5),
                              child: Image.asset(
                                'assets/images/search_normal.png',
                                alignment: Alignment.center,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: "Search here..",
                                    border: InputBorder.none,
                                  ),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontFamily: Constants.openSauceFont,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: Colors.black),
                                  onChanged: (text) {},
                                ),
                              ),
                            ),
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        elevation: 0.8,
                        margin: EdgeInsets.all(10),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      var object = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RoutineTags(
                                    viewType: "Filter",
                                  )));
                      if (object != null) {
                        catTitleList = object["selectedCatText"];
                        subCatTitleList = object["selectedSubCatText"];
                        toolsTitleList = object["selectedToolsText"];
                        settingsTitleList = object["selectedSettingssList"];
                        _cardsList.clear();
                        isFilterApplied = true;
                        if (catTitleList.length > 0) {
                          getFilteredData();
                        } else if (subCatTitleList.length > 0) {
                          getSubCatFilteredData();
                        } else if (toolsTitleList.length > 0) {
                          getToolsFilteredData();
                        } else if (settingsTitleList.length > 0) {
                          getSettingsFilteredData();
                        } else {
                          setState(() {});
                        }
                      }
                    },
                    child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 0.8,
                        child: Container(
                            margin: EdgeInsets.all(10),
                            width: 23,
                            height: 23,
                            child: SvgPicture.asset(
                              'assets/images/ic_filter.svg',
                              alignment: Alignment.center,
                              fit: BoxFit.fill,
                              color: AppColors.accentColor,
                            ))),
                  ),
                  isFilterApplied
                      ? InkWell(
                          onTap: () {
                            isFilterApplied = false;
                            _cardsList.clear();
                            getSuggestedCards();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Clear",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.darkTextColor,
                                fontFamily: Constants.openSauceFont,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ))
                      // Icon(Icons.undo, size: 20, color: Colors.black))
                      : Container()
                ],
              ),
            ),
            Expanded(
              child: Container(
                  height: MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top),
                  margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                  child: _cardsList.length > 0 ? cardListUI() : Container()),
            ),
          ],
        ),
      );
    });
  }

  bool isFilterApplied = false;
  List<String> catTitleList = new List.empty(growable: true);
  List<String> subCatTitleList = new List.empty(growable: true);
  List<String> settingsTitleList = new List.empty(growable: true);
  List<String> toolsTitleList = new List.empty(growable: true);

  void getFilteredData() {
    FirebaseFirestore.instance
        .collection(Constants.cardsColl)
        .where("category_list_title", arrayContainsAny: catTitleList)
        .get()
        .then((value) {
      if (value.docs.length > 0) {
        value.docs.forEach((element) {
          CardModel cardModel = CardModel.fromJson(element);
          cardModel.cardId = element.id;
          loadUser(cardModel.createdBy).then((value2) {
            cardModel.userFirebaseModel = value2;
            _cardsList.add(cardModel);
            if (element.id == value.docs[value.docs.length - 1].id) {
              if (subCatTitleList.length > 0) {
                getSubCatFilteredData();
              } else if (toolsTitleList.length > 0) {
                getToolsFilteredData();
              } else if (settingsTitleList.length > 0) {
                getSettingsFilteredData();
              } else {
                removeDuplicates();

                setState(() {});
              }
            }
          });
        });
      } else if (subCatTitleList.length > 0) {
        getSubCatFilteredData();
      } else if (toolsTitleList.length > 0) {
        getToolsFilteredData();
      } else if (settingsTitleList.length > 0) {
        getSettingsFilteredData();
      } else {
        removeDuplicates();

        setState(() {});
      }
    });
  }

  void getSubCatFilteredData() {
    FirebaseFirestore.instance
        .collection(Constants.cardsColl)
        .where("subcategory_list_title", arrayContainsAny: subCatTitleList)
        .get()
        .then((value) {
      if (value.docs.length > 0) {
        value.docs.forEach((element) {
          CardModel cardModel = CardModel.fromJson(element);
          cardModel.cardId = element.id;
          loadUser(cardModel.createdBy).then((value2) {
            cardModel.userFirebaseModel = value2;
            _cardsList.add(cardModel);
            if (element.id == value.docs[value.docs.length - 1].id) {
              if (toolsTitleList.length > 0) {
                getToolsFilteredData();
              } else if (settingsTitleList.length > 0) {
                getSettingsFilteredData();
              } else {
                removeDuplicates();

                setState(() {});
              }
            }
          });
        });
      } else if (toolsTitleList.length > 0) {
        getToolsFilteredData();
      } else if (settingsTitleList.length > 0) {
        getSettingsFilteredData();
      } else {
        removeDuplicates();

        setState(() {});
      }
    });
  }

  void getToolsFilteredData() {
    FirebaseFirestore.instance
        .collection(Constants.cardsColl)
        .where("tools_list_title", arrayContainsAny: toolsTitleList)
        .get()
        .then((value) {
      if (value.docs.length > 0) {
        value.docs.forEach((element) {
          CardModel cardModel = CardModel.fromJson(element);
          cardModel.cardId = element.id;
          loadUser(cardModel.createdBy).then((value2) {
            cardModel.userFirebaseModel = value2;
            _cardsList.add(cardModel);
            if (element.id == value.docs[value.docs.length - 1].id) {
              if (settingsTitleList.length > 0) {
                getSettingsFilteredData();
              } else {
                removeDuplicates();

                setState(() {});
              }
            }
          });
        });
      } else if (settingsTitleList.length > 0) {
        getSettingsFilteredData();
      } else {
        removeDuplicates();

        setState(() {});
      }
    });
  }

  void getSettingsFilteredData() {
    FirebaseFirestore.instance
        .collection(Constants.cardsColl)
        .where("settings_list_title", arrayContainsAny: settingsTitleList)
        .get()
        .then((value) {
      if (value.docs.length > 0) {
        value.docs.forEach((element) {
          CardModel cardModel = CardModel.fromJson(element);
          cardModel.cardId = element.id;
          loadUser(cardModel.createdBy).then((value2) {
            cardModel.userFirebaseModel = value2;
            _cardsList.add(cardModel);
            if (element.id == value.docs[value.docs.length - 1].id) {
              removeDuplicates();
              setState(() {});
            }
          });
        });
      } else {
        removeDuplicates();

        setState(() {});
      }
    });
  }

  List<CardModel> _cardsListTemp = new List.empty(growable: true);

  void removeDuplicates() {
    final ids = Set();
    _cardsList.retainWhere((x) => ids.add(x.cardId));
  }

  Widget tabWidget() {
    return Container(
      height: 32,
      margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      child: ListView.builder(
          itemCount: _tabModelList.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                for (int i = 0; i < _tabModelList.length; i++) {
                  _tabModelList[i].isSelected = false;
                }
                _tabModelList[index].isSelected = true;
                setState(() {});
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    color: _tabModelList[index].isSelected
                        ? AppColors.cardColor
                        : AppColors.lightSkyBlue),
                child: Center(
                  child: Text(
                    _tabModelList[index].tabTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13.0,
                        fontFamily: "open_saucesans_regular",
                        fontWeight: FontWeight.w400,
                        color: _tabModelList[index].isSelected ? Colors.white : Colors.blue),
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget cardListUI() {
    return Container(
      child: ListView.builder(
        itemBuilder: (context, index) {
          return CardItem(
            cardModel: _cardsList[index],
            selectCard: getSelectedCard,
            index: index,
            createMode: false,
            isEditMode: true,
            userName: _cardsList[index].userFirebaseModel.userName,
            numberValue: index + 1,
            cardList: _cardsList.length,
          );
        },
        itemCount: _cardsList.length,
        scrollDirection: Axis.vertical,
      ),
    );
  }

// get selected cards
  void getSelectedCard(CardModel cardModel, int index) {
    _cardsList[index].isSelected = !_cardsList[index].isSelected;

    if (_cardsList[index].isSelected) {
      _cardsList[index].importBy = globalUserId;
      selectedCards.add(_cardsList[index]);
    } else {
      selectedCards.remove(_cardsList[index]);
    }

    setCardState(() {});
  }
}
