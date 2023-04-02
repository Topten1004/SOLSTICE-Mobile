import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:country_list_pick/country_selection_theme.dart';
import 'package:country_list_pick/support/code_country.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:solstice/model/loginRegister/user_response_fb.dart';
import 'package:solstice/pages/onboardingflow/send_otp_Screen.dart';
import 'package:solstice/pages/onboardingflow/signup_screen2.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/pages/register_login/otp_verification.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/shared_preferences.dart';

class OnBoardingSignIn extends StatefulWidget {
  const OnBoardingSignIn({Key key}) : super(key: key);

  @override
  _OnBoardingSignInState createState() => _OnBoardingSignInState();
}

class _OnBoardingSignInState extends State<OnBoardingSignIn> {
  bool _showLoading = false;
  AuthCredential _phoneAuthCredential;
  String pinCode = "";
  String phoneErrorMessage = "";
  bool isPhoneError = true;
  bool isBtnEnable = false;
  bool isTimerRunning = false;
  User _firebaseUser;
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  String _verificationId;
  String _status;
  TextEditingController phoneController = new TextEditingController();
  String defaultCountryShortForm = "IND";
  String countryCode = "+91";
  String countryCodeWithoutPlus = "1";
  int _start = 60;
  String deviceType = "";
  String oneSignalID = "";
  String appVersion = "";

  @override
  Widget build(BuildContext context) {
     ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
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
      child: ModalProgressHUD(
        inAsyncCall: _showLoading,
        opacity: 0.4,
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          strokeWidth: 5.0,
        ),
        child: Scaffold(
          appBar: appBar,
          key: _scaffoldkey,
          bottomNavigationBar: Container(
            margin: EdgeInsets.only(bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Don’t have an account? ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: Utils.fontfamily, fontSize: 15, color: Color(0XFF969AA8))),
                Text('Register Here',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: Utils.fontfamily,
                        fontSize: 15,
                        color: Color(0XFF338BEF),
                        fontWeight: FontWeight.bold))
              ],
            ),
          ),
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 30, top: 10, bottom : 15),
                  width: 160,
                  height: 42,
                  child: Image(image: AssetImage(Utils.solsciteImage)),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 30,
                    ),
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                          fontFamily: Utils.fontfamily,
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                          color: Color(0XFF000000)),
                    ),
                    SizedBox(
                      width: 24,
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 30, right: 30, top:45, bottom : 30),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(
                      "Sign In",
                      style: TextStyle(
                          color: AppColors.onboardingDarkTextColor,
                          fontFamily: Constants.fontSfPro,
                          fontSize: 24,
                          fontWeight: FontWeight.w400),
                    ),
                  ]),
                ),
                Container(
                    height: 56,
                    margin: EdgeInsets.only(left: 30, right: 30),
                    padding: EdgeInsets.only(left: 10, right: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.withOpacity(0.1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: ScreenUtil().setSp(70),
                          child: CountryListPick(
                              appBar: AppBar(
                                backgroundColor: AppColors.primaryColor,
                                title: Text('Select country code'),
                              ),
                              // if you need custome picker use this
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
                              initialSelection: countryCode,
                              onChanged: (CountryCode code) {
                                setState(() {
                                  countryCode = code.dialCode;
                                  defaultCountryShortForm = code.dialCode;
                                });
                              },
                              // Whether to allow the widget to set a custom UI overlay
                              useUiOverlay: true,
                              // Whether the country list should be wrapped in a SafeArea
                              useSafeArea: false),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            child: TextField(
                              maxLength: 10,
                              controller: phoneController,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.number,
                              decoration: new InputDecoration(
                                hintText: 'Phone',
                                counterText: "",
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                              ),
                              style: TextStyle(),
                            ),
                          ),
                        ),
                      ],
                    )),
                SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    if (phoneController.text.isEmpty || phoneController.text.length != 10) {
                      Constants.showSnackBarWithMessage(
                          "Enter valid phone number", _scaffoldkey, context, Colors.red[700]);
                    } else {
                      sendOtp();
                    }
                    // Navigator.push(
                    //     context, MaterialPageRoute(builder: (context) => PushNotificationScreen()));
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 20, left: 30, right: 30),
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
                        child: Utils.text(
                            'Sign In', Utils.fontfamily, Color(0xFFFFFFFF), FontWeight.w400, 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        // if (widget.openFromLogin) {
        //   MyNavigator.goToHome(context);
        // } else {
        //   MyNavigator.goToAboutYou(context);
        // }
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
            .where(Constants.countryCodeFB, isEqualTo: countryCode.replaceAll("+", ""))
            .where(Constants.phoneFB, isEqualTo: phoneController.value.text.trim())
            .get();
        if (_query != null) {
          if (_query.docs.length > 0) {
            _showLoading = false;

            // if user exist in database. then go to OTP screen for autherization

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return SendOtpScren(
                    openFromLogin: true,
                    countryCode: countryCode.replaceAll("+", ""),
                    userName: '',
                    email: '',
                    phoneNumber: phoneController.value.text,
                    fromWhich: 'login', userImage: null,
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
                _OnGoToRegister(countryCode, phoneController.value.text.trim());
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
      return Signup2Screen(
          defaultCountryShortFormIntent: defaultCountryShortForm, phoneNoIntent: phoneNo);
    }));

    if (results != null && results.containsKey('update')) {
      var _isUpdate = "";
      setState(() {});
    }
  }
}
