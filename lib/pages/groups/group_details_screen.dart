import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/feed_model.dart';
import 'package:solstice/model/forum_model.dart';
import 'package:solstice/model/groups/groups_model.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/model/routine_model.dart';
import 'package:solstice/model/stitch_routine_model.dart';
import 'package:solstice/model/tabs_models.dart';
import 'package:solstice/pages/buckets_stitch/routine_detail_screen.dart';
import 'package:solstice/pages/feeds/card_feed_item.dart';
import 'package:solstice/pages/home/create_post.dart';
import 'package:solstice/pages/search_location.dart';

import 'package:solstice/pages/views/bucket_stitch_list_item.dart';
import 'package:solstice/pages/views/forum_list_fb_item.dart';
import 'package:solstice/pages/views/forum_list_item.dart';
import 'package:solstice/pages/views/routine_tab_list_item.dart';

import 'package:solstice/pages/views/tab_list_item.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/dialog_callback.dart';
import 'package:solstice/utils/shared_preferences.dart';
import 'package:solstice/utils/size_utils.dart';
import 'package:solstice/utils/utilities.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupIdIntent;

  const GroupDetailsScreen({Key key, @required this.groupIdIntent}) : super(key: key);

  @override
  _GroupDetailsState createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetailsScreen> implements DialogCallBack {
  bool isAboutgroupSelected = false;
  bool isBucketSelected = true;

  bool isMeAdminOfGroup = false;
  bool isMeMemberOfGroup = false;
  String groupTitle = "";
  String groupDescription = "";
  String groupImage = "";
  String aboutGroupDes = "";
  String groupCreateAddress = "";
  String userIDPref = "";
  String userNamePref = "";
  String userImagePref = "";
  bool isEditMode = false;
  List<String> adminsStrList = new List<String>();
  List<String> usersStrList = new List<String>();
  List<String> postIdsList = new List<String>.empty(growable: true);

  List<String> groupAdminImagesList = new List<String>();
  List<String> groupUsersImagesList = new List<String>();
  List<FeedModel> feedsList = new List<FeedModel>.empty(growable: true);
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  List<PostModel> selectedList = new List<PostModel>();
  List<TabsModel> bucketTabsList = new List<TabsModel>();

  GroupsFireBaseModel groupDetail;
  bool isGroupFile = true;

  bool isPublicStitch = true;
  String stitchTye = "Public";

  // for update group
  var imageFile = null;

  String _selectedImageUrl = "";
  var imageFileStitch = null;
  TextEditingController groupTitleController = new TextEditingController();
  TextEditingController groupDescriptionController = new TextEditingController();
  TextEditingController aboutGroupController = new TextEditingController();
  final FocusNode _groupTitleFocus = new FocusNode();
  final FocusNode _groupDescriptionFocus = new FocusNode();
  final FocusNode _aboutGroupFocus = new FocusNode();
  final _formKey = GlobalKey<FormState>();

  TextEditingController stitchDescriptionController = new TextEditingController();
  TextEditingController stitchTitleController = new TextEditingController();
  String stichId, stitchTitle, routineId, routineTitle;

  TextEditingController formTitleController = new TextEditingController();
  TextEditingController formDescriptionController = new TextEditingController();
  final FocusNode _formTitleFocus = new FocusNode();
  final FocusNode _formDescriptionFocus = new FocusNode();
  String _currentAddress;

  var selectedBottomTab = "All";

  LatLng currentLatLng;
  Position currentLocation;

  double selectedLatitude = 0.0;
  double selectedLongitude = 0.0;

  bool isPublic = true;
  List<String> selectedTabList = new List();
  String privacyType = "Public";
  String stitchId = "", routineIdToDelete = "", forumId = "", postId = "", imageUrl = "";

  @override
  void initState() {
    super.initState();
    getPrefData();

    bucketTabsList.add(new TabsModel("All", true));
    bucketTabsList.add(new TabsModel("Stitches", false));
    bucketTabsList.add(new TabsModel("Routines", false));
    bucketTabsList.add(new TabsModel("Forum", false));
    setDefaultList();

    getUserLocation();
  }

  // get user current location
  getUserLocation() async {
    currentLocation = await locateUser();
    currentLatLng = LatLng(currentLocation.latitude, currentLocation.longitude);
    //globals.currentLatLng = currentLatLng;
    try {
      selectedLatitude = currentLatLng.latitude;
      selectedLongitude = currentLatLng.longitude;
      List<Placemark> placemarks =
          await placemarkFromCoordinates(currentLocation.latitude, currentLocation.longitude);

      Placemark place = placemarks[0];

      _currentAddress = "${place.locality}, ${place.country}";
    } catch (e) {
    }

    if (mounted) setState(() {});
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  // get user from local storage
  getPrefData() {
    Future<String> userId = SharedPref.getStringFromPrefs(Constants.USER_ID);
    userId.then((value) => {userIDPref = value, getForumDetail(widget.groupIdIntent)},
        onError: (err) {
    });

    Future<String> userName = SharedPref.getStringFromPrefs(Constants.USER_NAME);
    userName.then(
        (value) => {
              userNamePref = value,
            },
        onError: (err) {});
    Future<String> userImage = SharedPref.getStringFromPrefs(Constants.PROFILE_IMAGE);
    userImage.then(
        (value) => {
              userImagePref = value,
            },
        onError: (err) {});

    if (mounted) setState(() {});
  }

  Future<bool> _onBackPressed() async {
    // Your back press code here...
    Navigator.of(context).pop({'update': "yes"});
  }

  // get particular forum detail with forum id from firestore db
  Future<String> getForumDetail(String groupId) async {
    FirebaseFirestore.instance
        .collection(Constants.groupsFB)
        .doc(groupId)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      Map<String, dynamic> mapObject = documentSnapshot.data();
      if (mounted) {
        setState(() {
          if (documentSnapshot.exists) {
            groupDetail = GroupsFireBaseModel.fromSnapshot(documentSnapshot);
            adminsStrList = List.from(documentSnapshot['admins']);
            usersStrList = List.from(documentSnapshot['users']);
            postIdsList = List.from(documentSnapshot['post_ids']);
            if (postIdsList.length > 0) {
              getPostDetails();
            }
            try {
              if (mapObject.containsKey("location")) {
                groupCreateAddress = documentSnapshot['location']['address'];
              }
            } catch (e) {}

            if (groupDetail != null) {
              groupTitle = groupDetail.title;
              groupDescription = groupDetail.description;
              aboutGroupDes = groupDetail.aboutGroup;
              groupImage = groupDetail.image;

              if (groupDetail.isPublic == true) {
                isPublic = true;
                privacyType = "Public";
              } else {
                isPublic = false;
                privacyType = "Private";
              }

              groupTitleController.text = groupTitle;
              groupDescriptionController.text = groupDescription;
              aboutGroupController.text = aboutGroupDes;
              _selectedImageUrl = groupImage;
            }

            isMeAdminOfGroup = adminsStrList.contains(userIDPref) ? true : false;
            isMeMemberOfGroup = usersStrList.contains(userIDPref) ? true : false;
            try {
              var adminsSnapshots = FirebaseFirestore.instance
                  .collection(Constants.UsersFB)
                  .where("userId", whereIn: adminsStrList)
                  .snapshots();
              adminsSnapshots.listen((querySnapshot) {
                groupAdminImagesList.clear();
                querySnapshot.docChanges.forEach((change) {
                  // Do something with change
                  groupAdminImagesList.add(change.doc.data()['userImage'].toString());
                  setState(() {
                  });
                });
              });
            } catch (e) {}

            try {
              var groupUsersSnapshots = FirebaseFirestore.instance
                  .collection(Constants.UsersFB)
                  .where("userId", whereIn: usersStrList)
                  .snapshots();
              groupUsersSnapshots.listen((querySnapshot) {
                groupUsersImagesList.clear();
                querySnapshot.docChanges.forEach((change) {
                  groupUsersImagesList.add(change.doc.data()['userImage'].toString());
                  if (this.mounted) {
                    setState(() {});
                  }
                });
              });
            } catch (e) {}
          } else {
            _onBackPressed();
          }
        });
      }
    }).onError((e) => print(e));
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldkey,
        body: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: <Widget>[
            Container(
              child: SliverAppBar(
                iconTheme: IconThemeData(color: Colors.black),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () => _onBackPressed(),
                ),
                actions: <Widget>[
                  Container(
                      child: PopupMenuButton<int>(
                    elevation: 5.0,
                    onSelected: (int value) {
                      setState(() {
                        //_selection = value;
                        switch (value) {
                          case 1:
                            _updateGroupBottomSheet(context);
                            break;
                          case 2:
                            ConfirmDeleteDialog(Constants.deleteGroup,
                                Constants.deleteGroupConfirmDes, "deleteGroup");
                            break;
                          case 3:
                            joinGroupMethod();
                            break;
                          case 4:
                            ConfirmDeleteDialog(
                                Constants.leaveGroup, Constants.leaveGroupConfirmDes, "leaveGroup");
                            break;
                          case 5:
                            //createPost
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CreatePost(
                                          routineId: widget.groupIdIntent,
                                          screenType: "Group",
                                        )));
                            break;
                          case 6:
                            //CreateStitch
                            createStitch(Constants.stitchCollection, true);
                            break;
                          case 7:
                            //Create Routine
                            createStitch(Constants.routineCollection, false);
                            break;
                          case 8:
                            //Create Forum
                            _createForumBottomSheet(context);
                            break;
                          default:
                            break;
                        }
                      });
                    },
                    child: Container(
                        width: 24,
                        height: 24,
                        margin: EdgeInsets.only(right: 10, left: 10),
                        child: SvgPicture.asset(
                          'assets/images/ic_menu.svg',
                          alignment: Alignment.center,
                          fit: BoxFit.contain,
                          color: Colors.black,
                        )),
                    itemBuilder: (c) => [
                      // if (groupDetail != null && isMeMemberOfGroup)
                      //   PopupMenuItem(
                      //     value: 5,
                      //     child: Text(
                      //       Constants.createPost,
                      //       style: TextStyle(
                      //           fontSize: ScreenUtil().setSp(28),
                      //           fontFamily: Constants.regularFont,
                      //           color: Colors.black),
                      //     ),
                      //   ),
                      if (groupDetail != null && isMeMemberOfGroup)
                        PopupMenuItem(
                          value: 6,
                          child: Text(
                            Constants.createStitch,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(28),
                                fontFamily: Constants.regularFont,
                                color: Colors.black),
                          ),
                        ),
                      if (groupDetail != null && isMeMemberOfGroup)
                        PopupMenuItem(
                          value: 7,
                          child: Text(
                            Constants.createRoutine,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(28),
                                fontFamily: Constants.regularFont,
                                color: Colors.black),
                          ),
                        ),
                      if (groupDetail != null && isMeMemberOfGroup)
                        PopupMenuItem(
                            value: 8,
                            child: Text(
                              Constants.createForum,
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(28),
                                  fontFamily: Constants.regularFont,
                                  color: Colors.black),
                            )),
                      if (groupDetail != null && isMeAdminOfGroup)
                        PopupMenuItem(
                          value: 1,
                          child: Text(
                            Constants.updateGroup,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(28),
                                fontFamily: Constants.regularFont,
                                color: Colors.black),
                          ),
                        ),
                      if (groupDetail != null && isMeAdminOfGroup)
                        PopupMenuItem(
                          value: 2,
                          child: Text(
                            Constants.deleteGroup,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(28),
                                fontFamily: Constants.regularFont,
                                color: AppColors.redColor),
                          ),
                        ),
                      if (groupDetail != null && !isMeMemberOfGroup)
                        PopupMenuItem(
                          value: 3,
                          child: Text(
                            Constants.joinGroup,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(28),
                                fontFamily: Constants.regularFont,
                                color: Colors.black),
                          ),
                        ),
                      if (groupDetail != null && isMeMemberOfGroup)
                        PopupMenuItem(
                          value: 4,
                          child: Text(
                            Constants.leaveGroup,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(28),
                                fontFamily: Constants.regularFont,
                                color: AppColors.redColor),
                          ),
                        ),
                    ],
                  )),
                ],
                pinned: true,
                floating: true,
                expandedHeight: 160.0,
                backgroundColor: Colors.white,
                stretch: true,
                snap: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    "",
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'epilogue_bold',
                        fontSize: ScreenUtil().setSp(30)),
                  ),
                  background: CachedNetworkImage(
                    imageUrl: groupImage,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => setGroupDefaultImage(),
                    errorWidget: (context, url, error) => setGroupDefaultImage(),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Card(
                    color: Colors.white,

                    margin: EdgeInsets.zero,

                    // clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0, top: 15.0),
                            child: Text(
                              groupTitle,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'epilogue_bold',
                                  fontSize: ScreenUtil().setSp(30)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0, top: 5.0),
                            child: Text(
                              groupDescription,
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontFamily: 'epilogue_regular',
                                  fontSize: ScreenUtil().setSp(30)),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 1,
                            color: Color(0xFFEBEBEB),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (isAboutgroupSelected) {
                                  isAboutgroupSelected = false;
                                } else {
                                  isAboutgroupSelected = true;
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'About',
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(26),
                                        fontFamily: 'epilogue_regular',
                                        color: Color(0xFF1A58E7)),
                                  ),
                                  isAboutgroupSelected == true
                                      ? Container(
                                          width: 16,
                                          height: 16,
                                          padding: EdgeInsets.all(2.5),
                                          margin: EdgeInsets.only(right: 5),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              'assets/images/ic_uper_arrow.svg',
                                              fit: BoxFit.contain,
                                              color: Color(0xFF1A58E7),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 16,
                                          height: 16,
                                          padding: EdgeInsets.all(2.5),
                                          margin: EdgeInsets.only(right: 5),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              'assets/images/ic_down_arrow.svg',
                                              fit: BoxFit.contain,
                                              color: Color(0xFF1A58E7),
                                            ),
                                          ),
                                        )
                                ],
                              ),
                            ),
                          ),
                          isAboutgroupSelected == true
                              ? Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    color: Colors.white,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (groupCreateAddress != null && groupCreateAddress != "")
                                          Text(
                                            groupCreateAddress,
                                            style: TextStyle(
                                              height: 1.5,
                                              fontSize: ScreenUtil().setSp(27),
                                              color: Colors.black,
                                              fontFamily: Constants.mediumFont,
                                            ),
                                          ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        if (groupAdminImagesList.length > 0)
                                          Text(
                                            groupAdminImagesList.length > 1 ? 'Admins' : "Admin",
                                            style: TextStyle(
                                              height: 1.5,
                                              fontSize: ScreenUtil().setSp(30),
                                              color: Color(0xFFB1B1B1),
                                              fontFamily: 'epilogue_bold',
                                            ),
                                          ),
                                        Container(
                                            height: 50,
                                            margin: EdgeInsets.only(top: 5),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(right: 8.0),
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: groupAdminImagesList == null
                                                          ? 0
                                                          : groupAdminImagesList.length,
                                                      physics: BouncingScrollPhysics(),
                                                      scrollDirection: Axis.horizontal,
                                                      itemBuilder: (context, positon) {
                                                        return Align(
                                                            widthFactor: 0.75,
                                                            child: positon < 6
                                                                ? usersImageUI(context,
                                                                    groupAdminImagesList[positon])
                                                                : Container());
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                (groupAdminImagesList.length > 6)
                                                    ? Expanded(
                                                        flex: 0,
                                                        child: Text(
                                                          "+" +
                                                              (groupAdminImagesList.length - 6)
                                                                  .toString() +
                                                              ' More',
                                                          style: TextStyle(
                                                              color: AppColors.accentColor,
                                                              fontSize: ScreenUtil().setSp(28)),
                                                        ),
                                                      )
                                                    : Container(),
                                              ],
                                            )),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        if (groupUsersImagesList.length > 0)
                                          Text(
                                            groupUsersImagesList.length > 1 ? 'Members' : 'Member',
                                            style: TextStyle(
                                              height: 1.5,
                                              fontSize: ScreenUtil().setSp(30),
                                              color: Color(0xFFB1B1B1),
                                              fontFamily: 'epilogue_bold',
                                            ),
                                          ),
                                        Container(
                                            height: 50,
                                            margin: EdgeInsets.only(top: 5),
                                            width: MediaQuery.of(context).size.width,
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(right: 8.0),
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: groupUsersImagesList == null
                                                          ? 0
                                                          : groupUsersImagesList.length,
                                                      physics: BouncingScrollPhysics(),
                                                      scrollDirection: Axis.horizontal,
                                                      itemBuilder: (context, positon) {
                                                        return Align(
                                                            widthFactor: 0.75,
                                                            child: positon < 6
                                                                ? usersImageUI(context,
                                                                    groupUsersImagesList[positon])
                                                                : Container());
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                (groupUsersImagesList.length > 6)
                                                    ? Expanded(
                                                        flex: 0,
                                                        child: Text(
                                                          "+" +
                                                              (groupUsersImagesList.length - 6)
                                                                  .toString() +
                                                              ' More',
                                                          style: TextStyle(
                                                              color: AppColors.accentColor,
                                                              fontSize: ScreenUtil().setSp(28)),
                                                        ),
                                                      )
                                                    : Container(),
                                              ],
                                            )),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 1,
                            color: Color(0xFFEBEBEB),
                          ),
                          if (groupDetail != null && !isMeMemberOfGroup)
                            InkWell(
                              onTap: () {
                                setState(() {
                                  joinGroupMethod();
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      Constants.joinGroup,
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(28),
                                          fontFamily: Constants.mediumFont,
                                          color: AppColors.greenColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (groupDetail != null && !isMeMemberOfGroup)
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 1,
                              color: Color(0xFFEBEBEB),
                            ),
                          SizedBox(
                            height: 15,
                          ),
                          // tabLayout(),
                          if (feedsList.length > 0)
                            Container(
                              child: ListView.builder(
                                itemCount: feedsList.length,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                      color: Colors.grey[100],
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: CardFeedItem(
                                        feedModel: feedsList[index],
                                        isInView: false,
                                        // filterCategory: refreshFilters,
                                      ));
                                },
                              ),
                            ),
                          SizedBox(
                            height: 15,
                          ),
                          // bottomLayout()
                        ],
                      ),
                    ),
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.only(
                    //     topLeft: Radius.circular(.0),
                    //     topRight: Radius.circular(25.0),
                    //   ),
                    // ),
                    elevation: 0,
                  );
                },
                childCount: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void deleteGroupFromDb() {
    FirebaseFirestore.instance
        .collection(Constants.groupsFB)
        .doc(widget.groupIdIntent)
        .delete()
        .then((docRef) {
          Constants.showSnackBarWithMessage(
              "Group deleted successfully!", _scaffoldkey, context, AppColors.greenColor);
          // Navigator.of(context).pop();
        })
        .timeout(Duration(seconds: 10))
        .catchError((error) {
          /* setState(() {
                      _isShowLoader = false;
                    });*/
        });
  }

  void ConfirmDeleteDialog(String title, String message, String type) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            child: Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 30),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: AppColors.viewLineColor)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        margin: EdgeInsets.only(top: 62, right: 30, left: 30),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: Constants.mediumFont,
                              fontSize: ScreenUtil().setSp(36)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 12, right: 30, left: 30),
                        alignment: Alignment.center,
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.blackColor[100],
                              fontFamily: Constants.regularFont,
                              fontSize: ScreenUtil().setSp(28)),
                        ),
                      ),
                      SizedBox(
                        height: 100.0,
                        width: 200,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                                child: GestureDetector(
                              onTap: () {
                                // Navigator.pop(context, true);
                              },
                              child: Container(
                                color: Colors.transparent,
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: 42,
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(color: AppColors.redColor)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    // Navigator.pop(context);
                                  },
                                  color: AppColors.redColor,
                                  textColor: Colors.white,
                                  padding: EdgeInsets.all(4.0),
                                  child: Text("No",
                                      style: TextStyle(fontSize: 16.0, fontFamily: 'rubikregular')),
                                ),
                              ),
                            )),
                            SizedBox(
                              width: 40,
                            ),
                            Expanded(
                                child: GestureDetector(
                              onTap: () {
                                // Navigator.pop(context, true);
                              },
                              child: Container(
                                color: Colors.transparent,
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: 42,
                                child: FlatButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(color: AppColors.redColor)),
                                  color: Colors.white,
                                  textColor: AppColors.redColor,
                                  padding: EdgeInsets.all(4.0),
                                  onPressed: () {
                                    Navigator.of(context).pop();

                                    //deleteForumFromDb();

                                    if (type == "deleteGroup") {
                                      deleteGroupFromDb();
                                    } else {
                                      leaveGroupMethod();
                                    }
                                  },
                                  child: Text(
                                    "Yes",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: 'rubikregular',
                                    ),
                                  ),
                                ),
                              ),
                            )),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.topCenter,
                  height: 100,
                  child: Container(
                    alignment: Alignment.center,
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: new Image.asset(
                      'assets/images/ic_question_green.png',
                      width: 45.0,
                      color: AppColors.redColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  setGroupDefaultImage() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: ScreenUtil().setSp(500),
      color: AppColors.viewLineColor,
    );
  }

  Widget tabLayout() {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(
        left: ScreenUtil().setSp(36),
        right: ScreenUtil().setSp(36),
      ),
      height: ScreenUtil().setSp(54),
      child: ListView.builder(
        itemCount: bucketTabsList == null ? 0 : bucketTabsList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return new InkWell(
            //highlightColor: Colors.red,
            splashColor: AppColors.primaryColor,
            onTap: () {
              setState(() {
                bucketTabsList.forEach((element) => element.isSelected = false);
                bucketTabsList[index].isSelected = true;

                selectedBottomTab = bucketTabsList[index].tabTitle;
                selectedTabList.clear();
                if (selectedBottomTab == "All") {
                  selectedTabList.addAll(groupDetail.routineIds);
                } else if (selectedBottomTab == "Stitches") {
                  selectedTabList.addAll(groupDetail.stitchIds);
                } else if (selectedBottomTab == "Routines") {
                  selectedTabList.addAll(groupDetail.routineIds);
                } else {
                  selectedTabList.addAll(groupDetail.forumIds);
                }
                //selectedLevel = levelDataList[index].type;
              });
            },
            child: new TabListItem(bucketTabsList[index]),
          );
        },
      ),
    );
  }

  Widget bottomLayout() {
    return isBucketSelected
        ? MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: selectedTabList.length == 0
                ? Container(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('No data available',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontFamily: Constants.mediumFont,
                              color: Colors.black,
                            )),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: selectedTabList == null ? 0 : selectedTabList.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, int position) {
                      return returnWigdetList(selectedTabList[position], position);
                    },
                  ),
          )
        : Container();
  }

  Future<StitchRoutineModel> loadData(String userId, collectionName) async {
    DocumentSnapshot ds =
        await FirebaseFirestore.instance.collection(collectionName).doc(userId).get();
    if (ds != null) print('Dss $ds');
    return Future.delayed(Duration(milliseconds: 100), () => StitchRoutineModel.fromSnapshot(ds));
  }

  Future<ForumFireBaseModel> loadForumData(String forumId, collectionName) async {
    DocumentSnapshot ds =
        await FirebaseFirestore.instance.collection(collectionName).doc(forumId).get();
    if (ds != null)
      return Future.delayed(Duration(milliseconds: 100), () => ForumFireBaseModel.fromSnapshot(ds));
  }

  Widget stitchListing(BuildContext context, id, index) {
    return FutureBuilder(
        future: loadData(id, Constants.stitchCollection),
        builder: (BuildContext context, AsyncSnapshot<StitchRoutineModel> userFirebase) {
          StitchRoutineModel sitchmodel = userFirebase.data;

          return sitchmodel != null
              ? Slidable(
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
                                  isEditMode = true,
                                  stitchTitleController.text = sitchmodel.title,
                                  stitchDescriptionController.text = sitchmodel.description,
                                  imageUrl = sitchmodel.image,
                                  isPublic = sitchmodel.isPublic,
                                  stitchId = sitchmodel.id,
                                  createStitch(Constants.stitchCollection, true),
                                }),
                      ),
                  ],
                  secondaryActions: <Widget>[
                    if (sitchmodel.createdBy == globalUserId)
                      IconSlideAction(
                        caption: 'Delete',
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () => {
                          stitchId = sitchmodel.id,
                          Utilities.confirmDeleteDialog(context, Constants.deleteStitch,
                              Constants.deleteStitchConfirmDes, this, 1),
                        },
                      ),
                  ],
                  child: new BucketStitchListItem(
                    sitchmodel,
                    index,
                    fromPostPage: false,
                  ),
                )
              : Container();
        });
  }

  Widget routineListing(BuildContext context, id, index) {
    return FutureBuilder(
        future: loadData(id, Constants.routineCollection),
        builder: (BuildContext context, AsyncSnapshot<StitchRoutineModel> userFirebase) {
          StitchRoutineModel routineModel = userFirebase.data;

          return routineModel != null
              ? InkWell(
                  onTap: () {
                    routineDetail(routineModel.id);
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
                                      isEditMode = true,
                                      stitchTitleController.text = routineModel.title,
                                      stitchDescriptionController.text = routineModel.description,
                                      imageUrl = routineModel.image,
                                      isPublic = routineModel.isPublic,
                                      routineId = routineModel.id,
                                      createStitch(Constants.routineCollection, false),
                                    }),
                          ),
                      ],
                      secondaryActions: <Widget>[
                        if (routineModel.createdBy == globalUserId)
                          IconSlideAction(
                            caption: 'Delete',
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () => {
                              routineIdToDelete = routineModel.id,
                              Utilities.confirmDeleteDialog(context, Constants.deleteRoutine,
                                  Constants.deleteRoutineConfirmDes, this, 2),
                            },
                          ),
                      ],
                      child: new RoutineTabListItem(routineModel, index)))
              : Container();
        });
  }

  void routineDetail(routineId) async {
    Map results = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return RoutineDetailScreen(
            routineIDIntent: routineId,
          );
        },
      ),
    );
  }

  Widget forumListing(BuildContext context, id, index) {
    return FutureBuilder(
        future: loadForumData(id, Constants.forumsCollection),
        builder: (BuildContext context, AsyncSnapshot<ForumFireBaseModel> userFirebase) {
          ForumFireBaseModel forumModel = userFirebase.data;

          return forumModel != null
              ? Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  actions: [
                    if (forumModel.createdBy == globalUserId)
                      Container(
                        margin: EdgeInsets.only(bottom: 30, top: 10.0),
                        child: IconSlideAction(
                            caption: 'Edit',
                            color: Colors.blue,
                            icon: Icons.delete,
                            onTap: () => {
                                  isEditMode = true,
                                  formTitleController.text = forumModel.title,
                                  formDescriptionController.text = forumModel.description,
                                  isPublicStitch = forumModel.isPublic,
                                  stitchTye = isPublicStitch ? 'Public' : 'Private',
                                  forumId = forumModel.id,
                                  _createForumBottomSheet(context),
                                }),
                      ),
                  ],
                  secondaryActions: <Widget>[
                    if (forumModel.createdBy == globalUserId)
                      IconSlideAction(
                        caption: 'Delete',
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () => {
                          forumId = forumModel.id,
                          Utilities.confirmDeleteDialog(context, Constants.deleteForum,
                              Constants.deleteForumConfirmDes, this, 3),
                        },
                      ),
                  ],
                  child: new ForumFbItem(
                    forumItem: forumModel,
                    appUserId: globalUserId,
                  ),
                )
              : Container();
        });
  }

  Widget profileTabListing(BuildContext context, id, index) {
    return FutureBuilder(
        future: loadData(id, Constants.stitchCollection),
        builder: (BuildContext context, AsyncSnapshot<StitchRoutineModel> userFirebase) {
          StitchRoutineModel sitchmodel = userFirebase.data;

          return new BucketStitchListItem(
            sitchmodel,
            index,
            fromPostPage: false,
          );
        });
  }

  void setDefaultList() {
    selectedList.add(new PostModel(
        "Joanne Kathrine",
        "http://i.imgur.com/QSev0hg.jpg",
        "https://www.bodybuilding.com/fun/images/2015/how-to-make-yourself-the-best-trainer-at-any-gym-facebook-box-960x540.jpg",
        "Radio House 83th",
        "3d",
        "This is the title for the journey",
        "Caption for this journey, Lorem ipsum dolor",
        "8",
        "4",
        true,
        true));
    selectedList.add(new PostModel(
        "Grace Aguri",
        "http://i.imgur.com/QSev0hg.jpg",
        "https://1.bp.blogspot.com/-ITDeKbpwTbk/XJePd5D2nyI/AAAAAAAAAkQ/JGEzWJ0uGCsLjo09hjNTeP7Cwndrp9x5ACEwYBhgL/s640/gym-trainer-1.jpg",
        "Video House 74th",
        "8d",
        "This is the title for the journey",
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled",
        "100",
        "40",
        false,
        false));
    selectedList.add(new PostModel(
        "Joanne Kathrine",
        "http://i.imgur.com/QSev0hg.jpg",
        "https://images.hindustantimes.com/Images/popup/2015/7/Crunches.jpg",
        "Radio House 83th",
        "3d",
        "This is the title for the journey",
        "Caption for this journey, Lorem ipsum dolor",
        "8",
        "4",
        true,
        true));
    selectedList.add(new PostModel(
        "Grace Aguri",
        "http://i.imgur.com/QSev0hg.jpg",
        "https://1.bp.blogspot.com/-ITDeKbpwTbk/XJePd5D2nyI/AAAAAAAAAkQ/JGEzWJ0uGCsLjo09hjNTeP7Cwndrp9x5ACEwYBhgL/s640/gym-trainer-1.jpg",
        "Video House 74th",
        "8d",
        "This is the title for the journey",
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled",
        "100",
        "40",
        false,
        false));
  }

  usersImageUI(BuildContext context, String userImage) {
    return CachedNetworkImage(
      imageUrl: userImage,
      imageBuilder: (context, imageProvider) => Container(
        width: ScreenUtil().setSp(70),
        height: ScreenUtil().setSp(70),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(50.0)),
          border: Border.all(
            color: Colors.white,
            width: 0.8,
          ),
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
      width: ScreenUtil().setSp(70),
      height: ScreenUtil().setSp(70),
      child: SvgPicture.asset(
        'assets/images/ic_male_placeholder.svg',
        width: ScreenUtil().setSp(70),
        height: ScreenUtil().setSp(70),
        fit: BoxFit.fill,
      ),
    );
  }

  void _updateGroupBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(child: StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setState) {
            return SingleChildScrollView(
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
                                  top: ScreenUtil().setSp(25), bottom: ScreenUtil().setSp(15)),
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
                                      Constants.createGroup,
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
                            Text(
                              Constants.uploadPhoto,
                              style: TextStyle(
                                  color: AppColors.accentColor,
                                  fontFamily: Constants.semiBoldFont,
                                  fontSize: ScreenUtil().setSp(24)),
                            ),
                            SizedBox(height: 8),
                            imageFile != null
                                ? InkWell(
                                    onTap: () {
                                      isGroupFile = true;
                                      _settingModalBottomSheet(context, setState);
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
                                            imageFile,
                                            fit: BoxFit.cover,
                                            height: 90,
                                            width: 90,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : _selectedImageUrl != "null" && _selectedImageUrl != ""
                                    ? InkWell(
                                        onTap: () {
                                          _settingModalBottomSheet(context, setState);
                                        },
                                        child: Container(
                                          child: PhysicalModel(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.grey,
                                            elevation: 5,
                                            shadowColor: AppColors.accentColor,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: CachedNetworkImage(
                                                imageUrl: _selectedImageUrl,
                                                fit: BoxFit.cover,
                                                height: 90,
                                                width: 90,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : InkWell(
                                        onTap: () {
                                          _settingModalBottomSheet(context, setState);
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
                            SizedBox(height: 10),
                            TextFormField(
                              maxLength: 200,
                              focusNode: _groupTitleFocus,
                              cursorColor: AppColors.primaryColor,
                              controller: groupTitleController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (v) {
                                FocusScope.of(context).requestFocus(_groupDescriptionFocus);
                              },
                              onChanged: (v) {},
                              decoration: InputDecoration(
                                counterText: "",
                                labelText: 'Group Title',
                                labelStyle: TextStyle(
                                    color: AppColors.accentColor,
                                    fontFamily: Constants.semiBoldFont,
                                    fontSize: ScreenUtil().setSp(24)),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              alignment: Alignment.topRight,
                              margin: const EdgeInsets.only(top: 4.0, left: 30.0, bottom: 3),
                              child: Text(
                                '',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.red,
                                    fontFamily: Constants.mediumFont),
                              ),
                            ),
                            TextFormField(
                              maxLength: 2000,
                              focusNode: _groupDescriptionFocus,
                              cursorColor: AppColors.primaryColor,
                              controller: groupDescriptionController,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              onChanged: (v) {
                                /*setState(() {
                                                              if (groupDescriptionController.value.text.trim().isEmpty) {
                                                                isBtnEnable = false;
                                                              } else if (groupDescriptionController.value.text.trim().length < 3) {
                                                                isBtnEnable = false;
                                                              } else {
                                                                if (imageFile!=null) {
                                                                  if (groupTitleController.text.length >= 3) {
                                                                    isBtnEnable = true;
                                                                  }
                                                                }
                                                              }
                                                            });*/
                              },
                              decoration: InputDecoration(
                                counterText: "",
                                labelText: "Group description",
                                labelStyle: TextStyle(
                                    color: AppColors.accentColor,
                                    fontFamily: Constants.semiBoldFont,
                                    fontSize: ScreenUtil().setSp(24)),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              alignment: Alignment.topRight,
                              margin: const EdgeInsets.only(top: 4.0, left: 30.0, bottom: 16),
                              child: Text(
                                "",
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.red,
                                    fontFamily: Constants.mediumFont),
                              ),
                            ),
                            Text(
                              Constants.privacyType,
                              style: TextStyle(
                                  color: AppColors.accentColor,
                                  fontFamily: Constants.semiBoldFont,
                                  fontSize: ScreenUtil().setSp(24)),
                            ),
                            SizedBox(
                              height: 4,
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
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                    border:
                                        Border.all(color: AppColors.appGreyColor[500], width: 1)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      isPublic ? Constants.publicIcon : Constants.privateIcon,
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

                            /*TextFormField(
                                                              maxLength: 2000,
                                                              focusNode: _aboutGroupFocus,
                                                              cursorColor: AppColors.primaryColor,
                                                              controller: aboutGroupController,
                                                              keyboardType: TextInputType.multiline,
                                                              maxLines: null,
                                                              onChanged: (v) {
                                                                */ /*setState(() {
                                                              if (groupDescriptionController.value.text.trim().isEmpty) {
                                                                isBtnEnable = false;
                                                              } else if (groupDescriptionController.value.text.trim().length < 3) {
                                                                isBtnEnable = false;
                                                              } else {
                                                                if (imageFile!=null) {
                                                                  if (groupTitleController.text.length >= 3) {
                                                                    isBtnEnable = true;
                                                                  }
                                                                }
                                                              }
                                                            });*/ /*
                                                              },
                                                              decoration: InputDecoration(
                                                                counterText: "",
                                                                labelText: "About group",
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
                                                            ),*/
                            SizedBox(height: 8),
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
                                  setState(() {
                                    var title = groupTitleController.value.text.trim();
                                    var description = groupDescriptionController.value.text.trim();
                                    var aboutGroup = aboutGroupController.value.text.trim();
                                    if (title.isEmpty) {
                                      Constants().errorToast(context, Constants.enterTitleError);
                                    } else if (description.isEmpty) {
                                      Constants()
                                          .errorToast(context, Constants.enterGroupDescription);
                                    } else if (title.length < 4) {
                                      Constants()
                                          .errorToast(context, Constants.gTitleMust4Characters);
                                    } else if (description.length < 4) {
                                      Constants()
                                          .errorToast(context, Constants.gDesMust4Characters);
                                    } else {
                                      if (_selectedImageUrl == "" || _selectedImageUrl == "null") {
                                        Constants().errorToast(context, Constants.imageFileError);
                                      } else {
                                        if (imageFile != null) {
                                          Navigator.of(context).pop();
                                          uploadGroupImage(title, description, aboutGroup);
                                        } else {
                                          Navigator.of(context).pop();
                                          updateGroupToDb(
                                              _selectedImageUrl, title, description, aboutGroup);
                                        }
                                      }
                                    }
                                  });
                                },
                                color: AppColors.primaryColor,
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
                  )),
            );
          },
        ));
      },
    );
  }

  Future<void> uploadGroupImage(String title, String description, String aboutGroup) async {
    Constants.showSnackBarWithMessage(
        "Group image uploading...", _scaffoldkey, context, AppColors.primaryColor);

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var reference = FirebaseStorage.instance.ref().child("groupImages").child(fileName);
    UploadTask uploadTask = reference.putFile(imageFile);

    uploadTask.whenComplete(() {
      reference.getDownloadURL().then((downloadUrl) {
        _selectedImageUrl = downloadUrl;
        setState(() {
          updateGroupToDb(_selectedImageUrl, title, description, aboutGroup);
        });
      });
    }).onError((error, stackTrace) {
      setState(() {
        //_showLoading = false;
      });
      Constants.showSnackBarWithMessage(
          "This file is not an image", _scaffoldkey, context, Colors.red[700]);
    });
  }

  void updateGroupToDb(String groupImageUrl, String title, String description, String aboutGroup) {
    //_isShowLoader = true;
    groupTitleController.text = "";
    groupDescriptionController.text = "";
    aboutGroupController.text = "";
    imageFile = null;
    _selectedImageUrl = "";

    Constants.showSnackBarWithMessage(
        "Group Updating...", _scaffoldkey, context, AppColors.primaryColor);
    FirebaseFirestore.instance
        .collection(Constants.groupsFB)
        .doc(widget.groupIdIntent)
        .update({
          "title": title,
          "description": description,
          "about_group": aboutGroup,
          "image": groupImageUrl,
          'updated_at': FieldValue.serverTimestamp(),
        })
        .then((docRef) {
          Constants.showSnackBarWithMessage(
              "Group updated successfully!", _scaffoldkey, context, AppColors.greenColor);
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

  void joinGroupMethod() {
    List<String> userList = new List<String>();
    userList.add(userIDPref);

    FirebaseFirestore.instance
        .collection(Constants.groupsFB)
        .doc(widget.groupIdIntent)
        .update({'users': FieldValue.arrayUnion(userList)})
        .then((docRef) {
          Constants().successToast(context, "Group joined successfully!");
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

  void leaveGroupMethod() {
    List<String> userList = new List<String>();
    userList.add(userIDPref);

    FirebaseFirestore.instance
        .collection(Constants.groupsFB)
        .doc(widget.groupIdIntent)
        .update({
          'users': FieldValue.arrayRemove([userIDPref])
        })
        .then((docRef) {
          Constants.showSnackBarWithMessage(
              "Leave group successfully!", _scaffoldkey, context, AppColors.greenColor);
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

    FirebaseFirestore.instance
        .collection(Constants.groupsFB)
        .doc(widget.groupIdIntent)
        .update({
          'admins': FieldValue.arrayRemove([userIDPref])
        })
        .then((docRef) {
        })
        .timeout(Duration(seconds: 10))
        .catchError((error) {
          /* setState(() {
                                        _isShowLoader = false;
                                      });*/
        });
  }

  void _settingModalBottomSheet(context, state) {
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

  Future imageSelector(BuildContext context, String pickerType, StateSetter state) async {
    switch (pickerType) {
      case "gallery":

        /// GALLERY IMAGE PICKER
        if (isGroupFile) {
          imageFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
        } else {
          imageFileStitch =
              await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
        }

        break;

      case "camera":

        /// CAMERA CAPTURE CODE
        if (isGroupFile) {
          imageFile = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 90);
        } else {
          imageFileStitch =
              await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 90);
        }

        break;
    }
    if (imageFile != null) {
      updated(state, imageFile);
    } else {
    }
  }

  Future<Null> updated(StateSetter updateState, imageFile) async {
    updateState(() {});
  }

  void createStitch(collectionName, isStitch) async {
    var object = await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Wrap(
                  children: [
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
                                        isStitch
                                            ? (isEditMode ? 'Edit a Stitch' : 'Create a new Stitch')
                                            : (isEditMode
                                                ? 'Edit a Routine'
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
                                    isStitch
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
                                  isGroupFile = false;
                                  _settingModalBottomSheet(context, setState);
                                  // imageSelector(context, "gallery",setState);
                                },
                                child: imageFileStitch == null
                                    ? (imageUrl.isNotEmpty
                                        ? Container(
                                            child: PhysicalModel(
                                              borderRadius: BorderRadius.circular(10),
                                              color: AppColors.viewLineColor,
                                              elevation: 5,
                                              shadowColor: AppColors.shadowColor,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Image.network(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                  height: 75,
                                                  width: 75,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Row(
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
                                isStitch ? 'Stitch Name' : 'Routine Name',
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
                                    return isStitch ? 'Enter stitch title!' : 'Enter routine title';
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
                                isStitch ? 'Stitch Description' : 'Routine Description',
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
                                    return isStitch
                                        ? 'Enter stitch description!'
                                        : 'Enter routine description';
                                  }
                                  return null;
                                },
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(30),
                                    fontFamily: 'epilogue_regular'),
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
                                  if (isPublicStitch) {
                                    stitchTye = 'Private';
                                  } else {
                                    stitchTye = 'Public';
                                  }
                                  isPublicStitch = !isPublicStitch;
                                  setState(() {});
                                },
                                child: Container(
                                  width: 100.0,
                                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                      border:
                                          Border.all(color: AppColors.appGreyColor[500], width: 1)),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        isPublicStitch
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
                                        '$stitchTye',
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
                                    checkValids(
                                        context,
                                        collectionName,
                                        isStitch
                                            ? Constants.stitchImagesFolder
                                            : Constants.routineImagesFolder,
                                        isStitch);
                                  },
                                  child: Text(
                                    isStitch
                                        ? (isEditMode ? 'Update Stitch' : 'Create Stitch')
                                        : (isEditMode ? 'Update Routine' : 'Create Routine'),
                                    style: TextStyle(
                                        fontFamily: 'epilogue_semibold', color: Colors.white),
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
    if (object != null) {
      if (isStitch) {
        stichId = object['stitch_id'];
        stitchTitle = object['stitch_title'];
      } else {
        routineId = object['routine_id'];
        routineTitle = object['routine_title'];
      }

      setState(() {});
    }
  }

  checkValids(BuildContext context, String collectionName, String storageName, isStitch) {
    if (_formKey.currentState.validate()) {
      Utilities.show(context);
      if (imageFileStitch == null) {
        _selectedImageUrl = (isEditMode && imageUrl != "") ? imageUrl : defaultPostImage;
        if (isEditMode) {
          updateStitchEntry(collectionName, isStitch);
        } else {
          createStitchEntry(collectionName, isStitch);
        }
      } else {
        uploadImageToFirebase(storageName, collectionName, isStitch);
      }
    } else {
      Constants().errorToast(context, "Please fill all the fields");
    }
  }

  void uploadImageToFirebase(String storageName, String collectionName, isStitch) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var reference = FirebaseStorage.instance.ref().child(storageName).child(fileName);
    UploadTask uploadTask = reference.putFile(imageFileStitch);

    uploadTask.whenComplete(() {
      reference.getDownloadURL().then((downloadUrl) {
        _selectedImageUrl = downloadUrl;
        if (isEditMode) {
          updateStitchEntry(collectionName, isStitch);
        } else {
          createStitchEntry(collectionName, isStitch);
        }
      });
    }).onError((error, stackTrace) {
      Utilities.hide();
      Constants().errorToast(context, "$error , please upload image again");
    });
  }

  void updateStitchEntry(collectionName, isStitch) {
    FirebaseFirestore.instance
        .collection(collectionName)
        .doc(isStitch ? stitchId : routineId)
        .update({
      "created_at": Timestamp.now(),
      "created_by": globalUserId,
      "description": stitchDescriptionController.text.trim(),
      "image": _selectedImageUrl,
      "is_public": isPublicStitch,
      "title": stitchTitleController.text.trim(),
      "updated_at": Timestamp.now()
    }).then((value) {
      isPublicStitch = true;
      stitchTye = "Public";
      Utilities.hide();
      selectedTabList.clear();
      Navigator.pop(context);
      if (selectedBottomTab == "All") {
        selectedTabList.addAll(groupDetail.routineIds);
      } else if (selectedBottomTab == "Stitches") {
        selectedTabList.addAll(groupDetail.stitchIds);
      } else if (selectedBottomTab == "Routines") {
        selectedTabList.addAll(groupDetail.routineIds);
      } else {
        selectedTabList.addAll(groupDetail.forumIds);
      }

      imageFileStitch = null;
      stitchDescriptionController.clear();
      stitchTitleController.clear();
    }).catchError((error) {
      Utilities.hide();
    });
  }

  void createStitchEntry(collectionName, isStitch) {
    FirebaseFirestore.instance.collection(collectionName).add({
      "created_at": Timestamp.now(),
      "created_by": globalUserId,
      "description": stitchDescriptionController.text.trim(),
      "image": _selectedImageUrl,
      "is_public": isPublicStitch,
      "title": stitchTitleController.text.trim(),
      "updated_at": Timestamp.now()
    }).then((value) {
      // _formKey.currentState?.reset();
      isPublicStitch = true;
      stitchTye = "Public";
      saveStitchRoutineToGroup(isStitch, value.id);
      if (isStitch) {
        groupDetail.stitchIds.add(value.id);
      } else {
        groupDetail.routineIds.add(value.id);
      }
      selectedTabList.clear();
      if (selectedBottomTab == "All") {
        selectedTabList.addAll(groupDetail.routineIds);
      } else if (selectedBottomTab == "Stitches") {
        selectedTabList.addAll(groupDetail.stitchIds);
      } else if (selectedBottomTab == "Routines") {
        selectedTabList.addAll(groupDetail.routineIds);
      } else {
        selectedTabList.addAll(groupDetail.forumIds);
      }
      imageFileStitch = null;
      stitchDescriptionController.clear();
      stitchTitleController.clear();
    }).catchError((error) {
      Utilities.hide();
    });
  }

  void saveStitchRoutineToGroup(isStitch, id) {
    if (isStitch) {
      FirebaseFirestore.instance.collection(Constants.groupsFB).doc(widget.groupIdIntent).update({
        'stitch_ids': FieldValue.arrayUnion([id])
      }).then((value) {
        Utilities.hide();
        Navigator.of(context).pop();
        Constants().successToast(context, "Stitch is added to group");
        setState(() {});
      }).catchError((onError) {
        Utilities.hide();
      });
    } else {
      FirebaseFirestore.instance.collection(Constants.groupsFB).doc(widget.groupIdIntent).update({
        'routine_ids': FieldValue.arrayUnion([id])
      }).then((value) {
        Utilities.hide();
        Navigator.of(context).pop();
        Constants().successToast(context, "Routine is added to group");
        setState(() {});
      }).catchError((onError) {
        Utilities.hide();
      });
    }
  }

  // Create Forum

  void _createForumBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, state) {
          return SingleChildScrollView(
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
                                top: ScreenUtil().setSp(30), bottom: ScreenUtil().setSp(15)),
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
                                    isEditMode ? Constants.updateForum : Constants.createForum,
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
                          // SizedBox(height: 10),
                          // TextFormField(
                          //   maxLength: 200,
                          //   focusNode: _formTitleFocus,
                          //   cursorColor: AppColors.primaryColor,
                          //   controller: formTitleController,
                          //   keyboardType: TextInputType.text,
                          //   textInputAction: TextInputAction.next,
                          //   onFieldSubmitted: (v) {
                          //     FocusScope.of(context)
                          //         .requestFocus(_formDescriptionFocus);
                          //   },
                          //   onChanged: (v) {},
                          //   decoration: InputDecoration(
                          //     counterText: "",
                          //     labelText: 'Name',
                          //     labelStyle: TextStyle(
                          //         color: AppColors.accentColor,
                          //         fontFamily: Constants.semiBoldFont,
                          //         fontSize: ScreenUtil().setSp(24)),
                          //   ),
                          // ),
                          Container(
                            padding: EdgeInsets.only(left: 10),
                            alignment: Alignment.topRight,
                            margin: const EdgeInsets.only(top: 4.0, left: 30.0, bottom: 3),
                            child: Text(
                              '',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red,
                                  fontFamily: Constants.mediumFont),
                            ),
                          ),
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
                            margin: const EdgeInsets.only(top: 4.0, left: 30.0, bottom: 16),
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
                                    (_currentAddress != null && _currentAddress != "")
                                        ? _currentAddress
                                        : Constants.selectLocation,
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(28),
                                        color: (_currentAddress != null && _currentAddress != "")
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
                          Text(
                            Constants.privacyType,
                            style: TextStyle(
                                color: AppColors.accentColor,
                                fontFamily: Constants.semiBoldFont,
                                fontSize: ScreenUtil().setSp(24)),
                          ),

                          InkWell(
                            onTap: () {
                              if (isPublicStitch) {
                                stitchTye = 'Private';
                              } else {
                                stitchTye = 'Public';
                              }
                              isPublicStitch = !isPublicStitch;
                              state(() {});
                            },
                            child: Container(
                              width: 100.0,
                              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                  border: Border.all(color: AppColors.appGreyColor[500], width: 1)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    isPublicStitch ? Constants.publicIcon : Constants.privateIcon,
                                    color: AppColors.accentColor,
                                    height: 15.0,
                                    width: 15.0,
                                  ),
                                  SizedBox(
                                    width: 4.0,
                                  ),
                                  Text(
                                    '$stitchTye ',
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
                          SizedBox(height: 8),
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
                                var title = formTitleController.value.text.trim();
                                var description = formDescriptionController.value.text.trim();
                                // if (title.isEmpty) {
                                //   Constants().errorToast(
                                //       context, Constants.enterNameError);
                                // } else if (title.length < 4) {
                                //   Constants().errorToast(
                                //       context, Constants.nameMust4Characters);
                                // }
                                if (description.isEmpty) {
                                  Constants().errorToast(context, Constants.enterDescriptionError);
                                } else if (description.length < 4) {
                                  Constants().errorToast(context, Constants.gDesMust4Characters);
                                } else {
                                  // Navigator.of(context).pop();
                                  if (isEditMode) {
                                    updateForum(title, description);
                                  } else {
                                    addForumToDb(title, description);
                                  }
                                }

                                if (mounted) {
                                  state(() {});
                                }
                              },
                              color: AppColors.primaryColor,
                              textColor: Colors.white,
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                isEditMode ? Constants.updateForum : Constants.continueTxt,
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
          );
        });
      },
    );
  }

  Future selectLocation() async {
    Map results =
        await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
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

  void addForumToDb(String title, String description) {
    //_isShowLoader = true;
    formTitleController.text = "";
    formDescriptionController.text = "";
    // Constants.showSnackBarWithMessage(
    //     "Forum uploading...", _scaffoldkey, context, AppColors.primaryColor);
    Utilities.show(context);
    FirebaseFirestore.instance
        .collection(Constants.ForumsFB)
        .add({
          "title": title,
          "description": description,
          "postLatitude": selectedLatitude.toString(),
          "postLongitude": selectedLongitude.toString(),
          "postAddress": _currentAddress.toString(),
          "is_public": isPublicStitch,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'createdBy': userIDPref,
          'createdByName': userNamePref,
          'createdByImage': userImagePref,
        })
        .then((docRef) {
          isPublicStitch = true;
          stitchTye = "Public";

          saveForumToGroup(docRef.id);
          groupDetail.forumIds.add(docRef.id);

          selectedTabList.clear();
          if (selectedBottomTab == "All") {
            selectedTabList.addAll(groupDetail.routineIds);
          } else if (selectedBottomTab == "Stitches") {
            selectedTabList.addAll(groupDetail.stitchIds);
          } else if (selectedBottomTab == "Routines") {
            selectedTabList.addAll(groupDetail.routineIds);
          } else {
            selectedTabList.addAll(groupDetail.forumIds);
          }

          /*setState(() {
                                        _isShowLoader = false;
                                      });*/
        })
        .timeout(Duration(seconds: 10))
        .catchError((error) {
          Utilities.hide();
          /* setState(() {
                                        _isShowLoader = false;
                                      });*/
        });
  }

  void updateForum(String title, String description) {
    //_isShowLoader = true;

    // Constants.showSnackBarWithMessage(
    //     "Forum uploading...", _scaffoldkey, context, AppColors.primaryColor);
    Utilities.show(context);
    FirebaseFirestore.instance
        .collection(Constants.ForumsFB)
        .doc(forumId)
        .update({
          "title": title,
          "description": description,
          "postLatitude": selectedLatitude.toString(),
          "postLongitude": selectedLongitude.toString(),
          "postAddress": _currentAddress.toString(),
          "is_public": isPublicStitch,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'createdBy': userIDPref,
          'createdByName': userNamePref,
          'createdByImage': userImagePref,
        })
        .then((docRef) {
          isPublicStitch = true;
          stitchTye = "Public";
          Navigator.pop(context);

          // saveForumToGroup(docRef.id);
          // groupDetail.forumIds.add(docRef.id);
          Utilities.hide();
          selectedTabList.clear();
          if (selectedBottomTab == "All") {
            selectedTabList.addAll(groupDetail.routineIds);
          } else if (selectedBottomTab == "Stitches") {
            selectedTabList.addAll(groupDetail.stitchIds);
          } else if (selectedBottomTab == "Routines") {
            selectedTabList.addAll(groupDetail.routineIds);
          } else {
            selectedTabList.addAll(groupDetail.forumIds);
          }

          /*setState(() {
                                        _isShowLoader = false;
                                      });*/
        })
        .timeout(Duration(seconds: 10))
        .catchError((error) {
          Utilities.hide();
          /* setState(() {
                                        _isShowLoader = false;
                                      });*/
        });
    formTitleController.text = "";
    formDescriptionController.text = "";
    setState(() {});
  }

  void saveForumToGroup(forumId) {
    FirebaseFirestore.instance.collection(Constants.groupsFB).doc(widget.groupIdIntent).update({
      'forum_ids': FieldValue.arrayUnion([forumId])
    }).then((value) {
      Utilities.hide();
      Navigator.of(context).pop();
      Constants.showSnackBarWithMessage(
          "Forum added to group!", _scaffoldkey, context, AppColors.greenColor);
      setState(() {});
    }).catchError((onError) {
      Utilities.hide();
    });
  }

  Widget returnWigdetList(String id, int index) {
    if (selectedBottomTab == "All") {
      return profileTabListing(context, id, index);
    } else if (selectedBottomTab == "Stitches") {
      return stitchListing(context, id, index);
    } else if (selectedBottomTab == "Routines") {
      return routineListing(context, id, index);
    } else {
      //return profileTabListing(context, snapshot);
      return forumListing(context, id, index);
    }
  }

  void deleteStitch() {
    FirebaseFirestore.instance.collection(Constants.groupsFB).doc(widget.groupIdIntent).update({
      "stitch_ids": FieldValue.arrayRemove([stitchId])
    });
    setState(() {});
  }

  void deleteRoutine() {
    FirebaseFirestore.instance.collection(Constants.groupsFB).doc(widget.groupIdIntent).update({
      "routine_ids": FieldValue.arrayRemove([routineIdToDelete])
    });
    setState(() {});
  }

  void deleteForum() {
    FirebaseFirestore.instance.collection(Constants.groupsFB).doc(widget.groupIdIntent).update({
      "forum_ids": FieldValue.arrayRemove([forumId])
    });
    setState(() {});
  }

  void deletePost() {
    FirebaseFirestore.instance.collection(Constants.groupsFB).doc(widget.groupIdIntent).update({
      "stitch_ids": FieldValue.arrayRemove([postId])
    });
    setState(() {});
  }

  @override
  void onOkClick(int code) {
    //code =1 (delete stitch), code=2 (delete routine), code =3 (delete forum),code=4(delete post)

    switch (code) {
      case 1:
        deleteStitch();
        break;
      case 2:
        deleteRoutine();
        break;
      case 3:
        deleteForum();
        break;
      case 4:
        deletePost();
        break;
    }
  }

  void getPostDetails() {
    for (int i = 0; i < postIdsList.length; i++) {
      FirebaseFirestore.instance
          .collection(Constants.feedsColl)
          .doc(postIdsList[i])
          .get()
          .then((value) {
        FeedModel feedModelUp = FeedModel.fromJson(value);

        FirebaseFirestore.instance
            .collection(Constants.routineFeedCollection)
            .doc(feedModelUp.itemId)
            .get()
            .then((routineData) {
          RoutineModel routineModeldat = RoutineModel.fromJson(routineData);
          feedModelUp.routineModel = routineModeldat;

          FirebaseFirestore.instance
              .collection(Constants.UsersFB)
              .doc(feedModelUp.userId)
              .get()
              .then((userData) {
            UserFirebaseModel firebaseModel = UserFirebaseModel.fromSnapshot(userData);
            feedModelUp.userFirebaseModel = firebaseModel;
            feedsList.add(feedModelUp);
            if (i == postIdsList.length - 1) {
              setState(() {});
            }
          });
        });
      });
    }
  }
}

class HomePostListItem extends StatelessWidget {
  final PostModel _selectedItem;
  final int index;

  HomePostListItem(this._selectedItem, this.index);

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: ScreenUtil().setSp(16),
        right: ScreenUtil().setSp(16),
      ),
      child: setViewsOnTypeBasis(_selectedItem, context),
    );
  }

  setViewsOnTypeBasis(PostModel selectedItem, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
            flex: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(ScreenUtil().setSp(20)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: (selectedItem.userImage.contains("https:") ||
                            selectedItem.userImage.contains("http:"))
                        ? selectedItem.userImage
                        : UrlConstant.BaseUrlImg + selectedItem.userImage,
                    imageBuilder: (context, imageProvider) => Container(
                      width: Dimens.imageSize25(),
                      height: Dimens.imageSize25(),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => Constants().setUserDefaultCircularImage(),
                    errorWidget: (context, url, error) => Constants().setUserDefaultCircularImage(),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.all(ScreenUtil().setSp(12)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              " " + selectedItem.userName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: AppColors.titleTextColor,
                                  fontFamily: Constants.boldFont,
                                  fontSize: ScreenUtil().setSp(26)),
                            ),
                            SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    width: 14,
                                    height: 14,
                                    child: SvgPicture.asset(
                                      'assets/images/ic_marker.svg',
                                      alignment: Alignment.center,
                                      fit: BoxFit.fill,
                                      color: AppColors.accentColor,
                                    )),
                                SizedBox(width: 3),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _selectedItem.locationName,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: AppColors.accentColor,
                                        fontFamily: Constants.regularFont,
                                        fontSize: ScreenUtil().setSp(22)),
                                  ),
                                ),
                                Text(
                                  _selectedItem.postTime,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: AppColors.titleTextColor,
                                      fontFamily: Constants.mediumFont,
                                      fontSize: ScreenUtil().setSp(22)),
                                ),
                              ],
                            ),
                          ]),
                    ),
                  ),
                ],
              ),
            )),
        SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 100 * 25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25.0),
                    ),
                  ),
                  child: PageView.builder(
                      itemCount: 5,
                      itemBuilder: (context, indexView) {
                        return Hero(
                          tag: 'homePageImage' + index.toString(),
                          child: CachedNetworkImage(
                            imageUrl: (_selectedItem.image.contains("https:") ||
                                    _selectedItem.image.contains("http:"))
                                ? _selectedItem.image
                                : UrlConstant.BaseUrlImg + _selectedItem.image,
                            imageBuilder: (context, imageProvider) => Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                //borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => setPostDefaultImage(context),
                            errorWidget: (context, url, error) => setPostDefaultImage(context),
                          ),
                        );
                      }),
                ),
                Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
                        width: 25,
                        height: 25,
                        child: SvgPicture.asset(
                          'assets/images/ic_arrow_swipe.svg',
                          fit: BoxFit.contain,
                          color: Colors.black,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          margin: EdgeInsets.only(
              top: ScreenUtil().setSp(26),
              bottom: ScreenUtil().setSp(26),
              right: ScreenUtil().setSp(36),
              left: ScreenUtil().setSp(36)),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  selectedItem.title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColors.titleTextColor,
                      fontFamily: Constants.boldFont,
                      fontSize: ScreenUtil().setSp(27)),
                ),
                SizedBox(height: 6),
                Text(
                  _selectedItem.description,
                  maxLines: 2,
                  style: TextStyle(
                      color: AppColors.titleTextColor,
                      fontFamily: Constants.regularFont,
                      fontSize: ScreenUtil().setSp(23)),
                ),
              ]),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          margin: EdgeInsets.only(
              right: ScreenUtil().setSp(20),
              left: ScreenUtil().setSp(20),
              bottom: ScreenUtil().setSp(36)),
          child: Row(
            children: [
              InkWell(
                child: Container(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26.0), color: AppColors.lightSkyBlue),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 18,
                            height: 18,
                            padding: EdgeInsets.all((1)),
                            child: SvgPicture.asset(
                              'assets/images/ic_comment.svg',
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                            )),
                        SizedBox(width: 8),
                        Text(
                          _selectedItem.commentsCount,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColors.titleTextColor,
                              fontFamily: Constants.boldFont,
                              fontSize: ScreenUtil().setSp(26)),
                        ),
                        SizedBox(width: 8),
                      ],
                    )), /*onTap: (){
                setState(() {
                  if(!isSelectedRecent){
                    isSelectedRecent = true;
                  }
                });
              },*/
              ),
              SizedBox(
                width: 10,
              ),
              InkWell(
                child: Container(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(width: 2, color: AppColors.lightSkyBlue),
                        borderRadius: BorderRadius.circular(26.0)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 18,
                            height: 18,
                            padding: EdgeInsets.all((1)),
                            child: SvgPicture.asset(
                              'assets/images/ic_heart.svg',
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                            )),
                        SizedBox(width: 8),
                        Text(
                          _selectedItem.likes,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColors.titleTextColor,
                              fontFamily: Constants.boldFont,
                              fontSize: ScreenUtil().setSp(26)),
                        ),
                        SizedBox(width: 8),
                      ],
                    )), /*onTap: (){
                setState(() {
                  if(!isSelectedRecent){
                    isSelectedRecent = true;
                  }
                });
              },*/
              ),
              Expanded(flex: 1, child: Container()),
              InkWell(
                child: Container(
                    padding: EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26.0), color: AppColors.lightSkyBlue),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 18,
                            height: 18,
                            padding: EdgeInsets.all((1)),
                            child: SvgPicture.asset(
                              _selectedItem.isSaved
                                  ? 'assets/images/ic_bookmarked.svg'
                                  : 'assets/images/ic_bookmark.svg',
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                            )),
                        SizedBox(width: 10),
                        Text(
                          "Stitch",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColors.primaryColor,
                              fontFamily: Constants.boldFont,
                              fontSize: ScreenUtil().setSp(26)),
                        ),
                        SizedBox(width: 8),
                      ],
                    )), /*onTap: (){
                setState(() {
                  if(!isSelectedRecent){
                    isSelectedRecent = true;
                  }
                });
              },*/
              ),
            ],
          ),
        )
      ],
    );
  }

  setPostDefaultImage(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: ScreenUtil().setSp(370),
      decoration: BoxDecoration(
        color: AppColors.viewLineColor,
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
    );
  }
}
