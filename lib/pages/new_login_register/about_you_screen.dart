import 'dart:convert';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:solstice/pages/humanBody/app_human_anatomy.dart';
import 'package:solstice/pages/search_location.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/my_navigator.dart';
import 'package:solstice/utils/shared_preferences.dart';

import '../../utils/constants.dart';

class AboutYouScreen extends StatefulWidget {
  bool isEdit;

  AboutYouScreen({this.isEdit});

  @override
  _AboutYouScreenState createState() => _AboutYouScreenState();
}

class _AboutYouScreenState extends State<AboutYouScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  String _currentAddress = "";
  LatLng currentLatLng;
  Position currentLocation;

  TextEditingController interestsTextController = new TextEditingController();
  GlobalKey<AutoCompleteTextFieldState<Suggestions>> keyInterests =
      new GlobalKey();
  List<Suggestions> interestsList = new List<Suggestions>();

  TextEditingController locationTextController = new TextEditingController();

  TextEditingController sportsActivityController = new TextEditingController();
  GlobalKey<AutoCompleteTextFieldState<Suggestions>> sportsActivityKey =
      new GlobalKey();
  List<Suggestions> sportsActivityList = new List<Suggestions>();

  TextEditingController occupationController = new TextEditingController();
  GlobalKey<AutoCompleteTextFieldState<Suggestions>> occupationKey =
      new GlobalKey();
  List<Suggestions> occupationList = new List<Suggestions>();

  TextEditingController activeInjuriesController = new TextEditingController();
  GlobalKey<AutoCompleteTextFieldState<Suggestions>> activeInjuriesKey =
      new GlobalKey();
  List<Suggestions> activeInjuriesList = new List<Suggestions>();

  TextEditingController previousInjuriesController =
      new TextEditingController();
  GlobalKey<AutoCompleteTextFieldState<Suggestions>> previousInjuriesKey =
      new GlobalKey();
  List<Suggestions> previousInjuriesList = new List<Suggestions>();

  TextEditingController certificationsController = new TextEditingController();
  GlobalKey<AutoCompleteTextFieldState<Suggestions>> certificationsKey =
      new GlobalKey();
  List<Suggestions> certificationsList = new List<Suggestions>();

  TextEditingController coachesController = new TextEditingController();
  GlobalKey<AutoCompleteTextFieldState<Suggestions>> coachesKey =
      new GlobalKey();
  List<Suggestions> coachesList = new List<Suggestions>();

  bool isActiveInjuriesPrivate = true;
  bool isPreviousInjuriesPrivate = true;
  String userIDPref = "";

  double selectedLatitude = 0.0;
  double selectedLongitude = 0.0;

  List<String> _bodyPartList = new List();

  void getUsers() async {
    // get interests hints list from firestore db
    try {
      CollectionReference reference =
          FirebaseFirestore.instance.collection("Interests");
      reference.snapshots().listen((querySnapshot) {
        interestsList.clear();
        querySnapshot.docChanges.forEach((change) {
          Map<String, dynamic> mapObject = change.doc.data();
          // Do something with change
          interestsList.add(new Suggestions(mapObject['title'].toString()));
          setState(() {});
        });
      });
    } catch (e) {
    }

    // get Sports Activities hints list from firestore db
    try {
      CollectionReference reference =
          FirebaseFirestore.instance.collection("SportsActivities");
      reference.snapshots().listen((querySnapshot) {
        sportsActivityList.clear();
        querySnapshot.docChanges.forEach((change) {
          Map<String, dynamic> mapObject = change.doc.data();
          // Do something with change
          sportsActivityList
              .add(new Suggestions(mapObject['title'].toString()));
          setState(() {});
        });
      });
    } catch (e) {
    }

    // get Occupation hints list from firestore db
    try {
      CollectionReference reference =
          FirebaseFirestore.instance.collection("Occupation");
      reference.snapshots().listen((querySnapshot) {
        occupationList.clear();
        querySnapshot.docChanges.forEach((change) {
          Map<String, dynamic> mapObject = change.doc.data();
          // Do something with change
          occupationList.add(new Suggestions(mapObject['title'].toString()));
          setState(() {});
        });
      });
    } catch (e) {
    }

    // get Active Injuries list from firestore db
    try {
      CollectionReference reference =
          FirebaseFirestore.instance.collection("ActiveInjuries");
      reference.snapshots().listen((querySnapshot) {
        activeInjuriesList.clear();
        querySnapshot.docChanges.forEach((change) {
          // Do something with change
          Map<String, dynamic> mapObject = change.doc.data();
          activeInjuriesList
              .add(new Suggestions(mapObject['title'].toString()));
          setState(() {});
        });
      });
    } catch (e) {
    }

    // get Previous Injuries list from firestore db
    try {
      CollectionReference reference =
          FirebaseFirestore.instance.collection("PreviousInjuries");
      reference.snapshots().listen((querySnapshot) {
        previousInjuriesList.clear();
        querySnapshot.docChanges.forEach((change) {
          Map<String, dynamic> mapObject = change.doc.data();
          // Do something with change
          previousInjuriesList
              .add(new Suggestions(mapObject['title'].toString()));
          setState(() {});
        });
      });
    } catch (e) {
    }

    // get Certifications list from firestore db
    try {
      CollectionReference reference =
          FirebaseFirestore.instance.collection("/Certifications");
      reference.snapshots().listen((querySnapshot) {
        certificationsList.clear();
        querySnapshot.docChanges.forEach((change) {
          // Do something with change
          Map<String, dynamic> mapObject = change.doc.data();
          certificationsList
              .add(new Suggestions(mapObject['title'].toString()));
          setState(() {});
        });
      });
    } catch (e) {
    }

    // get Coaches list from firestore db
    try {
      CollectionReference reference =
          FirebaseFirestore.instance.collection("Coaches");
      reference.snapshots().listen((querySnapshot) {
        coachesList.clear();
        querySnapshot.docChanges.forEach((change) {
          Map<String, dynamic> mapObject = change.doc.data();
          // Do something with change
          coachesList.add(new Suggestions(mapObject['title'].toString()));
          setState(() {});
        });
      });
    } catch (e) {
    }
  }

  @override
  void initState() {
    getUsers();
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
                          Container(
                            height: 50,
                            child: AutoCompleteTextField<Suggestions>(
                              key: keyInterests,
                              controller: interestsTextController,
                              clearOnSubmit: false,
                              suggestions: interestsList,
                              style: TextStyle(
                                  color: Colors.black, fontSize: 16.0),
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(0.0, 30.0, 10.0, 20.0),
                                hintText: "User Input",
                                hintStyle: TextStyle(
                                    color: Color(0xFF727272),
                                    fontFamily: Constants.regularFont,
                                    fontSize: ScreenUtil().setSp(25)),
                              ),
                              itemFilter: (item, query) {
                                return item.title
                                    .toLowerCase()
                                    .contains(query.toLowerCase());
                              },
                              itemSorter: (a, b) {
                                return a.title.compareTo(b.title);
                              },
                              itemSubmitted: (item) {
                                setState(() {
                                  interestsTextController.text = item.title;
                                });
                              },
                              itemBuilder: (context, item) {
                                // ui for the autocompelete row
                                return suggestionRow(item.title);
                              },
                            ),
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
                          Container(
                            height: 50,
                            child: AutoCompleteTextField<Suggestions>(
                              key: sportsActivityKey,
                              controller: sportsActivityController,
                              clearOnSubmit: false,
                              suggestions: sportsActivityList,
                              style: TextStyle(
                                  color: Colors.black, fontSize: 16.0),
                              decoration: InputDecoration(
                                /*suffixIcon: Container(
                                  padding: EdgeInsets.symmetric(vertical: 19,horizontal: 17),
                                  width: 17,
                                  height: 17,
                                  child: SvgPicture.asset(
                                    'assets/images/ic_down_arrow.svg',
                                    fit: BoxFit.contain,color: AppColors.accentColor,),
                                ),*/
                                contentPadding:
                                    EdgeInsets.fromLTRB(0.0, 30.0, 10.0, 20.0),
                                hintText: /*"Enter your "+Constants.sportActivity*/ "User Input",
                                hintStyle: TextStyle(
                                    color: Color(0xFF727272),
                                    fontFamily: Constants.regularFont,
                                    fontSize: ScreenUtil().setSp(25)),
                              ),
                              itemFilter: (item, query) {
                                return item.title
                                    .toLowerCase()
                                    .contains(query.toLowerCase());
                              },
                              itemSorter: (a, b) {
                                return a.title.compareTo(b.title);
                              },
                              itemSubmitted: (item) {
                                setState(() {
                                  sportsActivityController.text = item.title;
                                });
                              },
                              itemBuilder: (context, item) {
                                // ui for the autocompelete row
                                return suggestionRow(item.title);
                              },
                            ),
                          ),
                          lable(Constants.occupation),
                          Container(
                            height: 50,
                            child: AutoCompleteTextField<Suggestions>(
                              key: occupationKey,
                              controller: occupationController,
                              clearOnSubmit: false,
                              suggestions: occupationList,
                              style: TextStyle(
                                  color: Colors.black, fontSize: 16.0),
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(0.0, 30.0, 10.0, 20.0),
                                hintText: /*"Enter your "+Constants.occupation*/ "User Input",
                                hintStyle: TextStyle(
                                    color: Color(0xFF727272),
                                    fontFamily: Constants.regularFont,
                                    fontSize: ScreenUtil().setSp(25)),
                              ),
                              itemFilter: (item, query) {
                                return item.title
                                    .toLowerCase()
                                    .contains(query.toLowerCase());
                              },
                              itemSorter: (a, b) {
                                return a.title.compareTo(b.title);
                              },
                              itemSubmitted: (item) {
                                setState(() {
                                  occupationController.text = item.title;
                                });
                              },
                              itemBuilder: (context, item) {
                                // ui for the autocompelete row
                                return suggestionRow(item.title);
                              },
                            ),
                          ),
                          lable(Constants.activeInjuries),
                          Container(
                            height: 50,
                            child: AutoCompleteTextField<Suggestions>(
                              key: activeInjuriesKey,
                              controller: activeInjuriesController,
                              clearOnSubmit: false,
                              suggestions: activeInjuriesList,
                              style: TextStyle(
                                  color: Colors.black, fontSize: 16.0),
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(0.0, 30.0, 10.0, 20.0),
                                hintText: /*"Enter your "+Constants.activeInjuries*/ "User Input",
                                //isDense: true,
                                suffix: InkWell(
                                  onTap: () {
                                    setState(() {
                                      isActiveInjuriesPrivate =
                                          !isActiveInjuriesPrivate;
                                    });
                                  },
                                  child: Container(
                                    child: Text(
                                      isActiveInjuriesPrivate
                                          ? 'Private'
                                          : 'Public',
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(25),
                                          color: Colors.orangeAccent),
                                    ),
                                  ),
                                ),

                                suffixStyle: TextStyle(
                                    fontSize: ScreenUtil().setSp(25),
                                    color: Colors.orangeAccent),
                                hintStyle: TextStyle(
                                    color: Color(0xFF727272),
                                    fontFamily: Constants.regularFont,
                                    fontSize: ScreenUtil().setSp(25)),
                              ),
                              itemFilter: (item, query) {
                                return item.title
                                    .toLowerCase()
                                    .contains(query.toLowerCase());
                              },
                              itemSorter: (a, b) {
                                return a.title.compareTo(b.title);
                              },
                              itemSubmitted: (item) {
                                setState(() {
                                  activeInjuriesController.text = item.title;
                                });
                              },
                              itemBuilder: (context, item) {
                                // ui for the autocompelete row
                                return suggestionRow(item.title);
                              },
                            ),
                          ),
                          lable(Constants.previousInjuries),
                          Container(
                            height: 50,
                            child: AutoCompleteTextField<Suggestions>(
                              key: previousInjuriesKey,
                              controller: previousInjuriesController,
                              clearOnSubmit: false,
                              suggestions: previousInjuriesList,
                              style: TextStyle(
                                  color: Colors.black, fontSize: 16.0),
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(0.0, 30.0, 10.0, 20.0),
                                hintText: /*"Enter your "+Constants.previousInjuries*/ "User Input",
                                //isDense: true,
                                suffix: InkWell(
                                  onTap: () {
                                    setState(() {
                                      isPreviousInjuriesPrivate =
                                          !isPreviousInjuriesPrivate;
                                    });
                                  },
                                  child: Container(
                                    child: Text(
                                      isPreviousInjuriesPrivate
                                          ? 'Private'
                                          : 'Public',
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(25),
                                          color: Colors.orangeAccent),
                                    ),
                                  ),
                                ),
                                hintStyle: TextStyle(
                                    color: Color(0xFF727272),
                                    fontFamily: Constants.regularFont,
                                    fontSize: ScreenUtil().setSp(25)),
                              ),
                              itemFilter: (item, query) {
                                return item.title
                                    .toLowerCase()
                                    .contains(query.toLowerCase());
                              },
                              itemSorter: (a, b) {
                                return a.title.compareTo(b.title);
                              },
                              itemSubmitted: (item) {
                                setState(() {
                                  previousInjuriesController.text = item.title;
                                });
                              },
                              itemBuilder: (context, item) {
                                // ui for the autocompelete row
                                return suggestionRow(item.title);
                              },
                            ),
                          ),
                          lable(Constants.achievementsCertifications),
                          Container(
                            height: 50,
                            child: AutoCompleteTextField<Suggestions>(
                              key: certificationsKey,
                              controller: certificationsController,
                              clearOnSubmit: false,
                              suggestions: certificationsList,
                              style: TextStyle(
                                  color: Colors.black, fontSize: 16.0),
                              decoration: InputDecoration(
                                /*suffixIcon: Container(
                                  padding: EdgeInsets.symmetric(vertical: 19,horizontal: 17),
                                  width: 17,
                                  height: 17,
                                  child: SvgPicture.asset(
                                    'assets/images/ic_down_arrow.svg',
                                    fit: BoxFit.contain,color: AppColors.accentColor,),
                                ),*/
                                contentPadding:
                                    EdgeInsets.fromLTRB(0.0, 30.0, 10.0, 20.0),
                                hintText: /*"Enter your "+Constants.achievementsCertifications*/ "User Input",
                                hintStyle: TextStyle(
                                    color: Color(0xFF727272),
                                    fontFamily: Constants.regularFont,
                                    fontSize: ScreenUtil().setSp(25)),
                              ),
                              itemFilter: (item, query) {
                                return item.title
                                    .toLowerCase()
                                    .contains(query.toLowerCase());
                              },
                              itemSorter: (a, b) {
                                return a.title.compareTo(b.title);
                              },
                              itemSubmitted: (item) {
                                setState(() {
                                  certificationsController.text = item.title;
                                });
                              },
                              itemBuilder: (context, item) {
                                // ui for the autocompelete row
                                return suggestionRow(item.title);
                              },
                            ),
                          ),
                          lable(Constants.coachesInstructors),
                          Container(
                            height: 50,
                            child: AutoCompleteTextField<Suggestions>(
                              key: coachesKey,
                              controller: coachesController,
                              clearOnSubmit: false,
                              suggestions: coachesList,
                              style: TextStyle(
                                  color: Colors.black, fontSize: 16.0),
                              decoration: InputDecoration(
                                /*suffixIcon: Container(
                                  padding: EdgeInsets.symmetric(vertical: 19,horizontal: 17),
                                  width: 17,
                                  height: 17,
                                  child: SvgPicture.asset(
                                    'assets/images/ic_down_arrow.svg',
                                    fit: BoxFit.contain,color: AppColors.accentColor,),
                                ),*/
                                contentPadding:
                                    EdgeInsets.fromLTRB(0.0, 30.0, 10.0, 20.0),
                                hintText: /*"Enter your "+Constants.coachesInstructors*/ "User Input",
                                hintStyle: TextStyle(
                                    color: Color(0xFF727272),
                                    fontFamily: Constants.regularFont,
                                    fontSize: ScreenUtil().setSp(25)),
                              ),
                              itemFilter: (item, query) {
                                return item.title
                                    .toLowerCase()
                                    .contains(query.toLowerCase());
                              },
                              itemSorter: (a, b) {
                                return a.title.compareTo(b.title);
                              },
                              itemSubmitted: (item) {
                                setState(() {
                                  coachesController.text = item.title;
                                });
                              },
                              itemBuilder: (context, item) {
                                // ui for the autocompelete row
                                return suggestionRow(item.title);
                              },
                            ),
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
    var interest = interestsTextController.value.text.trim();
    var sports = sportsActivityController.value.text.trim();
    var occupation = occupationController.value.text.trim();
    var activeInjuries = activeInjuriesController.value.text.trim();
    var previousInjuries = previousInjuriesController.value.text.trim();
    var achievements = certificationsController.value.text.trim();
    var coaches = coachesController.value.text.trim();

    Constants.showSnackBarWithMessage(
        "Profile adding...", _scaffoldkey, context, AppColors.primaryColor);

    Map<String, String> locationMap = {
      "address": _currentAddress.toString(),
      "lat": selectedLatitude.toString(),
      "long": selectedLongitude.toString(),
    };
    FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(userIDPref)
        .set({
          "interest": interest,
          "sports": sports,
          "location": locationMap,
          'occupation': occupation,
          'activeInjuries': activeInjuries,
          'previousInjuries': previousInjuries,
          'achievements': achievements,
          'coaches': coaches,
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

  // set tags of body parts
  setTags(bodyPartName) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.0),
        color: AppColors.primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 6.0, bottom: 6, right: 8, left: 12),
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
                    if (_bodyPartList.contains(bodyPartName)) {
                      _bodyPartList.remove(bodyPartName);
                    }
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
        if (mapObject.containsKey("interest")) {
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
        }

        if (mapObject.containsKey("location")) {
          _currentAddress = ds['location']['address'];
          selectedLatitude = ds['location']['latitude'];
          selectedLongitude = ds['location']['longitude'];
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
