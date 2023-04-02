import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solstice/model/forum_model_new.dart';
import 'package:solstice/model/select_filter_model.dart';
import 'package:solstice/pages/filters/select_filters.dart';
import 'package:solstice/pages/onboardingflow/injury_History_Screen_updated.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/utils/constants.dart';

class IntrestsScreenUpdated extends StatefulWidget {
  const IntrestsScreenUpdated({Key key}) : super(key: key);

  @override
  _IntrestsScreenUpdatedState createState() => _IntrestsScreenUpdatedState();
}

class _IntrestsScreenUpdatedState extends State<IntrestsScreenUpdated> {
  bool asthetics = false;
  List<SelectFilterModel> categoryList = new List.empty(growable: true);
  List<String> selectedCatText = new List.empty(growable: true);
  List<SelectFilterModel> selectedCategoryList = new List.empty(growable: true);

  List<SelectFilterModel> subcategoryList = new List.empty(growable: true);
  List<String> selectedSubCatText = new List.empty(growable: true);
  List<SelectFilterModel> selectedSubCategoryList = new List.empty(growable: true);
  UserInterests userInterests;
  TextEditingController otherController = new TextEditingController();
  @override
  void initState() {
    super.initState();
    getCategories();
  }

  void getCategories() async {
    var collectionReference =
        FirebaseFirestore.instance.collection(Constants.trainingCategories).get();
    collectionReference.then((value) {
      final List<DocumentSnapshot> docs = value.docs;
      docs.forEach((data) {
        SelectFilterModel selectFilterModel = SelectFilterModel.fromJson(data.data());
        selectFilterModel.id = data.id;
        categoryList.add(selectFilterModel);
        if (data.id == value.docs[value.docs.length - 1].id) {
          setState(() {});
        }
      });
    }).catchError((onError) {
    });
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
        // onPressed: () {},
        onPressed: () => Navigator.of(context).pop(),
      ),
      elevation: 0,
      actions: [
        Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Image.asset("assets/images/help.png", height: 26, width: 26)),
        )
      ],
    );
    return SafeArea(
      child: Scaffold(
        appBar: appBar,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 91, right: 90),
              child: Text(
                'Tell us about\nyour interests',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFF1F1F1F),
                    fontWeight: FontWeight.normal,
                    fontFamily: Utils.fontfamily,
                    fontSize: 24),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 19, left: 48, right: 47),
              child: Text(
                'Which activities do you spend the most \ntime on? What matters most to you? Select \nall that apply.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF868686),
                  fontFamily: Utils.fontfamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              width: MediaQuery.of(context).size.width,
              child: Text(
                Constants.category,
                style: TextStyle(
                    fontFamily: "open_saucesans_regular",
                    color: Colors.black,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 15),
            Column(children: [
              InkWell(
                onTap: () async {
                  var result = await Navigator.push(
                      context,
                      new MaterialPageRoute(
                        builder: (BuildContext context) => new SelectFilterPage(
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
                      for (int j = 0; j < selectedCategoryList.length; j++) {
                        if (categoryList[i].id == selectedCategoryList[j].id) {
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
                    getSubCategory(Constants.trainingSubCategories, selectedCategoryList[i].id);
                  }

                  setState(() {});
                },
                child: Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
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
                margin: EdgeInsets.only(left: 20, right: 20),
                height: 0.5,
                width: MediaQuery.of(context).size.width,
                color: AppColors.lightGreyColor,
              )
            ]),
            SizedBox(height: 20),
            Container(
              height: 30,
              margin: EdgeInsets.only(left: 10, right: 10),
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryList.length,
                  itemBuilder: (BuildContext context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (categoryList[index].isSelected) {
                            categoryList[index].isSelected = false;
                            for (int j = 0; j < selectedCatText.length; j++) {
                              if (selectedCatText[j] == categoryList[index].title) {
                                selectedCatText.removeAt(j);
                                selectedCategoryList.remove(categoryList[index]);
                              }
                            }
                          } else {
                            categoryList[index].isSelected = true;
                            selectedCategoryList.add(categoryList[index]);
                            selectedCatText.add(categoryList[index].title);
                          }

                          subcategoryList.clear();
                          selectedSubCatText.clear();
                          for (int i = 0; i < selectedCategoryList.length; i++) {
                            getSubCategory(
                                Constants.trainingSubCategories, selectedCategoryList[i].id);
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0),
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            color:
                                categoryList[index].isSelected ? AppColors.blueColor : Colors.white,
                            border: Border.all(color: AppColors.blueColor),
                            borderRadius: BorderRadius.all(Radius.circular(48))),
                        child: Row(
                          children: [
                            Icon(
                              categoryList[index].isSelected ? Icons.check : Icons.add,
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
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Text(
                Constants.subCategory,
                style: TextStyle(
                    fontFamily: "open_saucesans_regular",
                    color: Colors.black,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 15),
            Column(children: [
              InkWell(
                onTap: () async {
                  if (selectedCategoryList.length > 0) {
                    var result = await Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) => new SelectFilterPage(
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
                        for (int j = 0; j < selectedSubCategoryList.length; j++) {
                          if (subcategoryList[i].id == selectedSubCategoryList[j].id) {
                            subcategoryList[i].isSelected = true;
                            selectedSubCatText.add(subcategoryList[i].title);
                          }
                        }
                      }
                    } else {
                      selectedSubCategoryList.clear();
                    }
                  } else {
                    Constants().errorToast(context, "Please select category first");
                  }
                  setState(() {});
                },
                child: Container(
                    height: 20,
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: selectedSubCatText.length > 0
                        ? ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: selectedSubCatText.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Container(
                                child: Text(selectedSubCatText[index] + ","),
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
                margin: EdgeInsets.only(left: 20, right: 20),
                width: MediaQuery.of(context).size.width,
                color: AppColors.lightGreyColor,
              )
            ]),
            SizedBox(height: 20),
            Container(
              height: 30,
              margin: EdgeInsets.only(left: 10, right: 10),
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: subcategoryList.length,
                  itemBuilder: (BuildContext context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (subcategoryList[index].isSelected) {
                            subcategoryList[index].isSelected = false;
                            for (int j = 0; j < selectedSubCatText.length; j++) {
                              if (selectedSubCatText[j] == subcategoryList[index].title) {
                                selectedSubCatText.removeAt(j);
                                selectedSubCategoryList.remove(subcategoryList[index]);
                              }
                            }
                          } else {
                            subcategoryList[index].isSelected = true;
                            selectedSubCategoryList.add(subcategoryList[index]);
                            selectedSubCatText.add(subcategoryList[index].title);
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
                            border: Border.all(color: AppColors.blueColor),
                            borderRadius: BorderRadius.all(Radius.circular(48))),
                        child: Row(
                          children: [
                            Icon(
                              subcategoryList[index].isSelected ? Icons.check : Icons.add,
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
            Padding(
                padding: const EdgeInsets.only(
                  top: 25,
                ),
                child: Stack(children: [
                  Container(
                    margin: EdgeInsets.only(left: 8, right: 8, top: 25),
                    height: MediaQuery.of(context).size.height * 0.08,
                    // width: MediaQuery.of(context).size.width*0.80,
                    decoration: BoxDecoration(
                        border: Border.all(color: Color(0XFFE8E8E8), width: 1),
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 20, right: 133),
                    child: Container(
                      height: 17,
                      width: 153,
                      child: Center(
                        child: Utils.text('Other (Please Specify)', Utils.fontfamily,
                            Color(0xFF1E263C), FontWeight.w400, 14),
                      ),
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 45, right: 70, left: 28),
                    child: TextField(
                      controller: otherController,
                      decoration: new InputDecoration.collapsed(
                        focusColor: Color(0xFFB9BAC8),
                        hintText: 'Marathon Training, Race Training',
                        hintStyle: TextStyle(
                            fontFamily: Utils.fontfamily,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0XFFB9BAC8)),
                      ),
                    ),
                  )
                ])),
            Padding(
              padding: const EdgeInsets.only(top: 130, left: 24, right: 24),
              child: InkWell(
                onTap: () {
                  saveInterest();
                },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFF283646),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF434344).withOpacity(0.07),
                        spreadRadius: 1,
                        blurRadius: 13,
                        offset: Offset(0, 15), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Center(
                      child: Utils.text(
                          'Continue', Utils.fontfamily, Color(0xFFFFFFFF), FontWeight.w400, 18)),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Utils.saveSkipScreenName("PersonalinfoScreen", context);
              },
              child: Container(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 34, bottom: 40),
                  child: Utils.text(
                      'Skip for now', Utils.fontfamily, Utils.buttonColor, FontWeight.w600, 15),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }

  void getSubCategory(String trainingSubCategories, categoryId) {
    var collectionReference = FirebaseFirestore.instance
        .collection(trainingSubCategories)
        .where("training_category_id", isEqualTo: categoryId)
        .get();
    collectionReference.then((value) {
      final List<DocumentSnapshot> docs = value.docs;
      docs.forEach((data) {
        SelectFilterModel selectFilterModel = SelectFilterModel.fromJson(data.data());
        selectFilterModel.id = data.id;
        subcategoryList.add(selectFilterModel);
        if (data.id == value.docs[value.docs.length - 1].id) {
          setState(() {});
        }
      });
    }).catchError((onError) {
    });
  }

  saveInterest() {
    userInterests = UserInterests(
        categoriesList: selectedCategoryList,
        subCategoriesList: subcategoryList,
        categoriesTitleList: selectedCatText,
        subCategoriesTitleList: selectedSubCatText,
        other: otherController.text.toString());

    FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(globalUserId)
        .update({"user_interest": userInterests.toMap(), "profileComplete": 0}).then((docRef) {
      goToNext();
    });
  }

  goToNext() {
    Navigator.push(
        context, MaterialPageRoute(builder: (BuildContext context) => InjuryHealthScreenUpdated()));
  }
}
