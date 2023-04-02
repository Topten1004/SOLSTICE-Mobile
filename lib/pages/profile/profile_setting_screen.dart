import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:solstice/main.dart';
import 'package:solstice/pages/new_login_register/about_you_screen.dart';
import 'package:solstice/pages/new_login_register/about_you_screen_new.dart';
import 'package:solstice/pages/profile/change_username_screen.dart';
import 'package:solstice/pages/profile/privacy_policy_screen.dart';
import 'package:solstice/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/utils/my_navigator.dart';
import 'package:solstice/utils/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'change_email.dart';

class ProfileSettingScreen extends StatefulWidget {
  @override
  ProfileSettingScreenState createState() {
    return ProfileSettingScreenState();
  }
}

class ProfileSettingScreenState extends State<ProfileSettingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
      key: _scaffoldkey,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.white),
          ),
          Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).padding.top,
              ),
              Expanded(
                  flex: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setSp(20),
                        right: ScreenUtil().setSp(36),
                        top: ScreenUtil().setSp(26),
                        bottom: ScreenUtil().setSp(26)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                              width: 22,
                              height: 22,
                              padding: EdgeInsets.all(2.5),
                              margin: EdgeInsets.only(left: 10, right: 18),
                              child: SvgPicture.asset(
                                'assets/images/ic_back.svg',
                                alignment: Alignment.center,
                                fit: BoxFit.contain,
                              )),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.all(ScreenUtil().setSp(12)),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    Constants.profileSettings,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: AppColors.titleTextColor,
                                        fontFamily: Constants.boldFont,
                                        fontSize: ScreenUtil().setSp(32)),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  )),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          Constants.profile,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColors.titleTextColor,
                              fontFamily: Constants.boldFont,
                              fontSize: ScreenUtil().setSp(28)),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () {
                            _goToDestiny(AboutYouNewScreen(isEdit: true));
                          },
                          child: Container(
                            padding: EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 26,
                                  height: 23,
                                  padding: EdgeInsets.all(1.5),
                                  margin: EdgeInsets.only(right: 5),
                                  child: SvgPicture.asset(
                                    'assets/images/ic_person.svg',
                                    alignment: Alignment.center,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "About You",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: AppColors.titleTextColor,
                                      fontFamily: Constants.regularFont,
                                      fontSize: ScreenUtil().setSp(30)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        setViewLine(),
                        InkWell(
                          onTap: () {
                            _goToDestiny(ChangeUserName());
                          },
                          child: Container(
                            padding: EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 26,
                                  height: 23,
                                  padding: EdgeInsets.all(1.5),
                                  margin: EdgeInsets.only(right: 5),
                                  child: SvgPicture.asset(
                                    'assets/images/ic_person.svg',
                                    alignment: Alignment.center,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  Constants.changeUserName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: AppColors.titleTextColor,
                                      fontFamily: Constants.regularFont,
                                      fontSize: ScreenUtil().setSp(30)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        setViewLine(),
                        InkWell(
                          onTap: () {
                            _goToDestiny(ChangeEmail());
                          },
                          child: Container(
                            padding: EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  padding: EdgeInsets.all(1.5),
                                  margin: EdgeInsets.only(right: 5),
                                  child: SvgPicture.asset(
                                    'assets/images/ic_mail.svg',
                                    alignment: Alignment.center,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(Constants.changeEmail,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: AppColors.titleTextColor,
                                        fontFamily: Constants.regularFont,
                                        fontSize: ScreenUtil().setSp(30))),
                              ],
                            ),
                          ),
                        ),
                        // setViewLine(),
                        // InkWell(
                        //   child: Container(
                        //     padding: EdgeInsets.all(14),
                        //     child: Row(
                        //       children: [
                        //         Container(
                        //           width: 26,
                        //           height: 26,
                        //           padding: EdgeInsets.all(1.5),
                        //           margin: EdgeInsets.only(right: 5),
                        //           child: SvgPicture.asset(
                        //             'assets/images/ic_lock.svg',
                        //             alignment: Alignment.center,
                        //             fit: BoxFit.contain,
                        //           ),
                        //         ),
                        //         SizedBox(
                        //           width: 10,
                        //         ),
                        //         Text(Constants.changePassword,
                        //             overflow: TextOverflow.ellipsis,
                        //             style: TextStyle(
                        //                 color: AppColors.titleTextColor,
                        //                 fontFamily: Constants.regularFont,
                        //                 fontSize: ScreenUtil().setSp(30))),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          Constants.helpCenter,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColors.titleTextColor,
                              fontFamily: Constants.boldFont,
                              fontSize: ScreenUtil().setSp(30)),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () {
                            _goToDestiny(PrivacyPolicy());
                          },
                          child: Container(
                            padding: EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  padding: EdgeInsets.all(1.5),
                                  margin: EdgeInsets.only(right: 5),
                                  child: SvgPicture.asset(
                                    'assets/images/ic_key.svg',
                                    alignment: Alignment.center,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  Constants.privacyPolicy,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: AppColors.titleTextColor,
                                      fontFamily: Constants.regularFont,
                                      fontSize: ScreenUtil().setSp(30)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        setViewLine(),
                        InkWell(
                          onTap: () {
                            _sendingMails();
                          },
                          child: Container(
                            padding: EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  padding: EdgeInsets.all(1.5),
                                  margin: EdgeInsets.only(right: 5),
                                  child: SvgPicture.asset(
                                    'assets/images/ic_customer_care.svg',
                                    alignment: Alignment.center,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(Constants.customerCare,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: AppColors.titleTextColor,
                                        fontFamily: Constants.regularFont,
                                        fontSize: ScreenUtil().setSp(30))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _logoutFromFireStore();
                  });
                },
                child: Container(
                  padding: EdgeInsets.only(top: 20, bottom: 50),
                  child: Text(
                    Constants.logOut,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColors.redColor,
                        fontFamily: Constants.mediumFont,
                        fontSize: ScreenUtil().setSp(30)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _logoutFromFireStore() async {
    /// Method to Logout the `FirebaseUser` (`_firebaseUser`)
    try {
      // signout code

      FirebaseFirestore.instance
          .collection(Constants.UsersFB)
          .doc(globalUserId)
          .update({
            'token': "",
          })
          .then((docRef) {
            setState(() async {
              await FirebaseAuth.instance.signOut();
              _cancelAllNotifications();

              SharedPref.saveBooleanInPrefs(Constants.LOGINSTATUS, false);
              SharedPref.clear();

              MyNavigator.goToWelcome(context);
            });
          })
          .timeout(Duration(seconds: 10))
          .catchError((error) {

            setState(() async {
              await FirebaseAuth.instance.signOut();
              _cancelAllNotifications();

              SharedPref.saveBooleanInPrefs(Constants.LOGINSTATUS, false);
              SharedPref.clear();

              MyNavigator.goToWelcome(context);
            });
          });
    } catch (e) {}
  }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  _sendingMails() async {
    const url = 'mailto:admin@solsapp.com​';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void showSnackBar(String msg) {
    final snackBarContent = SnackBar(
      content: Text(msg),
      action: SnackBarAction(
          label: 'OK',
          onPressed: _scaffoldkey.currentState.hideCurrentSnackBar,
          textColor: AppColors.primaryColor),
    );
    _scaffoldkey.currentState.showSnackBar(snackBarContent);
  }

  Widget setViewLine() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(left: 6, right: 6),
      height: ScreenUtil().setSp(1),
      child: DottedBorder(
        borderType: BorderType.Rect,
        color: AppColors.viewLineColor,
        radius: Radius.circular(40),
        dashPattern: [2.5, 4, 2, 4],
        strokeWidth: 1,
        child: Center(),
      ),
    );
  }

  Future _goToDestiny(Object className) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return className;
        },
      ),
    );
  }
}
