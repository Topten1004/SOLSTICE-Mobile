import 'dart:async';
import 'dart:io';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:solstice/apiservice/api_call.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/pages/register_login/otp_verification.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/my_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/utils/shared_preferences.dart';

class NewLoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<NewLoginScreen> implements ResponseInterFace{

  _LoginScreenState(){
    apiCall=ApiCall(this);
  }

  TextEditingController phoneController = new TextEditingController();
  final FocusNode _phoneFocus = new FocusNode();
  bool passwordVisible = true;
  ApiCall apiCall;
  String phoneErrorMessage = "";
  String pinCode = "";
  bool isPhoneError = true;
  String countryCode="91";
  String countryCodeWithoutPlus = "91";

  bool isBtnEnable = false;
  bool isTimerRunning = false;
  double _animatedHeight = 0.0;

  bool _showLoading=false;

  Timer _timer;
  int _start = 60;
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();


  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            isTimerRunning=false;
          });
        } else {
          setState(() {
            isTimerRunning=true;
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    if(_timer != null){
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      ),
    );
    return ModalProgressHUD(
      inAsyncCall: _showLoading,
      opacity: 0.4,
      progressIndicator: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          AppColors.primaryColor
        ),
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
                                                fontFamily:
                                                    Constants.regularFont),
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
                                        countryCode=code.code;
                                        countryCodeWithoutPlus = countryCode.replaceAll(new RegExp(r'[^\w\s]+'),'');
                                      },
                                      );
                                    },
                                    useUiOverlay: true,
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
                                      setState(() {
                                        if (phoneController.value.text.trim().isEmpty) {
                                          isPhoneError = true;
                                          phoneErrorMessage = Constants.enterPhoneError;
                                          _animatedHeight = 0.0;
                                          isBtnEnable=false;
                                        } else if ((phoneController.value.text.trim().length < 8) || (phoneController.value.text.trim().length > 12) ) {
                                          isPhoneError = true;
                                          phoneErrorMessage = Constants.enterValidPhoneError;
                                          _animatedHeight = 0.0;
                                          isBtnEnable=false;
                                        } else {
                                          isBtnEnable=true;
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
                              margin: const EdgeInsets.only(
                                  top: 3.0, left: 30.0, bottom: 3),
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
                                      top: ScreenUtil().setSp(12),
                                      bottom: ScreenUtil().setSp(30)),
                                  child: PinEntryTextField(
                                    fontSize: ScreenUtil().setSp(42),
                                    fieldWidth: ScreenUtil().setSp(68),
                                    fields: 5,
                                    onSubmit: (String pin) {
                                      setState(() {
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            Constants.didnotReceiveCode,
                                            style: TextStyle(
                                                color: AppColors.accentColor,
                                                fontSize:
                                                    ScreenUtil().setSp(26),
                                                fontFamily:
                                                    Constants.regularFont,
                                                fontWeight: FontWeight.normal),
                                          ),
                                          SizedBox(width: 4),
                                          new GestureDetector(
                                              child: Text(
                                                Constants.resend,
                                                style: TextStyle(
                                                    decoration: TextDecoration
                                                        .underline,
                                                    color:
                                                        AppColors.primaryColor,
                                                    fontFamily:
                                                        Constants.regularFont,
                                                    fontSize:
                                                        ScreenUtil().setSp(27),
                                                    fontWeight:
                                                        FontWeight.w300),
                                              ),
                                              onTap: () {
                                                MyNavigator.goToLogin(context);
                                                // do what you need to do when "Click here" gets clicked
                                              },
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          GestureDetector(
                                            child: Text(
                                              "Resend code in: $_start",
                                              style: TextStyle(
                                                  color: AppColors.accentColor,
                                                  fontSize:
                                                      ScreenUtil().setSp(26),
                                                  fontFamily:
                                                      Constants.regularFont,
                                                  fontWeight: FontWeight.normal),
                                            ),
                                            onTap: (){
                                               },
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
                              child: Text(Constants.sendCode,
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


  Future<void> sendOtp() async {
    if(FocusScope.of(context).isFirstFocus) {
      FocusScope.of(context).requestFocus(new FocusNode());
    }
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          _showLoading=true;
        });
        Map body={
          'phone':phoneController.value.text,
          'country_code':countryCodeWithoutPlus,
          'is_register':'login'
        };
        apiCall.hitPostApi(UrlConstant.sendOtp,body,'',UrlConstant.sendOtpCode);
      }
    } on SocketException catch (_) {
      Constants.showSnackBarWithMessage(Constants.noInternet,_scaffoldkey, context, AppColors.yellowColor);
    }
  }


  @override
  void onFailure(int code, String message) {
    setState(() {
      _showLoading=false;
    });
    Constants.showSnackBarWithMessage(""+message, _scaffoldkey,context, Colors.red[700]);

  }

  @override
  void onSuccess(Object data,int code) {
    setState(() {
      _showLoading=false;
    });
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) {
        return OtpVerficationScreen(
          openFromLogin: true,
          countryCode: countryCodeWithoutPlus,
          userName: '',
          email: '',
          phoneNumber: phoneController.value.text, fromWhich: 'login',);
      },
    ),
    );
  }
}
