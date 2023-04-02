import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:country_list_pick/country_selection_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:solstice/pages/onboardingflow/ChangePasswordForm.dart';
import 'package:solstice/pages/onboardingflow/send_otp_Screen.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/pages/register_login/otp_verification.dart';
import 'package:solstice/utils/constants.dart';
import 'intrests_screen.dart';

class Signup2Screen extends StatefulWidget {
  final String defaultCountryShortFormIntent;
  final String phoneNoIntent;
  const Signup2Screen(
      {Key key,
      @required this.defaultCountryShortFormIntent,
      @required this.phoneNoIntent})
      : super(key: key);
  @override
  _Signup2ScreenState createState() => _Signup2ScreenState();
}

class _Signup2ScreenState extends State<Signup2Screen> {
  TextEditingController phoneController = new TextEditingController();
  TextEditingController fullNameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController userNameController = new TextEditingController();
  // TextEditingController Fu = new TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  bool _isAlreayUsername = false ;
  bool isEmailError = false;
  bool _showLoading = false;
  bool showUserNameSuffixIcon = false;
  bool showFullNameSuffixIcon = false;
  bool showEmailSuffixIcon = false;
  bool showPhoneNumberSuffixIcon = false;

  String countryCodeWithoutPlus = "1";
  String countryCode = "+1";
  String countryFlag;

