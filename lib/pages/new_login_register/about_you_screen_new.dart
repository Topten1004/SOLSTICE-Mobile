import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:solstice/pages/home/select_filters.dart';
import 'package:solstice/pages/humanBody/app_human_anatomy.dart';
import 'package:solstice/pages/search_location.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/my_navigator.dart';
import 'package:solstice/utils/shared_preferences.dart';

import '../../utils/constants.dart';

class AboutYouNewScreen extends StatefulWidget {
  bool isEdit;

  AboutYouNewScreen({this.isEdit});

  @override
  _AboutYouNewScreenState createState() => _AboutYouNewScreenState();
}

class _AboutYouNewScreenState extends State<AboutYouNewScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  String _currentAddress = "";
  LatLng currentLatLng;
  Position currentLocation;
  TextEditingController locationTextController = new TextEditingController();

  bool isActiveInjuriesPrivate = true;
  bool isPreviousInjuriesPrivate = true;
  String userIDPref = "";

  double selectedLatitude = 0.0;
  double selectedLongitude = 0.0;
  List<String> _bodyPartList = new List();
  List<String> _interestsStrList = new List();
  List<String> _sportsStrList = new List();
  List<String> _occupationStrList = new List();
  List<String> _activeInjuriesStrList = new List();
  List<String> _previousInjuriesStrList = new List();
  List<String> _certificationsStrList = new List();
  List<String> _coachesStrList = new List();
  String selectedInputField = "";

  @override
  void initState() {
    super.initState();

    if (widget.isEdit != null && widget.isEdit == true) {
      getUserDataFromDB();
    } else {
      getUserLocation();
    }
    getPrefData();
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

      locationTextController.text = _currentAddress;
    } catch (e) {
      print(e);
    }

    if (mounted) setState(() {});
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
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
            mainAxisAlignment: MainAxisAlignment.start,
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
                          ),
                        ),
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
                                "About You",
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
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(36),
                        right: ScreenUtil().setWidth(36),
                        bottom: ScreenUtil().setHeight(26)),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          lable("Goals/Interest"),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectedInputField = "interests";
                                selectItemsDropDown(
                                    "Select Goals/Interest", _interestsStrList);
                              });
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (_interestsStrList != null &&
                                          _interestsStrList.length > 0)
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: ScreenUtil().setSp(20),
                                              bottom: ScreenUtil().setSp(10),
                                              right: ScreenUtil().setSp(20)),
                                          child: Wrap(
                                            children: [
                                              for (int i = 0;
                                                  i < _interestsStrList.length;
                                                  i++)
                                                Container(
                                                    margin: EdgeInsets.all(2),
                                                    child: setTags(
                                                        _interestsStrList[i],
                                                        _interestsStrList))
                                            ],
                                          ),
                                        ),
                                      if (_interestsStrList == null ||
                                          _interestsStrList.length == 0)
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 18, bottom: 14),
                                          child: Text(
                                            "Select Goals/Interest",
                                            style: TextStyle(
                                                color: Color(0xFF727272),
                                                fontFamily:
                                                    Constants.regularFont,
                                                fontSize:
                                                    ScreenUtil().setSp(25)),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 14,
                                  height: 14,
                                  child: SvgPicture.asset(
                                    'assets/images/ic_down_arrow.svg',
                                    fit: BoxFit.contain,
                                    color: AppColors.accentColor,
                                  ),
                                ),
                                SizedBox(width: 14)
                              ],
                            ),
                          ),
                          Container(
                            height: 0.8,
                            color: AppColors.accentColor,
                          ),

                          /*InkWell(
                            onTap: (){
                              setState(() {
                                selectSportsActivities();
                              });
                            },
                            child: Row(

                              children: [

                                Expanded(
                                  flex: 1,
                                    child:  Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (_bodyPartList != null &&
                                            _bodyPartList.length > 0) Container(
                                          margin: EdgeInsets.only(top: ScreenUtil().setSp(20), bottom: ScreenUtil().setSp(10), right:ScreenUtil().setSp(20) ),
                                          child: Wrap(
                                            children: [
                                              for (int i = 0; i < _bodyPartList.length; i++)
                                                Container(
                                                    margin:
                                                    EdgeInsets.all(2),
                                                    child: setTags(_bodyPartList[i]))
                                            ],
                                          ),
                                        ),

                                        if (_bodyPartList == null ||
                                            _bodyPartList.length == 0)Container(
                                          padding: EdgeInsets.only(top: 18,bottom: 14),
                                          child: Text(
                                            "Select Sports/Activities",
                                            style: TextStyle(
                                                color: Color(0xFF727272),
                                                fontFamily: Constants.regularFont,
                                                fontSize: ScreenUtil().setSp(25)),
                                          ),
                                        ),
                                      ],
                                    ) ,
                                ),

                                Container(
                                  width: 16,
                                  height: 16,
                                  child: SvgPicture.asset(
                                    'assets/images/ic_down_arrow.svg',
                                    fit: BoxFit.contain,color: AppColors.accentColor,),
                                ),

                              ],
                            ),
                          ),
                          Container(
                            height: 0.8,
                            color: AppColors.accentColor,
                          ),*/
                          lable(Constants.location),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectLocation();
                              });
                            },
                            child: Container(
                              child: TextFormField(
                                enabled: false,
                                controller: locationTextController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: /*"Enter your "+Constants.location*/ "User Input",
                                  suffixIcon: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 13),
                                    width: 19,
                                    height: 19,
                                    child: SvgPicture.asset(
                                      'assets/images/ic_marker.svg',
                                      fit: BoxFit.contain,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  hintStyle: TextStyle(
                                      color: Color(0xFF727272),
                                      fontFamily: Constants.regularFont,
                                      fontSize: ScreenUtil().setSp(25)),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 0.8,
                            color: AppColors.accentColor,
                          ),
                          lable(Constants.sportActivity),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectedInputField = "sportActivities";
                                selectItemsDropDown(
                                    "Select Sport/Activity", _sportsStrList);
                              });
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (_sportsStrList != null &&
                                          _sportsStrList.length > 0)
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: ScreenUtil().setSp(20),
                                              bottom: ScreenUtil().setSp(10),
                                              right: ScreenUtil().setSp(20)),
                                          child: Wrap(
                                            children: [
                                              for (int i = 0;
                                                  i < _sportsStrList.length;
                                                  i++)
                                                Container(
                                                    margin: EdgeInsets.all(2),
                                                    child: setTags(
                                                        _sportsStrList[i],
                                                        _sportsStrList))
                                            ],
                                          ),
                                        ),
                                      if (_sportsStrList == null ||
                                          _sportsStrList.length == 0)
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 18, bottom: 14),
                                          child: Text(
                                            "Select Sport/Activity",
                                            style: TextStyle(
                                                color: Color(0xFF727272),
                                                fontFamily:
                                                    Constants.regularFont,
                                                fontSize:
                                                    ScreenUtil().setSp(25)),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 14,
                                  height: 14,
                                  child: SvgPicture.asset(
                                    'assets/images/ic_down_arrow.svg',
                                    fit: BoxFit.contain,
                                    color: AppColors.accentColor,
                                  ),
                                ),
                                SizedBox(width: 14)
                              ],
                            ),
                          ),
                          Container(
                            height: 0.8,
                            color: AppColors.accentColor,
                          ),
                          lable(Constants.occupation),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectedInputField = "occupation";
                                selectItemsDropDown(
                                    "Select Occupation", _occupationStrList);
                              });
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (_occupationStrList != null &&
                                          _occupationStrList.length > 0)
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: ScreenUtil().setSp(20),
                                              bottom: ScreenUtil().setSp(10),
                                              right: ScreenUtil().setSp(20)),
                                          child: Wrap(
                                            children: [
                                              for (int i = 0;
                                                  i < _occupationStrList.length;
                                                  i++)
                                                Container(
                                                    margin: EdgeInsets.all(2),
                                                    child: setTags(
                                                        _occupationStrList[i],
                                                        _occupationStrList))
                                            ],
                                          ),
                                        ),
                                      if (_occupationStrList == null ||
                                          _occupationStrList.length == 0)
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 18, bottom: 14),
                                          child: Text(
                                            "Select Occupation",
                                            style: TextStyle(
                                                color: Color(0xFF727272),
                                                fontFamily:
                                                    Constants.regularFont,
                                                fontSize:
                                                    ScreenUtil().setSp(25)),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 14,
                                  height: 14,
                                  child: SvgPicture.asset(
                                    'assets/images/ic_down_arrow.svg',
                                    fit: BoxFit.contain,
                                    color: AppColors.accentColor,
                                  ),
                                ),
                                SizedBox(width: 14)
                              ],
                            ),
                          ),
                          Container(
                            height: 0.8,
                            color: AppColors.accentColor,
                          ),
                          lable(Constants.activeInjuries),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectedInputField = "activeInjuries";
                                selectItemsDropDown("Select Active Injuries",
                                    _activeInjuriesStrList);
                              });
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (_activeInjuriesStrList != null &&
                                          _activeInjuriesStrList.length > 0)
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: ScreenUtil().setSp(20),
                                              bottom: ScreenUtil().setSp(10),
                                              right: ScreenUtil().setSp(20)),
                                          child: Wrap(
                                            children: [
                                              for (int i = 0;
                                                  i <
                                                      _activeInjuriesStrList
                                                          .length;
                                                  i++)
                                                Container(
                                                    margin: EdgeInsets.all(2),
                                                    child: setTags(
                                                        _activeInjuriesStrList[
                                                            i],
                                                        _activeInjuriesStrList))
                                            ],
                                          ),
                                        ),
                                      if (_activeInjuriesStrList == null ||
                                          _activeInjuriesStrList.length == 0)
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 18, bottom: 14),
                                          child: Text(
                                            "Select Active Injuries",
                                            style: TextStyle(
                                                color: Color(0xFF727272),
                                                fontFamily:
                                                    Constants.regularFont,
                                                fontSize:
                                                    ScreenUtil().setSp(25)),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    isActiveInjuriesPrivate =
                                        !isActiveInjuriesPrivate;
                                    setState(() {});
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        isActiveInjuriesPrivate
                                            ? "Private"
                                            : "Public",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0XFFFF8C21))),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 5.0),
                                  width: 14,
                                  height: 14,
                                  child: SvgPicture.asset(
                                    'assets/images/ic_down_arrow.svg',
                                    fit: BoxFit.contain,
                                    color: AppColors.accentColor,
                                  ),
                                ),
                                SizedBox(width: 14)
                              ],
                            ),
                          ),
                          Container(
                            height: 0.8,
                            color: AppColors.accentColor,
                          ),
                          lable(Constants.previousInjuries),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectedInputField = "previousInjuries";
                                selectItemsDropDown("Select Previous Injuries",
                                    _previousInjuriesStrList);
                              });
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (_previousInjuriesStrList != null &&
                                          _previousInjuriesStrList.length > 0)
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: ScreenUtil().setSp(20),
                                              bottom: ScreenUtil().setSp(10),
                                              right: ScreenUtil().setSp(20)),
                                          child: Wrap(
                                            children: [
                                              for (int i = 0;
                                                  i <
                                                      _previousInjuriesStrList
                                                          .length;
                                                  i++)
                                                Container(
                                                    margin: EdgeInsets.all(2),
                                                    child: setTags(
                                                        _previousInjuriesStrList[
                                                            i],
                                                        _previousInjuriesStrList))
                                            ],
                                          ),
                                        ),
                                      if (_previousInjuriesStrList == null ||
                                          _previousInjuriesStrList.length == 0)
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 18, bottom: 14),
                                          child: Text(
                                            "Select Previous Injuries",
                                            style: TextStyle(
                                                color: Color(0xFF727272),
                                                fontFamily:
                                                    Constants.regularFont,
                                                fontSize:
                                                    ScreenUtil().setSp(25)),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    isPreviousInjuriesPrivate =
                                        !isPreviousInjuriesPrivate;
                                    setState(() {});
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        isPreviousInjuriesPrivate
                                            ? "Private"
                                            : "Public",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0XFFFF8C21))),
                                  ),
                                ),
                                Container(
                                  width: 14,
                                  height: 14,
                                  child: SvgPicture.asset(
                                    'assets/images/ic_down_arrow.svg',
                                    fit: BoxFit.contain,
                                    color: AppColors.accentColor,
                                  ),
                                ),
                                SizedBox(width: 14)
                              ],
                            ),
                          ),
                          Container(
                            height: 0.8,
                            color: AppColors.accentColor,
                          ),
                          lable(Constants.achievementsCertifications),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectedInputField = "certifications";
                                selectItemsDropDown(
                                    "Select Achievements/Certifications",
                                    _certificationsStrList);
                              });
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (_certificationsStrList != null &&
                                          _certificationsStrList.length > 0)
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: ScreenUtil().setSp(20),
                                              bottom: ScreenUtil().setSp(10),
                                              right: ScreenUtil().setSp(20)),
                                          child: Wrap(
                                            children: [
                                              for (int i = 0;
                                                  i <
                                                      _certificationsStrList
                                                          .length;
                                                  i++)
                                                Container(
                                                    margin: EdgeInsets.all(2),
                                                    child: setTags(
                                                        _certificationsStrList[
                                                            i],
                                                        _certificationsStrList))
                                            ],
                                          ),
                                        ),
                                      if (_certificationsStrList == null ||
                                          _certificationsStrList.length == 0)
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 18, bottom: 14),
                                          child: Text(
                                            "Select Achievements/Certifications",
                                            style: TextStyle(
                                                color: Color(0xFF727272),
                                                fontFamily:
                                                    Constants.regularFont,
                                                fontSize:
                                                    ScreenUtil().setSp(25)),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 14,
                                  height: 14,
                                  child: SvgPicture.asset(
                                    'assets/images/ic_down_arrow.svg',
                                    fit: BoxFit.contain,
                                    color: AppColors.accentColor,
                                  ),
                                ),
                                SizedBox(width: 14)
                              ],
                            ),
                          ),
                          Container(
                            height: 0.8,
                            color: AppColors.accentColor,
                          ),
                          lable(Constants.coachesInstructors),
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectedInputField = "coaches";
                                selectItemsDropDown(
                                    "Select Coaches", _coachesStrList);
                              });
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (_coachesStrList != null &&
                                          _coachesStrList.length > 0)
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: ScreenUtil().setSp(20),
                                              bottom: ScreenUtil().setSp(10),
                                              right: ScreenUtil().setSp(20)),
                                          child: Wrap(
                                            children: [
                                              for (int i = 0;
                                                  i < _coachesStrList.length;
                                                  i++)
                                                Container(
                                                    margin: EdgeInsets.all(2),
                                                    child: setTags(
                                                        _coachesStrList[i],
                                                        _coachesStrList))
                                            ],
                                          ),
                                        ),
                                      if (_coachesStrList == null ||
                                          _coachesStrList.length == 0)
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 18, bottom: 14),
                                          child: Text(
                                            "Select Coaches",
                                            style: TextStyle(
                                                color: Color(0xFF727272),
                                                fontFamily:
                                                    Constants.regularFont,
                                                fontSize:
                                                    ScreenUtil().setSp(25)),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 14,
                                  height: 14,
                                  child: SvgPicture.asset(
                                    'assets/images/ic_down_arrow.svg',
                                    fit: BoxFit.contain,
                                    color: AppColors.accentColor,
                                  ),
                                ),
                                SizedBox(width: 14)
                              ],
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
                                      color: AppColors.primaryColor)),
                              onPressed: () {
                                setState(() {
                                  validate();
                                });
                              },
                              color: AppColors.primaryColor,
                              textColor: Colors.white,
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                Constants.submit,
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(28),
                                  fontFamily: Constants.semiBoldFont,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          if (widget.isEdit == null || widget.isEdit == false)
                            InkWell(
                              onTap: () {
                                setState(() {
                                  MyNavigator.goToHome(context);
                                });
                              },
                              child: Container(
                                height: 40,
                                child: Center(
                                  child: Text(
                                    "Skip for now",
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontFamily: Constants.mediumFont,
                                      fontSize: ScreenUtil().setSp(26),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(
                            height: 30,
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
    );
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
                fontFamily: Constants.boldFont,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

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
              locationTextController.text = _currentAddress;
            }
          } catch (e) {
          }
        }
      });
    }
  }

  Future selectSportsActivities() async {
    Map results = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return AppHumanAnatomy(bodyPartsListIntent: _bodyPartList);
    }));

    if (results != null && results.containsKey('update')) {
      var _isUpdate = "";

      setState(() {
        _isUpdate = results['update'];
        if (_isUpdate == "yes") {
          try {
            List<String> bodyPartsList = results['returnBodyPartList'];
            if (bodyPartsList != null && bodyPartsList.length > 0) {
              _bodyPartList = bodyPartsList;

              //sportsTextController.text = _bodyPartList.toString();
            }
            /*SearchedLocationModel searchedLocationModel = results['returnData'];
            if(searchedLocationModel != null){
              _currentAddress = searchedLocationModel.title;
              selectedLatitude = searchedLocationModel.latitude;
              selectedLongitude = searchedLocationModel.longitude;
              locationTextController.text = _currentAddress;

            }*/
          } catch (e) {
          }
        }
      });
    }
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

  // validate data on button click
  void validate() {
    FocusScope.of(context).unfocus();

    if (widget.isEdit != null && widget.isEdit == true) {
      Constants.showSnackBarWithMessage(
          "Profile updating...", _scaffoldkey, context, AppColors.primaryColor);
    } else {
      Constants.showSnackBarWithMessage(
          "Profile adding...", _scaffoldkey, context, AppColors.primaryColor);
    }

    Map<String, String> locationMap = {
      "address": _currentAddress.toString(),
      "lat": selectedLatitude.toString(),
      "long": selectedLongitude.toString(),
    };
    FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(userIDPref)
        .set({
          "interestArray": _interestsStrList,
          "sportsArray": _sportsStrList,
          "location": locationMap,
          'occupationArray': _occupationStrList,
          'activeInjuriesArray': _activeInjuriesStrList,
          'previousInjuriesArray': _previousInjuriesStrList,
          'isActiveInjuriesPublic': !isActiveInjuriesPrivate,
          'isPreviousInjuriesPublic': !isPreviousInjuriesPrivate,
          'achievementsArray': _certificationsStrList,
          'coachesArray': _coachesStrList,
          //"bodyParts": FieldValue.arrayUnion(_bodyPartList)
        }, SetOptions(merge: true))
        .then((docRef) {
          /*setState(() {
        _isShowLoader = false;
      });*/

          if (widget.isEdit != null && widget.isEdit == true) {
            Constants.showSnackBarWithMessage("Profile updated successfully!",
                _scaffoldkey, context, AppColors.greenColor);
            Navigator.of(context).pop();
          } else {
            Constants.showSnackBarWithMessage("Profile added successfully!",
                _scaffoldkey, context, AppColors.greenColor);

            MyNavigator.goToHome(context);
          }
        })
        .timeout(Duration(seconds: 10))
        .catchError((error) {
          /* setState(() {
        _isShowLoader = false;
      });*/
        });
  }

  Future selectItemsDropDown(
      String filterName, List<String> selectedList) async {
    Map results = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return SelectFilterScreen(
          filterType: selectedInputField,
          filterName: filterName,
          selectedItemList: selectedList);
    }));

    if (results != null && results.containsKey('update')) {
      var _isUpdate = "";

      setState(() {
        _isUpdate = results['update'];
        if (_isUpdate == "yes") {
          try {
            List<String> selectedList = results['returnList'];
            if (selectedList != null && selectedList.length > 0) {
              if (selectedInputField == "interests") {
                _interestsStrList = selectedList;
              } else if (selectedInputField == "sportActivities") {
                _sportsStrList = selectedList;
              } else if (selectedInputField == "occupation") {
                _occupationStrList = selectedList;
              } else if (selectedInputField == "activeInjuries") {
                _activeInjuriesStrList = selectedList;
              } else if (selectedInputField == "previousInjuries") {
                _previousInjuriesStrList = selectedList;
              } else if (selectedInputField == "certifications") {
                _certificationsStrList = selectedList;
              } else if (selectedInputField == "coaches") {
                _coachesStrList = selectedList;
              }
              //sportsTextController.text = _bodyPartStrList.toString();
            }
          } catch (e) {
          }
        }
      });
    }
  }

  setTags(bodyPartName, List<String> tagsList) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.0),
        color: AppColors.primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 6.0, bottom: 5, right: 7, left: 11),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              bodyPartName,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: Constants.regularFont,
                  fontSize: ScreenUtil().setSp(23)),
            ),
            SizedBox(
              width: 6,
            ),
            RotationTransition(
              turns: new AlwaysStoppedAnimation(45 / 360),
              child: InkWell(
                onTap: () {
                  // Navigator.of(context).pop();
                  setState(() {
                    if (tagsList.contains(bodyPartName)) {
                      tagsList.remove(bodyPartName);
                    }

                    /*if(selectedInputField == "interests"){
                      _interestsStrList = tagsList;
                    }else if(selectedInputField == "sportActivities"){
                      _sportsStrList = tagsList;
                    }else if(selectedInputField == "occupation"){
                      _occupationStrList = tagsList;
                    }else if(selectedInputField == "activeInjuries"){
                      _activeInjuriesStrList = tagsList;
                    }else if(selectedInputField == "previousInjuries"){
                      _previousInjuriesStrList = tagsList;
                    }else if(selectedInputField == "certifications"){
                      _certificationsStrList = tagsList;
                    }else if(selectedInputField == "coaches"){
                      _coachesStrList = tagsList;
                    }*/
                  });
                },
                child: Container(
                  width: 20,
                  height: 20,
                  padding: EdgeInsets.all(3),
                  child: SvgPicture.asset(
                    'assets/images/ic_plus.svg',
                    alignment: Alignment.center,
                    color: Colors.white,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> getUserDataFromDB() async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(globalUserId)
        .get();
    if (ds != null) {
      Map<String, dynamic> mapObject = ds.data();
      try {
        _interestsStrList = mapObject.containsKey("interestArray")
            ? mapObject['interestArray'].cast<String>()
            : List();
        _sportsStrList = mapObject.containsKey("sportsArray")
            ? mapObject['sportsArray'].cast<String>()
            : List();
        _occupationStrList = mapObject.containsKey("occupationArray")
            ? mapObject['occupationArray'].cast<String>()
            : List();
        _activeInjuriesStrList = mapObject.containsKey("activeInjuriesArray")
            ? mapObject['activeInjuriesArray'].cast<String>()
            : List();
        _previousInjuriesStrList =
            mapObject.containsKey("previousInjuriesArray")
                ? mapObject['previousInjuriesArray'].cast<String>()
                : List();
        _certificationsStrList = mapObject.containsKey("achievementsArray")
            ? mapObject['achievementsArray'].cast<String>()
            : List();
        _coachesStrList = mapObject.containsKey("coachesArray")
            ? mapObject['coachesArray'].cast<String>()
            : List();

        isActiveInjuriesPrivate =
            mapObject.containsKey("isActiveInjuriesPublic")
                ? !mapObject["isActiveInjuriesPublic"]
                : true;
        isPreviousInjuriesPrivate =
            mapObject.containsKey("isPreviousInjuriesPublic")
                ? !mapObject["isPreviousInjuriesPublic"]
                : true;

        /*if (mapObject.containsKey("interest")) {
          interestsTextController.text = ds['interest'];
        }
        if (mapObject.containsKey("sports")) {
          sportsActivityController.text = ds['sports'];
        }
        if (mapObject.containsKey("occupation")) {
          occupationController.text = ds['occupation'];
        }
        if (mapObject.containsKey("activeInjuries")) {
          activeInjuriesController.text = ds['activeInjuries'];
        }
        if (mapObject.containsKey("previousInjuries")) {
          previousInjuriesController.text = ds['previousInjuries'];
        }
        if (mapObject.containsKey("achievements")) {
          certificationsController.text = ds['achievements'];
        }
        if (mapObject.containsKey("coaches")) {
          coachesController.text = ds['coaches'];
        }*/

        if (mapObject.containsKey("location")) {
          _currentAddress = ds['location']['address'];
          String latitude = ds['location']['lat'];
          String longitude = ds['location']['long'];

          try {
            selectedLatitude = double.parse(latitude);
            selectedLongitude = double.parse(longitude);
          } catch (e) {}
          locationTextController.text = _currentAddress;
        }
      } catch (e) {}

      if (mounted) setState(() {});
    }
  }
}

class Suggestions {
  String title;

  Suggestions(this.title);
}
