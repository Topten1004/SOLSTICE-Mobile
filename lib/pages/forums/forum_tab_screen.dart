import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/forum_model.dart';
import 'package:solstice/pages/chat/chat_users_history_screen.dart';
import 'package:solstice/pages/forums/forums_details_screen.dart';
import 'package:solstice/pages/home/search_filter.dart';
import 'package:solstice/pages/search_location.dart';
import 'package:solstice/pages/views/forum_list_fb_item.dart';
import 'package:solstice/pages/views/forum_list_item.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/dialog_callback.dart';
import 'package:solstice/utils/my_navigator.dart';
import 'package:solstice/utils/globals.dart' as globals;
import 'package:geocoding/geocoding.dart';
import 'package:solstice/utils/shared_preferences.dart';
import 'package:solstice/utils/size_utils.dart';
import 'package:solstice/utils/utilities.dart';

class ForumsTabScreen extends StatefulWidget {
  @override
  _ForumsTabScreenState createState() => _ForumsTabScreenState();
}

class _ForumsTabScreenState extends State<ForumsTabScreen>
    with AutomaticKeepAliveClientMixin
    implements DialogCallBack {
  @override
  bool get wantKeepAlive => true;

  String tokenPref = "";
  bool _isShowLoader = false;
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  TextEditingController formTitleController = new TextEditingController();
  TextEditingController formDescriptionController = new TextEditingController();
  final FocusNode _formTitleFocus = new FocusNode();
  final FocusNode _formDescriptionFocus = new FocusNode();
  String _currentAddress;

  LatLng currentLatLng;
  Position currentLocation;
  String userIDPref = "";
  String userNamePref = "";
  String userImagePref = "";

  final ScrollController listScrollController = ScrollController();
  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  int _limit = 10;
  int _limitIncrement = 10;
  double selectedLatitude = 0.0;
  double selectedLongitude = 0.0;
  bool isPublic = true;
  String postType = "Public";
  String forumId;
  var state;
  bool isEditMode = false;
  @override
  void initState() {
    super.initState();
    //setDefaultList();
    listScrollController.addListener(_scrollListener);
    /*_isShowLoader = true;
    Future.delayed(const Duration(milliseconds: 1100), () {
      setState(() {
        _isShowLoader = false;
      });
    });*/
    // get user data from local storage(SharedPref)
    getPrefData();
    // get user current location
    getUserLocation();
  }

  // get user data from local storage(SharedPref)
  getPrefData() {
    Future<String> userId = SharedPref.getStringFromPrefs(Constants.USER_ID);
    userId.then(
        (value) => {
              userIDPref = value,
            }, onError: (err) {
    });

    Future<String> userName =
        SharedPref.getStringFromPrefs(Constants.USER_NAME);
    userName.then(
        (value) => {
              userNamePref = value,
            },
        onError: (err) {});
    Future<String> userImage =
        SharedPref.getStringFromPrefs(Constants.PROFILE_IMAGE);
    userImage.then(
        (value) => {
              userImagePref = value,
            },
        onError: (err) {});

    if (mounted) setState(() {});
  }

  // for initilize Scroll Listner
  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
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

  _getAddressFromLatLng() async {}
  deleteForum(setState, id) {
    FirebaseFirestore.instance
        .collection(Constants.forumsCollection)
        .doc(id)
        .delete();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
      key: _scaffoldkey,
      body: ModalProgressHUD(
        inAsyncCall: _isShowLoader,
        // demo of some additional parameters
        opacity: 0.4,
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        ),
        child: Stack(
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
                          child: Container(
                            child: Text(
                              Constants.forum,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: ScreenUtil().setSp(42),
                                  fontFamily: Constants.boldFont),
                            ),
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
                              return SearchFilter(screenType: 'Forum');
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
                        InkWell(
                          onTap: () {
                            //_createFormBottomSheet();
                            _createForumBottomSheet(context);
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
                Flexible(
                    child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(Constants.ForumsFB)
                      .orderBy('timestamp', descending: true)
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
                      listMessage.clear();
                      listMessage.addAll(snapshot.data.docs);
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
                                      ForumFireBaseModel message =
                                          ForumFireBaseModel.fromSnapshot(
                                              rev[index]);
                                      return InkWell(
                                          onTap: () {
                                            setState(() {
                                              _OnGoToForumDetail(message);
                                            });
                                          },
                                          child: Slidable(
                                            actionPane:
                                                SlidableDrawerActionPane(),
                                            actionExtentRatio: 0.25,
                                            actions: [
                                              if (message.createdBy ==
                                                  globalUserId)
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: 10, top: 10.0),
                                                  child: IconSlideAction(
                                                      caption: 'Edit',
                                                      color: Colors.blue,
                                                      icon: Icons.delete,
                                                      onTap: () => {
                                                            isEditMode = true,
                                                            formTitleController
                                                                    .text =
                                                                message.title,
                                                            formDescriptionController
                                                                    .text =
                                                                message
                                                                    .description,
                                                                    _currentAddress = message.postAddress,
                                                            forumId =
                                                                message.id,
                                                            _createForumBottomSheet(
                                                                context)
                                                          }),
                                                ),
                                            ],
                                            secondaryActions: <Widget>[
                                              if (message.createdBy ==
                                                  globalUserId)
                                                IconSlideAction(
                                                  caption: 'Delete',
                                                  color: Colors.red,
                                                  icon: Icons.delete,
                                                  onTap: () => {
                                                    forumId = message.id,
                                                    state = setState,
                                                    Utilities.confirmDeleteDialog(
                                                        context,
                                                        Constants.deleteForum,
                                                        Constants
                                                            .deleteForumConfirmDes,
                                                        this,
                                                        1),
                                                  },
                                                ),
                                            ],
                                            child: ForumFbItem(
                                                key: ValueKey(message.id),
                                                forumItem: message,
                                                appUserId: userIDPref),
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
                    if (!snapshot.hasData) {
                      return Center(
                        child: Container(
                            /*child: Text(
                                Constants.noDataFound.toString(),style: TextStyle(
                                  fontSize: ScreenUtil().setSp(26),
                                  fontFamily: Constants.regularFont,
                                  height: 1.3,
                                  letterSpacing: 0.8),
                              ),*/
                            ),
                      );
                    } else {
                      listMessage.clear();
                      listMessage.addAll(snapshot.data.docs);
                      //updateChatCount();
                      return ListView(
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
                                ForumFireBaseModel message =
                                    ForumFireBaseModel.fromSnapshot(rev[index]);
                                return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _OnGoToForumDetail(message);
                                      });
                                    },
                                    child: ForumFbItem(
                                        key: ValueKey(message.id),
                                        forumItem: message,
                                        appUserId: userIDPref));
                              },
                              itemCount: snapshot.data.docs.length,
                              //controller: listScrollController,
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ))
              ],
            ),
          ],
        ),
      ),
    );
  }

  // on click Forum open detail page
  Future _OnGoToForumDetail(ForumFireBaseModel forumItem) async {
    Map results = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return ForumsDetailsScreen(forumIdIntent: forumItem.id);
    }));

    if (results != null && results.containsKey('update')) {
      var _isUpdate = "";
      setState(() {});
    }
  }

  // create forum bottom sheet
  void _createForumBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
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
                              //var title = formTitleController.value.text.trim();
                              var title = "";
                              var description =
                                  formDescriptionController.value.text.trim();
                              /*if (title.isEmpty) {
                                Constants().errorToast(
                                    context, Constants.enterNameError);
                              } else*/
                              if (description.isEmpty) {
                                Constants().errorToast(
                                    context, Constants.enterDescriptionError);
                              } /*else if (title.length < 4) {
                                Constants().errorToast(
                                    context, Constants.nameMust4Characters);
                              }*/
                              else if (description.length < 4) {
                                Constants().errorToast(
                                    context, Constants.gDesMust4Characters);
                              } else {
                                Navigator.of(context).pop();
                                addForumToDb(title, description);
                              }

                              if (mounted) {
                                setState(() {});
                              }
                            },
                            color: AppColors.primaryColor,
                            textColor: Colors.white,
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              isEditMode
                                  ? 'Update Forum'
                                  : Constants.continueTxt,
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
  void addForumToDb(String title, String description) {
    //_isShowLoader = true;
    formTitleController.text = "";
    formDescriptionController.text = "";
    if (isEditMode) {
      FirebaseFirestore.instance
          .collection(Constants.ForumsFB)
          .doc(forumId)
          .update({
            "title": title,
            "description": description,
            "postLatitude": selectedLatitude.toString(),
            "postLongitude": selectedLongitude.toString(),
            "postAddress": _currentAddress.toString(),
            "is_public": isPublic,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'createdBy': userIDPref,
            'createdByName': userNamePref,
            'createdByImage': userImagePref,
          })
          .then((docRef) {
            Constants.showSnackBarWithMessage("Forum updated successfully!",
                _scaffoldkey, context, AppColors.greenColor);
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
          .collection(Constants.ForumsFB)
          .add({
            "title": title,
            "description": description,
            "postLatitude": selectedLatitude.toString(),
            "postLongitude": selectedLongitude.toString(),
            "postAddress": _currentAddress.toString(),
            "is_public": isPublic,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'createdBy': userIDPref,
            'createdByName': userNamePref,
            'createdByImage': userImagePref,
          })
          .then((docRef) {
            Constants.showSnackBarWithMessage("Forum added successfully!",
                _scaffoldkey, context, AppColors.greenColor);
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

  @override
  void onOkClick(int code) {
    deleteForum(state, forumId);
  }
}
