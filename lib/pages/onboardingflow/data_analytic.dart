import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:solstice/pages/onboardingflow/profiletypescreen.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/utils/constants.dart';

import 'gender_selection.dart';

class Dataanalytic extends StatefulWidget {
  const Dataanalytic({Key key}) : super(key: key);

  @override
  _DataanalyticState createState() => _DataanalyticState();
}

class _DataanalyticState extends State<Dataanalytic> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Image(
                image: AssetImage(Utils.dataanylaticalImage),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular((20.0)),
                    topRight: Radius.circular(20.0),
                  ),
                  color: Color(0xFFFFFFFF),
                ),
                
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 45),
                      child: Text(
                        'Data & Analytics Tracking',
                        style: TextStyle(
                            fontFamily: Utils.fontfamily,
                            fontSize: 16,
                            color: Color(0xFF000000),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 21, left: 46, right: 46),
                      child: Center(
                          child: Text(
                        'Solstice uses your in-app behavior and data to enhance the personalized routine & wellness content recommendations.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: Utils.fontfamily,
                            fontSize: 16,
                            color: Color(0xFF868686),
                            fontWeight: FontWeight.normal),
                      )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: InkWell(
                        onTap: () {
                          saveData(true);
                        },
                        child: Container(
                          height: 55,
                          width: 251,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10), color: Color(0xFF283646)),
                          child: Center(
                              child: Text(
                            'Allow App Use Tracking',
                            style: TextStyle(
                                fontFamily: Utils.fontfamily,
                                fontWeight: FontWeight.w600,
                                color: Utils.signinColor),
                          )),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        saveData(false);
                      },
                      child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Utils.text(
                              'Not Now', Utils.fontfamily, Utils.notNowColor, FontWeight.w400, 14)),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void saveData(bool permisType) {
    // if (imageUrl.isEmpty) {
    //   Utilities.show(context);
    // }
    FirebaseFirestore.instance.collection(Constants.UsersFB).doc(globalUserId).update({
      'allow_app_use_tracking': permisType,
    }).then((docRef) {
      // SharedPref.saveStringInPrefs(Constants.location. imageUrl);
      Navigator.push(
          context, MaterialPageRoute(builder: (BuildContext context) => ProfileTypeScreen()));
    });
  }
}
