import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solstice/model/stitch_routine_model.dart';
import 'package:solstice/pages/views/bucket_stitch_list_item.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/utilities.dart';

class SaveToFeedRoutine extends StatefulWidget {
  @override
  _SaveToFeedRoutineState createState() => _SaveToFeedRoutineState();
}

class _SaveToFeedRoutineState extends State<SaveToFeedRoutine> {
  List<StitchRoutineModel> stitchList = new List();

  final _formKey = GlobalKey<FormState>();
  bool isBucketSelected = false;
  var imageFile = null;
  String intervalSlot = "Public";
  TextEditingController stitchDescriptionController =
      new TextEditingController();
  TextEditingController stitchTitleController = new TextEditingController();
  bool isPublic = true;
  bool enableButton = false;
  String privacyType = "Public";
  String _selectedImageUrl = "", stitchName = "";

  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRoutines();
  }

  void getRoutines() {
    stitchList.clear();
    FirebaseFirestore.instance
        .collection(Constants.routineFeedCollection)
        .where('created_by', isEqualTo: globalUserId)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        StitchRoutineModel stitchRoutineModel = new StitchRoutineModel();
        stitchRoutineModel.id = element.id;
        stitchRoutineModel.createdAt = element.data()["created_at"];
        stitchRoutineModel.createdBy = element.data()["created_by"];
        stitchRoutineModel.title = element.data()["title"];
        stitchRoutineModel.sectionIds =
            element.data()["section_ids"].cast<String>();
        stitchRoutineModel.isPublic = true;
        stitchRoutineModel.isSelected = false;
        stitchList.add(stitchRoutineModel);
        if (element.id == value.docs[value.docs.length - 1].id) {
          setState(() {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return SafeArea(
      child: Scaffold(
        key: _scaffoldkey,
        body: StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Padding(
              padding: EdgeInsets.only(top: 30),
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    SizedBox(
                      height: 5.0,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(
                          top: ScreenUtil().setSp(25),
                          left: ScreenUtil().setSp(25),
                          right: ScreenUtil().setSp(25),
                          bottom: ScreenUtil().setSp(15)),
                      height: ScreenUtil().setSp(45),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                Text(
                                  'Select Routine',
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: AppColors.titleTextColor,
                                      fontFamily: Constants.boldFont,
                                      fontSize: ScreenUtil().setSp(28)),
                                ),
                                // InkWell(
                                //   onTap: () {
                                //     setState(() {
                                //       createBucketAnsStitchBottomSheet();
                                //     });
                                //   },
                                //   child: Container(
                                //       width: 26,
                                //       height: 26,
                                //       margin: EdgeInsets.only(left: 5),
                                //       padding: EdgeInsets.all(4.5),
                                //       child: SvgPicture.asset(
                                //         'assets/images/ic_plus.svg',
                                //         alignment: Alignment.center,
                                //         color: Colors.black,
                                //         fit: BoxFit.contain,
                                //       )),
                                // ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                String stitchId = "";
                                String stitchTitle = "";
                                String sectionId = "";

                                for (int i = 0; i < stitchList.length; i++) {
                                  if (stitchList[i].isSelected) {
                                    stitchId = stitchList[i].id;
                                    stitchTitle = stitchList[i].title;
                                    sectionId = stitchList[i].sectionIds[
                                        stitchList[i].sectionIds.length - 1];

                                    break;
                                  }
                                }
                                if (stitchId.isEmpty) {
                                  return Constants().errorToast(context,
                                      "Please select at least one routine");
                                }

                                Navigator.of(context).pop({
                                  "routine_id": stitchId,
                                  "routine_title": stitchTitle,
                                  "sectionId": sectionId
                                });
                              });
                            },
                            child: Text(
                              'Done  ',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppColors.titleTextColor,
                                  fontFamily: Constants.boldFont,
                                  fontSize: ScreenUtil().setSp(28)),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 1.0,
                      color: AppColors.lightGreyColor,
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: stitchList.length > 0
                            ? SingleChildScrollView(
                                child: Container(
                                    child: stitchListing(context, stitchList)))
                            : Center(
                                child: Text(
                                'No Routines',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                                textAlign: TextAlign.center,
                              )),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void createBucketAnsStitchBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return SingleChildScrollView(
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
                                        isBucketSelected == true
                                            ? 'Create a new Stitch'
                                            : 'Create a new Routine',
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: AppColors.titleTextColor,
                                            fontFamily: Constants.boldFont,
                                            fontSize: ScreenUtil().setSp(28)),
                                      ),
                                    ),
                                    RotationTransition(
                                      turns:
                                          new AlwaysStoppedAnimation(45 / 360),
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
                                    isBucketSelected == true
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
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          DottedBorder(
                                            padding: EdgeInsets.all(
                                              ScreenUtil().setSp(40),
                                            ),
                                            borderType: BorderType.RRect,
                                            color: Color(0xFF1A58E7)
                                                .withOpacity(0.7),
                                            radius: Radius.circular(10),
                                            dashPattern: [2.5, 4, 2, 4],
                                            strokeWidth: 1.5,
                                            child: SvgPicture.asset(
                                              'assets/images/ic_media_image.svg',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(
                                        child: PhysicalModel(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: AppColors.viewLineColor,
                                          elevation: 5,
                                          shadowColor: AppColors.shadowColor,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                isBucketSelected == true
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
                                  stitchName = value;
                                  if (stitchDescriptionController.text.length >
                                          3 &&
                                      value.trim().isNotEmpty) {
                                    enableButton = true;
                                    setState(() {});
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return isBucketSelected == true
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
                                isBucketSelected == true
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
                                    return isBucketSelected == true
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
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0)),
                                      border: Border.all(
                                          color: AppColors.appGreyColor[500],
                                          width: 1)),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                    side: BorderSide(
                                        color: AppColors.primaryColor),
                                  ),
                                  color: AppColors.primaryColor,
                                  onPressed: () {
                                    if (isBucketSelected) {
                                      // createStitch();
                                      checkValids(
                                          context, Constants.stitchCollection);
                                    } else {
                                      checkValids(
                                          context, Constants.routineCollection);
                                    }
                                  },
                                  child: Text(
                                    isBucketSelected == true
                                        ? 'Create Stitch'
                                        : 'Create Routine',
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
            );
          },
        );
      },
    );
  }

  // Upload image to firebase storage

  void uploadImageToFirebase(String storageName, String collectionName) async {
    Utilities.show(context);

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var reference =
        FirebaseStorage.instance.ref().child(storageName).child(fileName);
    UploadTask uploadTask = reference.putFile(imageFile);
    uploadTask.whenComplete(() {
      reference.getDownloadURL().then((downloadUrl) {
        _selectedImageUrl = downloadUrl;
        updateDataToFb(collectionName, downloadUrl);
      });
    });
  }

  checkValids(BuildContext context, String collectionName) {
    if (_formKey.currentState.validate()) {
      Navigator.of(context).pop();
      FocusScope.of(context).unfocus();

      if (isBucketSelected) {
        if (imageFile != null) {
          Constants.showSnackBarWithMessage("Stitch image uploading...",
              _scaffoldkey, context, AppColors.primaryColor);

          uploadImageToFirebase(Constants.stitchImagesFolder, collectionName);
        } else {
          updateDataToFb(collectionName, defaultPostImage);
        }
      } else {
        if (imageFile != null) {
          Constants.showSnackBarWithMessage("Routine image uploading...",
              _scaffoldkey, context, AppColors.primaryColor);

          uploadImageToFirebase(Constants.routineImagesFolder, collectionName);
        } else {
          updateDataToFb(collectionName, defaultPostImage);
        }
      }
    } else {
    }
  }

  void updateDataToFb(String collectionName, String downloadUrl) {
    var stitchMap = {
      "created_at": Timestamp.now(),
      "created_by": globalUserId,
      "description": stitchDescriptionController.text.trim(),
      "image": downloadUrl,
      "is_public": isPublic,
      "title": stitchTitleController.text.trim(),
      "updated_at": Timestamp.now()
    };
    FirebaseFirestore.instance
        .collection(collectionName)
        .add(stitchMap)
        .then((value) {
      // _formKey.currentState?.reset();
      imageFile = null;
      stitchDescriptionController.clear();
      stitchTitleController.clear();
      String sMsg = "";
      if (isBucketSelected) {
        sMsg = "Stitch";
      } else {
        sMsg = "Routine";
      }
      //Constants().successToast(context, "$sMsg created successfully!");

      Utilities.hide();
      Constants.showSnackBarWithMessage("$sMsg created successfully!",
          _scaffoldkey, context, AppColors.greenColor);
      // setState(() {});

      getRoutines();
      // Navigator.of(context).pop();
    });
  }

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
      updated(state);
    } else {
    }
  }

  Future<Null> updated(StateSetter updateState) async {
    updateState(() {});
  }

  Widget stitchListing(BuildContext context, stitchListing) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: stitchListing.length,
      primary: false,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        return new BucketStitchListItem(
          stitchListing[index],
          index,
          fromPostPage: true,
          stitchListing: stitchList,
          routinePost: true,
          refreshList: refreshList,
        );
      },
    );
  }

  void refreshList(index) {
    for (int i = 0; i < stitchList.length; i++) {
      if (index != i) {
        stitchList[i].isSelected = false;
      }
    }
    setState(() {});
  }
}
