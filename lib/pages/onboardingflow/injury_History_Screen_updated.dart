import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solstice/model/forum_model_new.dart';
import 'package:solstice/model/select_filter_model.dart';
import 'package:solstice/pages/home_screen.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/shared_preferences.dart';
import 'package:solstice/utils/utilities.dart';

class InjuryHealthScreenUpdated extends StatefulWidget {
  const InjuryHealthScreenUpdated({Key key}) : super(key: key);

  @override
  _InjuryHealthScreenUpdatedState createState() => _InjuryHealthScreenUpdatedState();
}

class _InjuryHealthScreenUpdatedState extends State<InjuryHealthScreenUpdated> {
  List<SelectFilterModel> currentInjuriesList = new List.empty(growable: true);
  List<String> selectedCurrentInjuriesText = new List.empty(growable: true);
  List<SelectFilterModel> selectedcurrentInjuriesList = new List.empty(growable: true);

  List<SelectFilterModel> pastInjuriesList = new List.empty(growable: true);
  List<String> selectedPastInjuriesText = new List.empty(growable: true);
  List<SelectFilterModel> selectedPastInjuriesList = new List.empty(growable: true);

  InjuryHistory injuryHistory;
  TextEditingController otherController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  void getCategories() async {
    var collectionReference = FirebaseFirestore.instance
        .collection(Constants.trainingSubCategories)
        .where('training_category_id', isEqualTo: "5Hh0t3rD5KLCtCojNZEs")
        .get();
    collectionReference.then((value) {
      final List<DocumentSnapshot> docs = value.docs;
      docs.forEach((data) {
        SelectFilterModel selectFilterModel = SelectFilterModel.fromJson(data.data());
        selectFilterModel.id = data.id;
        currentInjuriesList.add(selectFilterModel);

        SelectFilterModel selectFilterModelPast = SelectFilterModel.fromJson(data.data());
        selectFilterModelPast.id = data.id;
        pastInjuriesList.add(selectFilterModelPast);
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
              child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 91, right: 90),
              child: Text(
                'Tell us about your injury history?',
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
                'Do you have any past or present injuries?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFF868686),
                    fontFamily: Utils.fontfamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(height: 30),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              width: MediaQuery.of(context).size.width,
              child: Text(
                "Describe Your Current Injuries",
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
                onTap: () async {},
                child: Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    height: 20,
                    child: selectedCurrentInjuriesText.length > 0
                        ? ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: selectedCurrentInjuriesText.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Container(
                                child: Text(selectedCurrentInjuriesText[index] + ","),
                              );
                            })
                        : Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Search injury...',
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
                  itemCount: currentInjuriesList.length,
                  itemBuilder: (BuildContext context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (currentInjuriesList[index].isSelected) {
                            currentInjuriesList[index].isSelected = false;
                            for (int j = 0; j < selectedCurrentInjuriesText.length; j++) {
                              if (selectedCurrentInjuriesText[j] ==
                                  currentInjuriesList[index].title) {
                                selectedCurrentInjuriesText.removeAt(j);
                                selectedcurrentInjuriesList.remove(currentInjuriesList[index]);
                              }
                            }
                          } else {
                            currentInjuriesList[index].isSelected = true;
                            selectedcurrentInjuriesList.add(currentInjuriesList[index]);
                            selectedCurrentInjuriesText.add(currentInjuriesList[index].title);
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0),
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            color: currentInjuriesList[index].isSelected
                                ? AppColors.blueColor
                                : Colors.white,
                            border: Border.all(color: AppColors.blueColor),
                            borderRadius: BorderRadius.all(Radius.circular(48))),
                        child: Row(
                          children: [
                            Icon(
                              currentInjuriesList[index].isSelected ? Icons.check : Icons.add,
                              size: 14,
                              color: currentInjuriesList[index].isSelected
                                  ? Colors.white
                                  : AppColors.blueColor,
                            ),
                            SizedBox(width: 3),
                            Text(currentInjuriesList[index].title,
                                style: TextStyle(
                                  color: currentInjuriesList[index].isSelected
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
              margin: EdgeInsets.only(left: 20, right: 20),
              width: MediaQuery.of(context).size.width,
              child: Text(
                "Describe Your Past Injuries",
                style: TextStyle(
                    fontFamily: "open_saucesans_regular",
                    color: Colors.black,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 15),
            Column(children: [
              Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  height: 20,
                  child: selectedPastInjuriesText.length > 0
                      ? ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: selectedPastInjuriesText.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Container(
                              child: Text(selectedPastInjuriesText[index] + ","),
                            );
                          })
                      : Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Search injury...',
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15.0,
                                fontFamily: "open_saucesans_regular",
                                fontWeight: FontWeight.w400),
                          ))),
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
                  itemCount: pastInjuriesList.length,
                  itemBuilder: (BuildContext context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (pastInjuriesList[index].isSelected) {
                            pastInjuriesList[index].isSelected = false;
                            for (int j = 0; j < selectedPastInjuriesText.length; j++) {
                              if (selectedPastInjuriesText[j] == pastInjuriesList[index].title) {
                                selectedPastInjuriesText.removeAt(j);
                                selectedPastInjuriesList.remove(pastInjuriesList[index]);
                              }
                            }
                          } else {
                            pastInjuriesList[index].isSelected = true;
                            selectedPastInjuriesList.add(pastInjuriesList[index]);
                            selectedPastInjuriesText.add(pastInjuriesList[index].title);
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0),
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            color: pastInjuriesList[index].isSelected
                                ? AppColors.blueColor
                                : Colors.white,
                            border: Border.all(color: AppColors.blueColor),
                            borderRadius: BorderRadius.all(Radius.circular(48))),
                        child: Row(
                          children: [
                            Icon(
                              pastInjuriesList[index].isSelected ? Icons.check : Icons.add,
                              size: 14,
                              color: pastInjuriesList[index].isSelected
                                  ? Colors.white
                                  : AppColors.blueColor,
                            ),
                            SizedBox(width: 3),
                            Text(pastInjuriesList[index].title,
                                style: TextStyle(
                                  color: pastInjuriesList[index].isSelected
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
            SizedBox(height: 30),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              width: MediaQuery.of(context).size.width,
              child: Text(
                "Other (Please Specify)",
                style: TextStyle(
                    fontFamily: "open_saucesans_regular",
                    color: Colors.black,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 15),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: TextField(
                decoration: new InputDecoration.collapsed(
                    focusColor: Color(0xFFB9BAC8),
                    hintText: 'eg. hairline fracture in left hand',
                    hintStyle: TextStyle(
                      fontFamily: Utils.fontfamily,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0XFFB9BAC8),
                    )),
              ),
            ),
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              height: 0.5,
              width: MediaQuery.of(context).size.width,
              color: AppColors.lightGreyColor,
            ),
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.only(
                top: 36,
              ),
              child: InkWell(
                onTap: () {
                  saveInjury();
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (BuildContext context) => IntrestsScreen()));
                },
                child: Container(
                  height: 56,
                  width: MediaQuery.of(context).size.width * 0.90,
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
                      child: Utils.text('Complete Profile', Utils.fontfamily, Color(0xFFFFFFFF),
                          FontWeight.w400, 18)),
                ),
              ),
            ),
          ]))),
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
        selectedcurrentInjuriesList.add(selectFilterModel);
        if (data.id == value.docs[value.docs.length - 1].id) {
          setState(() {});
        }
      });
    }).catchError((onError) {
    });
  }

  saveInjury() {
    Utilities.show(context);
    injuryHistory = InjuryHistory(
        injuriesList: selectedcurrentInjuriesList,
        injuriesTextList: selectedCurrentInjuriesText,
        other: otherController.text.toString(),
        pastInjuriesList: selectedPastInjuriesList,
        pastInjuriesTextList: selectedPastInjuriesText);

    FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(globalUserId)
        .update({"injury_history": injuryHistory.toMap(), "profileComplete": 1}).then((docRef) {
      Constants().successToast(context, "Profile completed successfully");
      goToNext();
    }).catchError((onError) {
      Utilities.hide();
    });
  }

  goToNext() {
    Utilities.hide();
     SharedPref.saveIntInPrefs(
            Constants.PROFILE_COMEPLETE, 1);
    profileCompleteStatus = 1;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                  currentIndex: 0,
                )),
        (route) => false);
    // Navigator.push(context,
    //     MaterialPageRoute(builder: (BuildContext context) => IntrestsScreen()));
  }
}
