import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/pages/filters/select_body_part.dart';
import 'package:solstice/utils/constants.dart';

class FilterPost extends StatefulWidget {
  final PostFeedModel postFeedModel;
  FilterPost({this.postFeedModel});

  @override
  _FilterPostState createState() => _FilterPostState();
}

class _FilterPostState extends State<FilterPost> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  TextEditingController _goalController = new TextEditingController();
  // TextEditingController _goalController = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                              Text(
                                "Filter Search",
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
                        left: ScreenUtil().setWidth(55),
                        right: ScreenUtil().setWidth(55),
                        top: ScreenUtil().setHeight(26),
                        bottom: ScreenUtil().setHeight(26)),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              Constants.goal,
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(24),
                                  fontFamily: Constants.regularFont,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Body Fit',
                                hintStyle: TextStyle(
                                    color: Color(0xFF727272),
                                    fontFamily: Constants.regularFont,
                                    fontSize: ScreenUtil().setSp(25)),
                              ),
                            ),
                          ),
                          lable(Constants.bodyParts),
                          Container(
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Shoulder',
                                suffix: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return SelectBodyPartForFilter();
                                        },
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Select Part",
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(25),
                                        fontFamily: Constants.regularFont,
                                        color: AppColors.primaryColor),
                                  ),
                                ),
                                hintStyle: TextStyle(
                                    color: Color(0xFF727272),
                                    fontFamily: Constants.regularFont,
                                    fontSize: ScreenUtil().setSp(25)),
                              ),
                            ),
                          ),
                          lable(Constants.movementType),
                          Container(
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Bench Press',
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
                                hintStyle: TextStyle(
                                    color: Color(0xFF727272),
                                    fontFamily: Constants.regularFont,
                                    fontSize: ScreenUtil().setSp(25)),
                              ),
                            ),
                          ),
                          lable(Constants.sportActivity),
                          Container(
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Gym Fitness',
                                hintStyle: TextStyle(
                                    color: Color(0xFF727272),
                                    fontFamily: Constants.regularFont,
                                    fontSize: ScreenUtil().setSp(25)),
                              ),
                            ),
                          ),
                          lable(Constants.equipmentPI),
                          Container(
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: 'User Input',
                                hintStyle: TextStyle(
                                    color: Color(0xFF727272),
                                    fontFamily: Constants.regularFont,
                                    fontSize: ScreenUtil().setSp(25)),
                              ),
                            ),
                          ),
                          lable(Constants.link),
                          Container(
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: 'www.bodybuilder.com',
                                hintStyle: TextStyle(
                                    color: Color(0xFF727272),
                                    fontFamily: Constants.regularFont,
                                    fontSize: ScreenUtil().setSp(25)),
                              ),
                            ),
                          ),
                          lable(Constants.movementOrNutrition),
                          Container(
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Body Fit',
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
                                hintStyle: TextStyle(
                                    color: Color(0xFF727272),
                                    fontFamily: Constants.regularFont,
                                    fontSize: ScreenUtil().setSp(25)),
                              ),
                            ),
                          ),
                          lable(Constants.people),
                          Container(
                            child: TextFormField(
                              onChanged: (value) {
                                if (value.contains("@")) {}
                              },
                              decoration: InputDecoration(
                                hintText: '@John Peterson',
                                hintStyle: TextStyle(
                                    color: Color(0xFF727272),
                                    fontFamily: Constants.regularFont,
                                    fontSize: ScreenUtil().setSp(25)),
                              ),
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
                              onPressed: () {},
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
                fontFamily: Constants.regularFont,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
