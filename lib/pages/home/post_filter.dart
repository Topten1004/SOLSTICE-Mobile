import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solstice/model/post_filter_model.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/pages/humanBody/app_human_anatomy.dart';
import 'package:solstice/pages/new_login_register/about_you_screen.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/utilities.dart';

class PostFilter extends StatefulWidget {
  final String postId;
  final PostFeedModel postFeedModel;
  final bool editFields;

  PostFilter({this.postId, this.postFeedModel, this.editFields});
  @override
  _PostFilterState createState() => _PostFilterState();
}

class _PostFilterState extends State<PostFilter> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  TextEditingController linkController = new TextEditingController();
  TextEditingController goalController = new TextEditingController();
  TextEditingController sportsTextController = new TextEditingController();
  TextEditingController equipmentsTextController = new TextEditingController();
  TextEditingController bodyPartsTextController = new TextEditingController();
  TextEditingController movementTypeTextController =
      new TextEditingController();
  TextEditingController nutritionsTextController = new TextEditingController();
  TextEditingController peopleTextController = new TextEditingController();
  String bodyParts;
  String movementType;
  String nutrition;
  GlobalKey<AutoCompleteTextFieldState<Suggestions>> keyGoal = new GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<Suggestions>> keyBodyParts =
      new GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<Suggestions>> keyMovementType =
      new GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<Suggestions>> keySports =
      new GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<Suggestions>> keyEquipment =
      new GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<Suggestions>> keyNutrition =
      new GlobalKey();
  String userIDPref = "";
  String postId;
  bool isBtnEnable = false;
  List<Suggestions> goalList = new List();
  List<Suggestions> bodyPartList = new List();
  List<Suggestions> movementTypeList = new List();
  List<Suggestions> sportsList = new List();
  List<Suggestions> equipmentList = new List();
  List<Suggestions> nutritionList = new List();
  List<String> _bodyPartStrList = new List();
  bool editFields = true;

  @override
  void initState() {
    super.initState();

    editFields = widget.editFields;
    postId = widget.postId;

    getBodyPartData();
    if (!editFields) {
      setDataToFields(widget.postFeedModel);
    }
  }

  void setDataToFields(PostFeedModel postFeedModel) {
    goalController.text = postFeedModel.goal;
    movementTypeTextController.text = postFeedModel.movementType;
    nutritionsTextController.text = postFeedModel.movementNutrition;
    linkController.text = postFeedModel.link;
    sportsTextController.text = postFeedModel.sportsActivity;
    equipmentsTextController.text = postFeedModel.equipments;
    _bodyPartStrList.addAll(postFeedModel.bodyParts);
  }

  void getBodyPartData() {
    FirebaseFirestore.instance
        .collection(Constants.goalsColl)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        goalList.add(Suggestions(element.get("title")));
      });
    });
    /*FirebaseFirestore.instance
        .collection(Constants.bodyPartsColl)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        bodyPartsList.add(Suggestions(element.get("title")));
      });
    });*/

    FirebaseFirestore.instance
        .collection(Constants.movementTypeColl)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        movementTypeList.add(Suggestions(element.get("title")));
      });
    });

    FirebaseFirestore.instance
        .collection(Constants.sportActivitiesColl)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        sportsList.add(Suggestions(element.get("title")));
      });
    });

    FirebaseFirestore.instance
        .collection(Constants.equipmentColl)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        equipmentList.add(Suggestions(element.get("title")));
      });
    });

    FirebaseFirestore.instance
        .collection(Constants.nutritionColl)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        nutritionList.add(Suggestions(element.get("title")));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
        key: _scaffoldkey,
        /* appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Filter Post',
            style: TextStyle(fontSize: 14.0, color: Colors.black),
          ),
          titleSpacing: -10,
          centerTitle: false,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
                size: 20.0,
              )),
        ),*/
        body: Stack(
          children: [
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
                                  "Filter Post",
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
                          top: ScreenUtil().setHeight(16),
                          bottom: ScreenUtil().setHeight(26)),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            lable(Constants.goal),
                            Container(
                              height: 50,
                              child: AutoCompleteTextField<Suggestions>(
                                key: keyGoal,
                                controller: goalController,
                                clearOnSubmit: false,
                                suggestions: goalList,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16.0),
                                decoration: InputDecoration(
                                  enabled: editFields,
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
                                  contentPadding: EdgeInsets.fromLTRB(
                                      0.0, 30.0, 10.0, 20.0),
                                  hintText: 'User Input',
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
                                    goalController.text = item.title;
                                  });
                                },
                                itemBuilder: (context, item) {
                                  // ui for the autocompelete row
                                  return suggestionRow(item.title);
                                },
                              ),
                            ),
                            lable(Constants.bodyParts),
                            /*Container(
                              height: 50,
                              child: AutoCompleteTextField<Suggestions>(
                                key: keyBodyParts,
                                controller: bodyPartsTextController,
                                clearOnSubmit: false,
                                suggestions: bodyPartsList,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16.0),
                                decoration: InputDecoration(
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
                                  contentPadding: EdgeInsets.fromLTRB(
                                      0.0, 30.0, 10.0, 20.0),
                                  hintText: 'Select Body parts',
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
                                    bodyPartsTextController.text = item.title;
                                  });
                                },
                                itemBuilder: (context, item) {
                                  // ui for the autocompelete row
                                  return suggestionRow(item.title);
                                },
                              ),
                            ),*/

                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (editFields) {
                                    selectSportsActivities();
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (_bodyPartStrList != null &&
                                            _bodyPartStrList.length > 0)
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: ScreenUtil().setSp(20),
                                                bottom: ScreenUtil().setSp(10),
                                                right: ScreenUtil().setSp(20)),
                                            child: Wrap(
                                              children: [
                                                for (int i = 0;
                                                    i < _bodyPartStrList.length;
                                                    i++)
                                                  Container(
                                                      margin: EdgeInsets.all(2),
                                                      child: setTags(
                                                          _bodyPartStrList[i]))
                                              ],
                                            ),
                                          ),
                                        if (_bodyPartStrList == null ||
                                            _bodyPartStrList.length == 0)
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 18, bottom: 14),
                                            child: Text(
                                              "Select Body Parts",
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
                            lable(Constants.movementType),
                            Container(
                              height: 50,
                              child: AutoCompleteTextField<Suggestions>(
                                key: keyMovementType,
                                controller: movementTypeTextController,
                                clearOnSubmit: false,
                                suggestions: movementTypeList,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16.0),
                                decoration: InputDecoration(
                                  enabled: editFields,
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
                                  contentPadding: EdgeInsets.fromLTRB(
                                      0.0, 30.0, 10.0, 20.0),
                                  hintText: 'Select Movement type',
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
                                    movementTypeTextController.text =
                                        item.title;
                                  });
                                },
                                itemBuilder: (context, item) {
                                  // ui for the autocompelete row
                                  return suggestionRow(item.title);
                                },
                              ),
                            ),
                            lable(Constants.sportActivity),
                            Container(
                              height: 50,
                              child: AutoCompleteTextField<Suggestions>(
                                key: keySports,
                                controller: sportsTextController,
                                clearOnSubmit: false,
                                suggestions: sportsList,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16.0),
                                decoration: InputDecoration(
                                  enabled: editFields,
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
                                  contentPadding: EdgeInsets.fromLTRB(
                                      0.0, 30.0, 10.0, 20.0),
                                  hintText: 'User Input',
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
                                    sportsTextController.text = item.title;
                                  });
                                },
                                itemBuilder: (context, item) {
                                  // ui for the autocompelete row
                                  return suggestionRow(item.title);
                                },
                              ),
                            ),
                            lable(Constants.equipmentPI),
                            Container(
                              height: 50,
                              child: AutoCompleteTextField<Suggestions>(
                                key: keyEquipment,
                                controller: equipmentsTextController,
                                clearOnSubmit: false,
                                suggestions: equipmentList,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16.0),
                                decoration: InputDecoration(
                                  enabled: editFields,
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
                                  contentPadding: EdgeInsets.fromLTRB(
                                      0.0, 30.0, 10.0, 20.0),
                                  hintText: 'User Input',
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
                                    equipmentsTextController.text = item.title;
                                  });
                                },
                                itemBuilder: (context, item) {
                                  // ui for the autocompelete row
                                  return suggestionRow(item.title);
                                },
                              ),
                            ),
                            lable(Constants.link),
                            TextFormField(
                              maxLength: 200,
                              cursorColor: AppColors.primaryColor,
                              controller: linkController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              maxLines: 1,
                              readOnly: !editFields,
                              onChanged: (v) {},
                              decoration: InputDecoration(
                                counterText: "",
                              ),
                            ),
                            lable(Constants.movementOrNutrition),
                            Container(
                              height: 50,
                              child: AutoCompleteTextField<Suggestions>(
                                key: keyNutrition,
                                controller: nutritionsTextController,
                                clearOnSubmit: false,
                                suggestions: nutritionList,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16.0),
                                decoration: InputDecoration(
                                  enabled: editFields,
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
                                  contentPadding: EdgeInsets.fromLTRB(
                                      0.0, 30.0, 10.0, 20.0),
                                  hintText: 'User Input',
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
                                    nutritionsTextController.text = item.title;
                                  });
                                },
                                itemBuilder: (context, item) {
                                  // ui for the autocompelete row
                                  return suggestionRow(item.title);
                                },
                              ),
                            ),
                            lable(Constants.people),
                            TextFormField(
                              maxLength: 200,
                              cursorColor: AppColors.primaryColor,
                              controller: peopleTextController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              maxLines: 1,
                              onChanged: (v) {},
                              decoration: InputDecoration(
                                counterText: "",
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Visibility(
                              visible: editFields,
                              maintainAnimation: true,
                              maintainSize: false,
                              maintainState: true,
                              child: Container(
                                color: Colors.transparent,
                                margin: EdgeInsets.only(top: 3),
                                width: MediaQuery.of(context).size.width,
                                height: ScreenUtil().setSp(100),
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40.0),
                                      side: BorderSide(
                                        color: AppColors.primaryColor,
                                      )),
                                  onPressed: () {
                                    saveFilters();
                                  },
                                  color: AppColors.primaryColor,
                                  textColor: Colors.white,
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    Constants.applyFilter,
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(28),
                                      fontFamily: Constants.semiBoldFont,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
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
        ));
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

  Widget suggestionRow(String title) {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 12),
      child: Text(
        title,
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }

  Future selectSportsActivities() async {
    Map results = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return AppHumanAnatomy(bodyPartsListIntent: _bodyPartStrList);
    }));

    if (results != null && results.containsKey('update')) {
      var _isUpdate = "";

      setState(() {
        _isUpdate = results['update'];
        if (_isUpdate == "yes") {
          try {
            List<String> bodyPartsList = results['returnBodyPartList'];
            if (bodyPartsList != null && bodyPartsList.length > 0) {
              _bodyPartStrList = bodyPartsList;

              //sportsTextController.text = _bodyPartStrList.toString();
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
                    if (_bodyPartStrList.contains(bodyPartName)) {
                      _bodyPartStrList.remove(bodyPartName);
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

  // Save Filters
  void saveFilters() {
    Utilities.show(context);
    /*PostFilterModel postFilterModel = new PostFilterModel(
        goal: goalController.text.toString(),
        bodyPart: */ /*bodyPartsTextController.text.toString()*/ /* "",
        bodyPartArray: FieldValue.arrayUnion(bodyPartsList),
        movementType: movementTypeTextController.text.toString(),
        equipment: equipmentsTextController.text.toString(),
        movementNutrition: nutritionsTextController.text.toString(),
        sportsActivity: this.sportsTextController.text.toString(),
        link: linkController.text.toString());
*/
    FirebaseFirestore.instance
        .collection(Constants.posts)
        .doc(postId)
        .update(/*postFilterModel.toMap()*/
            {
      "goal": goalController.text.toString(),
      "bod_part_array": FieldValue.arrayUnion(_bodyPartStrList),
      'movement_type': movementTypeTextController.text.toString(),
      'sports_activity': this.sportsTextController.text.toString(),
      'link': linkController.text.toString(),
      'equipment': equipmentsTextController.text.toString(),
      'movement_nutrition': nutritionsTextController.text.toString(),
    }).then((value) {
      Utilities.hide();
      Navigator.pop(context, {"goToNext": true});
    }).catchError((onError) {
      Utilities.hide();
    });
  }
}
