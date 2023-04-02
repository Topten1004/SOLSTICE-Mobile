import 'dart:convert';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/my_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/utils/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  final FocusNode _emailFocus = new FocusNode();
  final FocusNode _passwordFocus = new FocusNode();
  bool passwordVisible = true;
  bool _isSelected = false;

  String emailErrorMessage = "";
  String passwordErrorMessage = "";

  bool isEmailError = true;
  bool isPasswordError = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

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
        backgroundColor: AppColors.splashOpacityColor.withOpacity(0.5),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Container(height: MediaQuery.of(context).size.height ,
              width: MediaQuery.of(context).size.width,),
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
                              fontSize: 19,
                              fontFamily: Constants.semiBoldFont),
                        ),
                        SizedBox(height: ScreenUtil().setSp(52)),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: ScreenUtil().setSp(100),
                          child: TextFormField(
                            maxLength: 50,
                            focusNode: _emailFocus,
                            cursorColor: AppColors.primaryColor,
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (v) {
                              FocusScope.of(context)
                                  .requestFocus(_passwordFocus);
                            },
                            onChanged: (v) {
                              setState(() {
                                Pattern pattern =
                                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                RegExp regex = new RegExp(pattern);
                                if (emailController.value.text.trim().isEmpty) {
                                  isEmailError = true;
                                  emailErrorMessage = Constants.enterEmailError;
                                } else if (!regex.hasMatch(
                                    emailController.value.text.trim())) {
                                  isEmailError = true;
                                  emailErrorMessage =
                                      Constants.enterValidEmailError;
                                } else {
                                  isEmailError = false;
                                  emailErrorMessage = "";
                                }
                              });
                            },
                            decoration: InputDecoration(
                              counterText: "",
                              labelText: Constants.email,
                              labelStyle: TextStyle(
                                  color: AppColors.accentColor,
                                  fontFamily: Constants.semiBoldFont,
                                  fontSize: ScreenUtil().setSp(24)),
                              /* contentPadding:
                            EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),*/
                            ),
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 10),
                            alignment: Alignment.topRight,
                            margin: const EdgeInsets.only(
                                top: 4.0, left: 30.0, bottom: 3),
                            child: Text(
                              emailErrorMessage,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red,
                                  fontFamily: Constants.mediumFont),
                            )),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: ScreenUtil().setSp(100),
                          child: TextFormField(
                            maxLength: 30,
                            focusNode: _passwordFocus,
                            cursorColor: AppColors.primaryColor,
                            controller: passwordController,
                            obscureText: passwordVisible,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                            onChanged: (v) {
                              setState(() {
                                if (passwordController.value.text
                                    .trim()
                                    .isEmpty) {
                                  isPasswordError = true;
                                  passwordErrorMessage =
                                      Constants.enterPasswordError;
                                } else if (passwordController.value.text
                                    .trim()
                                    .length <
                                    4) {
                                  isPasswordError = true;
                                  passwordErrorMessage =
                                      Constants.enterValidPasswordError;
                                } else {
                                  isPasswordError = false;
                                  passwordErrorMessage = "";
                                }
                              });
                            },
                            decoration: InputDecoration(
                              counterText: "",
                              labelText: Constants.password,
                              labelStyle: TextStyle(
                                  color: AppColors.accentColor,
                                  fontFamily: Constants.semiBoldFont,
                                  fontSize: ScreenUtil().setSp(24)),
                              suffix: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    passwordVisible = !passwordVisible;
                                  });
                                },
                                child: Text(
                                  passwordVisible
                                      ? Constants.show
                                      : Constants.hide,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.primaryColor,
                                      fontFamily: Constants.semiBoldFont),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 10),
                            alignment: Alignment.topRight,
                            margin: const EdgeInsets.only(
                                top: 4.0, left: 30.0, bottom: 3),
                            child: Text(
                              passwordErrorMessage,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red,
                                  fontFamily: Constants.mediumFont),
                            )),
                        Container(
                            alignment: Alignment.topRight,
                            margin: EdgeInsets.only(
                                top: ScreenUtil().setSp(16),
                                bottom: ScreenUtil().setSp(32)),
                            child: Text(
                              Constants.forgotPassword,
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(26),
                                  color: AppColors.primaryColor,
                                  fontFamily: Constants.regularFont),
                            )),
                        Container(
                          color: Colors.transparent,
                          margin: EdgeInsets.only(top: 3),
                          width: MediaQuery.of(context).size.width,
                          height: ScreenUtil().setSp(100),
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40.0),
                                side:
                                BorderSide(color: AppColors.primaryColor)),
                            onPressed: () {
                              _validateInputs();

                              // MyNavigator.goToReferral(context);
                            },
                            color: AppColors.primaryColor,
                            textColor: Colors.white,
                            padding: EdgeInsets.all(10.0),
                            child: Text(Constants.login,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(28),
                                  fontFamily: Constants.semiBoldFont,
                                )),
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
                                  // do what you need to do when "Click here" gets clicked
                                })
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
    );
  }


  Future<void> _validateInputs() async {
    // MyNavigator.goToRegisterVerification(context);

    FocusScope.of(context).unfocus();

    var email = emailController.text.trim();
    var password = passwordController.text.trim();

    if (email.isEmpty) {
      setState(() {
        emailErrorMessage = Constants.enterEmailError;
      });
    }
    if (password.isEmpty) {
      setState(() {
        passwordErrorMessage = Constants.enterPasswordError;
      });
    } else if (!isEmailError && !isPasswordError) {
      SharedPref.saveBooleanInPrefs(Constants.LOGINSTATUS, true);

      MyNavigator.goToHome(context);

      /*try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          setState(() {
            _isShowLoader = true;
          });
          ApiCall.callLoginApi(email, password, this);
        }
      } on SocketException catch (_) {
        Constants().warningToast(Translations.of(context).noInternet);
      }*/
    }
  }
}

