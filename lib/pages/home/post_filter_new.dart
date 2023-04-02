import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/pages/home/select_filters.dart';
import 'package:solstice/pages/humanBody/app_human_anatomy.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/utilities.dart';

class PostFilterNew extends StatefulWidget {
  final String postId;
  final PostFeedModel postFeedModel;
  final bool editFields, isEditMode;

  PostFilterNew(
      {this.postId, this.postFeedModel, this.editFields, this.isEditMode});
  @override
  _PostFilterNewState createState() => _PostFilterNewState();
}

class _PostFilterNewState extends State<PostFilterNew> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  TextEditingController linkController = new TextEditingController();
  TextEditingController peopleTextController = new TextEditingController();
  String userIDPref = "";
  String postId;
  bool isBtnEnable = false;

  List<String> _goalStrList = new List.empty(growable: true);
  List<String> _bodyPartStrList = new List.empty(growable: true);
  List<String> _movementsStrList = new List.empty(growable: true);
  List<String> _sportsStrList = new List.empty(growable: true);
  List<String> _equipmentStrList = new List.empty(growable: true);
  List<String> _nutritionStrList = new List.empty(growable: true);

  String selectedInputField = "";

  bool editFields = true, isEditMode = false;

  @override
  void initState() {
    super.initState();

    editFields = widget.editFields;
    postId = widget.postId;

    if (!editFields) {
      setDataToFields(widget.postFeedModel);
    }
    if (widget.isEditMode) {
      setDataToFields(widget.postFeedModel);
    }
  }

  void setDataToFields(PostFeedModel postFeedModel) {
    linkController.text = postFeedModel.link ?? "";
    _bodyPartStrList.addAll(postFeedModel.bodyParts);
    _goalStrList.addAll(postFeedModel.goalsList);
    _movementsStrList.addAll(postFeedModel.movementTypeList);
    _nutritionStrList.addAll(postFeedModel.nutritionsList);
    _sportsStrList.addAll(postFeedModel.sportsList);
    _equipmentStrList.addAll(postFeedModel.equipmentsList);
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
                            margin: EdgeInsets.only(left: 5, right: 18),
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
                          top: ScreenUtil().setHeight(8),
                          bottom: ScreenUtil().setHeight(26)),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            lable(Constants.goal),
                            /*Container(
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
                            ),*/

                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (editFields) {
                                    selectedInputField = "goals";
                                    selectItemsDropDown(
                                        "Select Goals", _goalStrList);
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
                                        if (_goalStrList != null &&
                                            _goalStrList.length > 0)
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: ScreenUtil().setSp(20),
                                                bottom: ScreenUtil().setSp(10),
                                                right: ScreenUtil().setSp(20)),
                                            child: Wrap(
                                              children: [
                                                for (int i = 0;
                                                    i < _goalStrList.length;
                                                    i++)
                                                  Container(
                                                      margin: EdgeInsets.all(2),
                                                      child: setTags(
                                                          _goalStrList[i],
                                                          _goalStrList))
                                              ],
                                            ),
                                          ),
                                        if (_goalStrList == null ||
                                            _goalStrList.length == 0)
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 18, bottom: 14),
                                            child: Text(
                                              "Select Goals",
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
                                  selectSportsActivities();
                                  if (editFields) {}
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
                                                          _bodyPartStrList[i],
                                                          _bodyPartStrList))
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
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (editFields) {
                                    selectedInputField = "movementType";
                                    selectItemsDropDown("Select Movement Type",
                                        _movementsStrList);
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
                                        if (_movementsStrList != null &&
                                            _movementsStrList.length > 0)
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: ScreenUtil().setSp(20),
                                                bottom: ScreenUtil().setSp(10),
                                                right: ScreenUtil().setSp(20)),
                                            child: Wrap(
                                              children: [
                                                for (int i = 0;
                                                    i <
                                                        _movementsStrList
                                                            .length;
                                                    i++)
                                                  Container(
                                                      margin: EdgeInsets.all(2),
                                                      child: setTags(
                                                          _movementsStrList[i],
                                                          _movementsStrList))
                                              ],
                                            ),
                                          ),
                                        if (_movementsStrList == null ||
                                            _movementsStrList.length == 0)
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 18, bottom: 14),
                                            child: Text(
                                              "Select Movement Type",
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
                            lable(Constants.sportActivity),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (editFields) {
                                    selectedInputField = "sportActivities";
                                    selectItemsDropDown("Select Sport/Activity",
                                        _sportsStrList);
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
                            lable(Constants.equipmentPI),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (editFields) {
                                    selectedInputField = "equipment";
                                    selectItemsDropDown(
                                        "Select Equipment/Products/ingredients",
                                        _sportsStrList);
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
                                        if (_equipmentStrList != null &&
                                            _equipmentStrList.length > 0)
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: ScreenUtil().setSp(20),
                                                bottom: ScreenUtil().setSp(10),
                                                right: ScreenUtil().setSp(20)),
                                            child: Wrap(
                                              children: [
                                                for (int i = 0;
                                                    i <
                                                        _equipmentStrList
                                                            .length;
                                                    i++)
                                                  Container(
                                                      margin: EdgeInsets.all(2),
                                                      child: setTags(
                                                          _equipmentStrList[i],
                                                          _equipmentStrList))
                                              ],
                                            ),
                                          ),
                                        if (_equipmentStrList == null ||
                                            _equipmentStrList.length == 0)
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 18, bottom: 14),
                                            child: Text(
                                              "Select Equipment/Products/ingredients",
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
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (editFields) {
                                    selectedInputField = "nutrition";
                                    selectItemsDropDown(
                                        "Select Movement or nutrition",
                                        _nutritionStrList);
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
                                        if (_nutritionStrList != null &&
                                            _nutritionStrList.length > 0)
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: ScreenUtil().setSp(20),
                                                bottom: ScreenUtil().setSp(10),
                                                right: ScreenUtil().setSp(20)),
                                            child: Wrap(
                                              children: [
                                                for (int i = 0;
                                                    i <
                                                        _nutritionStrList
                                                            .length;
                                                    i++)
                                                  Container(
                                                      margin: EdgeInsets.all(2),
                                                      child: setTags(
                                                          _nutritionStrList[i],
                                                          _nutritionStrList))
                                              ],
                                            ),
                                          ),
                                        if (_nutritionStrList == null ||
                                            _nutritionStrList.length == 0)
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 18, bottom: 14),
                                            child: Text(
                                              "Select Movement or nutrition",
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
                                    saveFilters(context);
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
      return AppHumanAnatomy(
          bodyPartsListIntent: _bodyPartStrList, isEditableFields: editFields);
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
          } catch (e) {
          }
        }
      });
    }
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
              if (selectedInputField == "goals") {
                _goalStrList = selectedList;
              } else if (selectedInputField == "movementType") {
                _movementsStrList = selectedList;
              } else if (selectedInputField == "sportActivities") {
                _sportsStrList = selectedList;
              } else if (selectedInputField == "equipment") {
                _equipmentStrList = selectedList;
              } else if (selectedInputField == "nutrition") {
                _nutritionStrList = selectedList;
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
            if (editFields)
              SizedBox(
                width: 6,
              ),
            if (editFields)
              RotationTransition(
                turns: new AlwaysStoppedAnimation(45 / 360),
                child: InkWell(
                  onTap: () {
                    // Navigator.of(context).pop();
                    setState(() {
                      if (editFields) {
                        if (tagsList.contains(bodyPartName)) {
                          tagsList.remove(bodyPartName);
                        }
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
  void saveFilters(context) {
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
      "goal_array": _goalStrList,
      "body_part_array": _bodyPartStrList,
      'movement_type_array': _movementsStrList,
      'sports_activity_array': _sportsStrList,
      'link': linkController.text.toString(),
      // 'equipment_array': FieldValue.arrayUnion(_equipmentStrList),
      'equipment_array': _equipmentStrList,
      'nutrition_array': _nutritionStrList,
    }).then((value) {
      Utilities.hide();
      Navigator.pop(context, {"goToNext": true});
    }).catchError((onError) {
      Utilities.hide();
    });
  }
}

class Suggestions {
  String title;

  Suggestions(this.title);
}
