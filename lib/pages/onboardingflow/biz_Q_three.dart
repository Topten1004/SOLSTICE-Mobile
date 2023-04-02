import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solstice/model/forum_model_new.dart';
import 'package:solstice/model/select_filter_model.dart';
import 'package:solstice/pages/home_screen.dart';
import 'package:solstice/pages/onboardingflow/Profile_user.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/shared_preferences.dart';
import 'package:solstice/utils/utilities.dart';

import 'challangesScreen.dart';

class BizQ3Screen extends StatefulWidget {
  const BizQ3Screen({Key key}) : super(key: key);

  @override
  _BizQ3ScreenState createState() => _BizQ3ScreenState();
}

class _BizQ3ScreenState extends State<BizQ3Screen> {
  bool asthetics = false;
  List<SelectFilterModel> categoriesList = new List.empty(growable: true);
  List<String> selectedList = new List.empty(growable: true);
  TextEditingController otherController = new TextEditingController();
  List<int> text = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
  ];

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  void getCategories() async {
    var collectionReference = FirebaseFirestore.instance
        .collection(Constants.trainingCategories)
        .get();
    collectionReference.then((value) {
      final List<DocumentSnapshot> docs = value.docs;
      docs.forEach((data) {
        SelectFilterModel selectFilterModel =
            SelectFilterModel.fromJson(data.data());
        selectFilterModel.id = data.id;
        categoriesList.add(selectFilterModel);
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
              child:
                  Image.asset("assets/images/help.png", height: 26, width: 26)),
        )
      ],
    );
    return SafeArea(
      child: Scaffold(
        appBar: appBar,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(children: [
            Text(
              'Tell us more \nabout your brand',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xFF1F1F1F),
                  fontWeight: FontWeight.normal,
                  fontFamily: Utils.fontfamily,
                  fontSize: 24),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 19, left: 48, right: 47),
              child: Text(
                'Tell us what type of users you are looking \nto connect with on the Solstice platform.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF868686),
                  fontFamily: Utils.fontfamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
              child: Container(
                child: Wrap(
                  children: [
                    for (int i = 0; i < categoriesList.length; i++)
                      InkWell(
                        onTap: () {
                          setState(() {
                            categoriesList[i].isSelected =
                                !categoriesList[i].isSelected;
                          });
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 12, right: 3, left: 0),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            height: 39,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                border:
                                    Border.all(color: Colors.blue, width: 1),
                                color: categoriesList[i].isSelected
                                    ? AppColors.blueColor
                                    : Colors.white),
                            child: Text(
                              categoriesList[i].title,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: Utils.fontfamilyInter,
                                  fontSize: 14,
                                  color: categoriesList[i].isSelected
                                      ? Colors.white
                                      : AppColors.blueColor),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 25,
                      ),
                      child: Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 8, right: 8, top: 25),
                            height: 56,
                            // width: MediaQuery.of(context).size.width*0.80,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color(0XFFE8E8E8), width: 1),
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 15, left: 20, right: 133),
                            child: Container(
                              height: 17,
                              width: 153,
                              child: Center(
                                child: Utils.text(
                                    'Other (Please Specify)',
                                    Utils.fontfamily,
                                    Color(0xFF1E263C),
                                    FontWeight.w400,
                                    14),
                              ),
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 45, right: 50, left: 28),
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
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 109, left: 24, right: 24, bottom: 90),
              child: InkWell(
                onTap: () {
                  saveBusinessData();
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
                      child: Utils.text('Save and Complete', Utils.fontfamily,
                          Color(0xFFFFFFFF), FontWeight.w400, 18)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  saveBusinessData() {
    Utilities.show(context);
    for (int j = 0; j < categoriesList.length; j++) {
      if (categoriesList[j].isSelected) {
        selectedList.add(categoriesList[j].title);
      }
    }

    BusinessBrand businessBrand = new BusinessBrand(
        other: otherController.text.toString(), brandList: selectedList);
    FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(globalUserId)
        .update({
      'businessBrand': businessBrand.toMap(),
      'profileComplete': 1
    }).then((docRef) {
       SharedPref.saveIntInPrefs(
            Constants.PROFILE_COMEPLETE, 1);
      profileCompleteStatus = 1;
      Constants().successToast(context, "Profile completed succesfully");
      Utilities.hide();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => HomeScreen(
                    currentIndex: 0,
                  )),
          (route) => false);
    }).catchError((onError) {
      Utilities.hide();
    });
  }
}
