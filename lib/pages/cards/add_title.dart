import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solstice/model/card_title_model.dart';
import 'package:solstice/utils/constants.dart';

String selectedText = "";

class AddTitle extends StatefulWidget {
  String viewType = "", selectedText = "";
  AddTitle(this.viewType);

  @override
  _AddTitleState createState() => _AddTitleState();
}

TextEditingController textEditingController = new TextEditingController();
int selectedTab = 0;

class _AddTitleState extends State<AddTitle> {
  List<CardTitleMainModel> mainTitleList = new List.empty(growable: true);
  List<CardTitleMainModel> searchTitleList = new List.empty(growable: true);
  List<CardTitleModel> titleList = new List.empty(growable: true);
  String headerLetter = "";
  String oldHeaderLetter = "";
  String docField = "";
  var urlPattern =
      (r"((https?:www\.)|(https?:\/\/)|(www\.)|(a-zA-Z))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");

  @override
  void initState() {
    super.initState();
    if (widget.viewType == Constants.viewTitle) {
      docField = "title";
      // textEditingController.text = Constants.addTitle;
      getTitlesData(selectedTab, Constants.cardTitles);
    } else {
      docField = "description";
      // textEditingController.text = Constants.addDescription;
      getTitlesData(selectedTab, Constants.cardDescriptions);
    }
  }

  bool validateUrl(String hyperlink) {
    var match = new RegExp(urlPattern, caseSensitive: false);

    return match.hasMatch(hyperlink);
  }

  void getTitlesData(int selectedTabNum, String collectionName) {
    mainTitleList.clear();
    headerLetter = "";
    oldHeaderLetter = "";
    titleList.clear();
    var fb;

    if (collectionName == Constants.posts) {
      fb = FirebaseFirestore.instance
          .collection(collectionName)
          .orderBy(docField, descending: false)
          .where("is_public", isEqualTo: true)
          .limit(10);
    } else {
      fb = FirebaseFirestore.instance
          .collection(collectionName)
          .orderBy(docField, descending: false);
    }
    fb
        .get()
        .then((value) => value.docs.forEach((element) {
              if (element[docField].toString().toUpperCase().substring(0, 1) ==
                  headerLetter.toUpperCase()) {
                titleList.add(CardTitleModel(
                    id: element.id,
                    title: element[docField],
                    isTitleSelected: false));

              } else {
                titleList = new List.empty(growable: true);
                headerLetter =
                    element[docField].toString().toUpperCase().substring(0, 1);
                titleList.add(CardTitleModel(
                    id: element.id,
                    title: element[docField],
                    isTitleSelected: false));

              }
              if (oldHeaderLetter != headerLetter) {
                mainTitleList.add(CardTitleMainModel(
                    titleHeading: headerLetter, titleList: titleList));
              }

              oldHeaderLetter = headerLetter;
              if (element.id == value.docs[value.docs.length - 1].id) {
                setState(() {});
              }
            }))
        .catchError((onError) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              margin: EdgeInsets.only(left: 30, right: 30, top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: false,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: InkWell(
                      onTap: () {
                        if (textEditingController.text
                                .toString()
                                .startsWith("http") &&
                            validateUrl(
                                textEditingController.text.toString())) {
                          Navigator.pop(context, textEditingController.text);
                          textEditingController.text = "";
                          selectedTab = 0;
                        } else {
                          Navigator.pop(context, textEditingController.text);
                          textEditingController.text = "";
                          selectedTab = 0;
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          Constants.doneText,
                          style: TextStyle(
                              fontSize: 14.0,
                              color: AppColors.cardTextColor,
                              fontFamily: "open_saucesans_regular",
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                      visible: true,
                      maintainSize: false,
                      child: Container(
                          alignment: Alignment.center,
                          width: 150,
                          child: Text(
                            widget.viewType == Constants.viewTitle
                                ? Constants.chooseTitle
                                : Constants.chooseDescription,
                            style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          )
                          // TextField(
                          //     controller: textEditingController,
                          //     onChanged: (value) {},
                          //     textAlign: TextAlign.center,
                          //     readOnly: true,
                          //     style: TextStyle(
                          //         fontSize: 14.0,
                          //         color: Colors.black,
                          //         fontWeight: FontWeight.w600),
                          //     decoration: InputDecoration(
                          //         hintText: widget.viewType == Constants.viewTitle
                          //             ? Constants.addTitle
                          //             : Constants.addDescription,
                          //         floatingLabelBehavior:
                          //             FloatingLabelBehavior.never)),
                          )),
                  InkWell(
                    onTap: () {
                      textEditingController.text = "";
                      Navigator.pop(context);
                      selectedTab = 0;
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        Constants.cancel,
                        style: TextStyle(
                            fontSize: 14.0,
                            color: AppColors.cardTextColor,
                            fontFamily: "open_saucesans_regular",
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    color: AppColors.lightSkyBlue),
                padding: EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          selectedTab = 0;
                          if (widget.viewType == Constants.viewTitle) {
                            getTitlesData(0, Constants.cardTitles);
                          } else {
                            getTitlesData(0, Constants.cardDescriptions);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              color: selectedTab == 0
                                  ? AppColors.cardColor
                                  : AppColors.lightSkyBlue),
                          child: Text(
                            Constants.library,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14.0,
                                fontFamily: "open_saucesans_regular",
                                fontWeight: FontWeight.w400,
                                color: selectedTab == 0
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          selectedTab = 1;
                          getTitlesData(selectedTab, Constants.recentPosts);
                        },
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              color: selectedTab == 1
                                  ? AppColors.cardColor
                                  : AppColors.lightSkyBlue),
                          child: Text(
                            Constants.recents,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: "open_saucesans_regular",
                                fontWeight: FontWeight.w400,
                                fontSize: 14.0,
                                color: selectedTab == 1
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          selectedTab = 2;
                          getTitlesData(2, Constants.posts);
                        },
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              color: selectedTab == 2
                                  ? AppColors.cardColor
                                  : AppColors.lightSkyBlue),
                          child: Text(
                            Constants.public,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: "open_saucesans_regular",
                                fontWeight: FontWeight.w400,
                                fontSize: 14.0,
                                color: selectedTab == 2
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
            ),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
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
                                      fontFamily: "open_saucesans_regular",
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: Colors.black),
                                  onChanged: (text) {
                                    if (text.trim().isNotEmpty) {
                                      searchTitle(text);
                                    } else {
                                      searchTitleList.clear();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        elevation: 0.7,
                        margin: EdgeInsets.all(10),
                      ),
                    ),
                  ),
                  Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: 0.7,
                    child: Container(
                        margin: EdgeInsets.all(10),
                        width: 23,
                        height: 23,
                        child: SvgPicture.asset(
                          'assets/images/ic_filter.svg',
                          alignment: Alignment.center,
                          fit: BoxFit.fill,
                          color: AppColors.accentColor,
                        )),
                  )
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                    color: Colors.white,
                    height: MediaQuery.of(context).size.height +
                        50 -
                        (MediaQuery.of(context).padding.top),
                    margin:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                    child: tabsList(searchTitleList.length > 0
                        ? searchTitleList
                        : mainTitleList)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void searchTitle(String searchString) {
    searchTitleList.clear();
    List<CardTitleModel> searchList = new List();
    String header = searchString.substring(0, 1).toUpperCase();
    mainTitleList.forEach((element) {
      if (searchString
          .substring(0, 1)
          .toLowerCase()
          .startsWith(element.titleHeading.toLowerCase())) {
        element.titleList.forEach((element1) {
          if (element1.title
              .toLowerCase()
              .startsWith(searchString.toLowerCase())) {
            searchList.add(element1);
          }
        });
      }
    });

    if (searchList.length > 0) {
      searchTitleList
          .add(CardTitleMainModel(titleHeading: header, titleList: searchList));
    }
    setState(() {});
  }
}

Widget tabsList(mainTitleList) {
  return ListView.builder(
    primary: false,
    physics: NeverScrollableScrollPhysics(),
    itemBuilder: (context, index) {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                mainTitleList[index].titleHeading,
                style: TextStyle(fontSize: 14.0, color: Colors.black87),
                textAlign: TextAlign.start,
              ),
            ),
            TitleCardItem(
              cardTitleList: mainTitleList[index].titleList,
              index: index,
            ),
          ],
        ),
      );
    },
    itemCount: mainTitleList.length,
  );
}

