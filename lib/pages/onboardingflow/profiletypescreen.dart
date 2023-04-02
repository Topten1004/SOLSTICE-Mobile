import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solstice/pages/feeds/feed_listing.dart';
import 'package:solstice/pages/onboardingflow/gender_selection.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/shared_preferences.dart';
import 'package:solstice/utils/utilities.dart';

import 'biz_Q_one.dart';

class ProfileTypeScreen extends StatefulWidget {
  ProfileTypeScreen({Key key}) : super(key: key);

  @override
  _ProfileTypeScreenState createState() => _ProfileTypeScreenState();
}

class _ProfileTypeScreenState extends State<ProfileTypeScreen> {
  var imageFile = null;
  bool _switchValue = true;
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

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
      actions: [
        Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Image.asset("assets/images/help.png", height: 26, width: 26)),
        )
      ],
    );
    return Scaffold(
      key: _scaffoldkey,
      appBar: appBar,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Text(
                    'Tell us a little bit\n about yourself',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF1F1F1F),
                        fontWeight: FontWeight.normal,
                        fontFamily: Utils.fontfamily,
                        fontSize: 24),
                  ),
                  SizedBox(
                    height: 19,
                  ),
                  Text(
                    'For Solstice’s algorithms to curate useful \nworkouts & relevant content, we need to \nknow some details about you',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF868686),
                        fontFamily: Utils.fontfamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 50, left: 0),
                        child: Text(
                          'Individual',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: Utils.fontfamily,
                              color: Color(0xFF8A94A6),
                              fontSize: 17),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 50, left: 40),
                        child: FlutterSwitch(
                          width: 80.0,
                          height: 35.0,
                          valueFontSize: 20.0,
                          toggleSize: 30.0,
                          value: _switchValue,
                          borderRadius: 30.0,
                          padding: 5.0,
                          activeColor: Color(0xFF283646),
                          onToggle: (val) {
                            setState(() {
                              _switchValue = val;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 50, left: 30),
                        child: Text(
                          'Business',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: Utils.fontfamily,
                              color: Color(0xFF8A94A6),
                              fontSize: 17),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50, bottom: 15),
                    child: Text(
                      'Upload Your Logo',
                      style: TextStyle(
                          fontFamily: Utils.fontfamily,
                          color: Color(0xFF1F1F1F),
                          fontSize: 17,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _settingModalBottomSheet();
                    },
                    child: Container(
                        height: 118,
                        width: 297,
                        decoration: BoxDecoration(
                          color: Color(0XFFFFFFFF),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF434344).withOpacity(0.07),
                              spreadRadius: 1,
                              blurRadius: 13,
                              offset: Offset(0, 15), // changes position of shadow
                            ),
                          ],
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                          border: Border.all(
                            color: Color(0XFF283646),
                            width: 1,
                          ),
                        ),
                        child: imageFile == null
                            ? Image.asset(
                                Utils.clouduploadIcon,
                                height: 40,
                                width: 50,
                              )
                            : Image.file(
                                File(imageFile.path),
                                fit: BoxFit.cover,
                              )),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              if (imageFile == null) {
                saveData('');
              } else {
                uploadImage();
              }
            },
            child: Container(
              height: 56,
              margin: EdgeInsets.only(bottom: 40, left: 20, right: 20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF283646).withOpacity(0.32),
                      offset: Offset(0.0, 4.0), //(x,y)
                      blurRadius: 16,
                    ),
                  ],
                  color: Color(0xFF283646)),
              child: Center(
                  child: Text(
                Constants.continueTxt,
                style: TextStyle(
                    fontFamily: Utils.fontfamily,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFFFFFFFF),
                    fontSize: 18),
              )),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 20),
            child: InkWell(
                onTap: () {
                  Utils.saveSkipScreenName("ProfileTypeScreen", context);
                },
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15, color: Color(0XFF283646)),
                )),
          )
        ],
      ),
    );
  }

  void uploadImage() {
    Utilities.show(context);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var reference = FirebaseStorage.instance.ref().child(Constants.userImages).child(fileName);
    UploadTask uploadTask = reference.putFile(File(imageFile.path));

    uploadTask.whenComplete(() {
      reference.getDownloadURL().then((downloadUrl) {
        saveData(downloadUrl);
      });
    }).catchError((onError) {
      Constants.showSnackBarWithMessage(
          "Error uploading image ${onError.toString()}", _scaffoldkey, context, Colors.red[700]);
      Utilities.hide();
    });
  }

  void saveData(String imageUrl) {
    if (imageUrl.isEmpty) {
      Utilities.show(context);
    }

    FirebaseFirestore.instance.collection(Constants.UsersFB).doc(globalUserId).update({
      'userType': _switchValue ? 'Business' : 'Individual',
      'userImage': imageUrl,
      'profileComplete': 0
    }).then((docRef) {
      globaUserProfileImage = imageUrl;

      SharedPref.saveStringInPrefs(Constants.PROFILE_IMAGE, imageUrl);

      Utilities.hide();
      goToNext();
    });
  }

  void goToNext() {
    if (_switchValue) {
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => BizQ1Screen()));
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (BuildContext context) => GenderSelectionScreen()));
    }
  }

  // Select image bottom sheet
  void _settingModalBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setState) {
            return Container(
              child: new Wrap(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      "Select From",
                      style: TextStyle(
                          color: Colors.black, fontFamily: Constants.mediumFont, fontSize: 18.0),
                    ),
                  ),
                  new ListTile(
                    title: new Text('Camera',
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: Constants.regularFont,
                            fontSize: 16.0)),
                    onTap: () => {
                      FocusScope.of(context).unfocus(),
                      imageSelector(context, "camera", setState),
                      Navigator.pop(context)
                    },
                  ),
                  new ListTile(
                      title: new Text('Gallery',
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: Constants.regularFont,
                              fontSize: 16.0)),
                      onTap: () => {
                            FocusScope.of(context).unfocus(),
                            imageSelector(context, "gallery", setState),
                            Navigator.pop(context),
                          }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // image selector
  Future imageSelector(BuildContext context, String pickerType, StateSetter state) async {
    switch (pickerType) {
      case "gallery":

        /// GALLERY IMAGE PICKER
        imageFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
        break;

      case "camera":

        /// CAMERA CAPTURE CODE
        imageFile = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 90);
        break;
    }
    if (imageFile != null) {

      setState(() {});
    } else {
    }
  }
}
