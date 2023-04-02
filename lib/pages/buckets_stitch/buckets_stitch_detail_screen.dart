import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solstice/model/bucket_stitch_model.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/model/stitch_routine_model.dart';
import 'package:solstice/pages/buckets_stitch/bucket_details_expanded.dart';
import 'package:solstice/pages/home/create_post.dart';
import 'package:solstice/pages/home/post_detail_screen.dart';
import 'package:solstice/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/utils/dialog_callback.dart';
import 'package:solstice/utils/utilities.dart';
import 'package:transparent_image/transparent_image.dart';

class BucketStitchDetailScreen extends StatefulWidget {
  final StitchRoutineModel bucketStitchDetailIntent;
  final int index;

  const BucketStitchDetailScreen(
      {Key key, @required this.bucketStitchDetailIntent, @required this.index})
      : super(key: key);

  @override
  BucketStitchDetailScreenState createState() {
    return BucketStitchDetailScreenState();
  }
}

class BucketStitchDetailScreenState extends State<BucketStitchDetailScreen>
    implements DialogCallBack {
  String pinCode = "";
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  List<BucketStitchModel> stitchList = new List<BucketStitchModel>();
  bool hasPosts = false;

  bool isCreatedByMe = false;
  final _formKey = GlobalKey<FormState>();
  var imageFile = null;
  String intervalSlot = "Public";
  TextEditingController stitchDescriptionController =
      new TextEditingController();
  TextEditingController stitchTitleController = new TextEditingController();
  bool isPublic = true;
  String privacyType = "Public";
  String created_by = "";

  String postId = "";
  String _selectedImageUrl = "", stitchName = "", stitchIdIntent = "";

  @override
  void initState() {
    super.initState();

    getStitchPosts();
  }

  void checkUserStitch() {
    try {
      if (widget.bucketStitchDetailIntent != null) {
        if (created_by == globalUserId) {
          isCreatedByMe = true;
          stitchIdIntent = widget.bucketStitchDetailIntent.id;
          stitchTitleController.text = widget.bucketStitchDetailIntent.title;
          stitchDescriptionController.text =
              widget.bucketStitchDetailIntent.description;

          if (!widget.bucketStitchDetailIntent.isPublic) {
            isPublic = false;
            privacyType = "Private";
          }

          _selectedImageUrl = widget.bucketStitchDetailIntent.image != null &&
                  widget.bucketStitchDetailIntent.image != ""
              ? widget.bucketStitchDetailIntent.image
              : "";
          setState(() {});
        }
      }
    } catch (e) {}
  }

  void getStitchPosts() {
    Future<DocumentSnapshot> key = FirebaseFirestore.instance
        .collection(Constants.stitchCollection)
        .doc(widget.bucketStitchDetailIntent.id)
        .get();
    key.then((value) {
      if (value.data() != null) {
        Map<String, dynamic> mapObject = value.data();
        created_by = mapObject['created_by'];
        checkUserStitch();
        if (mapObject.containsKey("post_ids")) {
          hasPosts = true;
          setState(() {});
        }
      }
    });
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
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                              width: 22,
                              height: 22,
                              padding: EdgeInsets.all(2.5),
                              margin: EdgeInsets.only(left: 10, right: 18),
                              child: SvgPicture.asset(
                                'assets/images/ic_back.svg',
                                alignment: Alignment.center,
                                fit: BoxFit.contain,
                              )),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.all(ScreenUtil().setSp(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Hero(
                                  tag: 'titleOfItem' + widget.index.toString(),
                                  child: Text(
                                    widget.bucketStitchDetailIntent.title,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.titleTextColor,
                                      fontFamily: Constants.boldFont,
                                      fontSize: ScreenUtil().setSp(32),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isCreatedByMe)
                          InkWell(
                            onTap: () {
                              setState(() {
                                createBucketAnsStitchBottomSheet();
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
                        if (isCreatedByMe)
                          InkWell(
                            onTap: () async {
                              var object = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CreatePost(
                                            routineId: widget
                                                .bucketStitchDetailIntent.id,
                                            screenType: "Stitch",
                                          )));
                              if (object != null) {
                                setState(() {
                                  getStitchPosts();
                                });
                              }
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
                  )),
              Expanded(
                  flex: 1,
                  child: hasPosts
                      ? postsList()
                      : Container(
                          height: MediaQuery.of(context).size.height,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Text(
                                'No Posts added to stitch',
                                style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                    fontFamily: Constants.mediumFont),
                              ),
                            ),
                          ),
                        )),
            ],
          ),
        ],
      ),
    );
  }

  Widget postsList() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(Constants.stitchCollection)
            .doc(widget.bucketStitchDetailIntent.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var postsIdList = snapshot.data["post_ids"];

            return StaggeredGridView.countBuilder(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                itemCount: postsIdList.length,
                itemBuilder: (context, index) {
                  return FutureBuilder(
                      future: loadPosts(postsIdList[index]),
                      builder: (
                        context,
                        AsyncSnapshot<PostFeedModel> postFeedModel,
                      ) {
                        PostFeedModel _postFeedModel = postFeedModel.data;

                        return _postFeedModel != null
                            ? Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15))),
                                      child: InkWell(
                                        onTap: () {
                                          _postExpandedTapped(
                                              _postFeedModel.postId,
                                              widget.bucketStitchDetailIntent
                                                  .title,
                                              index);
                                        },
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                Hero(
                                                  tag: 'imageHero$index',
                                                  child:
                                                      FadeInImage.memoryNetwork(
                                                    placeholder:
                                                        kTransparentImage,
                                                    image: _postFeedModel
                                                                .mediaList
                                                                .first
                                                                .mediaType ==
                                                            "Image"
                                                        ? _postFeedModel
                                                            .mediaList.first.url
                                                        : _postFeedModel
                                                            .mediaList
                                                            .first
                                                            .thumbnail,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                if (_postFeedModel.mediaList
                                                        .first.mediaType ==
                                                    "video")
                                                  Container(
                                                    alignment: Alignment.center,
                                                    child: Icon(
                                                      Icons
                                                          .play_circle_fill_outlined,
                                                      color: Colors.white,
                                                      size: 30,
                                                    ),
                                                  ),
                                                InkWell(
                                                  onTap: () {
                                                    postId =
                                                        _postFeedModel.postId;
                                                    Utilities.confirmDeleteDialog(
                                                        context,
                                                        Constants.deletePost,
                                                        Constants
                                                            .deletePostConfirmDes,
                                                        this,
                                                        1);
                                                  },
                                                  child: Container(
                                                    alignment:
                                                        Alignment.topRight,
                                                    margin: EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.delete_rounded,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 3),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0, horizontal: 4.0),
                                      child: Text(
                                        _postFeedModel.title != null
                                            ? _postFeedModel.title
                                            : " ",
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.black,
                                            fontFamily: Constants.mediumFont),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            : Container();
                      });
                },
                staggeredTileBuilder: (index) {
                  return StaggeredTile.count(1, index.isEven ? 1.2 : 1.8);
                });
          } else {
            return Container();
          }
        },
      ),
    );
  }

  void deletePost() {
    FirebaseFirestore.instance
        .collection(Constants.stitchCollection)
        .doc(stitchIdIntent)
        .update({
      "post_ids": FieldValue.arrayRemove([postId])
    });
    setState(() {});
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

  Future _postExpandedTapped(
      String postId, String bucketName, int index) async {
    Map results = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      // return BucketDetailsExpanded(
      //   url: imageUrl,
      //   bucketName: bucketName,
      //   indexOfHero: index,
      // );
      return PostDetailScreen(
        postIdIntent: postId,
      );
    }));
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

  // Create Stitch and Routine Bottom sheet
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
                                        'Update Stitch',
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
                                'Stitch Name',
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
                                },
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
                                        context, Constants.stitchCollection);
                                  },
                                  child: Text(
                                    'Update Stitch',
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
      // uploadImageToFirebase(Constants.stitchImagesFolder);
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
    Constants.showSnackBarWithMessage("Stitch image uploading...", _scaffoldkey,
        context, AppColors.primaryColor);

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
        .collection(Constants.stitchCollection)
        .doc(stitchIdIntent)
        .update(stitchMap)
        .then((value) {
      // _formKey.currentState?.reset();
      /*imageFile = null;
        stitchDescriptionController.clear();
        stitchTitleController.clear();*/

      //Constants().successToast(context, "$sMsg created successfully!");
      Utilities.hide();

      Constants.showSnackBarWithMessage("Stitch updated successfully!",
          _scaffoldkey, context, AppColors.greenColor);
      // setState(() {});

      Navigator.of(context).pop();
    });
  }

  @override
  void onOkClick(int code) {
    deletePost();
  }
}
