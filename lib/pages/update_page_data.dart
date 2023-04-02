import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solstice/pages/search_location.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/shared_preferences.dart';
import 'package:solstice/utils/utilities.dart';

class UpdatePageData extends StatefulWidget {
  final String pageType, title, description, imageUrl, locationAddress, id;

  UpdatePageData(
      {this.pageType,
      this.title,
      this.description,
      this.imageUrl,
      this.locationAddress,
      this.id});

  @override
  _UpdatePageDataState createState() => _UpdatePageDataState();
}

class _UpdatePageDataState extends State<UpdatePageData> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  TextEditingController formTitleController = new TextEditingController();
  TextEditingController formDescriptionController = new TextEditingController();
  final FocusNode _formTitleFocus = new FocusNode();
  final FocusNode _formDescriptionFocus = new FocusNode();
  String _currentAddress;

  LatLng currentLatLng;
  Position currentLocation;
  double selectedLatitude = 0.0;
  double selectedLongitude = 0.0;
  bool isPublic = true;
  String postType = "Public";
  String forumId;
  var state;
  bool isEditMode = true, isStitchSelected = false;
  String userImagePref = "";

  final _formKey = GlobalKey<FormState>();
  bool enableButton = false;
  var imageFile = null;
  String privacyType = "Public";
  String imageUrl = "", selectedImageUrl = "";

  TextEditingController stitchDescriptionController =
      new TextEditingController();
  TextEditingController stitchTitleController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserLocation();
    if (widget.pageType == "Stitch") {
      isStitchSelected = true;
    }
    setData();
    Future<String> userImage =
        SharedPref.getStringFromPrefs(Constants.PROFILE_IMAGE);
    userImage.then(
        (value) => {
              userImagePref = value,
            },
        onError: (err) {});
  }

  void setData() {
    switch (widget.pageType) {
      case "Forum":
        formTitleController.text = widget.title;
        formDescriptionController.text = widget.description;
        _currentAddress = widget.locationAddress;
        break;

      case "Routine":
        stitchTitleController.text = widget.title;
        stitchDescriptionController.text = widget.description;
        imageUrl = widget.imageUrl;
        break;

      case "Stitch":
        stitchTitleController.text = widget.title;
        stitchDescriptionController.text = widget.description;
        imageUrl = widget.imageUrl;
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: setContainer(),
    );
  }

  Widget setContainer() {
    switch (widget.pageType) {
      case "Stitch":
        return stitchWidget();
        break;

      case "Routine":
        return stitchWidget();
        break;

      case "Forum":
        return forumWidget();
        break;

      default:
        return Container();
        break;
    }
  }

  Widget forumWidget() {
    return Container(
      child: SingleChildScrollView(
        child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Wrap(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(left: 20, right: 20),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(
                            top: ScreenUtil().setSp(25),
                            bottom: ScreenUtil().setSp(15)),
                        height: ScreenUtil().setSp(45),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              padding: EdgeInsets.all(2.5),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                isEditMode
                                    ? 'Update Forum'
                                    : Constants.createForum,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.titleTextColor,
                                    fontFamily: Constants.boldFont,
                                    fontSize: ScreenUtil().setSp(28)),
                              ),
                            ),
                            RotationTransition(
                              turns: new AlwaysStoppedAnimation(45 / 360),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  padding: EdgeInsets.all(2.5),
                                  child: SvgPicture.asset(
                                    'assets/images/ic_plus.svg',
                                    alignment: Alignment.center,
                                    color: AppColors.darkRedColor,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setSp(32)),
                      SizedBox(height: 10),
                      TextFormField(
                        maxLength: 2000,
                        focusNode: _formDescriptionFocus,
                        cursorColor: AppColors.primaryColor,
                        controller: formDescriptionController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onChanged: (v) {},
                        decoration: InputDecoration(
                          counterText: "",
                          labelText: "Describe your forum",
                          labelStyle: TextStyle(
                              color: AppColors.accentColor,
                              fontFamily: Constants.semiBoldFont,
                              fontSize: ScreenUtil().setSp(24)),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        alignment: Alignment.topRight,
                        margin: const EdgeInsets.only(
                            top: 4.0, left: 30.0, bottom: 16),
                        child: Text(
                          "",
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                              fontFamily: Constants.mediumFont),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        Constants.locationOptional,
                        style: TextStyle(
                            color: AppColors.accentColor,
                            fontFamily: Constants.semiBoldFont,
                            fontSize: ScreenUtil().setSp(24)),
                      ),
                      SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectLocation();
                          });
                        },
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                (_currentAddress != null &&
                                        _currentAddress != "")
                                    ? _currentAddress
                                    : Constants.selectLocation,
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(28),
                                    color: (_currentAddress != null &&
                                            _currentAddress != "")
                                        ? Colors.black
                                        : AppColors.accentColor,
                                    fontFamily: Constants.mediumFont),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.accentColor,
                              // size: Dimens.iconSize06(),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 1.0,
                        color: AppColors.accentColor,
                      ),
                      SizedBox(height: 15),
                      Container(
                        color: Colors.transparent,
                        margin: EdgeInsets.only(top: 12),
                        width: MediaQuery.of(context).size.width,
                        height: ScreenUtil().setSp(100),
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.0),
                          ),
                          onPressed: () {
                            var title = "";
                            var description =
                                formDescriptionController.value.text.trim();

                            if (description.isEmpty) {
                              Constants().errorToast(
                                  context, Constants.enterDescriptionError);
                            } else if (description.length < 4) {
                              Constants().errorToast(
                                  context, Constants.gDesMust4Characters);
                            } else {
                              addForumToDb(context, title, description);
                            }

                            if (mounted) {
                              setState(() {});
                            }
                          },
                          color: AppColors.primaryColor,
                          textColor: Colors.white,
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            isEditMode ? 'Update Forum' : Constants.continueTxt,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(28),
                              fontFamily: Constants.semiBoldFont,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }

  // select location with search location.
  Future selectLocation() async {
    Map results = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return SearchLocation();
    }));

    if (results != null && results.containsKey('update')) {
      var _isUpdate = "";

      setState(() {
        _isUpdate = results['update'];
        if (_isUpdate == "yes") {
          try {
            SearchedLocationModel searchedLocationModel = results['returnData'];
            if (searchedLocationModel != null) {
              _currentAddress = searchedLocationModel.title;
              selectedLatitude = searchedLocationModel.latitude;
              selectedLongitude = searchedLocationModel.longitude;
            }
          } catch (e) {
          }
        }
      });
    }
  }

  // add forum to db
  void addForumToDb(context, String title, String description) {
    //_isShowLoader = true;
    FocusScope.of(context).unfocus();

    FirebaseFirestore.instance
        .collection(Constants.ForumsFB)
        .doc(widget.id)
        .update({
          "title": title,
          "description": description,
          "postLatitude": selectedLatitude.toString(),
          "postLongitude": selectedLongitude.toString(),
          "postAddress": _currentAddress.toString(),
          "is_public": isPublic,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'createdBy': globalUserId,
          'createdByName': globalUserName,
          'createdByImage': userImagePref,
        })
        .then((docRef) {
          Navigator.of(context).pop();
          formTitleController.text = "";
          formDescriptionController.text = "";
          Constants().successToast(context, "Forum updated successfully!");

          Navigator.pop(context, {"update": "yes"});
          /*setState(() {
        _isShowLoader = false;
      });*/
        })
        .timeout(Duration(seconds: 10))
        .catchError((error) {
          /* setState(() {
        _isShowLoader = false;
      });*/
        });
  }

  Widget stitchWidget() {
    return Container(
        child: SingleChildScrollView(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Wrap(
          children: <Widget>[
            Form(
              key: _formKey,
              child: new Container(
                color: Colors.transparent,
                child: new Container(
                  /*  */
                  padding: EdgeInsets.all(ScreenUtil().setSp(40)),
                  decoration: new BoxDecoration(
                      color: Colors.white,
                      borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(25.0),
                          topRight: const Radius.circular(25.0))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: ScreenUtil().setSp(45),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              padding: EdgeInsets.all(2.5),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                isStitchSelected == true
                                    ? (isEditMode
                                        ? 'Edit Stitch'
                                        : 'Create a new Stitch')
                                    : (isEditMode
                                        ? 'Edit Routine'
                                        : 'Create a new Routine'),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.titleTextColor,
                                    fontFamily: Constants.boldFont,
                                    fontSize: ScreenUtil().setSp(28)),
                              ),
                            ),
                            RotationTransition(
                              turns: new AlwaysStoppedAnimation(45 / 360),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    Navigator.of(context).pop();
                                  });
                                },
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  padding: EdgeInsets.all(2.5),
                                  child: SvgPicture.asset(
                                    'assets/images/ic_plus.svg',
                                    alignment: Alignment.center,
                                    color: AppColors.darkRedColor,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setSp(32)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            isStitchSelected == true
                                // ? 'Upload Stitch Thumbnail'
                                // : 'Select the post form your stitch',
                                ? 'Upload Stitch Thumbnail'
                                : 'Upload Routine Thumbnail',
                            style: TextStyle(
                                fontFamily: 'epilogue_semibold',
                                fontSize: ScreenUtil().setSp(25),
                                color: Color(0xFF727272)),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      // isBucketSelected == true?
                      InkWell(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          _settingModalBottomSheet(context, setState);
                          // imageSelector(context, "gallery",setState);
                        },
                        child: imageFile == null
                            ? (imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      width: ScreenUtil().setSp(120),
                                      height: ScreenUtil().setSp(120),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.0)),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  )
                                : DottedBorder(
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
                                  ))
                            : Container(
                                child: PhysicalModel(
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppColors.viewLineColor,
                                  elevation: 5,
                                  shadowColor: AppColors.shadowColor,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      imageFile,
                                      fit: BoxFit.cover,
                                      height: 75,
                                      width: 75,
                                    ),
                                  ),
                                ),
                              ),
                      ),

                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        isStitchSelected == true
                            ? 'Stitch Name'
                            : 'Routine Name',
                        style: TextStyle(
                            fontFamily: 'epilogue_semibold',
                            fontSize: ScreenUtil().setSp(25),
                            color: Color(0xFF727272)),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        controller: stitchTitleController,
                        onChanged: (value) {
                          if (stitchDescriptionController.text.length > 3 &&
                              value.trim().isNotEmpty) {
                            enableButton = true;
                            setState(() {});
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return isStitchSelected == true
                                ? 'Enter stitch title!'
                                : 'Enter routine title!';
                          }
                          return null;
                        },
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(30),
                            fontFamily: 'epilogue_regular'),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        isStitchSelected == true
                            ? 'Stitch Description'
                            : 'Routine Description',
                        style: TextStyle(
                            fontFamily: 'epilogue_semibold',
                            fontSize: ScreenUtil().setSp(25),
                            color: Color(0xFF727272)),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        controller: stitchDescriptionController,
                        onChanged: (value) {
                          if (value.trim().length > 3 &&
                              stitchTitleController.text.isNotEmpty) {
                            enableButton = true;
                            setState(() {});
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return isStitchSelected == true
                                ? 'Enter stitch description!'
                                : 'Enter routine description!';
                          }
                          return null;
                        },
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(30),
                            fontFamily: 'epilogue_regular'),
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      Text(
                        Constants.privacyType,
                        style: TextStyle(
                            color: AppColors.accentColor,
                            fontFamily: Constants.semiBoldFont,
                            fontSize: ScreenUtil().setSp(24)),
                      ),
                      InkWell(
                        onTap: () {
                          if (isPublic) {
                            privacyType = 'Private';
                          } else {
                            privacyType = 'Public';
                          }
                          isPublic = !isPublic;
                          setState(() {});
                        },
                        child: Container(
                          width: 100.0,
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 10.0),
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              border: Border.all(
                                  color: AppColors.appGreyColor[500],
                                  width: 1)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                isPublic
                                    ? Constants.publicIcon
                                    : Constants.privateIcon,
                                color: AppColors.accentColor,
                                height: 15.0,
                                width: 15.0,
                              ),
                              SizedBox(
                                width: 4.0,
                              ),
                              Text(
                                '$privacyType',
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(28),
                                    color: AppColors.accentColor,
                                    fontFamily: Constants.mediumFont),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: ScreenUtil().setSp(95),
                        width: MediaQuery.of(context).size.width,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.0),
                            side: BorderSide(color: AppColors.primaryColor),
                          ),
                          color: AppColors.primaryColor,
                          onPressed: () {
                            if (isStitchSelected) {
                              // createStitch();
                              checkValids(context, Constants.stitchCollection);
                            } else {
                              checkValids(context, Constants.routineCollection);
                            }
                          },
                          child: Text(
                            isStitchSelected == true
                                ? (isEditMode
                                    ? 'Update Stitch'
                                    : 'Create Stitch')
                                : (isEditMode
                                    ? 'Update Routine'
                                    : 'Create Routine'),
                            style: TextStyle(
                                fontFamily: 'epilogue_semibold',
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  // get image bottom sheet
  void _settingModalBottomSheet(context, state) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Container(
              child: new Wrap(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      "Select From",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: Constants.mediumFont,
                          fontSize: 18.0),
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
                      imageSelector(context, "camera", state),
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
                            imageSelector(context, "gallery", state),
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
  Future imageSelector(
      BuildContext context, String pickerType, StateSetter state) async {
    switch (pickerType) {
      case "gallery":

        /// GALLERY IMAGE PICKER
        imageFile = await ImagePicker()
            .pickImage(source: ImageSource.gallery, imageQuality: 90);
        break;

      case "camera": // CAMERA CAPTURE CODE
        imageFile = await ImagePicker()
            .pickImage(source: ImageSource.camera, imageQuality: 90);
        break;
    }

    if (imageFile != null) {
      setState(() {});
    } else {
    }
  }

  checkValids(BuildContext context, String collectionName) {
    if (_formKey.currentState.validate()) {
      Navigator.of(context).pop();
      FocusScope.of(context).unfocus();

      if (isStitchSelected) {
        if (imageFile != null) {
          Constants.showSnackBarWithMessage("Stitch image uploading...",
              _scaffoldkey, context, AppColors.primaryColor);

          uploadImageToFirebase(Constants.stitchImagesFolder, collectionName);
        } else {
          Utilities.show(context);
          if (imageUrl.isNotEmpty) {
            updateDataToFb(collectionName, imageUrl);
          } else {
            updateDataToFb(collectionName, defaultPostImage);
          }
        }
      } else {
        if (imageFile != null) {
          Constants.showSnackBarWithMessage("Routine image uploading...",
              _scaffoldkey, context, AppColors.primaryColor);

          uploadImageToFirebase(Constants.routineImagesFolder, collectionName);
        } else {
          Utilities.show(context);
          if (imageUrl.isNotEmpty) {
            updateDataToFb(collectionName, imageUrl);
          } else {
            updateDataToFb(collectionName, defaultPostImage);
          }
        }
      }
    } else {
    }
  }

  // Upload image to firebase storage

  void uploadImageToFirebase(String storageName, String collectionName) async {
    Utilities.show(context);

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    var firebaseStorageRef =
        FirebaseStorage.instance.ref().child(storageName).child(fileName);

    UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
    uploadTask.whenComplete(() {
      firebaseStorageRef.getDownloadURL().then((downloadUrl) {
        selectedImageUrl = downloadUrl;

        updateDataToFb(collectionName, downloadUrl);
      });
    }).catchError((onError) {
    });
  }

  void updateDataToFb(String collectionName, String downloadUrl) {
    var stitchMap = {
      "created_at": Timestamp.now(),
      "created_by": globalUserId,
      "description": stitchDescriptionController.text.toString(),
      "image": downloadUrl,
      "is_public": isPublic,
      "title": stitchTitleController.text.toString(),
      "updated_at": Timestamp.now()
    };

    if (isEditMode) {
      FirebaseFirestore.instance
          .collection(collectionName)
          .doc(widget.id)
          .update(stitchMap)
          .then((value) {
        // _formKey.currentState?.reset();
        imageFile = null;
        stitchDescriptionController.clear();
        stitchTitleController.clear();
        String sMsg = "";
        if (widget.pageType == "Stitch") {
          sMsg = "Stitch";
        } else {
          sMsg = "Routine";
        }
        //Constants().successToast(context, "$sMsg created successfully!");

        Utilities.hide();
        Constants.showSnackBarWithMessage("$sMsg updated successfully!",
            _scaffoldkey, context, AppColors.greenColor);
        // setState(() {});

        // Navigator.of(context).pop();
      });
    }
  }

  // get user current location
  getUserLocation() async {

    currentLocation = await locateUser();
    currentLatLng = LatLng(currentLocation.latitude, currentLocation.longitude);
    //globals.currentLatLng = currentLatLng;
    try {
      selectedLatitude = currentLatLng.latitude;
      selectedLongitude = currentLatLng.longitude;
      List<Placemark> placemarks = await placemarkFromCoordinates(
          currentLocation.latitude, currentLocation.longitude);

      Placemark place = placemarks[0];

      _currentAddress = "${place.locality}, ${place.country}";
    } catch (e) {
    }

    if (mounted) setState(() {});
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}
