import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solstice/model/groups/groups_model.dart';
import 'package:solstice/model/tabs_models.dart';
import 'package:solstice/pages/chat/chat_users_history_screen.dart';
import 'package:solstice/pages/groups/group_details_screen.dart';
import 'package:solstice/pages/home/search_filter.dart';
import 'package:solstice/pages/views/group_list_fb_item.dart';
import 'package:solstice/pages/views/tab_list_item.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/dialog_callback.dart';
import 'package:solstice/utils/shared_preferences.dart';
import 'package:solstice/utils/utilities.dart';

class GroupsTabScreen extends StatefulWidget {
  @override
  _GroupsTabScreenState createState() => _GroupsTabScreenState();
}

class _GroupsTabScreenState extends State<GroupsTabScreen>
    with AutomaticKeepAliveClientMixin
    implements DialogCallBack {
  @override
  bool get wantKeepAlive => true;

  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  TextEditingController groupTitleController = new TextEditingController();
  TextEditingController groupDescriptionController = new TextEditingController();
  TextEditingController aboutGroupController = new TextEditingController();
  final FocusNode _groupTitleFocus = new FocusNode();
  final FocusNode _groupDescriptionFocus = new FocusNode();
  final FocusNode _aboutGroupFocus = new FocusNode();
  var imageFile = null;
  String _selectedImageUrl = "", imageUrl = "";
  bool isEditMode = false;
  String _currentAddress = "";
  LatLng currentLatLng;
  Position currentLocation;

  String userIDPref = "";
  final ScrollController listScrollController = ScrollController();
  final ScrollController listScrollControllerPublicGroup = ScrollController();
  //List<QueryDocumentSnapshot> listMessage = new List.from([]);
  int _limitPrivate = 10;
  int _limitPublic = 10;
  int _limitIncrement = 10;
  bool isPublic = true;
  String privacyType = "Public";

  var selectedTab = "Private Groups";
  List<TabsModel> GroupsTabsList = new List<TabsModel>();
  List<String> postIdsList = new List<String>();

  String groupId = "";
  var state1;
  @override
  void initState() {
    super.initState();
    listScrollController.addListener(_scrollListenerPrivate);
    listScrollControllerPublicGroup.addListener(_scrollListenerPublic);
    // set tabs
    setDefaultList();
    getPrefData();
    getUserLocation();
  }

  // set tabs
  void setDefaultList() {
    GroupsTabsList.add(new TabsModel("Private Groups", true));
    GroupsTabsList.add(new TabsModel("Public Groups", false));
  }

  // initialize private listing scroll listner
  _scrollListenerPrivate() {
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limitPrivate += _limitIncrement;
      });
    }
  }

  // initialize Public listing scroll listner
  _scrollListenerPublic() {
    if (listScrollControllerPublicGroup.offset >=
            listScrollControllerPublicGroup.position.maxScrollExtent &&
        !listScrollControllerPublicGroup.position.outOfRange) {
      setState(() {
        _limitPublic += _limitIncrement;

      });
    }
  }

  // Get data from local Storage(SharedPref)
  getPrefData() {
    Future<String> userId = SharedPref.getStringFromPrefs(Constants.USER_ID);
    userId.then(
        (value) => {
              userIDPref = value,
            }, onError: (err) {
    });

    if (mounted) setState(() {});
  }

  // get user current location
  getUserLocation() async {

    currentLocation = await locateUser();
    currentLatLng = LatLng(currentLocation.latitude, currentLocation.longitude);
    //globals.currentLatLng = currentLatLng;
    try {
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
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            InkWell(
                              child: Text(
                                Constants.group,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: ScreenUtil().setSp(42),
                                    fontFamily: Constants.boldFont),
                              ),
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
                                  child: globalUserUnSeenChats != null && globalUserUnSeenChats > 0
                                      ? Container(
                                          padding:
                                              EdgeInsets.only(top: 2, bottom: 2, right: 7, left: 7),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12.0),
                                            color: AppColors.primaryColor,
                                          ),
                                          child: Text(
                                            globalUserUnSeenChats > 99
                                                ? "99+"
                                                : globalUserUnSeenChats.toString(),
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
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (BuildContext context) {
                              return ChatUsersHistoryScreen();
                            }));
                          }),
                      InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (BuildContext context) {
                            return SearchFilter(screenType: 'Group');
                          }));
                        },
                        child: Container(
                          width: 26,
                          height: 26,
                          padding: EdgeInsets.all(2.5),
                          margin: EdgeInsets.only(right: 5, left: 5),
                          child: SvgPicture.asset(
                            'assets/images/ic_search.svg',
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // InkWell(
                      //   onTap: () {
                      //     Navigator.of(context).push(
                      //       MaterialPageRoute(
                      //         builder: (BuildContext context) {
                      //           return FilterGroups();
                      //         },
                      //       ),
                      //     );
                      //   },
                      //   child: Container(
                      //     width: 23,
                      //     height: 23,
                      //     padding: EdgeInsets.all(2.5),
                      //     margin: EdgeInsets.only(right: 5),
                      //     child: SvgPicture.asset(
                      //       'assets/images/ic_filter.svg',
                      //       alignment: Alignment.center,
                      //       fit: BoxFit.contain,
                      //     ),
                      //   ),
                      // ),

                      InkWell(
                        onTap: () {
                          _createGroupBottomSheet(context);
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
              Container(
                margin:
                    EdgeInsets.only(left: ScreenUtil().setSp(36), bottom: ScreenUtil().setSp(16)),
                height: ScreenUtil().setSp(54),
                child: ListView.builder(
                  itemCount: GroupsTabsList == null ? 0 : GroupsTabsList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return new InkWell(
                      //highlightColor: Colors.red,
                      splashColor: AppColors.primaryColor,
                      onTap: () {
                        setState(() {
                          GroupsTabsList.forEach((element) => element.isSelected = false);
                          GroupsTabsList[index].isSelected = true;
                          selectedTab = GroupsTabsList[index].tabTitle;
                          //selectedLevel = levelDataList[index].type;
                        });
                      },
                      child: new TabListItem(GroupsTabsList[index]),
                    );
                  },
                ),
              ),
              Visibility(
                visible: selectedTab == "Private Groups" ? true : false,
                child: privateGroupListing(),
              ),
              Visibility(
                visible: selectedTab == "Private Groups" ? false : true,
                child: publicGroupListing(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void deleteGroup(setState, id) {
    FirebaseFirestore.instance.collection(Constants.groupsFB).doc(id).delete();
    setState(() {});
  }

  // private group listing
  Widget privateGroupListing() {
    return Flexible(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(Constants.groupsFB)
            //.where('created_by', isEqualTo: globalUserId)
            .orderBy('created_at', descending: true)
            .where('admins', arrayContains: globalUserId)
            .where("is_public", isEqualTo: false)
            .limit(_limitPrivate)
            .snapshots(),
        /*Firestore.instance
                      .collection(Constants.groupsFB)
                      .orderBy('created_at', descending: true)
                      //.where('users', arrayContains: globalUserId)
                      .limit(_limitAll)
                      .snapshots(),*/
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor)),
            );
          } else {
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
                            GroupsFireBaseModel message =
                                GroupsFireBaseModel.fromSnapshot(rev[index]);
                            return InkWell(
                                onTap: () {
                                  setState(() {
                                    _OnGoToGroupDetail(message.id);
                                  });
                                },
                                child: Slidable(
                                  actionPane: SlidableDrawerActionPane(),
                                  actionExtentRatio: 0.25,
                                  actions: [
                                    if (message.createdBy == globalUserId)
                                      Container(
                                        margin: EdgeInsets.only(bottom: 10, top: 10.0),
                                        child: IconSlideAction(
                                            caption: 'Edit',
                                            color: Colors.blue,
                                            icon: Icons.delete,
                                            onTap: () => {
                                                  isEditMode = true,
                                                  groupTitleController.text = message.title,
                                                  groupDescriptionController.text =
                                                      message.description,
                                                  imageUrl = message.image,
                                                  isPublic = message.isPublic,
                                                  privacyType = isPublic ? 'Public' : 'Private',
                                                  groupId = message.id,
                                                  _createGroupBottomSheet(context),
                                                }),
                                      ),
                                  ],
                                  secondaryActions: <Widget>[
                                    if (message.createdBy == globalUserId)
                                      IconSlideAction(
                                        caption: 'Delete',
                                        color: Colors.red,
                                        icon: Icons.delete,
                                        onTap: () => {
                                          groupId = message.id,
                                          state1 = setState,
                                          Utilities.confirmDeleteDialog(
                                              context,
                                              Constants.deleteGroup,
                                              Constants.deleteGroupConfirmDes,
                                              this,
                                              1),
                                        },
                                      ),
                                  ],
                                  child: GroupFbItem(
                                      key: ValueKey(message.id),
                                      groupItem: message,
                                      appUserId: userIDPref,
                                      index: index),
                                ));
                          },
                          itemCount: snapshot.data.docs.length,
                          //controller: listScrollController,
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Container(
                      child: Text(
                        Constants.noDataFound.toString(),
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(26),
                            fontFamily: Constants.regularFont,
                            height: 1.3,
                            letterSpacing: 0.8),
                      ),
                    ),
                  );
          }
        },
      ),
    );
  }

  // public group listing prcess
  Widget publicGroupListing() {
    return Flexible(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(Constants.groupsFB)
            //.where('created_by', isEqualTo: globalUserId)
            .orderBy('created_at', descending: true)
            .where("is_public", isEqualTo: true)
            .limit(_limitPublic)
            .snapshots(),
        /*Firestore.instance
                      .collection(Constants.groupsFB)
                      .orderBy('created_at', descending: true)
                      //.where('users', arrayContains: globalUserId)
                      .limit(_limitAll)
                      .snapshots(),*/
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor)),
            );
          } else {
            return snapshot.data.docs.isNotEmpty
                ? ListView(
                    padding: EdgeInsets.zero,
                    controller: listScrollControllerPublicGroup,
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
                            GroupsFireBaseModel message =
                                GroupsFireBaseModel.fromSnapshot(rev[index]);
                            return InkWell(
                                onTap: () {
                                  setState(() {
                                    _OnGoToGroupDetail(message.id);
                                  });
                                },
                                child: Slidable(
                                  actionPane: SlidableDrawerActionPane(),
                                  actionExtentRatio: 0.25,
                                  actions: [
                                    if (message.createdBy == globalUserId)
                                      Container(
                                        margin: EdgeInsets.only(bottom: 10, top: 10.0),
                                        child: IconSlideAction(
                                            caption: 'Edit',
                                            color: Colors.blue,
                                            icon: Icons.delete,
                                            onTap: () => {
                                                  isEditMode = true,
                                                  groupTitleController.text = message.title,
                                                  groupDescriptionController.text =
                                                      message.description,
                                                  imageUrl = message.image,
                                                  isPublic = message.isPublic,
                                                  privacyType = isPublic ? 'Public' : 'Private',
                                                  groupId = message.id,
                                                  _createGroupBottomSheet(context),
                                                }),
                                      ),
                                  ],
                                  secondaryActions: <Widget>[
                                    if (message.createdBy == globalUserId)
                                      IconSlideAction(
                                        caption: 'Delete',
                                        color: Colors.red,
                                        icon: Icons.delete,
                                        onTap: () => {
                                          groupId = message.id,
                                          state1 = setState,
                                          Utilities.confirmDeleteDialog(
                                              context,
                                              Constants.deleteGroup,
                                              Constants.deleteGroupConfirmDes,
                                              this,
                                              1),
                                        },
                                      ),
                                  ],
                                  child: GroupFbItem(
                                      key: ValueKey(message.id),
                                      groupItem: message,
                                      appUserId: userIDPref,
                                      index: index),
                                ));
                          },
                          itemCount: snapshot.data.docs.length,
                          //controller: listScrollController,
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Container(
                      child: Text(
                        Constants.noDataFound.toString(),
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(26),
                            fontFamily: Constants.regularFont,
                            height: 1.3,
                            letterSpacing: 0.8),
                      ),
                    ),
                  );
          }
        },
      ),
    );
  }

  // on Group item tap open group detail page
  Future _OnGoToGroupDetail(String groupId) async {
    Map results =
        await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
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

  // create group bottom sheet
  void _createGroupBottomSheet(BuildContext context) {
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
                                      isEditMode ? 'Edit Group' : Constants.createGroup,
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
                                      FocusScope.of(context).unfocus();

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
                                            File(imageFile.path),
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
                                      FocusScope.of(context).unfocus();

                                      _settingModalBottomSheet(context, setState);
                                    },
                                    child: Container(
                                      width: 80,
                                      height: 75,
                                      child: imageUrl.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              imageBuilder: (context, imageProvider) => Container(
                                                width: ScreenUtil().setSp(120),
                                                height: ScreenUtil().setSp(120),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(Radius.circular(12.0)),
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
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
                                      if (imageFile == null) {
                                        if (isEditMode) {
                                          addGroupToDb(imageUrl, title, description, aboutGroup);
                                          Navigator.of(context).pop();
                                        } else {
                                          Constants().errorToast(context, Constants.imageFileError);
                                        }
                                      } else {
                                        uploadGroupImage(title, description, aboutGroup);
                                        Navigator.of(context).pop();
                                      }
                                    }
                                  });
                                },
                                color: AppColors.primaryColor,
                                textColor: Colors.white,
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  isEditMode ? 'Update Group' : Constants.continueTxt,
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

  // upload image to firebase storage
  Future<void> uploadGroupImage(String title, String description, String aboutGroup) async {
    Constants.showSnackBarWithMessage(
        "Group image uploading...", _scaffoldkey, context, AppColors.primaryColor);

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var reference = FirebaseStorage.instance.ref().child("groupImages").child(fileName);
    UploadTask uploadTask = reference.putFile(File(imageFile.path));

    uploadTask.whenComplete(() {
      reference.getDownloadURL().then((downloadUrl) {
        _selectedImageUrl = downloadUrl;
        setState(() {
          addGroupToDb(_selectedImageUrl, title, description, aboutGroup);
        });
      });
    }).catchError((onError) {
    }).onError((error, stackTrace) {
      setState(() {
        //_showLoading = false;
      });
      Constants.showSnackBarWithMessage(
          "This file is not an image", _scaffoldkey, context, Colors.red[700]);
    });
  }

  // After all. store Group to firestore db
  void addGroupToDb(String groupImageUrl, String title, String description, String aboutGroup) {
    //_isShowLoader = true;
    groupTitleController.text = "";
    groupDescriptionController.text = "";
    aboutGroupController.text = "";
    imageFile = null;
    _selectedImageUrl = "";

    Constants.showSnackBarWithMessage(
        "Group uploading...", _scaffoldkey, context, AppColors.primaryColor);

    List<String> userList = new List<String>();
    userList.add(userIDPref);

    Map<String, String> locationMap = {
      "address": _currentAddress.toString(),
      "lat": currentLatLng.latitude.toString(),
      "long": currentLatLng.longitude.toString(),
    };
    if (isEditMode) {
      FirebaseFirestore.instance
          .collection(Constants.groupsFB)
          .doc(groupId)
          .update({
            "title": title,
            "description": description,
            "about_group": aboutGroup,
            "image": groupImageUrl,
            "location": locationMap,
            "is_public": isPublic,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
            'created_by': userIDPref,
            'admins': userList,
            'users': userList,
            'post_ids': postIdsList,
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
    } else {
      FirebaseFirestore.instance
          .collection(Constants.groupsFB)
          .add({
            "title": title,
            "description": description,
            "about_group": aboutGroup,
            "image": groupImageUrl,
            "location": locationMap,
            "is_public": isPublic,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
            'created_by': userIDPref,
            'admins': userList,
            'users': userList,
            'post_ids': postIdsList,
          })
          .then((docRef) {
            Constants.showSnackBarWithMessage(
                "Group added successfully!", _scaffoldkey, context, AppColors.greenColor);
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
  }

  // Select image bottom sheet
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
      updated(state, imageFile);
    } else {
    }
  }

  Future<Null> updated(StateSetter updateState, imageFile) async {
    updateState(() {});
  }

  @override
  void onOkClick(int code) {
    deleteGroup(state1, groupId);
  }
}
