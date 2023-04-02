import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solstice/pages/onboardingflow/personal_Info_Screen.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/utilities.dart';

import 'geoLoaction_two.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({Key key}) : super(key: key);

  @override
  _GenderSelectionScreenState createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  bool male = true;
  bool female = false;
  bool others = false;
  String heightUnit = "FT";
  String feet = "FT";
  String centim = "CM";

  String weightUnit = "LB";
  String lb = "LB";
  String kg = "KG";
  String gender = "M";
  TextEditingController ageController = new TextEditingController();
  TextEditingController height1Controller = new TextEditingController();
  TextEditingController weightController = new TextEditingController();
  TextEditingController height2Controller = new TextEditingController();

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
              padding: const EdgeInsets.only(top: 40, left: 91, right: 90),
              child: Text(
                'Tell us a little bit about yourself',
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
                'For Solstice’s algorithms to curate useful workouts & relevant content, we need to know some details about you',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFF868686),
                    fontFamily: Utils.fontfamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                male = true;
                female = false;
                others = false;
                gender = "M";
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 50, left: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        height: 46,
                        width: 150,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(47),
                            border: Border.all(
                                color: male ? Utils.buttonColor : AppColors.blueColor, width: 1),
                            color: male ? Utils.buttonColor : Color(0XFFFFFFFF)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ImageIcon(
                              AssetImage(
                                Utils.maleIcon,
                              ),
                              color: male ? Color(0xFFFFFFFF) : AppColors.blueColor,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Utils.text(
                                'Male',
                                Utils.fontfamilyInter,
                                male ? Color(0xFFFFFFFF) : AppColors.blueColor,
                                FontWeight.w600,
                                13),
                          ],
                        )),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        male = false;
                        female = true;
                        others = false;
                        gender = "F";
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Container(
                            height: 46,
                            width: 150,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(47),
                                border: Border.all(color: Color(0xFF338BEF), width: 0.67),
                                color: female ? Utils.buttonColor : Color(0XFFFFFFFF)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ImageIcon(
                                  AssetImage(
                                    Utils.femaleIcon,
                                  ),
                                  color: female ? Colors.white : AppColors.blueColor,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Utils.text('Female', Utils.fontfamilyInter,
                                    female ? Colors.white : Color(0xFF338BEF), FontWeight.w400, 13),
                              ],
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                male = false;
                female = false;
                others = true;
                gender = "O";
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 11, left: 108, right: 117),
                child: Container(
                    height: 46,
                    width: 150,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(47),
                        border: Border.all(color: Color(0xFF338BEF), width: 0.67),
                        color: others ? Utils.buttonColor : Color(0XFFFFFFFF)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ImageIcon(
                          AssetImage(
                            Utils.otherIcon,
                          ),
                          color: others ? Colors.white : AppColors.blueColor,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Utils.text('Other', Utils.fontfamilyInter,
                            others ? Colors.white : Color(0xFF338BEF), FontWeight.w400, 13),
                      ],
                    )),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 24, right: 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 50,
                                ),
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Color(0xFFE8E8E8), width: 1),
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(top: 42, left: 20, right: 0),
                                  child: Container(
                                    child: Utils.text('Height', Utils.fontfamily, Color(0xFF1E263C),
                                        FontWeight.w400, 14),
                                    padding: EdgeInsets.symmetric(horizontal: 3),
                                    color: Colors.white,
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(top: 55, left: 20, right: 0),
                                child: Container(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: TextField(
                                            maxLines: 1,
                                            controller: height1Controller,
                                            decoration: InputDecoration(
                                                hintText: '6',
                                                contentPadding: EdgeInsets.all(0),
                                                border: InputBorder.none,
                                                hintStyle: TextStyle(
                                                    fontSize: 14.0, color: AppColors.hintTextColor),
                                                labelStyle: TextStyle(
                                                    fontSize: 14.0,
                                                    color: AppColors.darkTextColor)),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1.0,
                                        color: AppColors.viewColorGrey,
                                        height: 25,
                                      ),
                                      Expanded(
                                        child: TextField(
                                          maxLines: 1,
                                          controller: height2Controller,
                                          decoration: InputDecoration(
                                              hintText: '0',
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.all(0),
                                              labelStyle: TextStyle(
                                                  fontSize: 14.0, color: AppColors.darkTextColor),
                                              hintStyle: TextStyle(
                                                  fontSize: 14.0, color: AppColors.hintTextColor)),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            heightUnit = feet;
                                            setState(() {});
                                          },
                                          child: Text('FT',
                                              style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: heightUnit == feet
                                                      ? AppColors.darkTextColor
                                                      : AppColors.hintTextColor)),
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            heightUnit = centim;
                                            setState(() {});
                                          },
                                          child: Text('CM',
                                              style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: heightUnit == centim
                                                      ? AppColors.darkTextColor
                                                      : AppColors.hintTextColor)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 19,
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 50,
                                ),
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Color(0xFFE8E8E8), width: 1),
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 42, left: 20, right: 0),
                                child: Container(
                                  child: Utils.text('Weight', Utils.fontfamily, Color(0xFF1E263C),
                                      FontWeight.w400, 14),
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 55, left: 20, right: 0),
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 50,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: TextField(
                                            controller: weightController,
                                            maxLines: 1,
                                            decoration: InputDecoration(
                                                hintText: '5',
                                                contentPadding: EdgeInsets.all(0),
                                                border: InputBorder.none,
                                                counterText: '',
                                                hintStyle: TextStyle(
                                                    fontSize: 14.0, color: AppColors.hintTextColor),
                                                labelStyle: TextStyle(
                                                    fontSize: 14.0,
                                                    color: AppColors.darkTextColor)),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1.0,
                                        color: AppColors.viewColorGrey,
                                        height: 25,
                                        margin: EdgeInsets.symmetric(horizontal: 20),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            weightUnit = lb;
                                            setState(() {});
                                          },
                                          child: Text(lb,
                                              style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: weightUnit == lb
                                                      ? AppColors.darkTextColor
                                                      : AppColors.hintTextColor)),
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            weightUnit = kg;
                                            setState(() {});
                                          },
                                          child: Text(kg,
                                              style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: weightUnit == kg
                                                      ? AppColors.darkTextColor
                                                      : AppColors.hintTextColor)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 19,
                  ),
                  Container(
                    width: 150,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 50,
                          ),
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFE8E8E8), width: 1),
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 42, left: 20, right: 0),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Utils.text(
                                'Age', Utils.fontfamily, Color(0xFF1E263C), FontWeight.w400, 14),
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          // alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 55, right: 0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Center(
                                  // alignment: Alignment.center,
                                  child: TextField(
                                    maxLines: 1,
                                    controller: ageController,
                                    decoration: InputDecoration(
                                        hintText: '27',
                                        contentPadding: EdgeInsets.all(0),
                                        border: InputBorder.none,
                                        counterText: '',
                                        hintStyle: TextStyle(
                                            fontSize: 14.0, color: AppColors.hintTextColor),
                                        labelStyle: TextStyle(
                                            fontSize: 14.0, color: AppColors.darkTextColor)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Container(
                                width: 1.0,
                                color: AppColors.viewColorGrey,
                                height: 25,
                                margin: EdgeInsets.only(right: 20),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text('YRS',
                                    style:
                                        TextStyle(fontSize: 14.0, color: AppColors.darkTextColor)),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: InkWell(
                onTap: () {
                  saveUserData();
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
                      child: Utils.text(
                          'Continue', Utils.fontfamily, Color(0xFFFFFFFF), FontWeight.w400, 18)),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Utils.saveSkipScreenName("GenderSelectionScreen", context);
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 34),
                child: Utils.text(
                    'Skip for now', Utils.fontfamily, Utils.buttonColor, FontWeight.w600, 15),
              ),
            )
          ]),
        ),
      ),
    );
  }

// save user gender, weight, height,age and profile complete status 0
  saveUserData() {
    FirebaseFirestore.instance.collection(Constants.UsersFB).doc(globalUserId).update({
      'profileComplete': 0,
      "gender": gender,
      "weightUnit": weightUnit,
      "weight": weightController.text.toString(),
      "height": height1Controller.text.toString(),
      "height2": height2Controller.text.toString(),
      "heightUnit": heightUnit,
      "age": ageController.text.toString(),
    }).then((docRef) {
      goToNext();
    });
  }

  void goToNext() {
    Navigator.push(
        context, MaterialPageRoute(builder: (BuildContext context) => PersonalinfoScreen()));
  }
}
