import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_version/get_version.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:solstice/model/forum_model_new.dart';
import 'package:solstice/model/loginRegister/user_response_fb.dart';
import 'package:solstice/pages/home_screen.dart';
import 'package:solstice/pages/onboardingflow/profiletypescreen.dart';
import 'package:solstice/pages/onboardingflow/push_notification_Screen.dart';
import 'package:solstice/pages/onboardingflow/signup_screen2.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/my_navigator.dart';
import 'package:solstice/utils/shared_preferences.dart';

class SendOtpScren extends StatefulWidget {
  bool openFromLogin = false;
  String email, countryCode, userName, phoneNumber, fromWhich;
  File userImage;
  SendOtpScren({
    @required this.openFromLogin,
    @required this.countryCode,
    @required this.userName,
    @required this.email,
    @required this.phoneNumber,
    @required this.userImage,
    @required this.fromWhich,
  });

  @override
  _SendOtpScrenState createState() => _SendOtpScrenState();
}

class _SendOtpScrenState extends State<SendOtpScren> {
  TextEditingController key1 = new TextEditingController();
  TextEditingController key2 = new TextEditingController();
  TextEditingController key3 = new TextEditingController();
  TextEditingController key4 = new TextEditingController();
  TextEditingController key5 = new TextEditingController();
  TextEditingController key6 = new TextEditingController();

  FocusNode focusNodeKey1,
      focusNodeKey2,
      focusNodeKey3,
      focusNodeKey4,
      focusNodeKey5,
      focusNodeKey6;
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  String phoneErrorMessage = "";
  String pinCode = "";
  bool isPhoneError = true;
  bool isBtnEnable = false;
  bool isTimerRunning = false;
  bool showSendbutton = false;

  int _start = 60;
  bool _showLoading = false;
  String countryCodeWithoutPlus = "";
  String deviceType = "";
  String oneSignalID = "";
  String appVersion = "";
  AuthCredential _phoneAuthCredential;
  String _verificationId;

  User _firebaseUser;
  String _status;
  String _selectedImageUrl = "";

