import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solstice/model/card_title_model.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/model/select_filter_model.dart';
import 'package:solstice/pages/cards/numerical_inputs.dart';
import 'package:solstice/pages/filters/select_filters.dart';
import 'package:solstice/utils/constants.dart';

class QuickCardPage extends StatefulWidget {
  @override
  _QuickCardPageState createState() => _QuickCardPageState();
}

class _QuickCardPageState extends State<QuickCardPage> {
  List<SelectFilterModel> selectedTitleList = new List.empty(growable: true);
  List<CardTitleModel> titleList = new List.empty(growable: true);
  String docField = "";
  bool selectedFromList = false;
  TextEditingController titleController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();

  List<SelectFilterModel> subcategoryList = new List.empty(growable: true);
  List<String> selectedSubCatText = new List.empty(growable: true);
  List<SelectFilterModel> selectedSubCategoryList =
      new List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    getTitles(Constants.cardTitles);
    // getSubCategory(Constants.trainingSubCategories);
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
                    Constants.createCard,
                    style: TextStyle(
                        fontFamily: "open_saucesans_regular",
                        color: Colors.black,
                        fontSize: 24.0,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 40),
                  Text(
                    Constants.title,
                    style: TextStyle(
                        fontFamily: "open_saucesans_regular",
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700),
                  ),
                  Column(children: [
                    InkWell(
                        onTap: () async {},
                        child: Container(
                          child: TextField(
                            controller: titleController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter a title...',
                            ),
                            onChanged: (text) {
                              if (selectedFromList &&
                                  titleController.text.length > 0) {
                                selectedFromList = false;
                                titleController.clear();
                                setState(() {
                                  unselectAllTitles();
                                });
                              }
                            },
                            style: TextStyle(
                              color: AppColors.darkTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              fontFamily: "open_saucesans_regular",
                            ),
                          ),
                        )),
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
                        itemCount: titleList.length,
                        itemBuilder: (BuildContext context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                unselectAllTitles();
                                titleList[index].isTitleSelected = true;

                                titleController.clear();
                                titleController.text = titleList[index].title;
                                selectedFromList = true;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 8.0, right: 8.0),
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                  color: titleList[index].isTitleSelected
                                      ? AppColors.blueColor
                                      : Colors.white,
                                  border:
                                      Border.all(color: AppColors.blueColor),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(48))),
                              child: Row(
                                children: [
                                  Icon(
                                    titleList[index].isTitleSelected
                                        ? Icons.check
                                        : Icons.add,
                                    size: 14,
                                    color: titleList[index].isTitleSelected
                                        ? Colors.white
                                        : AppColors.blueColor,
                                  ),
                                  SizedBox(width: 3),
                                  Text(titleList[index].title,
                                      style: TextStyle(
                                        color: titleList[index].isTitleSelected
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
                    Constants.describeYourJourney,
                    style: TextStyle(
                        fontFamily: "open_saucesans_regular",
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 0),
                  Container(
                      child: Container(
                    child: TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.greyTextColor),
                            ),
                            hintText: Constants.explainWorkout,
                            hintStyle: TextStyle(
                              color: AppColors.greyTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              fontFamily: "open_saucesans_regular",
                            ))),
                  )),
                ],
              ),
            )),
            InkWell(
              onTap: () {},
              child: Container(
                color: Colors.transparent,
                margin: EdgeInsets.symmetric(vertical: 20.0),
                width: MediaQuery.of(context).size.width,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  onPressed: () async {
                    if (titleController.text.isEmpty) {
                      Constants().errorToast(context, "Enter Title");
                    } else if (descriptionController.text.isEmpty) {
                      Constants().errorToast(context, "Enter Description");
                    } else {
                      var res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  NumericalInputsPage(
                                      showAppBar: true,
                                      title: titleController.text,
                                      description:
                                          descriptionController.text)));

                      if (res != null) {
                        Navigator.pop(context, {
                          "numericInputs": res['numericInputs'],
                          "title": res['title'],
                          "desc": res['desc'],
                        });
                      }
                    }
                  },
                  color: AppColors.darkTextColor,
                  textColor: Colors.white,
                  padding: EdgeInsets.all(12.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(Constants.next.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          fontFamily: "open_saucesans_regular",
                        )),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20)
          ],
        ),
      ),
    );
  }

  void getTitles(String collCategory) {
    var collectionReference =
        FirebaseFirestore.instance.collection(collCategory).get();
    collectionReference.then((value) {
      final List<DocumentSnapshot> docs = value.docs;
      docs.forEach((data) {
        titleList.add(CardTitleModel(
            id: data.id, title: data["title"], isTitleSelected: false));
        if (data.id == value.docs[value.docs.length - 1].id) {
          setState(() {});
        }
      });
    }).catchError((onError) {
    });
  }

  void getSubCategory(String trainingSubCategories) {
    var collectionReference =
        FirebaseFirestore.instance.collection(trainingSubCategories).get();
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

  void unselectAllTitles() {
    for (int j = 0; j < titleList.length; j++) {
      titleList[j].isTitleSelected = false;
    }
  }
}