  List<String> userNameLists = new List<String>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    getUserNames();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    // if user already enter phone no. in Login Screen. then we auto-fill the phone no. and country code in register screen.
    if (widget.phoneNoIntent != null) {
      phoneController.text = widget.phoneNoIntent;
      // isPhoneError = false;
    }
    countryCode = widget.defaultCountryShortFormIntent != null
        ? widget.defaultCountryShortFormIntent
        : '+91';
  }

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
              child:
                  Image.asset("assets/images/help.png", height: 26, width: 26)),
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
            margin: EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account? ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: Utils.fontfamily,
                        fontSize: 12,
                        color: Color(0XFF969AA8))),
                Text('Sign In',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: Utils.fontfamily,
                        fontSize: 13,
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
                  margin: EdgeInsets.only(left: 30, top: 10),
                  width: 126,
                  height: 33,
                  child: Image(image: AssetImage(Utils.solsciteImage)),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 30,
                    ),
                    Text(
                      'Sign Up',
                      style: TextStyle(
                          fontFamily: Utils.fontfamily,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Color(0XFF000000)),
                    ),
                    SizedBox(
                      width: 24,
                    ),
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // color: Color(0XFFFAFAFA),
                          color: Color(0XFFF5F6F9)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // color: Color(0XFFFAFAFA),
                          color: Color(0XFFF5F6F9)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // color: Color(0XFFFAFAFA),
                          color: Color(0XFFF5F6F9)),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 30, right: 74),
                  child: Text(
                    'Join the Solstice fitness community to \nconnect, teach, inspire, and grow stronger!',
                    style: TextStyle(
                        fontFamily: Utils.fontfamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0XFF969AA8)),
                  ),
                ),
                Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 24, right: 24, top: 25),
                      height: 56,
                      // width: MediaQuery.of(context).size.width*0.80,
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0XFFE8E8E8), width: 1),
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 18, left: 45, right: 133),
                      child: Container(
                        height: 17,
                        width: 67,
                        child: Center(
                          child: Utils.text('Full Name', Utils.fontfamily,
                              Color(0xFF1E263C), FontWeight.w400, 14),
                        ),
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 30, right: 50, left: 45),
                      child: TextField(
                        controller: fullNameController,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (value) {
                          if (value.toString().length > 0) {
                            showFullNameSuffixIcon = true;
                          } else {
                            showFullNameSuffixIcon = false;
                          }
                          setState(() {});
                        },
                        decoration: new InputDecoration(
                          border: InputBorder.none,
                          suffix: showFullNameSuffixIcon
                              ? SizedBox(
                                  height: 7,
                                  width: 12,
                                  child: ImageIcon(
                                    AssetImage(Utils.tickIcon),
                                    color: Color(0xFF00B227),
                                  ))
                              : Container(width: 2),
                          focusColor: Color(0xFFB9BAC8),
                          hintText: 'Enter your full name',
                          hintStyle: TextStyle(
                              fontFamily: Utils.fontfamily,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0XFFB9BAC8)),
                        ),
                      ),
                    ),
                  ],
                ),
                Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 24, right: 24, top: 25),
                      height: 56,

                      // width: MediaQuery.of(context).size.width*0.80,
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0XFFE8E8E8), width: 1),
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 18, left: 40, right: 133),
                      child: Container(
                        height: 17,
                        width: 67,
                        child: Center(
                          child: Utils.text('Username', Utils.fontfamily,
                              Color(0xFF1E263C), FontWeight.w400, 14),
                        ),
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 30, right: 50, left: 45),
                      child: TextField(
                        controller: userNameController,
                        onChanged: (value) async {
                          await checkUserName(value.toString());
                          if (value.toString().length > 0) {
                            showUserNameSuffixIcon = true;
                          } else {
                            showUserNameSuffixIcon = false;
                          }
                          setState(() {});
                        },
                        decoration: new InputDecoration(
                          border: InputBorder.none,
                          suffix: (showUserNameSuffixIcon && !_isAlreayUsername)
                              ? SizedBox(
                                  height: 7,
                                  width: 12,
                                  child: ImageIcon(
                                    AssetImage(Utils.tickIcon),
                                    color: Color(0xFF00B227),
                                  ))
                              : _isAlreayUsername
                              ?  SizedBox(
                                  height: 12,
                                  width: 12,
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 17
                                  ))
                              :Container(width: 2),
                          focusColor: Color(0xFFB9BAC8),
                          hintText: 'Enter Username',
                          hintStyle: TextStyle(
                              fontFamily: Utils.fontfamily,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0XFFB9BAC8)),
                              labelText: _isAlreayUsername ? "This username is already taken." : null,
                              labelStyle: TextStyle(
                                  fontFamily: Utils.fontfamily,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
                Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 24, right: 24, top: 25),
                      height: 56,

                      // width: MediaQuery.of(context).size.width*0.80,
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0XFFE8E8E8), width: 1),
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 18, left: 45, right: 133),
                      child: Container(
                        height: 17,
                        width: 40,
                        child: Center(
                          child: Utils.text('Email', Utils.fontfamily,
                              Color(0xFF1E263C), FontWeight.w400, 14),
                        ),
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 30, right: 50, left: 48),
                      child: TextField(
                        controller: emailController,
                        onChanged: (value) {
                          Pattern pattern =
                              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                          RegExp regex = new RegExp(pattern);
                          if (emailController.value.text.trim().isEmpty) {
                            isEmailError = true;
                          } else if (!regex
                              .hasMatch(emailController.value.text.trim())) {
                            isEmailError = true;
                            showEmailSuffixIcon = false;
                            setState(() {});
                          } else if (regex
                              .hasMatch(emailController.value.text.trim())) {
                            isEmailError = false;
                            showEmailSuffixIcon = true;
                            setState(() {});
                          } else {
                            isEmailError = false;
                          }
                        },
                        decoration: new InputDecoration(
                          border: InputBorder.none,
                          suffix: showEmailSuffixIcon
                              ? SizedBox(
                                  height: 7,
                                  width: 12,
                                  child: ImageIcon(
                                    AssetImage(Utils.tickIcon),
                                    color: Color(0xFF00B227),
                                  ))
                              : Container(width: 2),
                          focusColor: Color(0xFFB9BAC8),
                          hintText: 'Enter email',
                          hintStyle: TextStyle(
                              fontFamily: Utils.fontfamily,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0XFFB9BAC8)),
                        ),
                      ),
                    ),
                  ],
                ),
                Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 24, right: 24, top: 25),
                      height: 56,

                      // width: MediaQuery.of(context).size.width*0.80,
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0XFFE8E8E8), width: 1),
                          borderRadius: BorderRadius.circular(8)),
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
                                pickerBuilder:
                                    (context, CountryCode countryCode) {
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

                                    countryCodeWithoutPlus =
                                        countryCode.replaceAll(
                                            new RegExp(r'[^\w\s]+'), '');
                                  });
                                },
                                // Whether to allow the widget to set a custom UI overlay
                                useUiOverlay: true,
                                // Whether the country list should be wrapped in a SafeArea
                                useSafeArea: false),
                          ),
                          Container(
                            height: 26,
                            width: 1,
                            color: Color(0XFFDCDEEE),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: TextField(
                                keyboardType: TextInputType.phone,
                                controller: phoneController,
                                onChanged: (value) {
                                  if (phoneController.text.length == 10) {
                                    showPhoneNumberSuffixIcon = true;
                                  } else {
                                    showPhoneNumberSuffixIcon = false;
                                  }
                                  setState(() {});
                                },
                                decoration: new InputDecoration(
                                  border: InputBorder.none,
                                  suffix: showPhoneNumberSuffixIcon
                                      ? SizedBox(
                                          height: 7,
                                          width: 12,
                                          child: ImageIcon(
                                            AssetImage(Utils.tickIcon),
                                            color: Color(0xFF00B227),
                                          ))
                                      : Container(width: 2),
                                  focusColor: Color(0xFFB9BAC8),
                                  hintText: 'Phone Number',
                                  hintStyle: TextStyle(
                                      fontFamily: Utils.fontfamily,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: Color(0XFFB9BAC8)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 18, left: 45, right: 133),
                      child: Container(
                        height: 17,
                        width: 50,
                        child: Utils.text('Phone', Utils.fontfamily,
                            Color(0xFF1E263C), FontWeight.w400, 14),
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
                InkWell(
                  onTap: () {
                    // checkValids();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordForm()));
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 20, left: 24, right: 24),
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
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
                        child: Utils.text('Sign Up', Utils.fontfamily,
                            Color(0xFFFFFFFF), FontWeight.w400, 18)),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(top: 20, left: 30, right: 30),
                  alignment: Alignment.center,
                  child: Text.rich(
                    TextSpan(
                      text:
                          'By creating an account, you agree to the \nCompany’s ',
                      style: TextStyle(
                          color: AppColors.lightGreyColor,
                          fontSize: 13,
                          fontFamily: Utils.fontfamilyInter,
                          fontWeight: FontWeight.w400),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              fontFamily: Utils.fontfamilyInter,
                              fontSize: 13,
                              color: Utils.notNowColor,
                              decoration: TextDecoration.underline,
                            )),
                        TextSpan(
                            text: ' and ',
                            style: TextStyle(
                              fontFamily: Utils.fontfamilyInter,
                              fontSize: 13,
                              color: Color(0xFF6B7285),
                            )),
                        TextSpan(
                            text: 'Privacy Policy.',
                            style: TextStyle(
                              fontFamily: Utils.fontfamilyInter,
                              fontSize: 13,
                              color: Utils.notNowColor,
                              decoration: TextDecoration.underline,
                            ))
                        // can add more TextSpans here...
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> checkUserName(userName) async {
    // check forum is liked or not
    var contain = userNameLists.where((element) => element == userName) ;

    if(contain.isEmpty) _isAlreayUsername = false;
    else _isAlreayUsername = true ;
  }

  void getUserNames() async {

    var collectionReference =
    FirebaseFirestore.instance.collection(Constants.UsersFB).get();
    await collectionReference.then((value) {
      final List<DocumentSnapshot> docs = value.docs;
      docs.forEach((data) {
        final Map<String, dynamic> dataMap = data.data();
        userNameLists.add(dataMap['userName']);
        if (data.id == value.docs[value.docs.length - 1].id) {
          setState(() {});
        }
      });
    }).catchError((onError) {
    });
  }

  Future<void> checkValids() async {

    if (fullNameController.text.isEmpty) {
      Constants.showSnackBarWithMessage(
          "Enter full name", _scaffoldkey, context, Colors.red[700]);
    } else if (emailController.text.isEmpty || isEmailError) {
      Constants.showSnackBarWithMessage(
          "Enter valid email", _scaffoldkey, context, Colors.red[700]);
    } else if (userNameController.text.isEmpty) {
      Constants.showSnackBarWithMessage(
          "Enter user name", _scaffoldkey, context, Colors.red[700]);
    } else if (phoneController.text.isEmpty) {
      Constants.showSnackBarWithMessage(
          "Enter valid phone number", _scaffoldkey, context, Colors.red[700]);
    } else {
      // in every thing is ok. then go to OTP Screen.

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return SendOtpScren(
              openFromLogin: false,
              countryCode: countryCode.toString().replaceAll("+", ""),
              userName: fullNameController.value.text.toString(),
              email: emailController.value.text.toString(),
              phoneNumber: phoneController.value.text,
              userImage: null,
              fromWhich: 'register',
            );
          },
        ),
      );
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
        QuerySnapshot _query = await FirebaseFirestore.instance
            .collection(Constants.UsersFB)
            .where(Constants.countryCodeFB, isEqualTo: countryCodeWithoutPlus)
            .where(Constants.phoneFB,
                isEqualTo: phoneController.value.text.trim())
            .get();

        // in this check is user phone no. and country code exist in database. if already exist then show error.

        if (_query != null) {
          if (_query.docs.length > 0) {
            _showLoading = false;
            if (mounted) {
              setState(() {});
            }
            Constants.showSnackBarWithMessage(
                "User already exist. Please login.",
                _scaffoldkey,
                context,
                Colors.red[700]);
          } else {
            // in this check is user email exist in database. if user not contains then go further process otherwise show error msg.

            String email = emailController.value.text.trim().toString();
            QuerySnapshot _queryEmail = await FirebaseFirestore.instance
                .collection(Constants.UsersFB)
                .where(Constants.userEmailFB, isEqualTo: email)
                .get();
            if (_queryEmail != null) {
              if (_queryEmail.docs.length > 0) {
                _showLoading = false;
                if (mounted) {
                  setState(() {});
                }
                Constants.showSnackBarWithMessage(
                    "Email already exist. Please enter different email.",
                    _scaffoldkey,
                    context,
                    Colors.red[700]);
              } else {
                _showLoading = false;
                if (mounted) {
                  setState(() {});
                }

                // in every thing is ok. then go to OTP Screen.

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return OtpVerficationScreen(
                        openFromLogin: false,
                        countryCode: countryCodeWithoutPlus,
                        userName: fullNameController.value.text.toString(),
                        email: emailController.value.text.toString(),
                        phoneNumber: phoneController.value.text,
                        userImage: null,
                        fromWhich: 'register',
                      );
                    },
                  ),
                );
              }
            }
          }
        }
      }
    } on SocketException catch (_) {
      Constants.showSnackBarWithMessage(
          Constants.noInternet, _scaffoldkey, context, AppColors.yellowColor);
    }
  }
}
