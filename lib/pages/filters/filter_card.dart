import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/model/feed_model.dart';
import 'package:solstice/model/select_filter_model.dart';
import 'package:solstice/pages/filters/select_filters.dart';
import 'package:solstice/pages/home_screen.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/utilities.dart';

class FilterCardPage extends StatefulWidget {
  final List<String> bodyPartsListIntent;
  final String cardType, title, description;
  final List<HashMap<File, File>> mediaList;
  final List<SetNumbers> numbersList;
  final List<File> files;

  FilterCardPage(
      {this.bodyPartsListIntent,
      this.cardType,
      this.title,
      this.description,
      this.mediaList,
      this.numbersList,
      this.files});

  @override
  _FilterCardPageState createState() => _FilterCardPageState();
}

class _FilterCardPageState extends State<FilterCardPage> {
  int _radioValue1 = -1;
  int _radioValue2 = -1;
  List<SelectFilterModel> categoryList = new List.empty(growable: true);
  List<SelectFilterModel> subcategoryList = new List.empty(growable: true);
  List<SelectFilterModel> toolsList = new List.empty(growable: true);
  List<SelectFilterModel> settingsList = new List.empty(growable: true);

  String image = "Image";
  String video = "Video";
  String text = "Text";
  List<Media> mediaFiles = new List.empty(growable: true);
  Media mediaModel = new Media();
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  void _handleRadioValueChange1(int value) {
    setState(() {
      _radioValue1 = value;

      switch (_radioValue1) {
        case 0:
          break;
        case 1:
          break;
      }
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
        Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child:
                  Image.asset("assets/images/help.png", height: 26, width: 26)),
        )
      ],
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          Constants.addTagsToCard,
                          style: TextStyle(
                              fontFamily: "open_saucesans_regular",
                              color: Colors.black,
                              fontSize: 24.0,
                              fontWeight: FontWeight.w600),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: Text(
                            'Tags help add more information to your card which makes it easier for searching.',
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14.0,
                                fontFamily: "open_saucesans_regular",
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        SizedBox(height: 40),
                        InkWell(
                          onTap: () async {
                            selectedIndex = 1;
                            var result = await Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      new SelectFilterPage(Constants.category,
                                          Constants.trainingCategories),
                                ));
                            if (result != null) {
                              categoryList = result["categoryList"];
                            }
                            setState(() {});
                          },
                          child: Container(
                              height: 74,
                              padding: EdgeInsets.only(left: 18, right: 18),
                              child: Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        Constants.category,
                                        style: TextStyle(
                                            fontFamily:
                                                "open_saucesans_regular",
                                            color: selectedIndex == 1
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Text(
                                          categoryList.length > 0
                                              ? categoryList[0].title ?? ""
                                              : "",
                                          style: TextStyle(
                                              color: selectedIndex == 1
                                                  ? Colors.white
                                                  : Color(0xff738497),
                                              fontSize: 13.0,
                                              fontFamily:
                                                  "open_saucesans_regular",
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Icon(Icons.keyboard_arrow_right,
                                      color: selectedIndex == 1
                                          ? Colors.white
                                          : Color(0xff6E6A6A))
                                ],
                              ),
                              decoration: BoxDecoration(
                                  color: selectedIndex == 1
                                      ? AppColors.segmentAppBarColor
                                      : AppColors.lightBlue,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)))),
                        ),
                        SizedBox(height: 20),
                        InkWell(
                          onTap: () async {
                            selectedIndex = 2;
                            var result;
                            categoryList.length == 0
                                ? Constants().errorToast(
                                    context, "Please select category")
                                : result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SelectFilterPage(
                                              Constants.subCategory,
                                              Constants.trainingSubCategories,
                                              categoryList: categoryList,
                                            )));
                            if (result != null) {
                              subcategoryList = result["subCategoryList"];

                           
                            }
                               setState(() {});
                          },
                          child: Container(
                              height: 74,
                              padding: EdgeInsets.only(left: 18, right: 18),
                              child: Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        Constants.subCategory,
                                        style: TextStyle(
                                            fontFamily:
                                                "open_saucesans_regular",
                                            color: selectedIndex == 2
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Text(
                                          subcategoryList.length > 0
                                              ? subcategoryList[0].title ?? ""
                                              : "",
                                          style: TextStyle(
                                              color: selectedIndex == 2
                                                  ? Colors.white
                                                  : Color(0xff738497),
                                              fontSize: 13.0,
                                              fontFamily:
                                                  "open_saucesans_regular",
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Icon(Icons.keyboard_arrow_right,
                                      color: selectedIndex == 2
                                          ? Colors.white
                                          : Color(0xff6E6A6A))
                                ],
                              ),
                              decoration: BoxDecoration(
                                  color: selectedIndex == 2
                                      ? AppColors.segmentAppBarColor
                                      : AppColors.lightBlue,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)))),
                        ),
                        SizedBox(height: 20),
                        InkWell(
                          onTap: () async {
                            selectedIndex = 3;
                            var result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SelectFilterPage(
                                        Constants.tools, Constants.tools)));
                            if (result != null) {
                              toolsList = result["toolsList"];

                              
                            }
                            setState(() {});
                          },
                          child: Container(
                              height: 74,
                              padding: EdgeInsets.only(left: 18, right: 18),
                              child: Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        Constants.tools,
                                        style: TextStyle(
                                            fontFamily:
                                                "open_saucesans_regular",
                                            color: selectedIndex == 3
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Text(
                                          toolsList.length > 0
                                              ? toolsList[0].title ?? ""
                                              : "",
                                          style: TextStyle(
                                              color: selectedIndex == 3
                                                  ? Colors.white
                                                  : Color(0xff738497),
                                              fontSize: 13.0,
                                              fontFamily:
                                                  "open_saucesans_regular",
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Icon(Icons.keyboard_arrow_right,
                                      color: selectedIndex == 3
                                          ? Colors.white
                                          : Color(0xff6E6A6A))
                                ],
                              ),
                              decoration: BoxDecoration(
                                  color: selectedIndex == 3
                                      ? AppColors.segmentAppBarColor
                                      : AppColors.lightBlue,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)))),
                        ),
                        SizedBox(height: 20),
                        InkWell(
                          onTap: () async {
                            selectedIndex = 4;
                            var result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SelectFilterPage(
                                        Constants.settings,
                                        Constants.settings)));
                            if (result != null) {
                              settingsList = result["settingsList"];

                              
                            }
                            setState(() {});
                          },
                          child: Container(
                              height: 74,
                              padding: EdgeInsets.only(left: 18, right: 18),
                              child: Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        Constants.settings,
                                        style: TextStyle(
                                            fontFamily:
                                                "open_saucesans_regular",
                                            color: selectedIndex == 4
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Text(
                                          settingsList.length > 0
                                              ? settingsList[0].title ?? ""
                                              : "",
                                          style: TextStyle(
                                              fontFamily:
                                                  "open_saucesans_regular",
                                              color: selectedIndex == 4
                                                  ? Colors.white
                                                  : Color(0xff738497),
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Icon(Icons.keyboard_arrow_right,
                                      color: selectedIndex == 4
                                          ? Colors.white
                                          : Color(0xff6E6A6A)),
                                ],
                              ),
                              decoration: BoxDecoration(
                                  color: selectedIndex == 4
                                      ? AppColors.segmentAppBarColor
                                      : AppColors.lightBlue,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)))),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.only(left: 5.0),
                        //   child: Text("Card Privacy",
                        //       style: TextStyle(
                        //           fontSize: 14,
                        //           fontFamily: "open_saucesans_regular",
                        //           fontWeight: FontWeight.w600,
                        //           color: AppColors.darkTextColor)),
                        // ),
                        // SizedBox(
                        //   height: 10,
                        // ),
                        // Row(
                        //   children: [
                        //     Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: <Widget>[
                        //         new Radio(
                        //           value: 0,
                        //           groupValue: _radioValue1,
                        //           onChanged: _handleRadioValueChange1,
                        //         ),
                        //         InkWell(
                        //           onTap: () {
                        //             _handleRadioValueChange1;
                        //           },
                        //           child: new Text(
                        //             Constants.public,
                        //             style: new TextStyle(
                        //               fontSize: 14.0,
                        //               fontFamily: "open_saucesans_regular",
                        //               fontWeight: FontWeight.w400,
                        //             ),
                        //           ),
                        //         ),
                        //         new Radio(
                        //           value: 1,
                        //           groupValue: _radioValue1,
                        //           onChanged: _handleRadioValueChange1,
                        //         ),
                        //         new Text(
                        //           Constants.private,
                        //           style: new TextStyle(
                        //             fontSize: 16.0,
                        //             fontFamily: "open_saucesans_regular",
                        //             fontWeight: FontWeight.w400,
                        //             color: AppColors.darkTextColor,
                        //           ),
                        //         ),
                        //       ],
                        //     )
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.transparent,
                  margin: EdgeInsets.symmetric(vertical: 20.0),
                  width: MediaQuery.of(context).size.width,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    onPressed: () {
                      if (checkValidation() && widget.cardType == text) {
                        Utilities.show(context);
                        createCardWithTextOnly();
                      } else if (checkValidation()) {
                        Utilities.show(context);
                        creatCardWithFile();
                      }
                    },
                    color: AppColors.darkTextColor,
                    textColor: Colors.white,
                    padding: EdgeInsets.all(12.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(Constants.publishCard.toUpperCase(),
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            fontFamily: "open_saucesans_regular",
                          )),
                    ),
                  ),
                ),
              ]),
        ));
  }

  bool checkValidation() {
    if (categoryList.length == 0) {
      Constants().errorToast(context, "Please select category");
      return false;
    }
    // else if (subcategoryList.length == 0) {
    //   Constants().errorToast(context, "Please select sub category");
    //   return false;
    // }
    else if (toolsList.length == 0) {
      Constants().errorToast(context, "Please select tools to be used.");
      return false;
    } else if (settingsList.length == 0) {
      Constants().errorToast(context, "Please select settings.");
      return false;
    }
    return true;
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
        .then((value) => {createFeed(value.id)})
        .catchError((onError) {
      Utilities.hide();
    });
  }

  void createFeed(String itemId) {
    FeedModel feedModel = new FeedModel();
    feedModel.itemId = itemId;
    feedModel.saveCount = 0;
    feedModel.timestamp = Timestamp.now();
    feedModel.type = "Card";
    feedModel.userId = globalUserId;
    feedModel.viewCount = [];

    FirebaseFirestore.instance
        .collection(Constants.feedsColl)
        .add(feedModel.toJson())
        .then((value) => {
              Utilities.hide(),
              Constants().successToast(context, "Card is created successfully"),
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(currentIndex: 0,)),
                  (route) => false)
            })
        .catchError((onError) {
      Utilities.hide();
    });
  }

  void creatCardWithFile() {
    if (widget.cardType == image) {
      for (int i = 0; i < widget.files.length; i++) {
        uploadFiles(widget.files[i], i);
      }
    } else {
      for (int i = 0; i < widget.mediaList.length; i++) {
        uploadThumbnail(widget.mediaList[i].keys.elementAt(0), i);
      }
    }
  }

  uploadThumbnail(File file, int index) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var reference = FirebaseStorage.instance
        .ref()
        .child(Constants.cardVideos)
        .child(fileName);
    UploadTask uploadTask = reference.putFile(File(file.path));
    uploadTask.whenComplete(() {
      reference.getDownloadURL().then((downloadUrl) {
        mediaModel.thumbnail = downloadUrl;
        uploadVideo(widget.mediaList[index][file], index);
      }).catchError((onError) {
        Utilities.hide();
        Constants().errorToast(context, "$onError , please upload image again");
      });
    });
  }

  uploadVideo(File file, int index) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var reference = FirebaseStorage.instance
        .ref()
        .child(Constants.cardVideos)
        .child(fileName);
    UploadTask uploadTask = reference.putFile(file);
    uploadTask.whenComplete(() {
      reference.getDownloadURL().then((downloadUrl) {
        mediaModel.fileUrl = downloadUrl;
        mediaFiles.add(mediaModel);
        if (index == widget.mediaList.length - 1) {
          createCardWithTextOnly();
        }
      }).catchError((onError) {
        Utilities.hide();
        Constants().errorToast(context, "$onError , please upload video again");
      });
    });
  }

  uploadFiles(File file, int index) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance
        .ref()
        .child(Constants.cardImages)
        .child(fileName);
    UploadTask uploadTask = reference.putFile(file);
    uploadTask.whenComplete(() {
      reference.getDownloadURL().then((downloadUrl) {

        mediaFiles.add(Media(fileUrl: downloadUrl, thumbnail: ""));
        if (index == widget.files.length - 1) {
          createCardWithTextOnly();
        }
      }).catchError((onError) {
        Utilities.hide();
        Constants().errorToast(context, "$onError , please upload image again");
      });
    });
  }
}
