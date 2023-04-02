import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solstice/pages/onboardingflow/signup_screen2.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/utils/constants.dart';

import 'onboarding_sign_in.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset(Constants.welcomeBgNew),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Image.asset(
                Constants.solsticeImage,
                height: 30,
              ),
            ),
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Text(
                Constants.embraceTextLine,
                style: TextStyle(
                    fontFamily: Constants.fontSfPro,
                    color: AppColors.onboardingDarkTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 24),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Text(
                Constants.welcomeDesc,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontFamily: Constants.fontSfPro,
                    color: AppColors.onboardingDarkTextColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 12),
              ),
            ),
            SizedBox(height: 30),
            InkWell(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => OnBoardingSignIn()));
              },
              child: Container(
                  height: 56,
                  width: MediaQuery.of(context).size.width * 0.90,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Color(0xff283646).withOpacity(0.32),
                            blurRadius: 3.0,
                            spreadRadius: 3),
                      ],
                      color: Color(0xFF283646)),
                  child: Center(
                      child: Utils.text(
                          'Sign In', Utils.fontfamily, Color(0xFFFFFFFF), FontWeight.w400, 20))),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Signup2Screen()));
              },
              child: Container(
                margin: EdgeInsets.only(bottom : 15),
                height: 56,
                width: MediaQuery.of(context).size.width * 0.90,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xFF338BEF), width: 1)),
                child: Center(
                    child: Utils.text(
                        'Register', Utils.fontfamily, Color(0xFF338BEF), FontWeight.w400, 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
