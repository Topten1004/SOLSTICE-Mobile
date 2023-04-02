import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:solstice/model/select_filter_model.dart';
import 'package:solstice/utils/constants.dart';

class SelectFilterPage extends StatefulWidget {
  String viewType = "";
  String collectionType = "";
  List<SelectFilterModel> categoryList;
  List<String> idList = new List.empty(growable: true);
  List<String> selectedFiltersList;

  SelectFilterPage(this.viewType, this.collectionType,
      {this.categoryList, this.selectedFiltersList});
  @override
  _SelectFilterPageState createState() => _SelectFilterPageState();
}

class _SelectFilterPageState extends State<SelectFilterPage> {
  List<SelectFilterModel> filterList = new List.empty(growable: true);
  List<SelectFilterModel> searchFilterList = new List.empty(growable: true);
  TextEditingController searchController = new TextEditingController();
  @override
  void initState() {
    super.initState();
    getFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: Row(children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(width: 20),
                      Text("Choose " + widget.viewType,
                          style: TextStyle(
                              fontFamily: Constants.openSauceFont,
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w700))
                    ]),
                  ),
                  SizedBox(height: 10),
                  Container(
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
                                controller: searchController,
                                onChanged: (text) {
                                  if (text.length == 0) {
                                    text = "";
                                    searchFilterList.clear();
                                  } else {
                                    applySearch();
                                  }
                                  setState(() {});
                                },
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
                              ),
                            ),
                          ),
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      elevation: 0.5,
                      margin: EdgeInsets.all(10),
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      // padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (searchFilterList.length > 0) {
                                searchFilterList[index].isSelected =
                                    !searchFilterList[index].isSelected;
                              } else {
                                filterList[index].isSelected = !filterList[index].isSelected;
                              }
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                  color: Colors.white,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                            searchFilterList.length > 0
                                                ? searchFilterList[index].title ?? ""
                                                : filterList[index].title ?? "",
                                            style: TextStyle(
                                                fontFamily: Constants.openSauceFont,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                      Visibility(
                                        visible: searchFilterList.length > 0
                                            ? filterList[index].isSelected
                                                ? true
                                                : false
                                            : filterList[index].isSelected
                                                ? true
                                                : false,
                                        maintainSize: true,
                                        maintainState: true,
                                        maintainAnimation: true,
                                        child: Image.asset("assets/images/checked_cat.png",
                                            height: 24, width: 24),
                                      )
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
                      itemCount:
                          searchFilterList.length > 0 ? searchFilterList.length : filterList.length,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.transparent,
              margin: EdgeInsets.only(bottom: 20),
              width: 120,
              height: 50,
              child: RaisedButton(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(45.0),
                ),
                onPressed: () {
                  List<SelectFilterModel> selectedList = new List.empty(growable: true);
                  for (int i = 0; i < filterList.length; i++) {
                    if (filterList[i].isSelected) {
                      selectedList.add(filterList[i]);
                    }
                    if (filterList.length - 1 == i) {
                      if (widget.viewType == Constants.category) {
                        Navigator.pop(context, {
                          "categoryList": selectedList,
                        });
                      } else if (widget.viewType == Constants.subCategory) {
                        Navigator.pop(context, {
                          "subCategoryList": selectedList,
                        });
                      } else if (widget.viewType == Constants.tools) {
                        Navigator.pop(context, {
                          "toolsList": selectedList,
                        });
                      } else if (widget.viewType == Constants.settings) {
                        Navigator.pop(context, {
                          "settingsList": selectedList,
                        });
                      }
                    }
                  }
                },
                color: AppColors.darkTextColor,
                textColor: Colors.white,
                padding: EdgeInsets.all(12.0),
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: Text(Constants.doneText.toUpperCase(),
                      style: TextStyle(
                        fontSize: 15.0,
                        fontFamily: Constants.openSauceFont,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  void getFilters() async {
    var collectionReference;

    if (widget.collectionType == "TrainingSubCategory") {
      getId();
      // collectionReference = FirebaseFirestore.instance
      //     .collection(widget.collectionType)
      //     .where("training_category_id", arrayContainsAny: [
      //   "5Hh0t3rD5KLCtCojNZEs",
      //   "IJbeyOI3sMYbONWuAHMH"
      // ]).get();
      for (int i = 0; i < widget.idList.length; i++) {
        collectionReference = FirebaseFirestore.instance
            .collection(widget.collectionType)
            .where("training_category_id", isEqualTo: widget.idList[i])
            .get();
        getData(collectionReference);
      }
    } else {
      collectionReference = FirebaseFirestore.instance.collection(widget.collectionType).get();
      getData(collectionReference);
    }
  }

  void getData(collectionReference) {
    collectionReference.then((value) {
      final List<DocumentSnapshot> docs = value.docs;
      docs.forEach((data) {
        SelectFilterModel selectFilterModel = SelectFilterModel.fromJson(data.data());
        selectFilterModel.id = data.id;
        filterList.add(selectFilterModel);
        if (data.id == value.docs[value.docs.length - 1].id) {
          for (int i = 0; i < filterList.length; i++) {
            for (int j = 0; j < widget.selectedFiltersList.length; j++) {
              if (filterList[i].title == widget.selectedFiltersList[j]) {
                filterList[i].isSelected = true;
              }
            }
          }
          setState(() {});
        }
      });
    }).catchError((onError) {
    });
  }

  List<String> getId() {
    for (int i = 0; i < widget.categoryList.length; i++) {
      widget.idList.add(widget.categoryList[i].id);
    }
    return widget.idList;
  }

  void applySearch() {
    searchFilterList.clear();
    if (searchController.text.isNotEmpty) {
      if (widget.collectionType == Constants.tools) {
        for (int i = 0; i < filterList.length; i++) {
          if (filterList[i]
              .searchTitle
              .toLowerCase()
              .trim()
              .contains(searchController.text.toLowerCase().trim())) {
            searchFilterList.add(filterList[i]);
          }
        }
      } else {
        for (int i = 0; i < filterList.length; i++) {
          if (filterList[i]
              .title
              .toLowerCase()
              .trim()
              .contains(searchController.text.toLowerCase().trim())) {
            searchFilterList.add(filterList[i]);
          }
        }
      }
    }
  }
}
