import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_version/get_version.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:solstice/apiservice/api_call.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/loginRegister/user_response_fb.dart';
import 'package:solstice/pages/login_register_fb/register_fb.dart';
import 'package:solstice/pages/register_login/otp_verification.dart';
import 'package:solstice/pages/register_login/otp_verification_screen.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/my_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/utils/shared_preferences.dart';
import 'package:solstice/utils/utilities.dart';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

class LoginFbScreen extends StatefulWidget {
  @override
  _LoginScreenFbState createState() => _LoginScreenFbState();
}

class _LoginScreenFbState extends State<LoginFbScreen> {
  TextEditingController phoneController = new TextEditingController();
  final FocusNode _phoneFocus = new FocusNode();
  bool passwordVisible = true;
  String phoneErrorMessage = "";
  String pinCode = "";
  bool isPhoneError = true;
  String countryCode = "+1";
  String countryCodeWithoutPlus = "1";
  String defaultCountryShortForm = "US";

  bool isBtnEnable = false;
  bool isTimerRunning = false;
  double _animatedHeight = 0.0;

  bool _showLoading = false;

  String deviceType = "";
  String oneSignalID = "";
  String appVersion = "";
  Timer _timer;
  int _start = 60;
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  Random _rnd = Random();

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  String getRandomString(int length) => String.fromCharCodes(
      Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  // start timer for resend code
  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            isTimerRunning = false;
          });
        } else {
          setState(() {
            isTimerRunning = true;
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // for getting device type and app version.
    getApplicationConfigurationDetails();

    // for initialize notification.
    initializeNotification();
  }

  void initializeNotification() {
    if (Platform.isIOS) iOS_Permission();
    /*var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOs);

    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);*/

    _firebaseMessaging.getToken().then((token) {
      setState(() {
        globalUserFBToken = token;
      });
    });

    if (mounted) {
      setState(() {});
    }
  }

  void iOS_Permission() {
    // _firebaseMessaging.requestNotificationPermissions(
    //     IosNotificationSettings(sound: true, badge: true, alert: true));
    // _firebaseMessaging.onIosSettingsRegistered
    //     .listen((IosNotificationSettings settings) {
    // });
  }

  Future<bool> _onBackPressed() async {
    if (_animatedHeight > 0) {
      _animatedHeight = 0.0;
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return ModalProgressHUD(
      inAsyncCall: _showLoading,
      opacity: 0.4,
      progressIndicator: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        strokeWidth: 5.0,
      ),
      child: Container(
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
                        Text(
                          Constants.welcomeBack,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil().setSp(64),
                              fontFamily: Constants.boldFont),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 60.0,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      enterAnonymousUser();
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
                            'Skip',
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
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Text(
                            Constants.login,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: ScreenUtil().setSp(38),
                                fontFamily: Constants.boldFont),
                          ),
                          SizedBox(height: ScreenUtil().setSp(52)),
                          Text(
                            Constants.phoneNumber,
                            style: TextStyle(
                                color: AppColors.accentColor,
                                fontFamily: Constants.semiBoldFont,
                                fontSize: ScreenUtil().setSp(24)),
                          ),
                          SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: ScreenUtil().setSp(70),
                                child: CountryListPick(
                                    appBar: AppBar(
                                      backgroundColor: AppColors.primaryColor,
                                      title: Text('Select country code'),
                                    ),
                                    pickerBuilder: (context, CountryCode countryCode) {
                                      return Row(
                                        children: [
                                          Image.asset(
                                            countryCode.flagUri,
                                            package: 'country_list_pick',
                                            width: 30,
                                            height: 22,
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            countryCode.dialCode,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontFamily: Constants.regularFont),
                                          ),
                                          Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Colors.black,
                                            // size: Dimens.iconSize06(),
                                          ),
                                        ],
                                      );
                                    },

                                    // To disable option set to false
                                    theme: CountryTheme(
                                      isShowFlag: true,
                                      isShowTitle: true,
                                      isShowCode: false,
                                      isDownIcon: true,
                                      showEnglishName: true,
                                    ),
                                    // Set default value
                                    initialSelection: '+91',
                                    onChanged: (CountryCode code) {
                                      setState(() {
                                      });
                                    },
                                    // Whether to allow the widget to set a custom UI overlay
                                    useUiOverlay: true,
                                    // Whether the country list should be wrapped in a SafeArea
                                    useSafeArea: false),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: ScreenUtil().setSp(70),
                                  padding: EdgeInsets.only(bottom: 2),
                                  child: TextFormField(
                                    maxLength: 50,
                                    focusNode: _phoneFocus,
                                    cursorColor: AppColors.primaryColor,
                                    controller: phoneController,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: <TextInputFormatter>[
                                      WhitelistingTextInputFormatter.digitsOnly
                                    ],
                                    textInputAction: TextInputAction.next,
                                    onChanged: (v) {
                                      setState(
                                        () {
                                          if (phoneController.value.text.trim().isEmpty) {
                                            isPhoneError = true;
                                            phoneErrorMessage = Constants.enterPhoneError;
                                            _animatedHeight = 0.0;
                                            isBtnEnable = false;
                                          } else if ((phoneController.value.text.trim().length <
                                                  8) ||
                                              (phoneController.value.text.trim().length > 12)) {
                                            isPhoneError = true;
                                            phoneErrorMessage = Constants.enterValidPhoneError;
                                            _animatedHeight = 0.0;
                                            isBtnEnable = false;
                                          } else {
                                            isBtnEnable = true;
                                            isPhoneError = false;
                                            phoneErrorMessage = "";
                                          }
                                        },
                                      );
                                    },
                                    decoration: InputDecoration(
                                      counterText: "",
                                      border: InputBorder.none,
                                      labelText: "",
                                      labelStyle: TextStyle(
                                        color: AppColors.accentColor,
                                        fontFamily: Constants.semiBoldFont,
                                        fontSize: ScreenUtil().setSp(24),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 1.0,
                            color: AppColors.accentColor,
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 10, top: 4),
                            alignment: Alignment.topRight,
                            margin: const EdgeInsets.only(top: 3.0, left: 30.0, bottom: 3),
                            child: Text(
                              phoneErrorMessage,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red,
                                  fontFamily: Constants.mediumFont),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: _animatedHeight,
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.only(
                                      top: ScreenUtil().setSp(12), bottom: ScreenUtil().setSp(30)),
                                  child: PinEntryTextField(
                                    fontSize: ScreenUtil().setSp(42),
                                    fieldWidth: ScreenUtil().setSp(68),
                                    fields: 5,
                                    onSubmit: (String pin) {
                                      setState(
                                        () {
                                          pinCode = pin;
                                          if (pinCode.length >= 5) {
                                            isBtnEnable = true;
                                          } else {
                                            isBtnEnable = false;
                                          }
                                        },
                                      );
                                    }, // end onSubmit
                                  ),
                                ),
                                SizedBox(height: 6),
                                isTimerRunning == false
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            Constants.didnotReceiveCode,
                                            style: TextStyle(
                                                color: AppColors.accentColor,
                                                fontSize: ScreenUtil().setSp(26),
                                                fontFamily: Constants.regularFont,
                                                fontWeight: FontWeight.normal),
                                          ),
                                          SizedBox(width: 4),
                                          new GestureDetector(
                                            child: Text(
                                              Constants.resend,
                                              style: TextStyle(
                                                  decoration: TextDecoration.underline,
                                                  color: AppColors.primaryColor,
                                                  fontFamily: Constants.regularFont,
                                                  fontSize: ScreenUtil().setSp(27),
                                                  fontWeight: FontWeight.w300),
                                            ),
                                            onTap: () {
                                              MyNavigator.goToLogin(context);
                                              // do what you need to do when "Click here" gets clicked
                                            },
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          GestureDetector(
                                            child: Text(
                                              "Resend code in: $_start",
                                              style: TextStyle(
                                                  color: AppColors.accentColor,
                                                  fontSize: ScreenUtil().setSp(26),
                                                  fontFamily: Constants.regularFont,
                                                  fontWeight: FontWeight.normal),
                                            ),
                                            onTap: () {},
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                          SizedBox(height: 32),
                          Container(
                            color: Colors.transparent,
                            margin: EdgeInsets.only(top: 3),
                            width: MediaQuery.of(context).size.width,
                            height: ScreenUtil().setSp(100),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40.0),
                                  side: BorderSide(
                                      color: isBtnEnable == false
                                          ? AppColors.accentColor
                                          : AppColors.primaryColor)),
                              onPressed: () {
                                if (isBtnEnable) {
                                  sendOtp();
                                }
                              },
                              color: isBtnEnable == false
                                  ? AppColors.accentColor
                                  : AppColors.primaryColor,
                              textColor: Colors.white,
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                Constants.sendCode,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(28),
                                  fontFamily: Constants.semiBoldFont,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 26),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                Constants.donotHaveAnAccount,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: ScreenUtil().setSp(28),
                                    fontFamily: Constants.regularFont,
                                    fontWeight: FontWeight.normal),
                              ),
                              SizedBox(width: 4),
                              new GestureDetector(
                                child: Text(Constants.signup,
                                    style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontFamily: Constants.regularFont,
                                        fontSize: ScreenUtil().setSp(28),
                                        fontWeight: FontWeight.w300)),
                                onTap: () {
                                  MyNavigator.goToRegister(context);
                                },
                              )
                            ],
                          ),
                          SizedBox(height: 25),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // in this check is user phone no. and country code exist in database.
  Future<void> sendOtp() async {
    if (FocusScope.of(context).isFirstFocus) {
      FocusScope.of(context).requestFocus(new FocusNode());
    }
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          _showLoading = true;
        });
        // in this check is user phone no. and country code exist in database.
        QuerySnapshot _query = await FirebaseFirestore.instance
            .collection(Constants.UsersFB)
            .where(Constants.countryCodeFB, isEqualTo: countryCodeWithoutPlus)
            .where(Constants.phoneFB, isEqualTo: phoneController.value.text.trim())
            .get();
        if (_query != null) {
          if (_query.docs.length > 0) {
            _showLoading = false;

            // if user exist in database. then go to OTP screen for autherization

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return OtpVerficationScreen(
                    openFromLogin: true,
                    countryCode: countryCodeWithoutPlus,
                    userName: '',
                    email: '',
                    phoneNumber: phoneController.value.text,
                    fromWhich: 'login',
                  );
                },
              ),
            );
          } else {
            // if user exist in database. then go to Register screen for registering user.

            _showLoading = false;
            if (mounted) {
              setState(() {});
            }
            Constants.showSnackBarWithMessage(
                "User not exist. Please register first.", _scaffoldkey, context, Colors.red[700]);

            Future.delayed(const Duration(milliseconds: 1000), () {
              setState(() {
                _OnGoToRegister(defaultCountryShortForm, phoneController.value.text.trim());
                // Here you can write your code for open new view
              });
            });
            // Document doesn't exist
          }
        }
      }
    } on SocketException catch (_) {
      Constants.showSnackBarWithMessage(
          Constants.noInternet, _scaffoldkey, context, AppColors.yellowColor);
    }
  }

  Future _OnGoToRegister(String defaultCountryShortForm, String phoneNo) async {
    Map results =
        await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
      return RegisterFbScreen(
          defaultCountryShortFormIntent: defaultCountryShortForm, phoneNoIntent: phoneNo);
    }));

    if (results != null && results.containsKey('update')) {
      var _isUpdate = "";
      setState(() {});
    }
  }

  Future<void> getApplicationConfigurationDetails() async {
    if (Platform.isIOS) {
      deviceType = "iOS";
    } else if (Platform.isAndroid) {
      deviceType = "Android";
    }
    try {
      appVersion = await GetVersion.projectVersion;
    } on PlatformException {
      appVersion = "";
    }
  }

  Future<void> enterAnonymousUser() async {
    Utilities.show(context);
    String userImage = "";
    FirebaseFirestore.instance
        .collection(Constants.settingsCollec)
        .get()
        .then((value) => userImage = value.docs.first.data()["user_image"]);
    UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();

    FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(userCredential.user.uid)
        .set({
          Constants.userIdFB: userCredential.user.uid,
          Constants.userNameFB: 'Anonymous${getRandomString(4)}',
          Constants.userImageFB: userImage,
          Constants.userEmailFB: userCredential.user.email,
          Constants.phoneFB: userCredential.user.phoneNumber,
          Constants.countryCodeFB: "",
          'appVersion': appVersion,
          'device': deviceType,
          'lastLogin': DateTime.now().millisecondsSinceEpoch.toString(),
        })
        .then((docRef) {
          Utilities.hide();
          Constants.showSnackBarWithMessage(
              "Login successfully!", _scaffoldkey, context, AppColors.greenColor);
          setState(() {
            navigatePage(userCredential.user.uid);
            //uploadUserImage(uId);
          });
        })
        .timeout(Duration(seconds: 10))
        .catchError((error) {
          Utilities.hide();
          setState(() {
            _showLoading = false;
            Constants.showSnackBarWithMessage(
                "Register error. Please try again.", _scaffoldkey, context, Colors.red[700]);
          });
        });
  }

  Future<void> navigatePage(String uId) async {
    DocumentSnapshot ds =
        await FirebaseFirestore.instance.collection(Constants.UsersFB).doc(uId).get();
    if (ds != null) {
      UserResponseFirebase userItem = UserResponseFirebase.fromSnapshot(ds);
      if (userItem != null) {
        SharedPref.saveStringInPrefs(Constants.USER_ID, uId.toString());
        SharedPref.saveStringInPrefs(Constants.EMAIL, userItem.userEmail);
        SharedPref.saveStringInPrefs(Constants.USER_NAME, userItem.userName);
        SharedPref.saveStringInPrefs(Constants.PHONE_NO, userItem.phone);
        SharedPref.saveStringInPrefs(Constants.COUNTRY_CODE, userItem.country_code);
        SharedPref.saveStringInPrefs(Constants.PROFILE_IMAGE, userItem.userImage);
        globalUserId = uId.toString();
        globalUserName = userItem.userName;
        globaUserProfileImage = userItem.userImage;

        SharedPref.saveBooleanInPrefs(Constants.LOGINSTATUS, true);

        MyNavigator.goToHome(context);
      }

      if (mounted)
        setState(() {
          _showLoading = false;
        });
    } else {
      setState(() {
        _showLoading = false;
      });
    }
  }
  /*@override
  void onSuccess(Object data,int code) {
    setState(() {
      _showLoading=false;
    });
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) {
        return OtpVerficationScreen(
          openFromLogin: true,
          countryCode: countryCodeWithoutPlus,
          username: '',
          email: '',
          phoneNumber: phoneController.value.text, fromWhich: 'login',);
      },
    ),
    );
  }*/
}
