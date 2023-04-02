import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_version/get_version.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:solstice/apiservice/api_call.dart';
import 'package:solstice/apiservice/models/common_message_model.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/loginRegister/user_response_fb.dart';
import 'package:solstice/model/loginRegister/user_response_model.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/my_navigator.dart';
import 'package:solstice/utils/shared_preferences.dart';
import 'package:solstice/utils/globals.dart' as globals;

// ignore: must_be_immutable
class OtpVerficationScreen extends StatefulWidget {
  bool openFromLogin = false;
  String email, countryCode, userName, phoneNumber, fromWhich;
  File userImage;

  OtpVerficationScreen({
    @required this.openFromLogin,
    @required this.countryCode,
    @required this.userName,
    @required this.email,
    @required this.phoneNumber,
    @required this.userImage,
    @required this.fromWhich,
  });

  @override
  _OtpVerficationScreenState createState() => _OtpVerficationScreenState();
}

class _OtpVerficationScreenState extends State<OtpVerficationScreen> implements ResponseInterFace {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  bool passwordVisible = true;
  String phoneErrorMessage = "";
  String pinCode = "";
  bool isPhoneError = true;
  bool isBtnEnable = false;
  bool isTimerRunning = false;
  Timer _timer;
  int _start = 60;
  ApiCall apiCall;
  bool _showLoading = false;
  String countryCodeWithoutPlus = "";
  String deviceType = "";
  String oneSignalID = "";
  String appVersion = "";

  User _firebaseUser;
  String _status;
  String _selectedImageUrl = "";

  AuthCredential _phoneAuthCredential;
  String _verificationId;
  int _code;

  _OtpVerficationScreenState() {
    apiCall = ApiCall(this);
  }

  // timer for resend code
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

  // on screen dispose stop timer.
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
    // get country code from register and login and remove '+' from string.
    if (widget.countryCode != null) {
      countryCodeWithoutPlus = widget.countryCode;
      countryCodeWithoutPlus = countryCodeWithoutPlus.replaceAll(new RegExp(r'[^\w\s]+'), '');
    }

    // get app version and app type
    getApplicationConfigurationDetails();