class TitleCardItem extends StatefulWidget {
  final int index;
  final List<CardTitleModel> cardTitleList;

  TitleCardItem({this.index, this.cardTitleList});
  @override
  _TitleCardItemState createState() => _TitleCardItemState();
}

class _TitleCardItemState extends State<TitleCardItem> {
  var urlPattern =
      (r"((https?:www\.)|(https?:\/\/)|(www\.)|(a-zA-Z))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () {
                    // selectedText = widget.cardTitleList[index].title;
                    textEditingController.text =
                        widget.cardTitleList[index].title;

                    if (textEditingController.text
                            .toString()
                            .startsWith("http") &&
                        validateUrl(textEditingController.text.toString())) {
                      Navigator.pop(context, textEditingController.text);
                      textEditingController.text = "";
                      selectedTab = 0;
                    } else {
                      Navigator.pop(context, textEditingController.text);
                      textEditingController.text = "";
                      selectedTab = 0;
                    }

                    // for (int i = 0; i < widget.cardTitleList.length; i++) {
                    //   widget.cardTitleList[i].isTitleSelected = false;
                    // }
                    // widget.cardTitleList[index].isTitleSelected =
                    //     !widget.cardTitleList[index].isTitleSelected;
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Row(
                      children: [
                        Image.asset("assets/images/body.png",
                            height: 45, width: 45),
                        SizedBox(width: 10),
                        Text(
                          widget.cardTitleList[index].title,
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                              fontFamily: "open_saucesans_regular",
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.start,
                        ),
                        Spacer(),
                        Visibility(
                          visible: false,
                          child: Icon(Icons.check,
                              color: AppColors.primaryColor, size: 12),
                        ),
                        Visibility(
                          visible: selectedTab == 2 ? true : false,
                          child: Container(
                              height: 20,
                              padding: EdgeInsets.only(left: 15, right: 15),
                              child: Center(
                                child: Text(
                                  "0",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: AppColors.lightBlue,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)))),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 0.4,
                  color: Colors.black12,
                )
              ],
            ),
          );
        },
        shrinkWrap: true,
        primary: false,
        itemCount: widget.cardTitleList.length,
      ),
    );
  }

  bool validateUrl(String hyperlink) {
    var match = new RegExp(urlPattern, caseSensitive: false);

    return match.hasMatch(hyperlink);
  }
}
