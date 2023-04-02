import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solstice/utils/constants.dart';

import '../../utils/shared_preferences.dart';

class ChangeEmail extends StatefulWidget {
  @override
  _ChangeEmailState createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  bool isBtnEnable = true;
  String userPrefImage = "", email = "", userId = "";
  final TextEditingController _controller = new TextEditingController();
  final TextEditingController _confirmEmailController =
      new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future<String> userPrefId =
        SharedPref.getStringFromPrefs(Constants.USER_ID);
    userPrefId.then(
        (value) => {
              userId = value,
            }, onError: (err) {
    });
    Future<String> userPrefemail =
        SharedPref.getStringFromPrefs(Constants.EMAIL);
    userPrefemail.then((value) => {_controller.text = value, },
        onError: (err) {});
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: ExactAssetImage('assets/images/splash_bg.png'),
          fit: BoxFit.fill,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Scaffold(
        key: _scaffoldkey,
        backgroundColor: AppColors.splashOpacityColor.withOpacity(0.5),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            ),
            Positioned(
              top: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.all(25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        'assets/images/splash_logo.svg',
                        width: MediaQuery.of(context).size.width * 0.30,
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 27,
                            height: 27,
                            padding: EdgeInsets.all(2.5),
                            margin: EdgeInsets.only(right: 5),
                            child: SvgPicture.asset(
                              'assets/images/ic_reset_email.svg',
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            width: 0,
                          ),
                          Text(
                            "Reset Email",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: ScreenUtil().setSp(38),
                                fontFamily: Constants.boldFont),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 40,
                          backgroundImage: NetworkImage(
                            "https://www.bodybuilding.com/fun/images/2015/how-to-make-yourself-the-best-trainer-at-any-gym-facebook-box-960x540.jpg",
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: _controller,
                        decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(
                                fontFamily: 'epilogue_regular',
                                fontSize: ScreenUtil().setSp(25))),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: _confirmEmailController,
                        decoration: InputDecoration(
                            labelText: "Confirm Email",
                            labelStyle: TextStyle(
                                fontFamily: 'epilogue_regular',
                                fontSize: ScreenUtil().setSp(25))),
                      ),
                      // SizedBox(
                      //   height: 20,
                      // ),
                      // TextFormField(
                      //   controller: _controller,
                      //   decoration: InputDecoration(
                      //       labelText: "Password",
                      //       labelStyle: TextStyle(
                      //           fontFamily: 'epilogue_regular',
                      //           fontSize: ScreenUtil().setSp(25))),
                      // ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        color: Colors.transparent,
                        margin: EdgeInsets.only(top: 3),
                        width: MediaQuery.of(context).size.width,
                        height: ScreenUtil().setSp(100),
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40.0),
                              side: BorderSide(color: AppColors.primaryColor)),
                          onPressed: () {
                            Pattern pattern =
                                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                            RegExp regex = new RegExp(pattern);
                            if (_controller.text.trim().isEmpty ||
                                _confirmEmailController.text.trim().isEmpty) {
                              Constants.showSnackBarWithMessage(
                                  "Enter valid email!",
                                  _scaffoldkey,
                                  context,
                                  AppColors.redColor);
                            } else if (!regex
                                    .hasMatch(_controller.text.trim()) ||
                                !regex.hasMatch(
                                    _confirmEmailController.text.trim())) {
                              Constants.showSnackBarWithMessage(
                                  "Enter valid email!",
                                  _scaffoldkey,
                                  context,
                                  AppColors.redColor);
                            } else if (regex
                                    .hasMatch(_controller.text.trim()) &&
                                regex.hasMatch(
                                    _confirmEmailController.text.trim()) &&
                                _controller.text ==
                                    _confirmEmailController.text) {
                              // isBtnEnable = true;

                              FirebaseFirestore.instance
                                  .collection(Constants.UsersFB)
                                  .doc(userId)
                                  .update({
                                'userEmail': _controller.text,
                              }).then((docRef) {
                                Constants.showSnackBarWithMessage(
                                    "Email updated successfully!",
                                    _scaffoldkey,
                                    context,
                                    AppColors.greenColor);
                                SharedPref.saveStringInPrefs(
                                    Constants.EMAIL, _controller.text);
                                Future.delayed(
                                    const Duration(milliseconds: 1000), () {
                                  Navigator.of(context).pop();
                                });
                              });
                            } else if (_controller.text !=
                                _confirmEmailController.text) {
                              Constants.showSnackBarWithMessage(
                                  "Enter valid email!",
                                  _scaffoldkey,
                                  context,
                                  AppColors.redColor);
                            }
                            setState(() {});
                            // if (_controller.text.trim() ==
                            //     _confirmEmailController.text.trim()) {
                            // } else {
                            // }
                          },
                          color: AppColors.primaryColor,
                          textColor: Colors.white,
                          padding: EdgeInsets.all(10.0),
                          child: Text(Constants.update,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(28),
                                fontFamily: Constants.semiBoldFont,
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            Constants.cancel,
                            style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: ScreenUtil().setSp(28),
                                fontFamily: Constants.regularFont,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
