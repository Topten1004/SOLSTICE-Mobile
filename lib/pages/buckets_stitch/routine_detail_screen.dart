import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/model/routine_post_model.dart';
import 'package:solstice/model/stitch_routine_model.dart';
import 'package:solstice/pages/buckets_stitch/select_stitch_for_routine_screen.dart';
import 'package:solstice/pages/groups/group_details_screen.dart';
import 'package:solstice/pages/home/create_post.dart';
import 'package:solstice/pages/views/routine_posts.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/shared_preferences.dart';
import 'package:solstice/utils/utilities.dart';

class RoutineDetailScreen extends StatefulWidget {
  final String routineIDIntent;

  const RoutineDetailScreen({Key key, @required this.routineIDIntent})
      : super(key: key);

  @override
  _RoutineDetailScreenState createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  String userIDPref = "";
  final ScrollController listScrollController = ScrollController();
  List<QueryDocumentSnapshot> listRoutines = new List.from([]);
  int _limit = 10;
  int _limitIncrement = 10;

  String routineIdIntent = "";
  String routineTitle = "";
  StitchRoutineModel routineModel = new StitchRoutineModel();

  bool isCreatedByMe = false;
  final _formKey = GlobalKey<FormState>();
  var imageFile = null;
  String intervalSlot = "Public";
  TextEditingController stitchDescriptionController =
      new TextEditingController();
  TextEditingController stitchTitleController = new TextEditingController();
  bool isPublic = true;
  String privacyType = "Public";

  String _selectedImageUrl = "", routineName = "";

  @override
  void initState() {
    super.initState();
    listScrollController.addListener(_scrollListener);
    routineIdIntent = widget.routineIDIntent;

    getRoutineDetail(routineIdIntent);
    getPrefData();
  }

