import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:solstice/pages/onboardingflow/profiletypescreen.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/globals.dart' as globals;
import 'package:solstice/utils/my_navigator.dart';
import 'package:solstice/utils/shared_preferences.dart';

import 'cards/create_card.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String token = "";
  bool isLoggedIn = false;

  bool isProfileSetup = false;

  LatLng currentLatLng;
  Position currentLocation;

  User _firebaseUser;
  // firebase notification
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile> _sharedFiles;
  String _sharedText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    /* Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
       // MyNavigator.goToLogin(context);

      });

    });*/
    // firebaseCloudMessaging_Listeners();
    _getFirebaseUser();
    getUserLocation();
    getPrefData();
  }

  Future onSelectNotification(String payload) {
    /*Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return NewScreen(
        payload: payload,
      );
    }));*/
  }

  // void firebaseCloudMessaging_Listeners() {
  //   if (Platform.isIOS) iOS_Permission();

  //   _firebaseMessaging.getToken().then((token){
  //     setState(() {
  //       globalUserFBToken = token;
  //     });
  //   });

  // }

  // void iOS_Permission() {
  //   _firebaseMessaging.requestNotificationPermissions(
  //       IosNotificationSettings(sound: true, badge: true, alert: true)
  //   );
  //   _firebaseMessaging.onIosSettingsRegistered
  //       .listen((IosNotificationSettings settings)
  //   {
  //   });
  // }

  Future<void> _getFirebaseUser() async {
    this._firebaseUser = await FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  getUserLocation() async {

    currentLocation = await locateUser();
    currentLatLng = LatLng(currentLocation.latitude, currentLocation.longitude);
    globals.currentLatLng = currentLatLng;
    if (mounted) {
      setState(() {});
    }
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  getPrefData() {
    Future<bool> status = SharedPref.getBool(Constants.LOGINSTATUS);
    status.then((value) => {isLoggedIn = value},
        onError: (err) {
    });
    Future<String> userId = SharedPref.getStringFromPrefs(Constants.USER_ID);
    userId.then((value) => {globalUserId = value},
        onError: (err) {
    });
    Future<String> userName = SharedPref.getStringFromPrefs(Constants.USER_NAME);
    userName.then((value) => {globalUserName = value},
        onError: (err) {
    });
    Future<String> profileImage = SharedPref.getStringFromPrefs(Constants.PROFILE_IMAGE);
    profileImage.then(
        (value) => {globaUserProfileImage = value},
        onError: (err) {
    });

    setState(() {});

    // function to check data shared by other apps.
    checkSharedData();
  }

  void checkSharedData() {
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
        if (_sharedText != null && _sharedText != "") {
          navigateToCreateCard(_sharedText);
        }
      });
    }, onError: (err) {
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
        if (_sharedText != null && _sharedText != "") {
          navigateToCreateCard(_sharedText);
        }
      });
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        _sharedText = value;
        if (_sharedText != null && _sharedText != "") {
          navigateToCreateCard(_sharedText);
        }
      });
    }, onError: (err) {
    });
    ReceiveSharingIntent.getInitialText().then((String value) {
      setState(() {
        _sharedText = value;
        if (_sharedText != null && _sharedText != "") {
          navigateToCreateCard(_sharedText);
        }
      });
    });
  }

  void navigateToCreateCard(String dataToShare) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreateCardPage(
                  sharedText: dataToShare,
                )));
  }

  @override
  void dispose() {
    // _connectivitySubscription.cancel();
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    FocusScope.of(context).unfocus();
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            child: Image.asset(
              'assets/images/splash_bg.png',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fill,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: AppColors.splashOpacityColor.withOpacity(0.5),
          ),
          Stack(
            children: <Widget>[
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(right: 20.0, left: 20.0),
                          child:
                              /*Image.asset(
                            'assets/images/splash_logo.png',
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: MediaQuery.of(context).size.width * 0.4,
                            fit: BoxFit.contain,
                            color: AppColors.primaryColor,
                          ),*/
                              SvgPicture.asset(
                            'assets/images/splash_logo.svg',
                            height: MediaQuery.of(context).size.width * 0.4,
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                          )),
                    ],
                  ),
                ),
              ),
              // Positioned(
              //     top: 70,
              //     right: 0,
              //     child: Row(
              //       children: [
              //         InkWell(
              //           onTap: () {
              //             setState(() {
              //               Navigator.push(
              //                   context,
              //                   MaterialPageRoute(
              //                       builder: (context) => Profile_User_brand_Screen()));
              //             });
              //           },
              //           child: Container(
              //             margin: EdgeInsets.only(left: 10),
              //             height: ScreenUtil().setSp(92),
              //             alignment: Alignment.center,
              //             decoration: BoxDecoration(
              //               color: AppColors.primaryColor,
              //               borderRadius: BorderRadius.only(
              //                 topLeft: Radius.circular(40),
              //                 bottomLeft: Radius.circular(40),
              //               ),
              //             ),
              //             child: Padding(
              //               padding: EdgeInsets.only(left: 16, right: 16),
              //               child: Row(
              //                 mainAxisAlignment: MainAxisAlignment.center,
              //                 crossAxisAlignment: CrossAxisAlignment.center,
              //                 children: [
              //                   Text(
              //                     'OnBoarding UI',
              //                     softWrap: true,
              //                     textAlign: TextAlign.center,
              //                     style: TextStyle(
              //                         fontSize: 16.0,
              //                         fontFamily: Constants.mediumFont,
              //                         color: Colors.white),
              //                   ),
              //                   Padding(
              //                       padding: EdgeInsets.only(left: 20.0),
              //                       child: SvgPicture.asset(
              //                         'assets/images/ic_arrow_next.svg',
              //                         height: 16,
              //                         width: 16,
              //                         alignment: Alignment.center,
              //                         fit: BoxFit.contain,
              //                       )),
              //                 ],
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     )),
              Positioned(
                  bottom: 70,
                  right: 0,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            navigationPage();
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 10),
                          height: ScreenUtil().setSp(92),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              bottomLeft: Radius.circular(40),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  Constants.getStarted,
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: Constants.mediumFont,
                                      color: Colors.white),
                                ),
                                Padding(
                                    padding: EdgeInsets.only(left: 20.0),
                                    child: SvgPicture.asset(
                                      'assets/images/ic_arrow_next.svg',
                                      height: 16,
                                      width: 16,
                                      alignment: Alignment.center,
                                      fit: BoxFit.contain,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
              Positioned(
                  bottom: 200,
                  right: 0,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(

                              context, MaterialPageRoute(builder: (context) => ProfileTypeScreen()));
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 10),
                          height: ScreenUtil().setSp(92),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              bottomLeft: Radius.circular(40),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "OnBoarding Flow",
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: Constants.mediumFont,
                                      color: Colors.white),
                                ),
                                Padding(
                                    padding: EdgeInsets.only(left: 20.0),
                                    child: SvgPicture.asset(
                                      'assets/images/ic_arrow_next.svg',
                                      height: 16,
                                      width: 16,
                                      alignment: Alignment.center,
                                      fit: BoxFit.contain,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ))
            ],
          )
        ],
      ),
    );
  }

  // navigate to home or login page
  void navigationPage() {
    /*if (isLoggedIn) {
      MyNavigator.goToHome(context);
    } else {
      MyNavigator.goToLogin(context);
    }*/

    // if user logged in then go to home otherwise go to login.
    if (FirebaseAuth.instance.currentUser != null && isLoggedIn) {
      // signed in
      // Constants().errorToast(context, FirebaseAuth.instance.currentUser.uid);
      MyNavigator.goToHome(context);
    } else {
      MyNavigator.goToLogin(context);
    }
  }
}