    // if every thing is available( phone no. and country code) then hit for phone authentication.
    _submitPhoneNumber();
  }

  // get app version and app type
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

  Future<bool> _onBackPressed() async {
    Navigator.pop(context);
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
        child: WillPopScope(
          onWillPop: _onBackPressed,
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
                            Constants.otpVerification,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  Constants.otp_verification,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: ScreenUtil().setSp(38),
                                      fontFamily: Constants.boldFont),
                                ),
                              ],
                            ),
                            SizedBox(height: ScreenUtil().setSp(52)),
                            Column(
                              children: [
                                Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.only(
                                      top: ScreenUtil().setSp(12), bottom: ScreenUtil().setSp(30)),
                                  child: OTPTextField(
                                    length: 6,
                                    width: MediaQuery.of(context).size.width,
                                    fieldWidth: 40,
                                    style: TextStyle(fontSize: 17),
                                    textFieldAlignment: MainAxisAlignment.spaceAround,
                                    fieldStyle: FieldStyle.underline,
                                    onCompleted: (pin) {
                                      pinCode = pin;
                                      if (pin.length == 6) {
                                        isBtnEnable = true;
                                      } else {
                                        isBtnEnable = false;
                                      }
                                    },
                                  ),

                                  // PinEntryTextField(
                                  //   fontSize: ScreenUtil().setSp(42),
                                  //   fieldWidth: ScreenUtil().setSp(68),
                                  //   fields: 6,
                                  //   onSubmit: (String pin) {
                                  //     setState(() {
                                  //       pinCode = pin;
                                  //       if (pin.length == 6) {
                                  //         isBtnEnable = true;
                                  //       } else {
                                  //         isBtnEnable = false;
                                  //       }
                                  //     });
                                  //   }, // end onSubmit
                                  // ),
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
                                              resendOtp();
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
                                          : AppColors.primaryColor),
                                ),
                                onPressed: () {
                                  if (isBtnEnable) {
                                    _submitOTP();

                                    /*if(widget.openFromLogin){
                                      loginUser();
                                    }else{
                                      registerUser();
                                    }*/
                                  }
                                },
                                color: isBtnEnable == false
                                    ? AppColors.accentColor
                                    : AppColors.primaryColor,
                                textColor: Colors.white,
                                padding: EdgeInsets.all(10.0),
                                child: Text(Constants.verifiedOtp,
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
                                new GestureDetector(
                                    child: Text("Change Number?",
                                        style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontFamily: Constants.regularFont,
                                            fontSize: ScreenUtil().setSp(28),
                                            fontWeight: FontWeight.w300)),
                                    onTap: () {
                                      Navigator.pop(context);
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
        ),
      ),
    );
  }

  void _submitOTP() {
    /// get the `smsCode` from the user
    String smsCode = pinCode;

    /// when used different phoneNumber other than the current (running) device
    /// we need to use OTP to get `phoneAuthCredential` which is inturn used to signIn/login
    this._phoneAuthCredential =
        PhoneAuthProvider.credential(verificationId: this._verificationId, smsCode: smsCode);

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
      await FirebaseAuth.instance.signInWithCredential(this._phoneAuthCredential).then((authRes) {
        _firebaseUser = authRes.user;

        setState(() {
          try {
            String uId = _firebaseUser.uid;
            if (uId != null) {
              if (widget.openFromLogin) {
                loginUser(uId);
              } else {
                if (widget.userImage != null &&
                    widget.userImage != "null" &&
                    widget.userImage != "") {
                  uploadUserImage(uId);
                } else {
                  registerUser(uId);
                }
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
      Constants.showSnackBarWithMessage("Auth error !!", _scaffoldkey, context, Colors.red[700]);
    }
  }

  Future<void> resendOtp() async {
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
          Constants.showSnackBarWithMessage(
              "Login successfully!", _scaffoldkey, context, AppColors.greenColor);
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
                "Login error. Please try again.", _scaffoldkey, context, Colors.red[700]);
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
          Constants.showSnackBarWithMessage(
              "Register successfully!", _scaffoldkey, context, AppColors.greenColor);
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
                "Register error. Please try again.", _scaffoldkey, context, Colors.red[700]);
          });
        });
  }

  Future<void> uploadUserImage(String uId) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var reference = FirebaseStorage.instance.ref().child("userImages").child(fileName);
    UploadTask uploadTask = reference.putFile(widget.userImage);

    uploadTask.whenComplete(() {
      reference.getDownloadURL().then((downloadUrl) {
        _selectedImageUrl = downloadUrl;
        setState(() {
          _showLoading = false;
          registerUser(uId);
        });
      }, onError: (err) {
        setState(() {
          _showLoading = false;
        });
        Constants.showSnackBarWithMessage(
            "This file is not an image", _scaffoldkey, context, Colors.red[700]);
      });
    });

    /* try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          _isShowLoader = true;
        });
        //Constants().warningToast(selectedFormatedStartDate+"  --  "+selectedFormatedEndDate);

        ApiCall.callUploadChatImageApi(_selectedImageUrl,tokenPref, this);
      }
    } on SocketException catch (_) {
      Constants().warningToast(Translations.of(context).noInternet);
    }*/
  }

  // navigate page to home page. after success.
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
        if (widget.openFromLogin) {
          MyNavigator.goToHome(context);
        } else {
          MyNavigator.goToAboutYou(context);
        }
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

  @override
  void onFailure(int code, String message) {
    setState(() {
      _showLoading = false;
    });
    Constants.showSnackBarWithMessage("" + message, _scaffoldkey, context, Colors.red[700]);
  }

  @override
  void onSuccess(Object data, int code) {
    setState(() {
      _showLoading = false;
    });

    if (code == UrlConstant.loginCode || code == UrlConstant.registerCode) {
      UserResponseModel userData = UserResponseModel.fromJson(data);
      if (userData != null) {
        globals.userDataModel = userData.data;
        String userId = userData.data.id;
        SharedPref.saveStringInPrefs(Constants.USER_ID, userData.data.id.toString());
        SharedPref.saveStringInPrefs(Constants.EMAIL, userData.data.email);
        SharedPref.saveStringInPrefs(Constants.USER_NAME, userData.data.name);
        SharedPref.saveStringInPrefs(Constants.PHONE_NO, userData.data.phone);
        SharedPref.saveStringInPrefs(Constants.LOGIN_RESPONSE, jsonEncode(userData.data));
        SharedPref.saveBooleanInPrefs(Constants.LOGINSTATUS, true);
        SharedPref.saveStringInPrefs(Constants.TOKEN, userData.token);

        String tempImage = "https://images.hindustantimes.com/Images/popup/2015/7/Crunches.jpg";

        //SharedPref.saveStringInPrefs(Constants.PROFILE_IMAGE, userData.data.image);
        SharedPref.saveStringInPrefs(Constants.PROFILE_IMAGE, tempImage);

        SharedPref.saveBooleanInPrefs(Constants.LOGINSTATUS, true);
        FirebaseFirestore.instance.collection(Constants.UsersFB).doc(userId).set({
          Constants.userIdFB: userId,
          Constants.userNameFB: userData.data.name.toString(),
          Constants.userImageFB: tempImage.toString()
        });

        if (code == UrlConstant.registerCode) {
          MyNavigator.goToAboutYou(context);
        } else {
          MyNavigator.goToHome(context);
        }
      }
    } else if (code == UrlConstant.sendOtpCode) {
      final CommonMessageModel commonMessageModel = CommonMessageModel.fromJson(data);
      Constants.showSnackBarWithMessage(
          "" + commonMessageModel.message, _scaffoldkey, context, AppColors.primaryColor);
    }
  }

  // if every thing is available( phone no. and country code) then hit for phone authentication.
  Future<void> _submitPhoneNumber() async {
    /// NOTE: Either append your phone number country code or add in the code itself
    /// Since I'm in India we use "+91 " as prefix `phoneNumber`
    String phoneNumber = "+" + countryCodeWithoutPlus + " " + widget.phoneNumber;
    setState(() {
      _showLoading = true;
    });

    /// The below functions are the callbacks, separated so as to make code more redable
    void verificationCompleted(AuthCredential phoneAuthCredential) {
      setState(() {
        _showLoading = false;
        _status += 'verificationCompleted\n';
      });
      this._phoneAuthCredential = phoneAuthCredential;
    }

    void codeSent(String verificationId, [int code]) {
      this._verificationId = verificationId;
      this._code = code;
      setState(() {
        startTimer();
        _showLoading = false;
        _status += 'Code Sent\n';
      });
    }

    void codeAutoRetrievalTimeout(String verificationId) {
      setState(() {
        _status += 'codeAutoRetrievalTimeout\n';
      });
    }

    void verificationFailed(error) {
      _handleError(error);
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      /// Make sure to prefix with your country code
      phoneNumber: phoneNumber,

      /// `seconds` didn't work. The underlying implementation code only reads in `millisenconds`
      timeout: Duration(milliseconds: 10000),

      /// If the SIM (with phoneNumber) is in the current device this function is called.
      /// This function gives `AuthCredential`. Moreover `login` function can be called from this callback
      /// When this function is called there is no need to enter the OTP, you can click on Login button to sigin directly as the device is now verified
      verificationCompleted: verificationCompleted,

      /// Called when the verification is failed
      verificationFailed: verificationFailed,

      /// This is called after the OTP is sent. Gives a `verificationId` and `code`
      codeSent: codeSent,

      /// After automatic code retrival `tmeout` this function is called
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    ); // All the callbacks are above
  }

  void _handleError(e) {
    setState(() {
      _showLoading = false;
    });
    try {
      Constants.showSnackBarWithMessage("" + e.message, _scaffoldkey, context, Colors.red[700]);
      _status += e.message + '\n';
    } catch (e) {}
  }

  // for print long log
  void printLongString(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }
}
