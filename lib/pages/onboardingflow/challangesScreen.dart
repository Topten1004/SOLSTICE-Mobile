import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';

import 'data_analytic.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({Key key}) : super(key: key);

  @override
  _ChallengesScreenState createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  bool asthetics = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(children: [
            Container(
              height: 60,
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ImageIcon(AssetImage(Utils.arrowleftIcon)),
                  ImageIcon(AssetImage(Utils.helpIcon)),
                ],
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Text(
              'Tell us about\n your health journey',
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
                'Which of the following have caused \nchallenges for you in your health journey?\nSelect all that apply.',
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
              padding: const EdgeInsets.only(left: 24, right: 24),
              child: Container(
                child: Wrap(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 29,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        height: 39,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: Colors.blue, width: 2),
                            color: false ? Colors.white : Colors.blue),
                        child: Text(
                          'Aesthetics',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: Utils.fontfamilyInter,
                              fontSize: 14,
                              color: asthetics == false ? Colors.white : Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 29),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        height: 39,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.blue, width: 1),
                        ),
                        child: Text(
                          'Weight Lifting',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: Utils.fontfamilyInter,
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 29),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        height: 39,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: Colors.blue, width: 2),
                            color: false ? Colors.white : Colors.blue),
                        child: Text(
                          'Injury Rehab',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: Utils.fontfamilyInter,
                              fontSize: 14,
                              color: asthetics == false ? Colors.white : Colors.white),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 11),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        height: 39,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: Colors.blue, width: 2),
                            color: false ? Colors.white : Colors.blue),
                        child: Text(
                          'Athletic Training',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: Utils.fontfamilyInter,
                              fontSize: 14,
                              color: asthetics == false ? Colors.white : Colors.white),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 11, left: 5),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        height: 39,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.blue, width: 1),
                        ),
                        child: Text(
                          'Sport-Specific Training',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: Utils.fontfamilyInter,
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 11),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        height: 39,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.blue, width: 1),
                        ),
                        child: Text(
                          'Weight Loss',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: Utils.fontfamilyInter,
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 11, left: 5),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        height: 39,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: Colors.blue, width: 2),
                            color: false ? Colors.white : Colors.blue),
                        child: Text(
                          'General Health',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: Utils.fontfamilyInter,
                              fontSize: 14,
                              color: asthetics == false ? Colors.white : Colors.white),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 11, left: 5),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          height: 39,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.blue, width: 1),
                          ),
                          child: Text(
                            'Running',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: Utils.fontfamilyInter,
                              color: Colors.blue,
                              fontSize: 14,
                            ),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(top: 11),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        height: 39,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: Colors.blue, width: 2),
                            color: false ? Colors.white : Colors.blue),
                        child: Text(
                          'Meditation',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: Utils.fontfamilyInter,
                              fontSize: 14,
                              color: asthetics == false ? Colors.white : Colors.white),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 11, left: 5),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        height: 39,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.blue, width: 1),
                        ),
                        child: Text(
                          'Flexibility & Mobility',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: Utils.fontfamilyInter,
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 11, left: 5),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        height: 39,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: Colors.blue, width: 2),
                            color: false ? Colors.white : Colors.blue),
                        child: Text(
                          'Other',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: Utils.fontfamilyInter,
                              fontSize: 14,
                              color: asthetics == false ? Colors.white : Colors.white),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40, left: 29, right: 60),
                      child: Center(
                        child: Text(
                          'Access to facilities / equipment, Occupation, Family Responsibilities, Injuries, Low Motivation / Lack of Consistency, Not Knowing What to Do, Intimidation / Lack of Confidence',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: Utils.fontfamily,
                              color: Color(0xFF000000),
                              fontSize: 14),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 76, left: 24, right: 24),
              child: InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) => Dataanalytic()));
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.08,
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
            Padding(
              padding: const EdgeInsets.only(top: 34, bottom: 40),
              child: Utils.text(
                  'Skip for now', Utils.fontfamily, Utils.buttonColor, FontWeight.w600, 15),
            )
          ]),
        ),
      ),
    );
  }

  Widget tagWidget() {
    return Container();
  }
}
