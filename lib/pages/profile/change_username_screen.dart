import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/forum_model.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/screen_utils.dart';
import 'package:solstice/utils/size_utils.dart';

import '../../utils/shared_preferences.dart';

class ChangeUserName extends StatefulWidget {
  @override
  _ChangeUserNameState createState() => _ChangeUserNameState();
}

class _ChangeUserNameState extends State<ChangeUserName> {
  bool isBtnEnable = true;
  String userPrefImage = "", userName = "", userId = "";
  final TextEditingController _controller = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  UserFirebaseModel userItem;

  String _selectedImageUrl = "";
  File _selectedImage;
  bool _showLoading = false;

  @override
  void initState() {
    super.initState();
    Future<String> userPrefId =
        SharedPref.getStringFromPrefs(Constants.USER_ID);
    userPrefId.then((value) => {userId = value, loadUser(userId)},
        onError: (err) {
    });
    Future<String> userPrefName =
        SharedPref.getStringFromPrefs(Constants.USER_NAME);
    userPrefName.then((value) => {_controller.text = value}, onError: (err) {});

    //  Future<String> userImage = SharedPref.getStringFromPrefs(Constants.PROFILE_IMAGE);
    // userImage.then((value) => {
    //   userImagePref = value,
    // }, onError: (err) {
    // });
  }

  Future<void> loadUser(String userId) async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(userId)
        .get();
    if (ds != null) {
      try {
        userItem = UserFirebaseModel.fromSnapshot(ds);

        if (userItem != null) {
          userPrefImage = userItem.userImage;
          userName = userItem.userName;
          _selectedImageUrl = userPrefImage;
        }
      } catch (e) {}

      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 27,
                              height: 27,
                              padding: EdgeInsets.all(2.5),
                              margin: EdgeInsets.only(right: 5),
                              child: SvgPicture.asset(
                                'assets/images/ic_person.svg',
                                alignment: Alignment.center,
                                fit: BoxFit.contain,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              width: 0,
                            ),
                            Text(
                              "Update Name",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: ScreenUtil().setSp(38),
                                  fontFamily: Constants.boldFont),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              FocusScope.of(context).unfocus();
                              bottomSheetforImage();
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: _profileImage(),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: _controller,
                          onChanged: (val) {
                            // if (_controller.text.isEmpty) {
                            //   isBtnEnable = true;
                            // } else {
                            //   isBtnEnable = true;
                            // }
                            setState(() {});
                          },
                          decoration: InputDecoration(
                              labelText: "Name",
                              labelStyle: TextStyle(
                                  fontFamily: 'epilogue_regular',
                                  fontSize: ScreenUtil().setSp(25))),
                        ),
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
                                side:
                                    BorderSide(color: AppColors.primaryColor)),
                            onPressed: () {
                              setState(() {
                                if (_controller.text.isEmpty) {
                                  Constants.showSnackBarWithMessage(
                                      "Enter user name!",
                                      _scaffoldkey,
                                      context,
                                      AppColors.redColor);
                                } else {
                                  if (_selectedImage != null) {
                                    uploadUserImage();
                                  } else {
                                    updateProfile();
                                  }
                                }
                              });
                            },
                            color: AppColors.primaryColor,
                            textColor: Colors.white,
                            padding: EdgeInsets.all(10.0),
                            child: Text(Constants.update,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(28),
                                  fontFamily: Constants.semiBoldFont,
                                )),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              Constants.cancel,
                              style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: ScreenUtil().setSp(28),
                                  fontFamily: Constants.regularFont,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
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

  Future<void> uploadUserImage() async {
    _showLoading = true;

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var reference =
        FirebaseStorage.instance.ref().child("userImages").child(fileName);
    UploadTask uploadTask = reference.putFile(_selectedImage);

    uploadTask.whenComplete(() {
      reference.getDownloadURL().then((downloadUrl) {
        _selectedImageUrl = downloadUrl;
        setState(() {
          _showLoading = false;
          updateProfile();
        });
      }, onError: (err) {
        setState(() {
          _showLoading = false;
        });

        Constants.showSnackBarWithMessage("This file is not an image",
            _scaffoldkey, context, Colors.red[700]);
      });
    });
  }

  setUserImage(String userImageUrl) {
    return CachedNetworkImage(
      imageUrl:
          (userImageUrl.contains("https:") || userImageUrl.contains("http:"))
              ? userImageUrl
              : UrlConstant.BaseUrlImg + userImageUrl,
      imageBuilder: (context, imageProvider) => Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(50.0)),
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => setUserDefaultCircularImage(),
      errorWidget: (context, url, error) => setUserDefaultCircularImage(),
    );
  }

  setUserDefaultCircularImage() {
    return Container(
      width: 90,
      height: 90,
      child: SvgPicture.asset(
        'assets/images/ic_male_placeholder.svg',
        width: 90,
        height: 90,
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _profileImage() {
//    _imagePath = SharedPref.getStringFromPrefs(ConstantVariables.PROFILEIMAGE);

    if (_selectedImage != null) {
      return Container(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.file(
            _selectedImage,
            fit: BoxFit.cover,
            height: 90,
            width: 90,
          ),
        ),
      );
    } else if (userPrefImage != null &&
        userPrefImage != "null" &&
        userPrefImage != "") {
      return setUserImage(userPrefImage);
    } else {
      return setUserDefaultCircularImage();
    }
  }

  bottomSheetforImage() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
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
                        color: Colors.black,
                        fontFamily: Constants.mediumFont,
                        fontSize: 18.0),
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
                  ),
                ),
              ],
            ),
          );
        });
  }

  getImage(ImageSource source) async {
    XFile image = await ImagePicker().pickImage(
        source: source, maxHeight: 700, maxWidth: 500);
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

    if (cropped != null) {
      _selectedImage = cropped;
      setState(() {});
    } else {
      //_imagePath = image.path.toString();
    }
  }

  imageButton() {
    if (Platform.isIOS) {
      return Container(
        width: SizeConfig.screenWidth,
        child: new CupertinoButton(
          padding: EdgeInsets.symmetric(
              vertical: Dimens.height17(), horizontal: Dimens.height20()),
          onPressed: () {
            Navigator.pop(context);
          },
          color: AppColors.defaultAppColor[500],
          child: InputText.textTitleInput(Constants.cancel,
              textAlign: TextAlign.center,
              color: Colors.black,
              fontWeight: FontWeight.bold),
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
          padding: EdgeInsets.symmetric(
              vertical: Dimens.height17(), horizontal: Dimens.height20()),
          child: InputText.textTitleInput(Constants.cancel,
              textAlign: TextAlign.center,
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
      );
    }
  }

  void updateProfile() {
    FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(userId)
        .update({
      'userName': _controller.text,
      'userImage': _selectedImageUrl,
    }).then((docRef) {
      Constants.showSnackBarWithMessage("Profile updated successfully!",
          _scaffoldkey, context, AppColors.greenColor);
      SharedPref.saveStringInPrefs(Constants.USER_NAME, _controller.text);
      SharedPref.saveStringInPrefs(Constants.PROFILE_IMAGE, _selectedImageUrl);
      Future.delayed(const Duration(milliseconds: 1000), () {
        Navigator.of(context).pop();
      });
    });
  }
}
