import 'dart:io';

import 'package:country_list_pick/country_list_pick.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:solstice/apiservice/api_call.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/pages/register_login/otp_verification.dart';
import 'package:solstice/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';

class NewRegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<NewRegisterScreen> implements ResponseInterFace{
  TextEditingController firstNameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();

  final FocusNode _firstNameFocus = new FocusNode();
  final FocusNode _emailFocus = new FocusNode();
  final FocusNode _phoneFocus = new FocusNode();

  bool isBtnEnable = false;
  String fNameErrorMessage = "";
  String emailErrorMessage = "";
  String phoneErrorMessage = "";
  String countryCode="91";
  String countryCodeWithoutPlus = "91";

  bool isFirstNameError = true;
  bool isEmailError = true;
  bool isPhoneError = true;
  bool _showLoading=false;
  var imageFile = null;
  ApiCall apiCall;
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  _RegisterScreenState(){
    apiCall=ApiCall(this);
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
  }

  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

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
                          Constants.letsGetStarted,
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
                  child: Padding(
                    padding: EdgeInsets.all(25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 0),
                        Text(
                          Constants.signup,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: ScreenUtil().setSp(38),
                              fontFamily: Constants.boldFont),
                        ),
                        //SizedBox(height: 20),
                        // InkWell(
                        //   onTap: () {
                        //     _settingModalBottomSheet(context);
                        //   },
                        //   child: imageFile == null
                        //       ? DottedBorder(
                        //           padding: EdgeInsets.all(
                        //             ScreenUtil().setSp(40),
                        //           ),
                        //           borderType: BorderType.RRect,
                        //           color: Color(0xFF1A58E7).withOpacity(0.7),
                        //           radius: Radius.circular(10),
                        //           dashPattern: [2.5, 4, 2, 4],
                        //           strokeWidth: 1.5,
                        //           child: SvgPicture.asset(
                        //             'assets/images/ic_media_image.svg',
                        //             fit: BoxFit.contain,
                        //           ),
                        //         )
                        //       : Container(
                        //           child: PhysicalModel(
                        //             borderRadius: BorderRadius.circular(10),
                        //             color: Colors.grey,
                        //             elevation: 5,
                        //             shadowColor: Colors.green[400],
                        //             child: ClipRRect(
                        //               borderRadius: BorderRadius.circular(10),
                        //               child: Image.file(
                        //                 imageFile,
                        //                 fit: BoxFit.cover,
                        //                 height: 75,
                        //                 width: 75,
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        // ),
                        SizedBox(height: ScreenUtil().setSp(10)),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: ScreenUtil().setSp(100),
                          child: TextFormField(
                            maxLength: 50,
                            focusNode: _firstNameFocus,
                            cursorColor: AppColors.primaryColor,
                            controller: firstNameController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (v) {
                              FocusScope.of(context).requestFocus(_emailFocus);
                            },
                            onChanged: (v) {
                              setState(() {
                                if (firstNameController.value.text
                                    .trim()
                                    .isEmpty) {
                                  isFirstNameError = true;
                                  isBtnEnable = false;
                                  fNameErrorMessage =
                                      Constants.enterUserNameError;
                                } else if (firstNameController.value.text
                                        .trim()
                                        .length <
                                    2) {
                                  isFirstNameError = true;
                                  isBtnEnable = false;
                                  fNameErrorMessage =
                                      Constants.enterValidUserNameError;
                                } else {
                                  isFirstNameError = false;
                                  fNameErrorMessage = "";
                                  if (isPhoneError == false &&
                                      isEmailError == false) {
                                    isBtnEnable = true;
                                  }
                                }
                              });
                            },
                            decoration: InputDecoration(
                              counterText: "",
                              labelText: Constants.username,
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
                              fNameErrorMessage,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red,
                                  fontFamily: Constants.mediumFont),
                            ),
                        ),
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
                              FocusScope.of(context).requestFocus(_phoneFocus);
                            },
                            onChanged: (v) {
                              setState(() {
                                Pattern pattern =
                                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                RegExp regex = new RegExp(pattern);
                                if (emailController.value.text.trim().isEmpty) {
                                  isEmailError = true;
                                  emailErrorMessage = Constants.enterEmailError;
                                  isBtnEnable = false;
                                } else if (!regex.hasMatch(
                                    emailController.value.text.trim())) {
                                  isEmailError = true;
                                  emailErrorMessage =
                                      Constants.enterValidEmailError;
                                  isBtnEnable = false;
                                } else {
                                  isEmailError = false;
                                  emailErrorMessage = "";
                                  if (isPhoneError == false &&
                                      isFirstNameError == false) {
                                    isBtnEnable = true;
                                  }
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
                            ),
                        ),
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
                                  initialSelection: '+91',
                                  onChanged: (CountryCode code) {
                                    setState(() {
                                      countryCode=code.code;
                                      countryCodeWithoutPlus = countryCode.replaceAll(new RegExp(r'[^\w\s]+'),'');
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
                                  controller: phoneController,
                                  cursorColor: AppColors.primaryColor,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: <TextInputFormatter>[
                                    WhitelistingTextInputFormatter.digitsOnly
                                  ],
                                  textInputAction: TextInputAction.next,
                                  onChanged: (v) {
                                    setState(() {
                                      if (phoneController.value.text.isEmpty) {
                                        phoneErrorMessage =
                                            Constants.enterPhoneError;
                                        isPhoneError = true;
                                        isBtnEnable = false;
                                      } else if ((phoneController.value.text
                                                  .trim()
                                                  .length <
                                              8) ||
                                          (phoneController.value.text
                                                  .trim()
                                                  .length >
                                              12)) {
                                        phoneErrorMessage =
                                            Constants.enterValidPhoneError;
                                        isPhoneError = true;
                                        isBtnEnable = false;
                                      } else {
                                        isPhoneError = false;
                                        phoneErrorMessage = "";
                                        if (isEmailError == false &&
                                            isFirstNameError == false) {
                                          isBtnEnable = true;
                                        }
                                      }
                                    });
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
                            ),
                          ],
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 1.0,
                          color: AppColors.accentColor,
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 10),
                            alignment: Alignment.topRight,
                            margin: const EdgeInsets.only(
                                top: 4.0, left: 30.0, bottom: 3),
                            child: Text(
                              phoneErrorMessage,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red,
                                  fontFamily: Constants.mediumFont),
                            )),
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
                              Constants.signup,
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
                              Constants.alreadyHaveAccount,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: ScreenUtil().setSp(28),
                                  fontFamily: Constants.regularFont,
                                  fontWeight: FontWeight.normal),
                            ),
                            SizedBox(width: 4),
                            new GestureDetector(
                                child: Text(Constants.login,
                                    style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontFamily: Constants.regularFont,
                                        fontSize: ScreenUtil().setSp(28),
                                        fontWeight: FontWeight.w300)),
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  Navigator.of(context).pop();
                                },
                            ),
                          ],
                        ),
                        SizedBox(height: 25),
                      ],
                    ),
                  ),
                ),
              ),
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
          'is_register':'register'
        };
        apiCall.hitPostApi(UrlConstant.sendOtp,body,'',UrlConstant.sendOtpCode);

      }
    } on SocketException catch (_) {
      Constants.showSnackBarWithMessage(Constants.noInternet,_scaffoldkey, context, AppColors.yellowColor);
    }
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      title: new Text('Gallery'),
                      onTap: () => {
                            imageSelector(context, "gallery"),
                            Navigator.pop(context),
                          }),
                  new ListTile(
                    title: new Text('Camera'),
                    onTap: () => {
                      imageSelector(context, "camera"),
                      Navigator.pop(context)
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future imageSelector(BuildContext context, String pickerType) async {
    switch (pickerType) {
      case "gallery":
        /// GALLERY IMAGE PICKER
        imageFile = await ImagePicker().pickImage(
            source: ImageSource.gallery, imageQuality: 90);
        break;
      case "camera": // CAMERA CAPTURE CODE
        imageFile = await ImagePicker().pickImage(
            source: ImageSource.camera, imageQuality: 90);
        break;
    }
    if (imageFile != null) {
      setState(() {});
    } else {
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
            openFromLogin: false,
            countryCode: countryCodeWithoutPlus,
            userName: firstNameController.value.text.toString(),
            email: emailController.value.text.toString(), phoneNumber: phoneController.value.text, fromWhich: 'register',);
        },
    ),
    );
  }

}
