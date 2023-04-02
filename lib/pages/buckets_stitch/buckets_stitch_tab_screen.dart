import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solstice/model/bucket_stitch_model.dart';
import 'package:solstice/model/stitch_routine_model.dart';
import 'package:solstice/model/tabs_models.dart';
import 'package:solstice/pages/buckets_stitch/routine_detail_screen.dart';
import 'package:solstice/pages/buckets_stitch/select_bucket_for_stitch.dart';
import 'package:solstice/pages/chat/chat_users_history_screen.dart';
import 'package:solstice/pages/home/search_filter.dart';
import 'package:solstice/pages/routine/routine_name.dart';
import 'package:solstice/pages/views/bucket_stitch_list_item.dart';
import 'package:solstice/pages/views/routine_tab_list_item.dart';
import 'package:solstice/pages/views/tab_list_item.dart';
import 'package:solstice/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/utils/dialog_callback.dart';
import 'package:solstice/utils/shared_preferences.dart';
import 'package:solstice/utils/utilities.dart';

class BucketStitchTabScreen extends StatefulWidget {
  @override
  BucketStitchTabScreenState createState() {
    return BucketStitchTabScreenState();
  }
}

class BucketStitchTabScreenState extends State<BucketStitchTabScreen>
    implements DialogCallBack {
  String pinCode = "", _selectedImageUrl = "", stitchName = "", userId = "";
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  List<BucketStitchModel> bucketList = new List<BucketStitchModel>();
  List<BucketStitchModel> stitchList = new List<BucketStitchModel>();
  List<StitchRoutineModel> stitchRoutinesList = new List();
  final _formKey = GlobalKey<FormState>();
  bool isStitchSelected = true;
  bool isEditMode = false;
  var selectedStitcheTab = "All";
  var selectedRoutineTab = "All";
  //Stream<dynamic> stitcheSnapshots;
  List<TabsModel> stitchTabsList = new List<TabsModel>();
  List<TabsModel> routineTabsList = new List<TabsModel>();
  var imageFile = null;
  String intervalSlot = "Public";
  TextEditingController stitchDescriptionController =
      new TextEditingController();
  TextEditingController stitchTitleController = new TextEditingController();
  bool isPublic = true;
  bool enableButton = false;
  String privacyType = "Public";

  String stitchId = "";
  var state;

  String routineId = "";
  var state1;

  String name = "", description = "", imageUrl = "";

  @override
  void initState() {
    //fetchStitches();
    // set tabs
    setDefaultList();

    // fetch stitches listing from firestore
    fetchStitcheSnapshots();

    // get username
    Future<String> userPrefName =
        SharedPref.getStringFromPrefs(Constants.USER_ID);
    userPrefName.then((value) => {userId = value}, onError: (err) {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
      key: _scaffoldkey,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.white),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).padding.top,
              ),
              Expanded(
                flex: 0,
                child: Container(
                  padding: EdgeInsets.only(
                      left: ScreenUtil().setSp(36),
                      right: ScreenUtil().setSp(36),
                      top: ScreenUtil().setSp(26),
                      bottom: ScreenUtil().setSp(26)),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            InkWell(
                              child: Text(
                                "Stitch",
                                style: TextStyle(
                                    color: isStitchSelected
                                        ? Colors.black
                                        : AppColors.lightGreyColor,
                                    fontSize: ScreenUtil().setSp(42),
                                    fontFamily: Constants.boldFont),
                              ),
                              onTap: () {
                                setState(() {
                                  if (!isStitchSelected) {
                                    isStitchSelected = true;
                                  }
                                });
                              },
                            ),
                            SizedBox(width: 16),
                            InkWell(
                              child: Text(
                                "Routine",
                                style: TextStyle(
                                    color: !isStitchSelected
                                        ? Colors.black
                                        : AppColors.lightGreyColor,
                                    fontSize: ScreenUtil().setSp(42),
                                    fontFamily: Constants.boldFont),
                              ),
                              onTap: () {
                                setState(() {
                                  if (isStitchSelected) {
                                    isStitchSelected = false;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                          child: Container(
                            child: Stack(
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  padding: EdgeInsets.all(2.0),
                                  margin: EdgeInsets.only(right: 5),
                                  child: Image.asset(
                                    'assets/images/ic_chat_unactive.png',
                                    width: ScreenUtil().setSp(32),
                                    height: ScreenUtil().setSp(32),
                                  ),
                                ),
                                Positioned(
                                  right: 1,
                                  child: globalUserUnSeenChats != null &&
                                          globalUserUnSeenChats > 0
                                      ? Container(
                                          padding: EdgeInsets.only(
                                              top: 2,
                                              bottom: 2,
                                              right: 7,
                                              left: 7),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            color: AppColors.primaryColor,
                                          ),
                                          child: Text(
                                            globalUserUnSeenChats > 99
                                                ? "99+"
                                                : globalUserUnSeenChats
                                                    .toString(),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'rubikregular',
                                                fontSize: 10),
                                          ),
                                        )
                                      : Container(),
                                )
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return ChatUsersHistoryScreen();
                            }));
                          }),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) {
                            return SearchFilter(
                                screenType:
                                    isStitchSelected ? 'Stitch' : 'Routine');
                          }));
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          padding: EdgeInsets.all(2.5),
                          margin: EdgeInsets.only(right: 5, left: 5),
                          child: SvgPicture.asset(
                Constants.searchIcon,
                fit: BoxFit.cover,
              
              ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            isEditMode = false;
                            if (isStitchSelected) {
                              createBucketAndStitchBottomSheet();
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CreateRoutineName()));
                            }
                          });
                        },
                        child: Container(
                            width: 26,
                            height: 26,
                            margin: EdgeInsets.only(left: 5),
                            padding: EdgeInsets.all(4.5),
                            child: SvgPicture.asset(
                              'assets/images/ic_plus.svg',
                              alignment: Alignment.center,
                              color: Colors.black,
                              fit: BoxFit.contain,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 0,
              ),
              isStitchSelected
                  ? Container(
                      margin: EdgeInsets.only(
                          left: ScreenUtil().setSp(36),
                          bottom: ScreenUtil().setSp(16)),
                      height: ScreenUtil().setSp(54),
                      child: ListView.builder(
                        itemCount:
                            stitchTabsList == null ? 0 : stitchTabsList.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return new InkWell(
                            //highlightColor: Colors.red,
                            splashColor: AppColors.primaryColor,
                            onTap: () {
                              setState(() {
                                stitchTabsList.forEach(
                                    (element) => element.isSelected = false);
                                stitchTabsList[index].isSelected = true;
                                selectedStitcheTab =
                                    stitchTabsList[index].tabTitle;
                                //selectedLevel = levelDataList[index].type;
                              });
                            },
                            child: new TabListItem(stitchTabsList[index]),
                          );
                        },
                      ),
                    )
                  : Container(
                      margin: EdgeInsets.only(
                          left: ScreenUtil().setSp(36),
                          bottom: ScreenUtil().setSp(16)),
                      height: ScreenUtil().setSp(54),
                      child: ListView.builder(
                        itemCount: routineTabsList == null
                            ? 0
                            : routineTabsList.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return new InkWell(
                            //highlightColor: Colors.red,
                            splashColor: AppColors.primaryColor,
                            onTap: () {
                              setState(() {
                                routineTabsList.forEach(
                                    (element) => element.isSelected = false);
                                routineTabsList[index].isSelected = true;
                                selectedRoutineTab =
                                    routineTabsList[index].tabTitle;
                                //selectedLevel = levelDataList[index].type;
                              });
                            },
                            child: new TabListItem(routineTabsList[index]),
                          );
                        },
                      ),
                    ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      isStitchSelected
                          ? MediaQuery.removePadding(
                              context: context,
                              removeTop: true,
                              removeBottom: true,
                              child: StreamBuilder(

                                  // stream: FirebaseFirestore.instance
                                  //     .collection(Constants.stitchCollection).get
                                  //     .snapshots(),
                                  stream: fetchStitcheSnapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    AppColors.primaryColor)),
                                      );
                                    }
                                    if (snapshot.data.docs.length == 0) {
                                      return Center(
                                          child: Container(
                                        margin: EdgeInsets.only(top: 20),
                                        child: Text(
                                          'No Stitches',
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black),
                                          textAlign: TextAlign.center,
                                        ),
                                      ));
                                    }
                                    return stitchListing(context, snapshot);
                                  }))
                          : MediaQuery.removePadding(
                              context: context,
                              removeTop: true,
                              removeBottom: true,
                              child: StreamBuilder(
                                  // stream: FirebaseFirestore.instance
                                  //     .collection(Constants.routineCollection)
                                  //     .snapshots(),
                                  stream: fetchRoutineSnapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    AppColors.primaryColor)),
                                      );
                                    }
                                    if (snapshot.data.docs.length == 0) {
                                      return Center(
                                          child: Container(
                                        margin: EdgeInsets.only(top: 20),
                                        child: Text(
                                          'No Routines',
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black),
                                          textAlign: TextAlign.center,
                                        ),
                                      ));
                                    }
                                    return routineListing(context, snapshot);
                                  })),
                      SizedBox(height: ScreenUtil().setSp(10)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
      updated(state);
    } else {
    }
  }

  Future<Null> updated(StateSetter updateState) async {
    updateState(() {});
  }

  Future _navigateToSelectBucket() async {
    Map results = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return SelectBucketForStitch();
        },
      ),
    );
  }

  // on routine tap open detail page
  Future _routineTapped(String routineId) async {
    Map results = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return RoutineDetailScreen(
        routineIDIntent: routineId,
      );
    }));

    if (results != null && results.containsKey('update')) {
      var _isUpdate = "";
      setState(() {
        _isUpdate = results['update'];
        if (_isUpdate == "yes") {
          //getDataFromApi(true);
        }
      });
    }
  }

  void showSnackBar(String msg) {
    final snackBarContent = SnackBar(
      content: Text(msg),
      action: SnackBarAction(
          label: 'OK',
          onPressed: _scaffoldkey.currentState.hideCurrentSnackBar,
          textColor: AppColors.primaryColor),
    );
    _scaffoldkey.currentState.showSnackBar(snackBarContent);
  }

  // for fetching stitches from firestore
  Stream<dynamic> fetchStitcheSnapshots() {
    if (selectedStitcheTab == "All") {
      return FirebaseFirestore.instance
          .collection(Constants.stitchCollection)
          .where('created_by', isEqualTo: globalUserId)
          .snapshots();
    } else if (selectedStitcheTab == "Public Stitches") {
      return FirebaseFirestore.instance
          .collection(Constants.stitchCollection)
          .where('created_by', isEqualTo: globalUserId)
          .where("is_public", isEqualTo: true)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection(Constants.stitchCollection)
          .where('created_by', isEqualTo: globalUserId)
          .where("is_public", isEqualTo: false)
          .snapshots();
    }
  }

  // for fetching Rotines from firestore
  Stream<dynamic> fetchRoutineSnapshots() {
    if (selectedRoutineTab == "All") {
      return FirebaseFirestore.instance
          .collection(Constants.routineCollection)
          .where('created_by', isEqualTo: globalUserId)
          .snapshots();
    } else if (selectedRoutineTab == "Public Routine") {
      return FirebaseFirestore.instance
          .collection(Constants.routineCollection)
          .where('created_by', isEqualTo: globalUserId)
          .where("is_public", isEqualTo: true)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection(Constants.routineCollection)
          .where('created_by', isEqualTo: globalUserId)
          .where("is_public", isEqualTo: false)
          .snapshots();
    }
  }

  // for fetching stitches from firestore
  void fetchStitches() async {
    var collectionReference =
        FirebaseFirestore.instance.collection(Constants.stitchCollection).get();
    // var collectionReference = FirebaseFirestore.instance
    //     .collection(Constants.stitchCollection)
    //     .where('created_by', isEqualTo: globalUserId)
    //     .where("is_public", isEqualTo: false)
    //     .snapshots();
    collectionReference.then((value) {
      final List<DocumentSnapshot> docs = value.docs;
      docs.forEach((data) {
        StitchRoutineModel bucketStitchModel =
            StitchRoutineModel.fromJson(data.data());
        // StitchRoutineModel. = data.id;
        stitchRoutinesList.add(bucketStitchModel);
      });
      // TopVoicesModel topVoicesModel = TopVoicesModel.fromJson(data.data());
      // topVoicesModel.id = data.id;
    });
  }

  void setDefaultList() {
    stitchTabsList.add(new TabsModel("All", true));
    stitchTabsList.add(new TabsModel("Private Stitches", false));
    stitchTabsList.add(new TabsModel("Public Stitches", false));
    //stitchTabsList.add(new TabsModel("Public Stitche ewew", false));

    // stitch list
    routineTabsList.add(new TabsModel("All", true));
    routineTabsList.add(new TabsModel("Private Routine", false));
    routineTabsList.add(new TabsModel("Public Routine", false));
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
        _selectedImageUrl = downloadUrl;

        updateDataToFb(collectionName, downloadUrl);
      });
    }).catchError((onError) {
    });
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

  void updateDataToFb(String collectionName, String downloadUrl) {
    var stitchMap = {
      "created_at": Timestamp.now(),
      "created_by": userId,
      "description": stitchDescriptionController.text.trim(),
      "image": downloadUrl,
      "is_public": isPublic,
      "title": stitchTitleController.text.trim(),
      "updated_at": Timestamp.now()
    };

    if (isEditMode) {
      FirebaseFirestore.instance
          .collection(collectionName)
          .doc(isStitchSelected ? stitchId : routineId)
          .update(stitchMap)
          .then((value) {
        // _formKey.currentState?.reset();
        imageFile = null;
        stitchDescriptionController.clear();
        stitchTitleController.clear();
        String sMsg = "";
        if (isStitchSelected) {
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
    } else {
      FirebaseFirestore.instance
          .collection(collectionName)
          .add(stitchMap)
          .then((value) {
        // _formKey.currentState?.reset();
        imageFile = null;
        stitchDescriptionController.clear();
        stitchTitleController.clear();
        String sMsg = "";
        if (isStitchSelected) {
          sMsg = "Stitch";
        } else {
          sMsg = "Routine";
        }
        //Constants().successToast(context, "$sMsg created successfully!");

        Utilities.hide();
        Constants.showSnackBarWithMessage("$sMsg created successfully!",
            _scaffoldkey, context, AppColors.greenColor);
        // setState(() {});

        // Navigator.of(context).pop();
      });
    }
  }

  // sttich listing
  Widget stitchListing(BuildContext context, snapshots) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: snapshots.data.docs.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        List stitchList = snapshots.data.docs.reversed.toList();
        StitchRoutineModel sitchmodel =
            StitchRoutineModel.fromSnapshot(stitchList[index]);

        return Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          actions: [
            if (sitchmodel.createdBy == globalUserId)
              Container(
                margin: EdgeInsets.only(bottom: 30, top: 10.0),
                child: IconSlideAction(
                    caption: 'Edit',
                    color: Colors.blue,
                    icon: Icons.delete,
                    onTap: () => {
                          isStitchSelected = true,
                          isEditMode = true,
                          stitchTitleController.text = sitchmodel.title,
                          stitchDescriptionController.text =
                              sitchmodel.description,
                          imageUrl = sitchmodel.image,
                          isPublic = sitchmodel.isPublic,
                          stitchId = sitchmodel.id,
                          createBucketAndStitchBottomSheet(),
                        }),
              ),
          ],
          secondaryActions: <Widget>[
            if (sitchmodel.createdBy == globalUserId)
              Container(
                margin: EdgeInsets.only(bottom: 30, top: 10.0),
                child: IconSlideAction(
                    caption: 'Delete',
                    color: Colors.red,
                    icon: Icons.delete,
                    onTap: () => {
                          stitchId = sitchmodel.id,
                          state = setState,
                          Utilities.confirmDeleteDialog(
                              context,
                              Constants.deleteStitch,
                              Constants.deleteStitchConfirmDes,
                              this,
                              1),
                        }),
              ),
          ],
          child: new BucketStitchListItem(
            sitchmodel,
            index,
            fromPostPage: false,
            routinePost: false,
          ),
        );
      },
    );
  }

  void deleteStitch(setState, id) {
    FirebaseFirestore.instance
        .collection(Constants.stitchCollection)
        .doc(id)
        .delete();
    setState(() {});
  }

  // Routine Listing.
  Widget routineListing(BuildContext context, snapshots) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: snapshots.data.docs.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        List stitchList = snapshots.data.docs.reversed.toList();
        StitchRoutineModel routineModel =
            StitchRoutineModel.fromSnapshot(stitchList[index]);
        return new InkWell(
          //highlightColor: Colors.red,
          splashColor: AppColors.primaryColor,
          onTap: () {
            setState(() {
              _routineTapped(routineModel.id);
            });
          },
          child: Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              actions: [
                if (routineModel.createdBy == globalUserId)
                  Container(
                    margin: EdgeInsets.only(bottom: 30, top: 10.0),
                    child: IconSlideAction(
                      caption: 'Edit',
                      color: Colors.blue,
                      icon: Icons.delete,
                      onTap: () => {
                        routineId = routineModel.id,
                        isStitchSelected = false,
                        isEditMode = true,
                        stitchTitleController.text = routineModel.title,
                        stitchDescriptionController.text =
                            routineModel.description,
                        imageUrl = routineModel.image,
                        isPublic = routineModel.isPublic,
                        createBucketAndStitchBottomSheet()
                      },
                    ),
                  ),
              ],
              secondaryActions: <Widget>[
                if (routineModel.createdBy == globalUserId)
                  Container(
                    margin: EdgeInsets.only(bottom: 30, top: 10.0),
                    child: IconSlideAction(
                      caption: 'Delete',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () => {
                        routineId = routineModel.id,
                        state1 = setState,
                        Utilities.confirmDeleteDialog(
                            context,
                            Constants.deleteRoutine,
                            Constants.deleteRoutineConfirmDes,
                            this,
                            2),
                      },
                    ),
                  ),
              ],
              child: new RoutineTabListItem(routineModel, index)),
        );
      },
    );
  }

  void deleteRoutine(setState, id) {
    FirebaseFirestore.instance
        .collection(Constants.routineCollection)
        .doc(id)
        .delete();
    setState(() {});
  }

  // Create Stitch and Routine Bottom sheet
  void createBucketAndStitchBottomSheet() {
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
                                            imageBuilder:
                                                (context, imageProvider) =>
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
                                            color: Color(0xFF1A58E7)
                                                .withOpacity(0.7),
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
                                    if (isStitchSelected) {
                                      // createStitch();
                                      checkValids(
                                          context, Constants.stitchCollection);
                                    } else {
                                      checkValids(
                                          context, Constants.routineCollection);
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
            );
          },
        );
      },
    );
  }

  @override
  void onOkClick(int code) {
    if (code == 1) {
      deleteStitch(state, stitchId);
    } else {
      deleteRoutine(state1, routineId);
    }
    stitchId = "";
    routineId = "";
  }
}