  @override
  void initState() {
    super.initState();
    focusNodeKey1 = FocusNode();
    focusNodeKey2 = FocusNode();
    focusNodeKey3 = FocusNode();
    focusNodeKey4 = FocusNode();
    focusNodeKey5 = FocusNode();
    focusNodeKey6 = FocusNode();

    getApplicationConfigurationDetails();

    _submitPhoneNumber();
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

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
        // onPressed: () {},
        onPressed: () => Navigator.of(context).pop(),
      ),
      elevation: 0,
      // actions: [
      //   Center(
      //     child: Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 20.0),
      //         child: Image.asset("assets/images/help.png", height: 26, width: 26)),
      //   )
      // ],
    );
    return ModalProgressHUD(
      inAsyncCall: _showLoading,
      opacity: 0.4,
      progressIndicator: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        strokeWidth: 5.0,
      ),
      child: Scaffold(
        appBar: appBar,
        key: _scaffoldkey,
        backgroundColor: Color(0XFFFFFFFFF),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 124, right: 124),
                child: Image(image: AssetImage(Utils.sendotpScreenlogo)),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Verify Your Identity',
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontFamily: Utils.fontfamily,
                    color: Color(0XFF1F1F1F),
                    fontSize: 24),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24, right: 84, left: 84),
                child: Text(
                  'Enter the verification code we’ve sent you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontFamily: Utils.fontfamily,
                      color: Color(0XFF7A7A7A),
                      fontSize: 16),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Container(
                      height: MediaQuery.of(context).size.width / 7.5,
                      width: MediaQuery.of(context).size.width / 7.5,
                      decoration: BoxDecoration(
                          color: Color(0XFFF5F6F9),
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: Center(
                        child: TextField(
                          keyboardType: TextInputType.numberWithOptions(
                              decimal: false, signed: true),
                          maxLength: 1,
                          controller: key1,
                          focusNode: focusNodeKey1,
                          showCursor: true,
                          readOnly: true,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {},
                          decoration: InputDecoration(
                              hintText: "",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "roboto_regular",
                                  fontSize: 20),
                              contentPadding:
                                  EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 7.0),
                              // counterStyle: TextStyle(
                              //   height: double.minPositive,
                              // ),
                              counterText: ""),
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "roboto_regular",
                              fontWeight: FontWeight.w700,
                              fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 9, top: 60),
                    child: Container(
                      height: MediaQuery.of(context).size.width / 7.5,
                      width: MediaQuery.of(context).size.width / 7.5,
                      decoration: BoxDecoration(
                          color: Color(0XFFF5F6F9),
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: Center(
                        child: TextField(
                          keyboardType: TextInputType.numberWithOptions(
                              decimal: false, signed: true),
                          maxLength: 1,
                          focusNode: focusNodeKey2,
                          controller: key2,
                          readOnly: true,
                          showCursor: true,
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {},
                          decoration: InputDecoration(
                              hintText: "",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "roboto_regular",
                                  fontSize: 20),
                              contentPadding:
                                  EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 7.0),
                              // counterStyle: TextStyle(
                              //   height: double.minPositive,
                              // ),
                              counterText: ""),
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "roboto_regular",
                              fontWeight: FontWeight.w700,
                              fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 9, top: 60),
                    child: Container(
                      height: MediaQuery.of(context).size.width / 7.5,
                      width: MediaQuery.of(context).size.width / 7.5,
                      decoration: BoxDecoration(
                          color: Color(0XFFF5F6F9),
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: Center(
                        child: TextField(
                          keyboardType: TextInputType.numberWithOptions(
                              decimal: false, signed: true),
                          maxLength: 1,
                          focusNode: focusNodeKey3,
                          controller: key3,
                          readOnly: true,
                          showCursor: true,
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {},
                          decoration: InputDecoration(
                              hintText: "",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "roboto_regular",
                                  fontSize: 20),
                              contentPadding:
                                  EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 7.0),
                              // counterStyle: TextStyle(
                              //   height: double.minPositive,
                              // ),
                              counterText: ""),
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "roboto_regular",
                              fontWeight: FontWeight.w700,
                              fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 9, top: 60),
                    child: Container(
                      height: MediaQuery.of(context).size.width / 7.5,
                      width: MediaQuery.of(context).size.width / 7.5,
                      decoration: BoxDecoration(
                          color: Color(0XFFF5F6F9),
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: Center(
                        child: TextField(
                          keyboardType: TextInputType.numberWithOptions(
                              decimal: false, signed: true),
                          maxLength: 1,
                          focusNode: focusNodeKey4,
                          controller: key4,
                          readOnly: true,
                          showCursor: true,
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {},
                          decoration: InputDecoration(
                              hintText: "",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "roboto_regular",
                                  fontSize: 20),
                              contentPadding:
                                  EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 7.0),
                              // counterStyle: TextStyle(
                              //   height: double.minPositive,
                              // ),
                              counterText: ""),
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "roboto_regular",
                              fontWeight: FontWeight.w700,
                              fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 9, top: 60),
                    child: Container(
                      height: MediaQuery.of(context).size.width / 7.5,
                      width: MediaQuery.of(context).size.width / 7.5,
                      decoration: BoxDecoration(
                          color: Color(0XFFF5F6F9),
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: Center(
                        child: TextField(
                          keyboardType: TextInputType.numberWithOptions(
                              decimal: false, signed: true),
                          maxLength: 1,
                          focusNode: focusNodeKey5,
                          controller: key5,
                          readOnly: true,
                          showCursor: true,
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {},
                          decoration: InputDecoration(
                              hintText: "",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "roboto_regular",
                                  fontSize: 20),
                              contentPadding:
                                  EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 7.0),
                              // counterStyle: TextStyle(
                              //   height: double.minPositive,
                              // ),
                              counterText: ""),
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "roboto_regular",
                              fontWeight: FontWeight.w700,
                              fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 9, top: 60),
                    child: Container(
                      height: MediaQuery.of(context).size.width / 7.5,
                      width: MediaQuery.of(context).size.width / 7.5,
                      decoration: BoxDecoration(
                          color: Color(0XFFF5F6F9),
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: Center(
                        child: TextField(
                          keyboardType: TextInputType.numberWithOptions(
                              decimal: false, signed: true),
                          maxLength: 1,
                          focusNode: focusNodeKey6,
                          controller: key6,
                          readOnly: true,
                          showCursor: true,
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {},
                          decoration: InputDecoration(
                              hintText: "",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "roboto_regular",
                                  fontSize: 20),
                              contentPadding:
                                  EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 7.0),
                              // counterStyle: TextStyle(
                              //   height: double.minPositive,
                              // ),
                              counterText: ""),
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "roboto_regular",
                              fontWeight: FontWeight.w700,
                              fontSize: 20),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 70,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        checkFocus("1");
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '1',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: Utils.fontfamily,
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: Color(0XFF333333)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        checkFocus("2");
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '2',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: Utils.fontfamily,
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: Color(0XFF333333)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        checkFocus("3");
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '3',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: Utils.fontfamily,
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: Color(0XFF333333)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 24,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        checkFocus("4");
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '4',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: Utils.fontfamily,
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: Color(0XFF333333)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        checkFocus("5");
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '5',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: Utils.fontfamily,
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: Color(0XFF333333)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        checkFocus("6");
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '6',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: Utils.fontfamily,
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: Color(0XFF333333)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 24,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        checkFocus("7");
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '7',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: Utils.fontfamily,
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: Color(0XFF333333)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        checkFocus("8");
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '8',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: Utils.fontfamily,
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: Color(0XFF333333)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        checkFocus("9");
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '9',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: Utils.fontfamily,
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: Color(0XFF333333)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 24,
              ),
              Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: InkWell(
                          onTap: () {
                            _submitOTP();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            alignment: Alignment.center,
                            child: InkWell(
                                onTap: () {
                                  _submitOTP();
                                },
                                child: showSendbutton
                                    ? Icon(Icons.send)
                                    : Container()),
                          ))),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        checkFocus("0");
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '0',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: Utils.fontfamily,
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: Color(0XFF333333)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        if (focusNodeKey1.hasFocus) {
                          key1.clear();
                        } else if (focusNodeKey2.hasFocus) {
                          key2.clear();
                          focusNodeKey2.unfocus();
                          focusNodeKey1.requestFocus();
                        } else if (focusNodeKey3.hasFocus) {
                          key3.clear();
                          focusNodeKey3.unfocus();
                          focusNodeKey2.requestFocus();
                        } else if (focusNodeKey4.hasFocus) {
                          key4.clear();
                          focusNodeKey4.unfocus();
                          focusNodeKey3.requestFocus();
                        } else if (focusNodeKey5.hasFocus) {
                          key5.clear();
                          focusNodeKey5.unfocus();
                          focusNodeKey4.requestFocus();
                        } else if (focusNodeKey6.hasFocus) {
                          key6.clear();
                          focusNodeKey6.unfocus();
                          focusNodeKey5.requestFocus();
                        }
                        showSendbutton = showSendbuttonFunc();
                        setState(() {});
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Icon(
                            Icons.backspace,
                          )),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 70, left: 48, right: 48),
                child: InkWell(
                    onTap: () {
                    
                      resendOtp();
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (BuildContext context) => ProfileTypeScreen()));
                    },
                    child: Text(
                      'Didn’t get it? Resend Verification Code',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0XFF283646)),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  void checkFocus(String setKey) {
    if (focusNodeKey1.hasFocus) {
      key1.text = setKey;
      focusNodeKey1.unfocus();
      focusNodeKey2.requestFocus();
    } else if (focusNodeKey2.hasFocus) {
      key2.text = setKey;
      focusNodeKey2.unfocus();
      focusNodeKey3.requestFocus();
    } else if (focusNodeKey3.hasFocus) {
      key3.text = setKey;
      focusNodeKey3.unfocus();
      focusNodeKey4.requestFocus();
    } else if (focusNodeKey4.hasFocus) {
      key4.text = setKey;
      focusNodeKey4.unfocus();
      focusNodeKey5.requestFocus();
    } else if (focusNodeKey5.hasFocus) {
      key5.text = setKey;
      focusNodeKey5.unfocus();
      focusNodeKey6.requestFocus();
    } else if (focusNodeKey6.hasFocus) {
      key6.text = setKey;
    }
    showSendbutton = showSendbuttonFunc();
    setState(() {});
  }

  bool showSendbuttonFunc() {
    if (key1.text.isNotEmpty &&
        key2.text.isNotEmpty &&
        key3.text.isNotEmpty &&
        key4.text.isNotEmpty &&
        key5.text.isNotEmpty &&
        key6.text.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _submitPhoneNumber() async {
    /// NOTE: Either append your phone number country code or add in the code itself
    /// Since I'm in India we use "+91 " as prefix `phoneNumber`
    String phoneNumber = "+" + widget.countryCode + " " + widget.phoneNumber;
    setState(() {
      _showLoading = true;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(milliseconds: 10000),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void verificationCompleted(AuthCredential phoneAuthCredential) {
    setState(() {
      _showLoading = false;
      _status += 'verificationCompleted\n';
    });
    this._phoneAuthCredential = phoneAuthCredential;
  }

  void verificationFailed(error) {
    _handleError(error);
  }

  void codeAutoRetrievalTimeout(String verificationId) {
    setState(() {
      _status += 'codeAutoRetrievalTimeout\n';
    });
  }

  void _handleError(e) {
    setState(() {
      _showLoading = false;
    });
    try {
      Constants.showSnackBarWithMessage(
          "" + e.message, _scaffoldkey, context, Colors.red[700]);
      _status += e.message + '\n';
    } catch (e) {}
  }

  void codeSent(String verificationId, [int code]) {
    this._verificationId = verificationId;
    setState(() {
      // startTimer();
      _showLoading = false;
      // _status += 'Code Sent\n';
    });
  }

  void _submitOTP() {
    /// get the `smsCode` from the user
    String smsCode =
        key1.text + key2.text + key3.text + key4.text + key5.text + key6.text;

    /// when used different phoneNumber other than the current (running) device
    /// we need to use OTP to get `phoneAuthCredential` which is inturn used to signIn/login
    this._phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: this._verificationId, smsCode: smsCode);
    _firebaseLogin();
  }

  Future<void> _firebaseLogin() async {
    /// This method is used to login the user
    /// `AuthCredential`(`_phoneAuthCredential`) is needed for the signIn method
    /// After the signIn method from AuthResult we can get `FirebaserUser`(`_firebaseUser`)
    setState(() {
      _showLoading = true;
    });

    try {
      await FirebaseAuth.instance
          .signInWithCredential(this._phoneAuthCredential)
          .then((authRes) {
        _firebaseUser = authRes.user;

        setState(() {
          try {
            String uId = _firebaseUser.uid;
            if (uId != null) {
              if (widget.openFromLogin) {
                loginUser(uId);
              } else {
                registerUser(uId);
              }
            }
          } catch (e) {}
        });
      }).catchError((e) => setState(() {
                _showLoading = false;

                Constants.showSnackBarWithMessage(
                    "Auth error!!", _scaffoldkey, context, Colors.red[700]);

                _status += 'Signed In\n';
              }));
    } catch (e) {
      _showLoading = false;
      setState(() {});
      Constants.showSnackBarWithMessage(
          "Auth error !!", _scaffoldkey, context, Colors.red[700]);
    }
  }

  Future<void> resendOtp() async {

     key1.clear();
     key2.clear();
     key3.clear();
     key4.clear();
     key5.clear();
     key6.clear();
   
    if (FocusScope.of(context).isFirstFocus) {
      FocusScope.of(context).requestFocus(new FocusNode());
    }
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _submitPhoneNumber();
      }
    } on SocketException catch (_) {
      Constants.showSnackBarWithMessage(
          Constants.noInternet, _scaffoldkey, context, AppColors.yellowColor);
    }
  }

  Future<void> loginUser(String uId) async {
    _showLoading = false;
    setState(() {});
    FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(uId)
        .update({
          'appVersion': appVersion,
          'device': deviceType,
          'lastLogin': DateTime.now().millisecondsSinceEpoch.toString(),
        })
        .then((docRef) {
          Constants.showSnackBarWithMessage("Login successfully!", _scaffoldkey,
              context, AppColors.greenColor);
          setState(() {
            navigatePage(uId);
            //uploadUserImage(uId);
          });
        })
        .timeout(Duration(seconds: 10))
        .catchError((error) {
          setState(() {
            _showLoading = false;
            Constants.showSnackBarWithMessage("Login error. Please try again.",
                _scaffoldkey, context, Colors.red[700]);
          });
        });
  }

  Future<void> registerUser(String uId) async {
    FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(uId)
        .set({
          Constants.userIdFB: uId,
          Constants.userNameFB: widget.userName,
          Constants.userImageFB: _selectedImageUrl,
          Constants.userEmailFB: widget.email,
          Constants.phoneFB: widget.phoneNumber,
          Constants.countryCodeFB: widget.countryCode,
          'appVersion': appVersion,
          'device': deviceType,
          'lastLogin': DateTime.now().millisecondsSinceEpoch.toString(),
        })
        .then((docRef) {
          Constants.showSnackBarWithMessage("Register successfully!",
              _scaffoldkey, context, AppColors.greenColor);
          setState(() {
            navigatePage(uId);
            //uploadUserImage(uId);
          });
        })
        .timeout(Duration(seconds: 10))
        .catchError((error) {
          setState(() {
            _showLoading = false;
            Constants.showSnackBarWithMessage(
                "Register error. Please try again.",
                _scaffoldkey,
                context,
                Colors.red[700]);
          });
        });
  }

  Future<void> navigatePage(String uId) async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(uId)
        .get();
    if (ds != null) {
      UserFirebaseModel userItem = UserFirebaseModel.fromSnapshot(ds);
      if (userItem != null) {
        SharedPref.saveIntInPrefs(
            Constants.PROFILE_COMEPLETE, userItem.profileCommplete);
        SharedPref.saveStringInPrefs(Constants.USER_ID, uId.toString());
        SharedPref.saveStringInPrefs(Constants.EMAIL, userItem.userEmail);
        SharedPref.saveStringInPrefs(Constants.USER_NAME, userItem.userName);
        SharedPref.saveStringInPrefs(Constants.PHONE_NO, userItem.phone);
        SharedPref.saveStringInPrefs(
            Constants.COUNTRY_CODE, userItem.country_code);
        SharedPref.saveStringInPrefs(
            Constants.PROFILE_IMAGE, userItem.userImage);
        globalUserId = uId.toString();
        globalUserName = userItem.userName;
        globaUserProfileImage = userItem.userImage;
        profileCompleteStatus = userItem.profileCommplete;

        SharedPref.saveBooleanInPrefs(Constants.LOGINSTATUS, true);

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => HomeScreen(currentIndex: 0,)),
            (route) => false);
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (BuildContext context) => PushNotificationScreen()));
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
}
