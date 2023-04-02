library human_anatomy;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solstice/utils/constants.dart';

class AppHumanAnatomy extends StatefulWidget {
  final List<String> bodyPartsListIntent;
  final bool isEditableFields;

  const AppHumanAnatomy(
      {Key key, this.bodyPartsListIntent, this.isEditableFields})
      : super(key: key);
  @override
  _AppHumanAnatomyState createState() => new _AppHumanAnatomyState();
}

class _AppHumanAnatomyState extends State<AppHumanAnatomy> {
  List<String> _bodyPartList = new List();
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  bool isSelectedFront = true;
  bool isEditableFields;

  @override
  void initState() {
    super.initState();

    if (widget.bodyPartsListIntent != null &&
        widget.bodyPartsListIntent.length > 0) {
      _bodyPartList = widget.bodyPartsListIntent;
    }
    isEditableFields = widget.isEditableFields;
  }

  /*@override
  Widget build(BuildContext context) {
    return humanAnatomy();
  }*/
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
                                "Body Parts",
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
                      if (_bodyPartList.length > 0 && isEditableFields)
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (_bodyPartList.length > 0) {
                                Navigator.of(context).pop({
                                  'update': "yes",
                                  "returnBodyPartList": _bodyPartList
                                });
                              }
                            });
                          },
                          child: Text(
                            "Done",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.titleTextColor,
                              fontFamily: Constants.boldFont,
                              fontSize: ScreenUtil().setSp(30),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    left: ScreenUtil().setSp(36),
                    right: ScreenUtil().setSp(36),
                    bottom: ScreenUtil().setSp(16)),
                height: ScreenUtil().setSp(54),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      child: Container(
                        width: ScreenUtil().setSp(145),
                        height: ScreenUtil().setSp(50),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26.0),
                          color: isSelectedFront == true
                              ? AppColors.primaryColor
                              : Colors.transparent,
                        ),
                        child: Text(
                          Constants.Front,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: isSelectedFront == true
                                  ? Colors.white
                                  : AppColors.accentColor,
                              fontFamily: Constants.semiBoldFont,
                              fontSize: ScreenUtil().setSp(22)),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          if (!isSelectedFront) {
                            isSelectedFront = true;
                          }
                        });
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      child: Container(
                        width: ScreenUtil().setSp(145),
                        height: ScreenUtil().setSp(50),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26.0),
                          color: isSelectedFront == false
                              ? AppColors.primaryColor
                              : Colors.transparent,
                        ),
                        child: Text(
                          Constants.Back,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: isSelectedFront == false
                                  ? Colors.white
                                  : AppColors.accentColor,
                              fontFamily: Constants.mediumFont,
                              fontSize: ScreenUtil().setSp(22)),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          if (isSelectedFront) {
                            isSelectedFront = false;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      isSelectedFront == true
                          ? humanFrontAnatomy()
                          : humanBackAnatomy(),
                      SizedBox(
                        height: 20,
                      ),
                      if (_bodyPartList != null && _bodyPartList.length > 0)
                        new Container(
                          margin: EdgeInsets.all(ScreenUtil().setSp(12)),
                          child: Wrap(
                            children: [
                              for (int i = 0; i < _bodyPartList.length; i++)
                                Container(
                                    margin: EdgeInsets.all(2),
                                    child: setTags(_bodyPartList[i]))
                            ],
                          ),
                        ),
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

  Widget humanFrontAnatomy() {
    return Center(
      child: Container(
        width: 340.0,
        height: 527,
        child: SizedBox(
          child: Stack(
            children: <Widget>[
              //(String svgPath, String svgName, marginTop, marginRight, marginLeft, height)

              bodyPart("assets/front_body/front_blank.svg", "front_blank", 0.0,
                  0.0, 0.0, 527.0),
              bodyPart("assets/front_body/upper_back.svg", "Upper Back", 66.0,
                  2.2, 0.0, 28.0),
              bodyPart(
                  "assets/front_body/neck.svg", "Neck", 46.0, 11.0, 0.0, 43.5),
              bodyPart(
                  "assets/front_body/chest.svg", "Chest", 95.0, 0.0, 0.0, 54.0),
              bodyPart("assets/front_body/left_deltoid.svg", "Deltoid", 82.0,
                  130.0, 2.0, 43.0),
              bodyPart("assets/front_body/right_deltoid.svg", "Deltoid", 81.5,
                  0.0, 130.0, 43.0),
              bodyPart("assets/front_body/left_tricep.svg", "Triceps", 112.0,
                  202.0, 4.0, 36.5),
              bodyPart("assets/front_body/right_tricep.svg", "Triceps", 108.5,
                  3.0, 200.0, 26.5),
              bodyPart("assets/front_body/left_forarm.svg", "Forarms", 153.5,
                  10.0, 194.0, 34.5),
              bodyPart("assets/front_body/right_forarm.svg", "Forarms", 163.0,
                  182.0, 8.0, 38.5),
              bodyPart("assets/front_body/left_bicep.svg", "Biceps", 116.0,
                  164.0, 0.5, 42.0),
              bodyPart("assets/front_body/right_bicep.svg", "Biceps", 119.0,
                  3.5, 162.0, 30.5),

              bodyPart("assets/front_body/left_obliques.svg", "Obliques", 146.0,
                  79.0, 0.5, 98.5),
              bodyPart("assets/front_body/right_obliques.svg", "Obliques",
                  146.0, 1.5, 66.0, 94.5),

              bodyPart("assets/front_body/left_middleback.svg", "Middle Back",
                  133.0, 109.0, 0.5, 26.5),
              bodyPart("assets/front_body/right_middleback.svg", "Middle Back",
                  125.0, 0.5, 109.0, 27.5),

              bodyPart("assets/front_body/left_quadriceps.svg", "Quadriceps",
                  248.0, 100.0, 0.5, 96.5),
              bodyPart("assets/front_body/right_quadriceps.svg", "Quadriceps",
                  248.0, 0.5, 65.0, 104.5),
              bodyPart("assets/front_body/abdominals.svg", "Abdominals", 146.0,
                  14.5, 0.0, 130.0),
              bodyPart("assets/front_body/left_tibialis_anterior.svg",
                  "Tibialis Anterior", 390.0, 109.0, 0.0, 90.0),
              bodyPart("assets/front_body/right_tibialis_anterior.svg",
                  "Tibialis Anterior", 387.0, 0.0, 10.0, 72.0),
              bodyPart(
                  "assets/front_body/calf.svg", "Calf", 388.0, 49.0, 0.0, 46.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget humanBackAnatomy() {
    return Center(
      child: Container(
        width: 340.0,
        height: 527,
        child: SizedBox(
          child: Stack(
            children: <Widget>[
              //(String svgPath, String svgName, marginTop, marginRight, marginLeft, height)

              bodyPart("assets/back_body/back_blank.svg", "back_blank", 0.0,
                  0.0, 0.0, 527.0),
              bodyPart(
                  "assets/back_body/neck.svg", "Neck", 48.5, 2.0, 0.0, 34.5),
              bodyPart("assets/back_body/upper_back.svg", "Upper Back", 69.5,
                  2.0, 0.0, 43.5),
              bodyPart("assets/back_body/left_deltoid.svg", "Deltoid", 85.0,
                  126.0, 2.0, 26.0),
              bodyPart("assets/back_body/right_deltoid.svg", "Deltoid", 86.0,
                  0.0, 126.0, 25.0),
              bodyPart("assets/back_body/left_tricep.svg", "Triceps", 113.0,
                  156.0, 4.0, 28.5),
              bodyPart("assets/back_body/right_tricep.svg", "Triceps", 119.5,
                  0.0, 160.0, 27.0),
              bodyPart("assets/back_body/left_forarm.svg", "Forarms", 159.5,
                  186.0, 10.0, 34.5),
              bodyPart("assets/back_body/right_forarm.svg", "Forarms", 166.0,
                  8.0, 172.0, 28.5),
              bodyPart("assets/back_body/middle_back.svg", "Middle Back", 137.5,
                  14.0, 0.0, 55.0),
              bodyPart("assets/back_body/lower_back.svg", "Lower Back", 180.5,
                  17.0, 0.0, 40.5),
              bodyPart("assets/back_body/gluteus_maximas.svg",
                  "Gluteus Maximas", 216.5, 17.0, 0.0, 76.5),

              bodyPart("assets/back_body/hamstring_infraspinatus.svg",
                  "Hamstring Infraspinatus", 282.5, 17.0, 18.0, 100.5),

              bodyPart("assets/back_body/left_hamstring.svg", "Hamstring",
                  355.0, 37.0, 4.0, 28.5),
              bodyPart("assets/back_body/right_hamstring.svg", "Hamstring",
                  360.0, 4.0, 56.0, 27.0),

              bodyPart(
                  "assets/back_body/calf.svg", "Calf", 369.5, 17.0, 34.0, 71.5),

              bodyPart("assets/back_body/achilles.svg", "Achilles", 447.5, 16.0,
                  45.0, 52.5),
            ],
          ),
        ),
      ),
    );
  }

  Widget bodyPart(String svgPath, String svgName, double marginTop,
      double marginRight, double marginLeft, double height) {
    //Color _svgColor = _bodyPartList.contains(svgName) ? Colors.redAccent : null;
    Color _svgColor = svgName != "front_blank" && svgName != "back_blank"
        ? _bodyPartList.contains(svgName)
            ? null
            : Colors.white10
        : null;
    final Widget bodyPartSvg = new SvgPicture.asset(svgPath,
        semanticsLabel: svgName, color: _svgColor);
    return Container(
      margin:
          EdgeInsets.only(top: marginTop, right: marginRight, left: marginLeft),
      height: height,
      alignment: Alignment.topCenter,
      child: GestureDetector(
          onTap: () {
            setState(() {
              if (isEditableFields) {
                if (svgName != "front_blank" && svgName != "back_blank") {
                  if (_bodyPartList.contains(svgName)) {
                    _bodyPartList.remove(svgName);
                  } else {
                    _bodyPartList.add(svgName);
                    // _bodyPartList.forEach((e) => print(e));
                  }
                }
              }
            });
          },
          child: bodyPartSvg),
    );
  }

  setTags(bodyPartName) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.0),
        color: AppColors.primaryColor,
      ),
      child: Padding(
        padding: isEditableFields
            ? EdgeInsets.only(top: 6.0, bottom: 6, right: 8, left: 12)
            : EdgeInsets.all(12),
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
            if (isEditableFields)
              SizedBox(
                width: 6,
              ),
            if (isEditableFields)
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
}
