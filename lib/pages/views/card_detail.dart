import 'dart:io';
import 'dart:io' as io;

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:solstice/model/cards_fb_model.dart';
import 'package:solstice/model/post_card_model.dart';
import 'package:solstice/pages/home/video_trimmer.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/utilities.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CardDetail extends StatefulWidget {
  final String postId;
  final int indexKey;
  final Map<File, File> postVideoFilesMap;
  final CardsFbModel selectedItem;
  CardDetail(
      {this.postId, this.indexKey, this.postVideoFilesMap, this.selectedItem});

  @override
  _CardDetailState createState() => _CardDetailState();
}

class _CardDetailState extends State<CardDetail> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  TextEditingController nameTextController = new TextEditingController();
  TextEditingController descriptionTextController = new TextEditingController();

  String userIDPref = "";
  bool isBtnEnable = false;
  PostCardModel postCardModel;
  XFile imageCardFile;
  int mediaType = 1;
  String imagePath = "";
  String videoPath = "";
  XFile videoFile;
  bool isThumbnail = false;
  bool fromPostVideo = false, isEditMode = false;
  String imageThumb = "", videoUrl = "",cardId="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.selectedItem != null) {
      nameTextController.text = widget.selectedItem.title;
      descriptionTextController.text = widget.selectedItem.description;
      imageThumb = widget.selectedItem.image;
      videoUrl = widget.selectedItem.videoUrl;
      isBtnEnable = true;
      mediaType = widget.selectedItem.mediaType;
      cardId = widget.selectedItem.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return SafeArea(
      child: Scaffold(
        key: _scaffoldkey,
        body: Stack(
          fit: StackFit.loose,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(color: Colors.white),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setSp(20),
                        right: ScreenUtil().setSp(36),
                        top: ScreenUtil().setSp(26),
                        bottom: ScreenUtil().setSp(26)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.all(ScreenUtil().setSp(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Card Details",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.titleTextColor,
                                    fontFamily: Constants.boldFont,
                                    fontSize: ScreenUtil().setSp(32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 22,
                            height: 22,
                            padding: EdgeInsets.all(2.5),
                            margin: EdgeInsets.only(left: 10, right: 10),
                            child: SvgPicture.asset(
                              Constants.crossIcon,
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(height: 1.0, color: AppColors.lightGreyColor),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(36),
                        right: ScreenUtil().setWidth(36),
                        top: ScreenUtil().setHeight(26),
                      ),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0.0, vertical: 9.0),
                              child: Text(
                                'Card Photo/Video',
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(24),
                                    fontFamily: Constants.regularFont,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 2.0, right: 8.0),
                              child: InkWell(
                                onTap: () {
                                  // chooseVideoToUpload(context, setState);
                                  _settingModalBottomSheet(context, setState);
                                },
                                child: Container(
                                  width: 80,
                                  height: 75,
                                  alignment: Alignment.centerLeft,
                                  child: imageCardFile == null
                                      ? (imageThumb.isNotEmpty
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 2.0, right: 0.0),
                                              child: Container(
                                                child: PhysicalModel(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color:
                                                      AppColors.viewLineColor,
                                                  elevation: 5,
                                                  shadowColor:
                                                      AppColors.shadowColor,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.network(
                                                      imageThumb,
                                                      fit: BoxFit.cover,
                                                      height: 90,
                                                      width: 90,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : DottedBorder(
                                              borderType: BorderType.RRect,
                                              color: AppColors.primaryColor,
                                              radius: Radius.circular(6),
                                              dashPattern: [3, 3, 3, 3],
                                              strokeWidth: 1.2,
                                              child: Center(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: 24,
                                                  height: 24,
                                                  padding: EdgeInsets.all(2.5),
                                                  child: SvgPicture.asset(
                                                    'assets/images/ic_plus.svg',
                                                    alignment: Alignment.center,
                                                    color:
                                                        AppColors.primaryColor,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ))
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                              left: 2.0, right: 0.0),
                                          child: Container(
                                            child: PhysicalModel(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: AppColors.viewLineColor,
                                              elevation: 5,
                                              shadowColor:
                                                  AppColors.shadowColor,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.file(
                                                  File(imageCardFile.path),
                                                  fit: BoxFit.cover,
                                                  height: 90,
                                                  width: 90,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            lable('Name'),
                            TextFormField(
                              maxLength: 200,
                              cursorColor: AppColors.primaryColor,
                              controller: nameTextController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              maxLines: 1,
                              onChanged: (v) {
                                setState(() {
                                  if (nameTextController.value.text
                                      .trim()
                                      .isEmpty) {
                                    isBtnEnable = false;
                                  } else if (nameTextController.value.text
                                          .trim()
                                          .length <
                                      3) {
                                    isBtnEnable = false;
                                  } else {
                                    // if (imageCardFile != null) {
                                    if (nameTextController.text.length > 0) {
                                      isBtnEnable = true;
                                    }
                                    // }
                                  }
                                });
                              },
                              decoration: InputDecoration(
                                counterText: "",
                              ),
                            ),
                            lable('Description'),
                            TextFormField(
                              maxLength: 2000,
                              cursorColor: AppColors.primaryColor,
                              controller: descriptionTextController,
                              keyboardType: TextInputType.multiline,
                              maxLines: 5,
                              minLines: 1,
                              onChanged: (v) {
                                setState(() {
                                  if (descriptionTextController.value.text
                                      .trim()
                                      .isEmpty) {
                                    isBtnEnable = false;
                                  } else if (descriptionTextController
                                          .value.text
                                          .trim()
                                          .length <
                                      3) {
                                    isBtnEnable = false;
                                  } else {
                                    // if (imageCardFile != null) {
                                    if (descriptionTextController.text.length >
                                        0) {
                                      isBtnEnable = true;
                                    }
                                    // }
                                  }
                                });
                              },
                              decoration: InputDecoration(
                                counterText: "",
                                // labelText: Constants.describeYourJourney,
                                // labelStyle: TextStyle(
                                //     color: AppColors.accentColor,
                                //     fontFamily: Constants.semiBoldFont,
                                //     fontSize: ScreenUtil().setSp(24)),
                                /* contentPadding:
                                    EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),*/
                              ),
                            ),
                            Container(
                              height: 0.8,
                              color: AppColors.accentColor,
                            ),
                            SizedBox(
                              height: 30,
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
                                      color: isBtnEnable
                                          ? AppColors.primaryColor
                                          : AppColors.accentColor,
                                    )),
                                onPressed: () {
                                  setState(() {
                                    validateFields();
                                  });
                                },
                                color: isBtnEnable
                                    ? AppColors.primaryColor
                                    : AppColors.accentColor,
                                textColor: Colors.white,
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  widget.selectedItem != null
                                      ? 'Update Card'
                                      : Constants.addCard,
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(28),
                                    fontFamily: Constants.semiBoldFont,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void chooseVideoToUpload(BuildContext context, setState) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Wrap(
              children: [
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
                  title: new Text('Upload a new video',
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: Constants.regularFont,
                          fontSize: 16.0)),
                  onTap: () => {
                    FocusScope.of(context).unfocus(),
                    _settingModalBottomSheet(context, setState),
                    Navigator.pop(context)
                  },
                ),
                new ListTile(
                  title: new Text('Upload a segment from post video',
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: Constants.regularFont,
                          fontSize: 16.0)),
                  onTap: () => {
                    FocusScope.of(context).unfocus(),
                    Navigator.pop(context),
                    showTrimmerBottomSheet(File(videoFile.path), null, setState)
                  },
                ),
              ],
            ),
          );
        });
  }

  Widget lable(String lable) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20,
        ),
        Container(
          child: Text(
            lable,
            style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                fontFamily: Constants.regularFont,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget suggestionRow(String title) {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 12),
      child: Text(
        title,
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }

  void validate() {
    Constants.showSnackBarWithMessage(
        "Profile adding...", _scaffoldkey, context, AppColors.primaryColor);
  }

  void _settingModalBottomSheet(context, state) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
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
                  if (widget.postVideoFilesMap.length > 0)
                    new ListTile(
                      title: new Text('Upload segment from post video',
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: Constants.regularFont,
                              fontSize: 16.0)),
                      onTap: () => {
                        FocusScope.of(context).unfocus(),
                        Navigator.pop(context),
                        showPostVideos(),
                      },
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
                  new ListTile(
                      title: new Text('Video Camera',
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: Constants.regularFont,
                              fontSize: 16.0)),
                      onTap: () => {
                            FocusScope.of(context).unfocus(),
                            imageSelector(context, "video_camera", state),
                            Navigator.pop(context),
                          }),
                  new ListTile(
                      title: new Text('Video Gallery',
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: Constants.regularFont,
                              fontSize: 16.0)),
                      onTap: () => {
                            FocusScope.of(context).unfocus(),
                            imageSelector(context, "video", state),
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

  void showPostVideos() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: EdgeInsets.all(25),
                child: Wrap(
                  children: [
                    new ListTile(
                      title: new Text('Choose video to upload',
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: Constants.regularFont,
                              fontSize: 16.0)),
                    ),
                    GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            // maxCrossAxisExtent: 200,
                            crossAxisCount: 2,
                            childAspectRatio: 3 / 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20),
                        itemCount: widget.postVideoFilesMap.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              var key = widget.postVideoFilesMap.keys
                                  .elementAt(index);
                              var file = widget.postVideoFilesMap[key];
                              isThumbnail = true;
                              fromPostVideo = true;
                              showTrimmerBottomSheet(
                                  widget.postVideoFilesMap[key], key, setState);

                              // Navigator.pop(context);
                            },
                            child: Container(
                              child: PhysicalModel(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.viewLineColor,
                                elevation: 5,
                                shadowColor: AppColors.shadowColor,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    widget.postVideoFilesMap.keys
                                        .elementAt(index),
                                    fit: BoxFit.cover,
                                    height: 85,
                                    width: 80,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ],
                ),
              );
            },
          );
        });
  }

  Future imageSelector(
      BuildContext context, String pickerType, StateSetter state) async {
    switch (pickerType) {
      case "gallery":
        videoFile = null;

        /// GALLERY IMAGE PICKER

        imageCardFile = await ImagePicker().pickImage(
            source: ImageSource.gallery, imageQuality: 90);
        break;
      case "video":
        imageCardFile = null;
        videoFile = await ImagePicker().pickVideo(
            source: ImageSource.gallery, maxDuration: Duration(seconds: 30));
        break;
      case "video_camera":
        imageCardFile = null;
        videoFile = await ImagePicker().pickVideo(
            source: ImageSource.camera, maxDuration: Duration(seconds: 30));
        break;
      case "camera":
        videoFile = null;

        /// CAMERA CAPTURE CODE

        imageCardFile = await ImagePicker().pickImage(
            source: ImageSource.camera, imageQuality: 90);

        break;
    }

    if (imageCardFile != null) {
      isThumbnail = false;
      uploadImage(File(imageCardFile.path), state);
      updated(state);
    } else if (videoFile != null) {
      isThumbnail = true;

      getThumbnail(videoFile).then((value) async {

        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;
        var filePath = tempPath +
            '/${DateTime.now().millisecondsSinceEpoch.toString()}.jpeg';
        // file_01.tmp is dump file, can be anything
        await File(filePath).writeAsBytes(value).then((thumbFile) {
          imageCardFile = XFile(thumbFile.path);
          uploadImage(thumbFile, state);
          updated(state);
          // uploadImage(thumbFile);
        });
      });
      // showTrimmerBottomSheet(videoFile, null, state);
    } else {
    }
  }

  showTrimmerBottomSheet(File videoFile, File thumbFile, state) async {
    // var object = await showModalBottomSheet(
    //     isScrollControlled: true,
    //     context: context,
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.only(
    //           topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
    //     ),
    //     builder: (context) {
    //       return VideoTrimmer(videoFile: videoFile);
    //     });

    var object = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VideoTrimmer(videoFile: videoFile)));

    if (object != null) {
      Utilities.show(context);
      videoFile = File(object['videoPath']);
      if (thumbFile != null) {
        Navigator.pop(context);
        imageCardFile = XFile(thumbFile.path);
        updated(state);
        setState(() {});
      }

      final bytes = videoFile.lengthSync();
      final kb = bytes / 1024;
      final mb = kb / 1024;

      if (mb <= 15) {
        updatedVideo(videoFile, state, thumbFile);
      } else {
        Utilities.hide();
        imageCardFile = null;

        Constants().errorToast(context, "Please select video below 15 MB.");
        state(() {});
      }
    }
  }

  Future<Null> updated(StateSetter updateState) async {
    updateState(() {});
  }

  void validateFields() {
    if (nameTextController.text.trim().isEmpty) {
      return Constants().errorToast(context, 'Please enter name');
    } else if (descriptionTextController.text.trim().isEmpty) {
      return Constants().errorToast(context, 'Please enter description');
    }

    Utilities.show(context);

    if (imageCardFile != null && mediaType == 1) {
      addCardData(imagePath, mediaType, videoPath);
    } else if (mediaType == 2) {
      addCardData(imagePath, mediaType, videoPath);
    } else {
      if (mediaType == 1) {
        addCardData(imageThumb, 1, imageThumb);
      } else if (mediaType == 2) {
        addCardData(imageThumb, 2, videoUrl);
      } else {
        addCardData(defaultPostImage, 1, "");
      }
    }
  }

  // get video thumbnail
  getThumbnail(videofile) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: videofile.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 384,
      // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 100,
    );
    return uint8list;
  }

  Future<void> uploadImage(File file, state) async {
    Utilities.show(context);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('${Constants.cardImagesFolder}/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(io.File(file.path));
    uploadTask.whenComplete(() {
      firebaseStorageRef.getDownloadURL().then((value) {
        Utilities.hide();
        if (isThumbnail) {
          imagePath = value;
          mediaType = 2;
          if (!fromPostVideo) {
            showTrimmerBottomSheet(File(videoFile.path), null, state);
          }

          // updatedVideo(videoFile);
        } else {
          imagePath = value;
          mediaType = 1;
          videoPath = "";
        }

      }).catchError((error) {
      });
    });
  }

  // upload file(video) to firebase storage
  Future<Null> updatedVideo(imageFile, state, File thumbFilenew) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('${Constants.cardVideosFolder}/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(io.File(imageFile.path));
    uploadTask.whenComplete(() {
      firebaseStorageRef.getDownloadURL().then((value) {
        videoPath = value;
        mediaType = 2;

        if (thumbFilenew != null) {
          imageCardFile =new  XFile(thumbFilenew.path);
          Utilities.hide();
          uploadImage(thumbFilenew, state);
          // updated(state);
        } else {
          // getThumbnail(imageFile).then((value) async {
          //   if (value == null) {
          //     Utilities.hide();
          //   } else {
          //     Directory tempDir = await getTemporaryDirectory();
          //     String tempPath = tempDir.path;
          //     var filePath = tempPath +
          //         '/${DateTime.now().millisecondsSinceEpoch.toString()}.jpeg';
          //     // file_01.tmp is dump file, can be anything
          //     await File(filePath).writeAsBytes(value).then((thumbFile) {
          //       imageCardFile = thumbFile;
          //       uploadImage(thumbFile);
          //       updated(state);
          //       // uploadImage(thumbFile);
          //     });
          //   }
          // });
          Utilities.hide();
        }
      }).catchError((error) {
        Utilities.hide();
      });
    });
  }

  void addCardData(imagePath, mediaType, videoPath) {
    if (widget.selectedItem != null) {
      updateCard(imagePath, mediaType, videoPath);
    } else {
      createCard(imagePath, mediaType, videoPath);
    }
  }

  void updateCard(imagePath, mediaType, videoPath) {
 
    var documentReference = FirebaseFirestore.instance
        .collection(Constants.posts)
        .doc(widget.postId)
        .collection(Constants.cardsColl)
        .doc(cardId);
    postCardModel = new PostCardModel(
        cardId: cardId,
        key: ValueKey(widget.indexKey),
        createdAt: Timestamp.now(),
        description: descriptionTextController.text.trim(),
        position: widget.indexKey,
        image: imagePath,
        mediaType: mediaType,
        videoUrl: videoPath,
        title: nameTextController.text.trim(),
        updatedAt: Timestamp.now());

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(documentReference, postCardModel.toMap());
    }).then((value) {
      Utilities.hide();
       Constants.showSnackBarWithMessage("Card updated successfully!",
              _scaffoldkey, context, AppColors.greenColor);
      Navigator.pop(context, {"cardObject": postCardModel});
    }).catchError((exf) {
      Constants().errorToast(context, '$exf');
      Utilities.hide();
    });
  }

  void createCard(imagePath, mediaType, videoPath) {
    String cardId = DateTime.now().millisecondsSinceEpoch.toString();
    var documentReference = FirebaseFirestore.instance
        .collection(Constants.posts)
        .doc(widget.postId)
        .collection(Constants.cardsColl)
        .doc(cardId);
    postCardModel = new PostCardModel(
        cardId: cardId,
        // bodyPart: bodyPartsTextController.text.trim(),
        key: ValueKey(widget.indexKey),
        createdAt: Timestamp.now(),
        description: descriptionTextController.text.trim(),
        position: widget.indexKey,
        // equipment: equipmentsTextController.text.trim(),
        image: imagePath,
        mediaType: mediaType,
        videoUrl: videoPath,
        // movementNutrition: nutritionsTextController.text.trim(),
        // movementType: movementTypeTextController.text.trim(),
        // sportsActivity: sportsTextController.text.trim(),
        title: nameTextController.text.trim(),
        updatedAt: Timestamp.now());

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(documentReference, postCardModel.toMap());
    }).then((value) {
      Utilities.hide();
      Navigator.pop(context, {"cardObject": postCardModel});
    }).catchError((exf) {
      Constants().errorToast(context, '$exf');
      Utilities.hide();
    });
  }
}