  Future<String> getRoutineDetail(String postId) async {
    FirebaseFirestore.instance
        .collection(Constants.routineCollection)
        .doc(postId)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      if (mounted) {
        setState(() {
          if (documentSnapshot.exists) {
            try {
              routineModel = StitchRoutineModel.fromSnapshot(documentSnapshot);

              if (routineModel != null) {
                routineTitle = routineModel.title;
                // loadUser(postFeedModel.createdBy);

                if (routineModel.createdBy == globalUserId) {
                  isCreatedByMe = true;
                  stitchTitleController.text = routineModel.title;
                  stitchDescriptionController.text = routineModel.description;
                  if (!routineModel.isPublic) {
                    isPublic = false;
                    privacyType = "Private";
                  }
                  _selectedImageUrl =
                      routineModel.image != null && routineModel.image != ""
                          ? routineModel.image
                          : "";
                }
              }
            } catch (e) {}
          } else {
            Navigator.of(context).pop({'update': "yes"});
          }
        });
      }
    }).onError((e) => print(e));
  }

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  getPrefData() {
    Future<String> userId = SharedPref.getStringFromPrefs(Constants.USER_ID);
    userId.then(
        (value) => {
              userIDPref = value,
            }, onError: (err) {
    });

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
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
                      InkWell(
                        onTap: () {
                          setState(() {
                            Navigator.pop(context);
                          });
                        },
                        child: Container(
                            width: 22,
                            height: 22,
                            padding: EdgeInsets.all(2.5),
                            margin: EdgeInsets.only(left: 5),
                            child: SvgPicture.asset(
                              'assets/images/ic_back.svg',
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                            )),
                      ),
                      if (isCreatedByMe)
                        Container(
                          width: 26,
                          height: 26,
                          padding: EdgeInsets.all(2.5),
                          margin: EdgeInsets.only(right: 5),
                        ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            routineTitle,
                            maxLines: 2,
                            style: TextStyle(
                              color: AppColors.titleTextColor,
                              fontFamily: Constants.boldFont,
                              fontSize: ScreenUtil().setSp(32),
                            ),
                          ),
                        ),
                      ),
                      if (isCreatedByMe)
                        InkWell(
                          onTap: () {
                            setState(() {
                              updateRoutineBottomSheet();
                            });
                          },
                          child: Container(
                            width: 26,
                            height: 26,
                            padding: EdgeInsets.all(2.5),
                            margin: EdgeInsets.only(right: 5),
                            child: SvgPicture.asset(
                              'assets/images/ic_edit.svg',
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      if (!isCreatedByMe)
                        Container(
                          width: 22,
                          height: 22,
                          padding: EdgeInsets.all(2.5),
                        ),
                      if (isCreatedByMe)
                        InkWell(
                          onTap: () {
                            //_createGroupBottomSheet(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CreatePost(
                                          routineId: widget.routineIDIntent,
                                          screenType: "Routine",
                                        )));
                          },
                          child: Container(
                              width: 22,
                              height: 22,
                              padding: EdgeInsets.all(2.5),
                              child: SvgPicture.asset(
                                'assets/images/ic_plus.svg',
                                alignment: Alignment.center,
                                color: Colors.black,
                                fit: BoxFit.contain,
                              )),
                        )
                    ],
                  ),
                ),
              ),
              Flexible(
                  child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(Constants.routineCollection)
                    .doc(routineIdIntent)
                    .collection(Constants.posts)
                    //.orderBy('created_at', descending: true)
                    .limit(_limit)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor)),
                    );
                  } else {
                    listRoutines.clear();
                    listRoutines.addAll(snapshot.data.docs);
                     //updateChatCount();
                    return snapshot.data.docs.isNotEmpty
                        ? ListView(
                            padding: EdgeInsets.zero,
                            controller: listScrollController,
                            children: <Widget>[
                              MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: ListView.builder(
                                  reverse: false,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index) {
                                    List rev = snapshot.data.docs.toList();

                                    RoutinePostModel message =
                                        new RoutinePostModel();
                                    message.routineId = widget.routineIDIntent;

                                    DocumentSnapshot documentSnapshot =
                                        rev[index];
                                    Map<String, dynamic> mapObject =
                                        documentSnapshot.data();
                                    message.id = documentSnapshot.id;
                                    message.complete = mapObject['complete'];

                                    return FutureBuilder(
                                        future: loadPosts(mapObject["post_id"]),
                                        builder: (
                                          context,
                                          AsyncSnapshot<PostFeedModel>
                                              postFeedModel,
                                        ) {
                                          if (postFeedModel.data != null) {
                                            message.postFeedModel =
                                                postFeedModel.data;
                                            return RoutinePostItem(
                                                key: ValueKey(message.id),
                                                groupItem: message,
                                                index: index);
                                          } else {
                                            return Container();
                                          }
                                        });
                                  },
                                  itemCount: snapshot.data.docs.length,
                                  //controller: listScrollController,
                                ),
                              ),
                            ],
                          )
                        : noPostAvailableLayout();
                  }
                },
              )),
            ],
          ),
        ],
      ),
    );
  }

  Future<PostFeedModel> loadPosts(postId) async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection(Constants.posts)
        .doc(postId)
        .get();
    if (ds != null)
      return Future.delayed(
          Duration(milliseconds: 100), () => PostFeedModel.fromSnapshot(ds));
  }

  Future _OnGoToGroupDetail(String groupId) async {
    Map results = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return GroupDetailsScreen(groupIdIntent: groupId);
    }));

    if (results != null && results.containsKey('update')) {
      var _isUpdate = "";
      setState(() {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ));
      });
    }
  }

  Widget noPostAvailableLayout() {
    return Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                width: 120,
                child: SvgPicture.asset(
                  'assets/images/ic_no_post.svg',
                  alignment: Alignment.center,
                  fit: BoxFit.contain,
                )),
            SizedBox(
              height: 10,
            ),
            Text(
              "No Post Added Yet!",
              style: TextStyle(
                  color: Color(0xFFA9AFBD),
                  fontSize: ScreenUtil().setSp(42),
                  fontFamily: Constants.boldFont),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Text(
                "When any post add in this routine  will appear here. Click on add button to add post.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontFamily: Constants.regularFont,
                    height: 1.3,
                    letterSpacing: 0.8),
              ),
            ),
            Container(
              height: ScreenUtil().setSp(95),
              margin: EdgeInsets.only(top: 10),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                  side: BorderSide(color: AppColors.primaryColor),
                ),
                color: AppColors.primaryColor,
                onPressed: () {
                  addPost();

                  // _OnGoToStitch();
                },
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 8.0, bottom: 8),
                  child: Text(
                    'Add Post',
                    style: TextStyle(
                        fontFamily: 'epilogue_semibold', color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
          ],
        ));
  }

  void addPost() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreatePost(
                  routineId: routineIdIntent,
                  screenType: "Routine",
                )));

    // showModalBottomSheet<void>(
    //   isScrollControlled: true,
    //   context: context,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.only(
    //         topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
    //   ),
    //   builder: (BuildContext context) {
    //     return CreatePost();
    //   },
    // );
  }

  Future _OnGoToStitch() async {
    Map results = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return SelectStitchForRoutineScreen();
    }));

    if (results != null && results.containsKey('update')) {
      var _isUpdate = "";
      setState(() {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ));
      });
    }
  }

  // Update Routine Bottom sheet
  void updateRoutineBottomSheet() {
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
                                        'Update Routine',
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
                                    'Upload Routine Thumbnail',
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
                                },
                                child: imageFile != null
                                    ? Container(
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
                                      )
                                    : _selectedImageUrl != ""
                                        ? Container(
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
                                                child: CachedNetworkImage(
                                                  imageUrl: _selectedImageUrl,
                                                  imageBuilder: (context,
                                                          imageProvider) =>
                                                      Container(
                                                    width: 75,
                                                    height: 75,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  8.0)),
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
                                              ),
                                            ),
                                          )
                                        : Row(
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
                                          ),
                              ),

                              SizedBox(
                                height: 30,
                              ),
                              Text(
                                'Routine Name',
                                style: TextStyle(
                                    fontFamily: 'epilogue_semibold',
                                    fontSize: ScreenUtil().setSp(25),
                                    color: Color(0xFF727272)),
                              ),
                              TextFormField(
                                keyboardType: TextInputType.text,
                                controller: stitchTitleController,
                                onChanged: (value) {
                                  routineName = value;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter routine title!';
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
                                'Routine Description',
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
                                    return 'Enter routine description!';
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
                                    checkValids(
                                        context, Constants.routineCollection);
                                  },
                                  child: Text(
                                    'Update Routine',
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

  checkValids(BuildContext context, String collectionName) {
    if (_formKey.currentState.validate()) {
      Navigator.of(context).pop();
      FocusScope.of(context).unfocus();

      if (imageFile != null) {
        //updated(state);
        uploadImageToFirebase(Constants.routineImagesFolder);
      } else {
        updateDataToFb();
      }
    } else {
    }
  }

  // image selector
  Future imageSelector(
      BuildContext context, String pickerType, StateSetter state) async {
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
      updated(state);
      //uploadImageToFirebase(Constants.routineImagesFolder);

    } else {
    }
  }

  setPostDefaultImage(BuildContext context) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: AppColors.viewLineColor,
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
    );
  }

  void uploadImageToFirebase(String storageName) async {
    Constants.showSnackBarWithMessage("Routine image uploading...",
        _scaffoldkey, context, AppColors.primaryColor);

    Utilities.show(context);

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var firebaseStorageRef =
        FirebaseStorage.instance.ref().child(storageName).child(fileName);
    UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);

    uploadTask.whenComplete(() {
      firebaseStorageRef.getDownloadURL().then((downloadUrl) {
        _selectedImageUrl = downloadUrl;
        updateDataToFb();
      });
    }).catchError((onError) {
    });
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

  Future<Null> updated(StateSetter updateState) async {
    updateState(() {});
  }

  void updateDataToFb() {
    var stitchMap = {
      "description": stitchDescriptionController.text.trim(),
      "image": _selectedImageUrl,
      "is_public": isPublic,
      "title": stitchTitleController.text.trim(),
      "updated_at": Timestamp.now()
    };
    FirebaseFirestore.instance
        .collection(Constants.routineCollection)
        .doc(routineIdIntent)
        .update(stitchMap)
        .then((value) {
     
      Utilities.hide();
      Constants.showSnackBarWithMessage("Routine updated successfully!",
          _scaffoldkey, context, AppColors.greenColor);
      // setState(() {});

      Navigator.of(context).pop();
    });
  }
}
