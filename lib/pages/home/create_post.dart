import 'dart:collection';
import 'dart:io';
import 'dart:io' as io;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:solstice/model/add_card_model.dart';
import 'package:solstice/model/post_card_model.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/pages/home/card_reorder_item.dart';
import 'package:solstice/pages/home/post_filter_new.dart';
import 'package:solstice/pages/home/save_to_stitch.dart';
import 'package:solstice/pages/home/video_trimmer.dart';
import 'package:solstice/pages/search_location.dart';
import 'package:solstice/pages/views/card_detail.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/utilities.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CreatePost extends StatefulWidget {
  final String routineId;
  final String screenType;
  final PostFeedModel postFeedModel;
  CreatePost({this.routineId, this.screenType, this.postFeedModel});

  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  TextEditingController postTitleController = new TextEditingController();
  TextEditingController postGoalController = new TextEditingController();
  TextEditingController postDescriptionController = new TextEditingController();
  TextEditingController postCardIDController = new TextEditingController();
  TextEditingController postCardNameController = new TextEditingController();
  TextEditingController stitchDescriptionController =
      new TextEditingController();
  TextEditingController stitchTitleController = new TextEditingController();
  final FocusNode _postTitleFocus = new FocusNode();
  final FocusNode _postDescriptionFocus = new FocusNode();
  final FocusNode _postCardIDFocus = new FocusNode();
  final FocusNode _postCardNameFocus = new FocusNode();
  String postTitleErrorMessage = "";
  String postDescriptionErrorMessage = "";
  String postCardIDErrorMessage = "";
  String postCardNameErrorMessage = "";
  bool isPostTitleHaveError = true;
  bool isPostDescriptionHaveError = true;
  bool isPostCardIDHaveError = true;
  bool isPostCardNameHaveError = true;
  bool isBtnEnable = false;
  bool isCardBtnEnable = false;
  var imageFile = null;
  var imageFileStitch = null;

  XFile imageCardFile;

  List imageFileList = new List.empty(growable: true);
  List imageUrlList = new List.empty(growable: true);
  List<String> mediaFileList = new List.empty(growable: true);
  List<HashMap<String, dynamic>> mediaMapList = new List.empty(growable: true);
  HashMap<String, dynamic> mediaMap = new HashMap();
  bool isCardImage = false;
  List<AddCardModel> cardModelList = new List.empty(growable: true);
  MediaPostModel mediaPostModel = new MediaPostModel();

  String location = Constants.selectLocation;
  double latitude;
  double longitude;
  List<PostCardModel> cardList = new List.empty(growable: true);

  PageController pageController = new PageController();
  int imagePageIndex = 0;
  String postId;
  final _formKey = GlobalKey<FormState>();
  String _selectedImageUrl = "";
  String stichId = "", stitchTitle = "";
  bool showCreate = false;
  String userIDPref = "";
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  ScrollController _controller;
  bool showNewPost = true;

  bool isPublic = true;
  String postType = "Public";

  XFile videoFile;
  bool isThumbnail = false;

  LatLng currentLatLng;
  Position currentLocation;
  Map<File, File> postVideoFilesMap = new HashMap();
  bool isEditPost = false;
  PostFeedModel postFeedModel;

  @override
  void initState() {
    super.initState();
    // _controller = ScrollController();

    setPostDataForEditMode();
  }

  void setPostDataForEditMode() {
    postFeedModel = widget.postFeedModel;
    if (postFeedModel != null) {
      isCardBtnEnable = true;
      isEditPost = true;
      isBtnEnable = true;
      postTitleController.text = postFeedModel.title;
      postDescriptionController.text = postFeedModel.description;
      location = postFeedModel.location;
      isPublic = postFeedModel.isPublic;
      postType = isPublic ? "Public" : "Private";
      for (int i = 0; i < postFeedModel.mediaList.length; i++) {
        if (postFeedModel.mediaList[i].mediaType == "Image") {
          imageUrlList.add(postFeedModel.mediaList[i].url);
          mediaFileList.add(postFeedModel.mediaList[i].url);
        } else {
          imageUrlList.add(postFeedModel.mediaList[i].thumbnail);
          mediaFileList.add(postFeedModel.mediaList[i].thumbnail);
        }
        HashMap<String, dynamic> map = new HashMap();
        map["thumbnail"] = postFeedModel.mediaList[i].thumbnail;
        map["url"] = postFeedModel.mediaList[i].url;
        map["type"] = postFeedModel.mediaList[i].mediaType;
        mediaMapList.add(map);
      }
    } else {
      getUserLocation();
    }
  }

  getUserLocation() async {

    currentLocation = await locateUser();
    currentLatLng = LatLng(currentLocation.latitude, currentLocation.longitude);
    //globals.currentLatLng = currentLatLng;
    try {
      latitude = currentLatLng.latitude;
      longitude = currentLatLng.longitude;
      List<Placemark> placemarks = await placemarkFromCoordinates(
          currentLocation.latitude, currentLocation.longitude);

      Placemark place = placemarks[0];
      location = "${place.locality}, ${place.country}";
    } catch (e) {
    }
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            key: _scaffoldkey,
            body: SingleChildScrollView(
              child: Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: showNewPost
                      ? Wrap(
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
                                            isEditPost
                                                ? "Update Post"
                                                : Constants.postJourney,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: AppColors.titleTextColor,
                                                fontFamily: Constants.boldFont,
                                                fontSize:
                                                    ScreenUtil().setSp(28)),
                                          ),
                                        ),
                                        InkWell(
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
                                              Constants.crossIcon,
                                              alignment: Alignment.center,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: ScreenUtil().setSp(32)),
                                  Text(
                                    Constants.uploadPhoto,
                                    style: TextStyle(
                                        color: AppColors.accentColor,
                                        fontFamily: Constants.semiBoldFont,
                                        fontSize: ScreenUtil().setSp(24)),
                                  ),
                                  SizedBox(height: 8),
                                  Wrap(
                                    direction: Axis.horizontal,
                                    children: [
                                      if (imageUrlList.length > 0)
                                        Container(
                                          height: 80,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: imageUrlList.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return imageListFromUrl(
                                                  context, index, setState);
                                            },
                                          ),
                                        ),
                                      Container(
                                        height: 80,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: imageFileList.length + 1,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return imageListUi(
                                                context, index, setState);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  TextFormField(
                                    maxLength: 200,
                                    focusNode: _postTitleFocus,
                                    cursorColor: AppColors.primaryColor,
                                    controller: postTitleController,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (v) {
                                      FocusScope.of(context)
                                          .requestFocus(_postDescriptionFocus);
                                    },
                                    onChanged: (v) {
                                      setState(() {
                                        if (postTitleController.value.text
                                            .trim()
                                            .isEmpty) {
                                          // isPostTitleHaveError = true;
                                          isBtnEnable = false;
                                          // postTitleErrorMessage = Constants.enterTitleError;
                                        } else if (postTitleController
                                                .value.text
                                                .trim()
                                                .length <
                                            3) {
                                          isBtnEnable = false;
                                          // isPostTitleHaveError = true;
                                          // postTitleErrorMessage = Constants.minimum4Character;
                                        } else {
                                          // if (imageFileList.length > 0) {
                                          if (postDescriptionController
                                                  .text.length >
                                              0) {
                                            isBtnEnable = true;
                                          }
                                          // }
                                          // isPostTitleHaveError = false;
                                          // postTitleErrorMessage = "";
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      counterText: "",
                                      labelText: Constants.title,
                                      labelStyle: TextStyle(
                                          color: AppColors.accentColor,
                                          fontFamily: Constants.semiBoldFont,
                                          fontSize: ScreenUtil().setSp(24)),
                                      /* contentPadding:
                                  EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),*/
                                    ),
                                  ),
                                  Container(
                                      padding: EdgeInsets.only(left: 10),
                                      alignment: Alignment.topRight,
                                      margin: const EdgeInsets.only(
                                          top: 4.0, left: 30.0, bottom: 3),
                                      child: Text(
                                        postTitleErrorMessage,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.red,
                                            fontFamily: Constants.mediumFont),
                                      )),
                                  TextFormField(
                                    maxLength: 2000,
                                    focusNode: _postDescriptionFocus,
                                    cursorColor: AppColors.primaryColor,
                                    controller: postDescriptionController,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 5,
                                    minLines: 1,
                                    onChanged: (v) {
                                      setState(() {
                                        if (postDescriptionController.value.text
                                            .trim()
                                            .isEmpty) {
                                          // isPostDescriptionHaveError = true;
                                          isBtnEnable = false;
                                          // postDescriptionErrorMessage = Constants.enterJourneyError;
                                        } else if (postDescriptionController
                                                .value.text
                                                .trim()
                                                .length <
                                            3) {
                                          // isPostDescriptionHaveError = true;
                                          isBtnEnable = false;
                                          // postDescriptionErrorMessage = Constants.minimum4Character;
                                        } else {
                                          // if (imageFileList.length > 0) {
                                          if (postDescriptionController
                                                  .text.length >
                                              0) {
                                            isBtnEnable = true;
                                          }
                                          // }
                                          // isPostDescriptionHaveError = false;
                                          // postDescriptionErrorMessage = "";
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      counterText: "",
                                      labelText: Constants.describeYourJourney,
                                      labelStyle: TextStyle(
                                          color: AppColors.accentColor,
                                          fontFamily: Constants.semiBoldFont,
                                          fontSize: ScreenUtil().setSp(24)),
                                      /* contentPadding:
                                  EdgeInsets.fromLTRB(10.0, 15.0, 20.0, 15.0),*/
                                    ),
                                  ),
                                  Container(
                                      padding: EdgeInsets.only(left: 10),
                                      alignment: Alignment.topRight,
                                      margin: const EdgeInsets.only(
                                          top: 4.0, left: 30.0, bottom: 16),
                                      child: Text(
                                        postDescriptionErrorMessage,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.red,
                                            fontFamily: Constants.mediumFont),
                                      )),
                                  Text(
                                    Constants.locationOptional,
                                    style: TextStyle(
                                        color: AppColors.accentColor,
                                        fontFamily: Constants.semiBoldFont,
                                        fontSize: ScreenUtil().setSp(24)),
                                  ),
                                  SizedBox(height: 10),
                                  InkWell(
                                    onTap: () async {
                                      FocusScope.of(context).unfocus();
                                      var object = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SearchLocation()));

                                      if (object != null) {
                                        SearchedLocationModel
                                            searchedLocationModel =
                                            object['returnData'];
                                        location = searchedLocationModel.title;
                                        latitude =
                                            searchedLocationModel.latitude;
                                        longitude =
                                            searchedLocationModel.longitude;
                                        setState(() {});
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            location,
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(28),
                                                color: AppColors.accentColor,
                                                fontFamily:
                                                    Constants.mediumFont),
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
                                    height: 1,
                                    color: AppColors.lightGreyColor,
                                  ),
                                  SizedBox(height: 15),
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
                                        postType = 'Private';
                                      } else {
                                        postType = 'Public';
                                      }
                                      isPublic = !isPublic;
                                      setState(() {});
                                    },
                                    child: Container(
                                      width: 100.0,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 10.0),
                                      margin:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20.0)),
                                          border: Border.all(
                                              color:
                                                  AppColors.appGreyColor[500],
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
                                            '$postType',
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(28),
                                                color: AppColors.accentColor,
                                                fontFamily:
                                                    Constants.mediumFont),
                                            textAlign: TextAlign.center,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    color: Colors.transparent,
                                    margin: EdgeInsets.only(top: 12),
                                    width: MediaQuery.of(context).size.width,
                                    height: ScreenUtil().setSp(100),
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(40.0),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          var title = postTitleController
                                              .value.text
                                              .trim();
                                          var description =
                                              postDescriptionController
                                                  .value.text
                                                  .trim();
                                          if (title.isEmpty) {
                                            Constants().errorToast(context,
                                                Constants.enterTitleError);
                                            // postTitleErrorMessage = Constants.enterTitleError;
                                          } else if (description.isEmpty) {
                                            Constants().errorToast(context,
                                                Constants.enterJourneyError);
                                          } else if (title.length < 4) {
                                            Constants().errorToast(context,
                                                Constants.titleMust4Characters);
                                          } else if (description.length < 4) {
                                            Constants().errorToast(
                                                context,
                                                Constants
                                                    .journeyMust4Characters);
                                          } else {
                                            if (isBtnEnable == true) {
                                              // uploadImages(
                                              //     postTitleController.text,
                                              //     postDescriptionController
                                              //         .text,
                                              //     postGoalController.text,
                                              //     imageFileList);
                                              Utilities.show(context);
                                              if (isEditPost) {
                                                updatePost(
                                                    postTitleController.text,
                                                    postDescriptionController
                                                        .text,
                                                    postGoalController.text);
                                              } else {
                                                createPost(
                                                    postTitleController.text,
                                                    postDescriptionController
                                                        .text,
                                                    postGoalController.text);
                                              }
                                            }
                                          }
                                        });
                                      },
                                      color: isBtnEnable == true
                                          ? AppColors.primaryColor
                                          : AppColors.accentColor,
                                      textColor: Colors.white,
                                      padding: EdgeInsets.all(10.0),
                                      child: Text(
                                        Constants.continueTxt,
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
                        )
                      : Container()),
            )));
  }

  Widget imageListFromUrl(BuildContext context, int index,
      void Function(void Function() p1) setState) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 0.0),
      child: Stack(
        children: [
          Container(
            child: PhysicalModel(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.viewLineColor,
              elevation: 5,
              shadowColor: AppColors.shadowColor,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrlList[index],
                  fit: BoxFit.cover,
                  height: 85,
                  width: 80,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: InkWell(
              onTap: () {
                setState(() {
                  imageUrlList.removeAt(index);

                  mediaMapList.removeAt(index);
                  postVideoFilesMap.forEach((key, value) {
                    if (key == imageFileList[index]) {
                      postVideoFilesMap.remove(key);
                    }
                  });
                });
              },
              child: Container(
                width: 22,
                height: 22,
                padding: EdgeInsets.all(2.0),
                child: SvgPicture.asset(
                  Constants.redCrossIcon,
                  alignment: Alignment.center,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget imageListUi(BuildContext context, int index,
      void Function(void Function() p1) setState) {
    return imageFileList.length == 0
        ? Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: InkWell(
              onTap: () {
                isCardImage = false;
                _settingModalBottomSheet(context, setState, false);
              },
              child: Container(
                width: 80,
                height: 75,
                child: DottedBorder(
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
                        color: AppColors.primaryColor,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        : index < imageFileList.length
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 0.0),
                child: Stack(
                  children: [
                    Container(
                      child: PhysicalModel(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.viewLineColor,
                        elevation: 5,
                        shadowColor: AppColors.shadowColor,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            imageFileList[index],
                            fit: BoxFit.cover,
                            height: 85,
                            width: 80,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            mediaMapList.removeAt(index);
                            imageFileList.removeAt(index);
                            postVideoFilesMap.forEach((key, value) {
                              if (key == imageFileList[index]) {
                                postVideoFilesMap.remove(key);
                              }
                            });
                          });
                        },
                        child: Container(
                          width: 22,
                          height: 22,
                          padding: EdgeInsets.all(2.0),
                          child: SvgPicture.asset(
                            Constants.redCrossIcon,
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: InkWell(
                  onTap: () {
                    isCardImage = false;
                    _settingModalBottomSheet(context, setState, false);
                  },
                  child: Container(
                    width: 80,
                    height: 75,
                    child: DottedBorder(
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
                            color: AppColors.primaryColor,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
  }

  Widget cardListUi(int position, state) {
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17.0),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: PhysicalModel(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.viewLineColor,
                  elevation: 5,
                  shadowColor: AppColors.shadowColor,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      cardModelList[position].cardImage,
                      fit: BoxFit.cover,
                      height: 50,
                      width: 50,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: ScreenUtil().setSp(25),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      cardModelList[position].cardName,
                      style: TextStyle(
                          fontFamily: 'epilogue_semibold',
                          fontSize: ScreenUtil().setSp(30),
                          color: Colors.black),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setSp(10),
                  ),
                  Text(
                    'ID . ' + cardModelList[position].cardId,
                    style: TextStyle(
                        fontFamily: 'epilogue_regular',
                        fontSize: ScreenUtil().setSp(30),
                        color: Color(0xFF727272)),
                  ),
                ],
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  updatedCardList(state, position, false);
                },
                child: Container(
                  width: 30,
                  height: 30,
                  padding: EdgeInsets.all(2.5),
                  margin: EdgeInsets.only(right: 5),
                  child: SvgPicture.asset(
                    'assets/images/ic_edit_card.svg',
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  updatedCardList(state, position, true);
                },
                child: Container(
                  width: 30,
                  height: 30,
                  padding: EdgeInsets.all(2.5),
                  margin: EdgeInsets.only(right: 5),
                  child: SvgPicture.asset(
                    'assets/images/ic_delete_group.svg',
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void createPostFinal() {
    showCreate = false;
    if (isEditPost) {
      if (widget.screenType == "Stitch") {
        savePostToStitch();
      } else if (widget.screenType == "Routine") {
        savePostToRoutine();
      } else {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } else {
      Utilities.show(context);
      FirebaseFirestore.instance
          .collection(Constants.posts)
          .doc(postId)
          .update({
        "active": 1,
        "stitch_id": "",
        "updated_at": Timestamp.now()
      }).then((value) {
        if (widget.screenType == "Stitch") {
          savePostToStitch();
        } else if (widget.screenType == "Routine") {
          savePostToRoutine();
        } else {
          Utilities.hide();
        }
      }).catchError((err) {
        Utilities.hide();
      });
    }
  }

  void savePostToStitch() {
    FirebaseFirestore.instance
        .collection(Constants.stitchCollection)
        .doc(widget.routineId)
        .update({
      'post_ids': FieldValue.arrayUnion([postId])
    }).then((value) {
      Utilities.hide();
      Constants().successToast(context, "Post is created successfully");
      setState(() {});
      Navigator.pop(context, {"Return": true});
      Navigator.pop(context, {"Return": true});
    }).catchError((err) {
      Utilities.hide();
    });
  }

  void savePostToRoutine() {
    FirebaseFirestore.instance
        .collection(Constants.routineCollection)
        .doc(widget.routineId)
        .collection(Constants.posts)
        .add({
      "post_id": postId,
      "complete": 0,
    }).then((value) {
      Utilities.hide();
      Constants().successToast(context, "Post is created successfully");
      setState(() {});
      Navigator.pop(context, {"Return": true});
      Navigator.pop(context, {"Return": true});
      // MyNavigator.goToHome(context);
    }).catchError((err) {
      Utilities.hide();
    });
  }

  void continueCretePost() {
    isCardBtnEnable = true;
    if (cardList.length > 0) {
      Utilities.show(context);

      FirebaseFirestore.instance
          .collection(Constants.posts)
          .doc(postId)
          .update({"active": 1, "updated_at": Timestamp.now()});

      for (int i = 0; i < cardList.length; i++) {
        FirebaseFirestore.instance
            .collection(Constants.posts)
            .doc(postId)
            .collection(Constants.cardsColl)
            .get()
            .then((value) {
          value.docs.forEach((element) {
            if (cardList[i].cardId == element.id) {
              FirebaseFirestore.instance
                  .collection(Constants.posts)
                  .doc(postId)
                  .collection(Constants.cardsColl)
                  .doc(element.id)
                  .update({"position": i, "updated_at": Timestamp.now()});
            }
            if (i == cardList.length - 1) {
              Utilities.hide();
            }
          });
        });
      }
    }
  }

  void uploadImageToFirebase(
      String storageName, String collectionName, setState1) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var reference =
        FirebaseStorage.instance.ref().child(storageName).child(fileName);
    UploadTask uploadTask = reference.putFile(imageFileStitch);
    uploadTask.whenComplete(() {
      reference.getDownloadURL().then((downloadUrl) {
        _selectedImageUrl = downloadUrl;
        createStitchEntry(collectionName, setState1);
      }).catchError((onError) {
        Utilities.hide();
        Constants().errorToast(context, "$onError , please upload image again");
      });
    });
  }

  void createStitchEntry(collectionName, setState1) {
    FirebaseFirestore.instance.collection(collectionName).add({
      "created_at": Timestamp.now(),
      "created_by": globalUserId,
      "description": stitchDescriptionController.text.trim(),
      "image": _selectedImageUrl,
      "title": stitchTitleController.text.trim(),
      "updated_at": Timestamp.now()
    }).then((value) {
      // _formKey.currentState?.reset();
      String title = stitchTitleController.text.trim();
      Constants.showSnackBarWithMessage("Stitch created successfully!",
          _scaffoldkey, context, AppColors.greenColor);
      Utilities.hide();
      Future.delayed(const Duration(milliseconds: 1000), () {
        Navigator.of(context)
            .pop({"stitch_id": value.id, "stitch_title": title});

        imageFileStitch = null;
        stitchDescriptionController.clear();
        stitchTitleController.clear();
      });
    }).catchError((error) {
      Utilities.hide();
    });
  }

  checkValids(BuildContext context, String collectionName, String storageName,
      setState1) {
    if (_formKey.currentState.validate()) {
      Utilities.show(context);
      if (imageFileStitch == null) {
        _selectedImageUrl = defaultPostImage;
        createStitchEntry(collectionName, setState1);
      } else {
        uploadImageToFirebase(storageName, collectionName, setState1);
      }
    } else {
      Constants().errorToast(context, "Please fill all the fields");
    }
  }

  void createStitch(setState1) async {
    var object = await showModalBottomSheet(
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
              child: Form(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 1.0, top: 10.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  padding: EdgeInsets.all(2.5),
                                  margin: EdgeInsets.only(right: 5),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/images/ic_cross_bottom.svg',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Create a new Stitch',
                              style: TextStyle(
                                  fontFamily: 'epilogue_semibold',
                                  fontSize: ScreenUtil().setSp(30),
                                  color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Upload Stitch Thumbnail',
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
                            _settingModalBottomSheet(context, setState, true);
                            // imageSelector(context, "gallery",setState);
                          },
                          child: imageFileStitch == null
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    DottedBorder(
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
                                  ],
                                )
                              : Container(
                                  child: PhysicalModel(
                                    borderRadius: BorderRadius.circular(10),
                                    color: AppColors.viewLineColor,
                                    elevation: 5,
                                    shadowColor: AppColors.shadowColor,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        imageFileStitch,
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
                          'Stitch Name',
                          style: TextStyle(
                              fontFamily: 'epilogue_semibold',
                              fontSize: ScreenUtil().setSp(25),
                              color: Color(0xFF727272)),
                        ),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: stitchTitleController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter stitch title!';
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
                          'Stitch Description',
                          style: TextStyle(
                              fontFamily: 'epilogue_semibold',
                              fontSize: ScreenUtil().setSp(25),
                              color: Color(0xFF727272)),
                        ),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: stitchDescriptionController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter stitch description!';
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
                              // createStitch();
                              checkValids(context, Constants.stitchCollection,
                                  Constants.stitchImagesFolder, setState1);
                            },
                            child: Text(
                              'Create Stitch',
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
            );
          },
        );
      },
    );
    if (object != null) {
      stichId = object['stitch_id'];
      stitchTitle = object['stitch_title'];
      setState(() {});
    }
  }

  void _settingModalBottomSheet(context, state, bool fromStitch) {
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
                      "Select from",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: Constants.mediumFont,
                          fontSize: 18.0),
                    ),
                  ),
                  new ListTile(
                    title: new Text('Photo Camera',
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: Constants.regularFont,
                            fontSize: 16.0)),
                    onTap: () => {
                      FocusScope.of(context).unfocus(),
                      imageSelector(context, "camera", state, fromStitch),
                      Navigator.pop(context)
                    },
                  ),
                  new ListTile(
                      title: new Text('Photo Gallery',
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: Constants.regularFont,
                              fontSize: 16.0)),
                      onTap: () => {
                            FocusScope.of(context).unfocus(),
                            imageSelector(
                                context, "gallery", state, fromStitch),
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
                            imageSelector(
                                context, "video_camera", state, fromStitch),
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
                            imageSelector(context, "video", state, fromStitch),
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

  Future imageSelector(BuildContext context1, String pickerType,
      StateSetter state, bool fromStitch) async {
    switch (pickerType) {
      case "video":
        videoFile = await ImagePicker().pickVideo(
            source: ImageSource.gallery, maxDuration: Duration(seconds: 30));
        break;
      case "video_camera":
        videoFile = await ImagePicker().pickVideo(
            source: ImageSource.camera, maxDuration: Duration(seconds: 30));
        break;

      case "gallery":

        /// GALLERY IMAGE PICKER
        if (fromStitch) {
          imageFileStitch = await ImagePicker()
              .pickImage(source: ImageSource.gallery, imageQuality: 90);
        } else if (isCardImage) {
          imageCardFile = await ImagePicker()
              .pickImage(source: ImageSource.gallery, imageQuality: 90);
        } else {
          imageFile = await ImagePicker()
              .pickImage(source: ImageSource.gallery, imageQuality: 90);
        }
        break;

      case "camera":

        /// CAMERA CAPTURE CODE
        if (fromStitch) {
          imageFileStitch = await ImagePicker()
              .pickImage(source: ImageSource.camera, imageQuality: 90);
        } else if (isCardImage) {
          imageCardFile = await ImagePicker()
              .pickImage(source: ImageSource.camera, imageQuality: 90);
        } else {
          imageFile = await ImagePicker()
              .pickImage(source: ImageSource.camera, imageQuality: 90);
        }
        break;
    }

    if (isCardImage) {
      if (imageCardFile != null) {
        updated(state, imageCardFile);
      } else {
      }
    } else {
      if (imageFile != null) {
        //imageFileList.add(imageFile);
        updated(state, imageFile);

        imageFileList.add(imageFile);
        state(() {});
      } else {
      }
      if (videoFile != null) {
        // Utilities.show(context);
        isThumbnail = true;
        showTrimmerBottomSheet(File(videoFile.path), state);
        // updatedVideo(state, videoFile);
      }
    }
  }

  showTrimmerBottomSheet(File videoFile, state) async {
    // var object = await showModalBottomSheet(
    //     isScrollControlled: true,
    //     context: context,
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.only(o
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

      final bytes = videoFile.lengthSync();
      final kb = bytes / 1024;
      final mb = kb / 1024;

      if (mb <= 15) {
        updatedVideo(state, videoFile);
      } else {
        Utilities.hide();
        mediaFileList.removeAt(mediaFileList.length - 1);
        imageFileList.removeAt(imageFileList.length - 1);
        mediaMapList.removeAt(mediaMapList.length - 1);

        Constants().errorToast(context, "Please select video below 15 MB.");
        state(() {});
      }

      // updatedVideo(state, videoFile);
    }
  }

  Future<Null> updatedVideo(StateSetter updateState, imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var firebaseStorageRef =
        FirebaseStorage.instance.ref().child('postsImages/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(io.File(imageFile.path));

    uploadTask.whenComplete(() {
      firebaseStorageRef.getDownloadURL().then((value) {
        if (isThumbnail) {
          getThumbnail(videoFile, updateState).then((value) async {
            Directory tempDir = await getTemporaryDirectory();
            String tempPath = tempDir.path;
            var filePath = tempPath +
                '/${DateTime.now().millisecondsSinceEpoch.toString()}.jpeg';
            // file_01.tmp is dump file, can be anything
            await File(filePath).writeAsBytes(value).then((thumbFile) {
              imageFileList.add(thumbFile);
              postVideoFilesMap[thumbFile] = imageFile;
              updated(updateState, thumbFile);
            });

            // writeToFile(value).then((thumbFile) {
            // if (thumbFile != null) {
            //   updated(updateState, thumbFile);
            // }
            // });
          });
          Utilities.hide();
        } else {}
        mediaMap["type"] = "video";
        mediaMap["url"] = value;
        mediaPostModel.mediaType = "video";
        mediaPostModel.url = value;

      }).catchError((error) {
      });
    });

    updateState(() {});
  }

  getThumbnail(videofile, StateSetter updateState) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: videofile.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 384,
      // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 100,
    );
    return uint8list;
  }

  Future<Null> updated(StateSetter updateState, imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var firebaseStorageRef =
        FirebaseStorage.instance.ref().child('postsImages/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(io.File(imageFile.path));

    uploadTask.whenComplete(() {
      firebaseStorageRef.getDownloadURL().then((value) {
        if (isThumbnail) {
          mediaPostModel.thumbnail = value;
          mediaMap["thumbnail"] = value;
        } else {
          mediaPostModel.mediaType = "Image";
          mediaMap["thumbnail"] = "";
          mediaMap["type"] = "Image";
          mediaMap["url"] = value;
          mediaPostModel.url = value;
        }

        mediaFileList.add(value);
        mediaMapList.add(mediaMap);

      }).catchError((error) {
      });
    });

    if (imageFileList.length > 0) {
      if (postTitleController.text.length > 0 &&
          postDescriptionController.text.length > 0) {
        isBtnEnable = true;
      }
    } else {
      isBtnEnable = false;
    }
    updateState(() {});

    // updateState(() {
    //   if (!isCardImage) {
    //     imageFileList.add(imageFile);
    //     if (imageFileList.length > 0) {
    //       if (postTitleController.text.length > 0 &&
    //           postDescriptionController.text.length > 0) {
    //         isBtnEnable = true;
    //       }
    //     } else {
    //       isBtnEnable = false;
    //     }
    //   }
    // });
  }

  Future<Null> updatedCardList(
      StateSetter updateState, int position, bool isDelete) async {
    updateState(() {
      if (isDelete == true) {
        cardModelList.removeAt(position);
        if (cardModelList.length > 0) {
          if (postCardIDController.text.trim().length > 0 &&
              postCardNameController.text.trim().length > 0) {
            isCardBtnEnable = true;
          } else {
            isCardBtnEnable = false;
          }
        } else {
          if (imageCardFile != null &&
              postCardIDController.text.trim().length > 0 &&
              postCardNameController.text.trim().length > 0) {
            isCardBtnEnable = true;
          } else {
            isCardBtnEnable = false;
          }
        }
      } else {
        postCardIDController.text = cardModelList[position].cardId;
        postCardNameController.text = cardModelList[position].cardName;
        imageCardFile = cardModelList[position].cardImage;
      }
    });
  }

  void updatePost(String title, String description, String goal) {
    postId = postFeedModel.postId;
    var documentReference =
        FirebaseFirestore.instance.collection(Constants.posts).doc(postId);
    getPostCards();

    if (mediaMapList.length == 0) {
      HashMap<String, dynamic> map = new HashMap();
      map["thumbnail"] = "";
      map["url"] = defaultPostImage;
      map["type"] = "Image";
      mediaMapList.add(map);
      mediaFileList.add(defaultPostImage);
    }

    PostFeedModel postFeedModel1 = new PostFeedModel(
        active: postFeedModel.active,
        createdAt: Timestamp.now(),
        commentCount: postFeedModel.commentCount,
        description: description,
        title: title,
        postId: postId,
        isCardPost: false,
        createdBy: globalUserId,
        mediaMapList: mediaMapList,
        latitude: latitude.toString(),
        isPublic: isPublic,
        longitude: longitude.toString(),
        location: location,
        likeCount: postFeedModel.likeCount,
        upatedAt: Timestamp.now());

    documentReference.update(postFeedModel1.toMap()).then((value) {
      postTitleController.text = "";
      postDescriptionController.text = "";
      location = "";
      postGoalController.text = "";
      mediaMap.clear();

      addPostFilter(context, postId, title, description, mediaFileList, true);
    }).catchError((exc) {
    });
    Utilities.hide();
  }

  void getPostCards() {
    FirebaseFirestore.instance
        .collection(Constants.posts)
        .doc(postId)
        .collection(Constants.cardsColl)
        .orderBy('created_at', descending: false)
        .get()
        .then((value) {
      if (value != null) {
        for (int i = 0; i < value.docs.length; i++) {
          PostCardModel cardModel = PostCardModel.fromSnapshot(value.docs[i]);
          cardList.add(cardModel);
        }
      }
    });
  }

  void createPost(String title, String description, String goal) {
    postId = DateTime.now().millisecondsSinceEpoch.toString();
    var documentReference =
        FirebaseFirestore.instance.collection(Constants.posts).doc(postId);
    if (mediaMapList.length == 0) {
      HashMap<String, dynamic> map = new HashMap();
      map["thumbnail"] = "";
      map["url"] = defaultPostImage;
      map["type"] = "Image";
      mediaMapList.add(map);
      mediaFileList.add(defaultPostImage);
    }

    PostFeedModel postFeedModel = new PostFeedModel(
        active: 0,
        createdAt: Timestamp.now(),
        commentCount: 0,
        description: description,
        title: title,
        postId: postId,
        isCardPost: false,
        createdBy: globalUserId,
        mediaMapList: mediaMapList,
        latitude: latitude.toString(),
        isPublic: isPublic,
        longitude: longitude.toString(),
        location: location,
        likeCount: 0,
        upatedAt: Timestamp.now());

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(documentReference, postFeedModel.toMap());
    }).then((value) {
      postTitleController.text = "";
      postDescriptionController.text = "";
      location = "";
      postGoalController.text = "";
      mediaMap.clear();

      addPostFilter(context, postId, title, description, mediaFileList, false);
    }).catchError((exc) {
    });
    Utilities.hide();
  }

  Future<void> addPostFilter(context, postId, String title, String description,
      mediaFileList, bool isEditPost) async {
    var object = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostFilterNew(
                  postId: postId,
                  postFeedModel: postFeedModel,
                  editFields: true,
                  isEditMode: isEditPost,
                )));
    if (object != null) {
      if (object['goToNext']) {
        showNewPost = false;
        setState(() {});
        addCardBottomSheetUI(
            context, postId, title, description, mediaFileList);
      }
    }
  }

  void addCardBottomSheetUI(context, postId, String title, String description,
      List<String> imageList) async {
    var object = await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          child: SafeArea(
            child: SingleChildScrollView(
              controller: _controller,
              child: StatefulBuilder(
                builder: (BuildContext context,
                    void Function(void Function()) setState) {
                  return Padding(
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
                                  child: Text(
                                    Constants.postJourney,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: AppColors.titleTextColor,
                                        fontFamily: Constants.boldFont,
                                        fontSize: ScreenUtil().setSp(28)),
                                  ),
                                ),
                                SizedBox(height: ScreenUtil().setSp(12)),
                                Card(
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25))),
                                  child: Stack(
                                    children: [
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                100 *
                                                25,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(25.0),
                                          ),
                                        ),
                                        child: PageView.builder(
                                            itemCount: imageList.length,
                                            controller: pageController,
                                            onPageChanged: (pos) {
                                              this.imagePageIndex = pos;
                                            },
                                            itemBuilder: (context, indexView) {
                                              imagePageIndex = indexView;

                                              return Hero(
                                                tag: 'homePageImage' +
                                                    indexView.toString(),
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      imageList[indexView],
                                                  imageBuilder: (context,
                                                          imageProvider) =>
                                                      Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      //borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                                      image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  placeholder: (context, url) =>
                                                      setPostDefaultImage(
                                                          context),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          setPostDefaultImage(
                                                              context),
                                                ),
                                              );
                                            }),
                                      ),
                                      Positioned(
                                        right: 10,
                                        top: 0,
                                        bottom: 0,
                                        child: Visibility(
                                          visible: imageList.length > 1,
                                          maintainAnimation: true,
                                          maintainSize: false,
                                          maintainState: true,
                                          child: InkWell(
                                            onTap: () {
                                              pageController.nextPage(
                                                  duration: Duration(
                                                      milliseconds: 100),
                                                  curve: Curves.ease);
                                            },
                                            child: Center(
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                  ),
                                                  width: 25,
                                                  height: 25,
                                                  child: SvgPicture.asset(
                                                    Constants.rightArrow,
                                                    fit: BoxFit.contain,
                                                    color: Colors.black,
                                                  )),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  title,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: AppColors.titleTextColor,
                                      fontFamily: Constants.boldFont,
                                      fontSize: ScreenUtil().setSp(27)),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  description,
                                  maxLines: 2,
                                  style: TextStyle(
                                      color: AppColors.titleTextColor,
                                      fontFamily: Constants.regularFont,
                                      fontSize: ScreenUtil().setSp(23)),
                                ),
                                SizedBox(height: 6),
                                // Text(
                                //   goal,
                                //   maxLines: 2,
                                //   style: TextStyle(
                                //       color: AppColors.titleTextColor,
                                //       fontFamily: Constants.regularFont,
                                //       fontSize: ScreenUtil().setSp(23)),
                                // ),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        Constants.addACard,
                                        style: TextStyle(
                                            color: AppColors.blackColor[500],
                                            fontFamily: Constants.semiBoldFont,
                                            fontSize: ScreenUtil().setSp(24)),
                                      ),
                                      Expanded(
                                        child: Container(),
                                      ),
                                      InkWell(
                                          onTap: () async {
                                            if (cardList.length <= 6) {
                                              var object = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          CardDetail(
                                                            postId: postId,
                                                            indexKey:
                                                                cardList.length,
                                                            postVideoFilesMap:
                                                                postVideoFilesMap,
                                                          )));

                                              if (object != null) {
                                                PostCardModel cardModel =
                                                    object["cardObject"];
                                                cardList.add(cardModel);
                                                isCardBtnEnable = true;
                                                setState(() {});
                                              }
                                            } else {
                                              Constants().errorToast(context,
                                                  'You can select maximum 6 cards');
                                            }
                                          },
                                          child: Container(
                                              height: ScreenUtil().setSp(80),
                                              child: DottedBorder(
                                                  borderType: BorderType.RRect,
                                                  color: AppColors.primaryColor,
                                                  radius: Radius.circular(40),
                                                  dashPattern: [3, 3, 3, 3],
                                                  strokeWidth: 1.2,
                                                  child: Center(
                                                      child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                        SizedBox(
                                                          width: 10.0,
                                                        ),
                                                        Container(
                                                          alignment:
                                                              Alignment.center,
                                                          width: 18,
                                                          height: 18,
                                                          padding:
                                                              EdgeInsets.all(
                                                                  1.5),
                                                          child:
                                                              SvgPicture.asset(
                                                            'assets/images/ic_plus.svg',
                                                            alignment: Alignment
                                                                .center,
                                                            color: AppColors
                                                                .primaryColor,
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text(
                                                          Constants.addCard,
                                                          style: TextStyle(
                                                            fontSize:
                                                                ScreenUtil()
                                                                    .setSp(24),
                                                            color: AppColors
                                                                .primaryColor,
                                                            fontFamily: Constants
                                                                .semiBoldFont,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10.0,
                                                        ),
                                                      ]))))),
                                    ]),
                                // ReorderableListView(
                                //   onReorder: _onReorder,
                                //   children: <Widget>[
                                //     for (int i = 0;
                                //         i < cardList.length - 1;
                                //         i++)
                                //       CardReorderItem(
                                //         isFirst: i == 0,
                                //         isLast: i == cardList.length - 1,
                                //         postCardModel: cardList[i],
                                //         index: i,
                                //       ),
                                //   ],
                                //   // itemCount: cardList.length,
                                //   // itemBuilder: (context, index) {
                                //   //   return CardReorderItem(
                                //   //     isFirst: index == 0,
                                //   //     isLast: index == cardList.length - 1,
                                //   //     postCardModel: cardList[index],
                                //   //     index: index,
                                //   //   );
                                //   // },
                                // ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Container(
                                    child: cardList.length > 0
                                        ? ListView.builder(
                                            itemCount: cardList.length,
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemBuilder: (BuildContext context,
                                                int positon) {
                                              return CardReorderItem(
                                                isFirst: positon == 0,
                                                isLast: positon ==
                                                    cardList.length - 1,
                                                postCardModel:
                                                    cardList[positon],
                                                index: positon,
                                              );
                                            })
                                        : Container()),
                                SizedBox(height: ScreenUtil().setSp(32)),
                                Visibility(
                                  visible: false,
                                  maintainAnimation: true,
                                  maintainSize: false,
                                  maintainState: true,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Save to Stitch',
                                        style: TextStyle(
                                            color: AppColors.titleTextColor,
                                            fontFamily: Constants.regularFont,
                                            fontSize: ScreenUtil().setSp(23)),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          createStitch(setState);
                                        },
                                        child: Text(
                                          'Create Stitch',
                                          style: TextStyle(
                                              color: AppColors.primaryColor,
                                              fontFamily: Constants.regularFont,
                                              fontSize: ScreenUtil().setSp(23)),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: false,
                                  maintainAnimation: true,
                                  maintainSize: false,
                                  maintainState: true,
                                  child: TextFormField(
                                    cursorColor: AppColors.primaryColor,
                                    readOnly: true,
                                    textInputAction: TextInputAction.none,
                                    maxLines: 1,
                                    onTap: () async {
                                      var object = await showModalBottomSheet(
                                          isScrollControlled: true,
                                          context: context,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(30.0),
                                                topRight:
                                                    Radius.circular(30.0)),
                                          ),
                                          builder: (BuildContext context) {
                                            return SaveToStitch();
                                          });

                                      if (object != null) {
                                        stichId = object["stitch_id"];
                                        stitchTitle = object["stitch_title"];
                                        setState(() {
                                        });
                                      }
                                    },
                                    controller: TextEditingController(
                                        text: stitchTitle.isNotEmpty
                                            ? stitchTitle
                                            : ''),
                                    decoration: InputDecoration(
                                      counterText: "",
                                      hintText: 'SOLS Recommendations(Default)',
                                      hintStyle: TextStyle(
                                          fontSize: ScreenUtil().setSp(22),
                                          color: Colors.black87),
                                      suffixIcon: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 19, horizontal: 17),
                                        width: 17,
                                        height: 17,
                                        child: SvgPicture.asset(
                                          'assets/images/ic_down_arrow.svg',
                                          fit: BoxFit.contain,
                                          color: AppColors.accentColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                    visible: false,
                                    maintainAnimation: true,
                                    maintainSize: false,
                                    maintainState: true,
                                    child: SizedBox(
                                        height: ScreenUtil().setSp(32))),
                                Container(
                                  color: Colors.transparent,
                                  margin: EdgeInsets.only(top: 20),
                                  width: MediaQuery.of(context).size.width,
                                  height: ScreenUtil().setSp(100),
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(40.0),
                                        side: BorderSide(
                                            color: isCardBtnEnable == true
                                                ? AppColors.primaryColor
                                                : AppColors.accentColor)),
                                    onPressed: () {
                                      setState(() {
                                        if (!showCreate) {
                                          showCreate = true;
                                          setState(() {});
                                          continueCretePost();
                                        } else {
                                          createPostFinal();
                                        }
                                      });
                                    },
                                    color: isCardBtnEnable == true
                                        ? AppColors.primaryColor
                                        : AppColors.accentColor,
                                    textColor: Colors.white,
                                    padding: EdgeInsets.all(10.0),
                                    child: Text(
                                        showCreate
                                            ? isEditPost
                                                ? 'Update Post'
                                                : 'Create Post'
                                            : Constants.continueTxt,
                                        style: TextStyle(
                                          fontSize: ScreenUtil().setSp(28),
                                          fontFamily: Constants.semiBoldFont,
                                        )),
                                  ),
                                ),
                                SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ],
                      ));
                },
              ),
            ),
          ),
        );
      },
    );

    if (object != null) {
      Navigator.pop(context, {"Return": true});
    }
  }

  static setPostDefaultImage(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: ScreenUtil().setSp(370),
        decoration: BoxDecoration(
          color: AppColors.viewLineColor,
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ));
  }
}
