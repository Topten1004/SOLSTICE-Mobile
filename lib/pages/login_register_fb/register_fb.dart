import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:solstice/apiservice/api_call.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/pages/register_login/otp_verification.dart';
import 'package:solstice/pages/register_login/otp_verification_screen.dart';
import 'package:solstice/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/utils/screen_utils.dart';
import 'package:solstice/utils/size_utils.dart';

class RegisterFbScreen extends StatefulWidget {
  final String defaultCountryShortFormIntent;
  final String phoneNoIntent;

  const RegisterFbScreen(
      {Key key, @required this.defaultCountryShortFormIntent, @required this.phoneNoIntent})
      : super(key: key);

  @override
  _RegisterFbScreenState createState() => _RegisterFbScreenState();
}

class _RegisterFbScreenState extends State<RegisterFbScreen> {
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
  String countryCode = "+1";
  String countryCodeWithoutPlus = "1";

  bool isFirstNameError = true;
  bool isEmailError = true;
  bool isPhoneError = true;
  bool _showLoading = false;
  File _selectedImage;

  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    // if user already enter phone no. in Login Screen. then we auto-fill the phone no. and country code in register screen.
    if (widget.phoneNoIntent != null) {
      phoneController.text = widget.phoneNoIntent;
      isPhoneError = false;
    }
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
                        SizedBox(height: 20),
                        _profileImage(),
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
                                if (firstNameController.value.text.trim().isEmpty) {
                                  isFirstNameError = true;
                                  isBtnEnable = false;
                                  fNameErrorMessage = Constants.enterUserNameError;
                                } else if (firstNameController.value.text.trim().length < 2) {
                                  isFirstNameError = true;
                                  isBtnEnable = false;
                                  fNameErrorMessage = Constants.enterValidUserNameError;
                                } else {
                                  isFirstNameError = false;
                                  fNameErrorMessage = "";
                                  if (isPhoneError == false && isEmailError == false) {
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
                          margin: const EdgeInsets.only(top: 4.0, left: 30.0, bottom: 3),
                          child: Text(
                            fNameErrorMessage,
                            style: TextStyle(
                                fontSize: 11, color: Colors.red, fontFamily: Constants.mediumFont),
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
                                } else if (!regex.hasMatch(emailController.value.text.trim())) {
                                  isEmailError = true;
                                  emailErrorMessage = Constants.enterValidEmailError;
                                  isBtnEnable = false;
                                } else {
                                  isEmailError = false;
                                  emailErrorMessage = "";
                                  if (isPhoneError == false && isFirstNameError == false) {
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
                          margin: const EdgeInsets.only(top: 4.0, left: 30.0, bottom: 3),
                          child: Text(
                            emailErrorMessage,
                            style: TextStyle(
                                fontSize: 11, color: Colors.red, fontFamily: Constants.mediumFont),
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
                                  initialSelection: widget.defaultCountryShortFormIntent != null
                                      ? widget.defaultCountryShortFormIntent
                                      : 'US',
                                  onChanged: (CountryCode code) {
                                    setState(() {
                                      countryCode = code.dialCode;
                                      countryCodeWithoutPlus =
                                          countryCode.replaceAll(new RegExp(r'[^\w\s]+'), '');
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
                                  maxLength: 10,
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
                                        phoneErrorMessage = Constants.enterPhoneError;
                                        isPhoneError = true;
                                        isBtnEnable = false;
                                      } else if ((phoneController.value.text.trim().length < 8) ||
                                          (phoneController.value.text.trim().length > 12)) {
                                        phoneErrorMessage = Constants.enterValidPhoneError;
                                        isPhoneError = true;
                                        isBtnEnable = false;
                                      } else {
                                        isPhoneError = false;
                                        phoneErrorMessage = "";
                                        if (isEmailError == false && isFirstNameError == false) {
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
                            margin: const EdgeInsets.only(top: 4.0, left: 30.0, bottom: 3),
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
            .where(Constants.phoneFB, isEqualTo: phoneController.value.text.trim())
            .get();

        // in this check is user phone no. and country code exist in database. if already exist then show error.

        if (_query != null) {
          if (_query.docs.length > 0) {
            _showLoading = false;
            if (mounted) {
              setState(() {});
            }
            Constants.showSnackBarWithMessage(
                "User already exist. Please login.", _scaffoldkey, context, Colors.red[700]);
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
                        userName: firstNameController.value.text.toString(),
                        email: emailController.value.text.toString(),
                        phoneNumber: phoneController.value.text,
                        userImage: _selectedImage,
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

  // for image selection
  Widget _profileImage() {
//    _imagePath = SharedPref.getStringFromPrefs(ConstantVariables.PROFILEIMAGE);
    // for image file equal null. then show placeholder image for selection.

    if (_selectedImage == null) {
      return GestureDetector(
        onTap: () {
          bottomSheetforImage();
        },
        child: Container(
          child: DottedBorder(
            padding: EdgeInsets.all(
              ScreenUtil().setSp(40),
            ),
            borderType: BorderType.RRect,
            color: Color(0xFF1A58E7).withOpacity(0.7),
            radius: Radius.circular(10),
            dashPattern: [2.5, 4, 2, 4],
            strokeWidth: 1.5,
            child: SvgPicture.asset(
              'assets/images/ic_media_image.svg',
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    } else {
      // for image file not equal null. then show image that user selected.

      return GestureDetector(
        onTap: () {
          bottomSheetforImage();
        },
        child: Container(
          child: PhysicalModel(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey,
            elevation: 5,
            shadowColor: AppColors.accentColor,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                _selectedImage,
                fit: BoxFit.cover,
                height: 75,
                width: 75,
              ),
            ),
          ),
        ),
      );
    }
  }

  // bottom sheet for camera and gallery selection.
  bottomSheetforImage() {
    showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.whiteColor[400],
        elevation: 4.0,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text(
                    "Select from",
                    style: TextStyle(
                        color: Colors.black, fontFamily: Constants.mediumFont, fontSize: 18.0),
                  ),
                ),
                ListTile(
                  onTap: () {
                    getImage(ImageSource.camera);
                    Navigator.of(context).pop(context);
                  },
                  /*leading: Icon(
                    Icons.camera,
                    color: AppColors.appGreyColor[400],
                    size: Dimens.iconSize06(),
                  ),*/
                  title: Text(
                    "Camera",
                    style: TextStyle(
                        color: Colors.black, fontFamily: Constants.regularFont, fontSize: 16.0),
                  ),
                ),
                ListTile(
                  onTap: () {
                    getImage(ImageSource.gallery);
                    Navigator.of(context).pop(context);
                  },
                  /*leading: Icon(
                    Icons.photo,
                    color: AppColors.appGreyColor[400],
                    size: Dimens.iconSize06(),
                  ),*/
                  title: Text(
                    "Gallery",
                    style: TextStyle(
                        color: Colors.black, fontFamily: Constants.regularFont, fontSize: 16.0),
                  ),
                ),
              ],
            ),
          );
        });
  }

  // get file uri after crop the image.
  getImage(ImageSource source) async {
    XFile image = await ImagePicker().pickImage(source: source, maxHeight: 700, maxWidth: 500);
    File cropped = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
        maxHeight: 700,
        maxWidth: 700,
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: AndroidUiSettings(
          toolbarColor: AppColors.whiteColor[500],
          toolbarTitle: "Crop image",
          backgroundColor: AppColors.whiteColor[500],
        ));
    setState(() {
      if (cropped != null) {
        _selectedImage = cropped;
      } else {
        //_imagePath = image.path.toString();
      }
    });
  }

  imageButton() {
    if (Platform.isIOS) {
      return Container(
        width: SizeConfig.screenWidth,
        child: new CupertinoButton(
          padding: EdgeInsets.symmetric(vertical: Dimens.height17(), horizontal: Dimens.height20()),
          onPressed: () {
            Navigator.pop(context);
          },
          color: AppColors.defaultAppColor[500],
          child: InputText.textTitleInput(Constants.cancel,
              textAlign: TextAlign.center, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return Container(
        width: SizeConfig.screenWidth,
        child: new MaterialButton(
          elevation: 4.0,
          onPressed: () {
            Navigator.pop(context);
          },
          color: AppColors.defaultAppColor[500],
          splashColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
          ),
          padding: EdgeInsets.symmetric(vertical: Dimens.height17(), horizontal: Dimens.height20()),
          child: InputText.textTitleInput(Constants.cancel,
              textAlign: TextAlign.center, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      );
    }
  }
}
