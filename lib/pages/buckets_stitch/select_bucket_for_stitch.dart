import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solstice/model/bucket_stitch_model.dart';
import 'package:solstice/model/stitch_routine_model.dart';
import 'package:solstice/model/tabs_models.dart';
import 'package:solstice/pages/buckets_stitch/select_bucket_post_screen.dart';
import 'package:solstice/pages/views/bucket_stitch_list_item.dart';
import 'package:solstice/pages/views/tab_list_item.dart';
import 'package:solstice/utils/constants.dart';

class SelectBucketForStitch extends StatefulWidget {
  @override
  _SelectBucketForStitchState createState() => _SelectBucketForStitchState();
}

class _SelectBucketForStitchState extends State<SelectBucketForStitch> {
  bool isBucketSelected = true;
  List<TabsModel> bucketTabsList = new List<TabsModel>();
  List<StitchRoutineModel> bucketList = new List<StitchRoutineModel>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bucketTabsList.add(new TabsModel("All", true));
    bucketTabsList.add(new TabsModel("Forum", false));
    bucketTabsList.add(new TabsModel("Buckets", false));
    bucketTabsList.add(new TabsModel("About", false));

    bucketList.add(new StitchRoutineModel(
      image:
          "https://www.bodybuilding.com/fun/images/2015/how-to-make-yourself-the-best-trainer-at-any-gym-facebook-box-960x540.jpg",
      title: "Stitch A",
      description: "Lorem Ipsum is simply dummy text of the printing",
    ));
    bucketList.add(new StitchRoutineModel(
      image:
          "https://www.bodybuilding.com/fun/images/2015/how-to-make-yourself-the-best-trainer-at-any-gym-facebook-box-960x540.jpg",
      title: "Stitch A",
      description: "Lorem Ipsum is simply dummy text of the printing",
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.white),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: ScreenUtil().setSp(26), bottom: ScreenUtil().setSp(26)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).padding.top,
                ),
                Expanded(
                  flex: 0,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: ScreenUtil().setSp(40),
                      right: ScreenUtil().setSp(40),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
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
                              padding: EdgeInsets.all(3),
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
                              padding:
                                  EdgeInsets.only(left: ScreenUtil().setSp(20)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Select Stitch",
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
                          InkWell(
                            onTap: () {},
                            child: Container(
                              width: 26,
                              height: 26,
                              padding: EdgeInsets.all(3),
                              child: SvgPicture.asset(
                                'assets/images/ic_search.svg',
                                alignment: Alignment.center,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Container(
                              width: 26,
                              height: 26,
                              padding: EdgeInsets.all(5),
                              child: SvgPicture.asset(
                                'assets/images/ic_plus.svg',
                                alignment: Alignment.center,
                                color: Colors.black,
                                fit: BoxFit.contain,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                tabLayout(),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: Stack(
                    fit: StackFit.loose,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: ScreenUtil().setSp(10),
                          right: ScreenUtil().setSp(10),
                        ),
                        child: ListView.builder(
                          itemCount: bucketList == null ? 0 : bucketList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () {
                                _navigateToSelectBucketPost();
                              },
                              splashColor: AppColors.primaryColor,
                              child: BucketStitchListItem(
                                  bucketList[index], index,fromPostPage: false,),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          height: 115,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  Color(0xFFFFFFFF).withOpacity(0.7),
                                  Color(0xFFFFFFFF).withOpacity(0.5),
                                ],
                                begin: FractionalOffset(1.0, 0.0),
                                end: FractionalOffset(1.0, 0.0),
                                stops: [0.0, 1.0],
                                tileMode: TileMode.clamp),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setSp(40),
                                    right: ScreenUtil().setSp(40)),
                                child: Container(
                                  height: ScreenUtil().setSp(100),
                                  child: RaisedButton(
                                    color: AppColors.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40.0),
                                      side: BorderSide(
                                          color: AppColors.primaryColor),
                                    ),
                                    onPressed: () {},
                                    textColor: Colors.white,
                                    child: Text(
                                      'Save to Routine',
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
                              Container(
                                alignment: Alignment.center,
                                child: Text(
                                  '7 Post selected',
                                  style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontFamily: 'epilogue_regular',
                                      fontSize: ScreenUtil().setSp(25)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget tabLayout() {
    return isBucketSelected
        ? Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(
              left: ScreenUtil().setSp(36),
              right: ScreenUtil().setSp(12),
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
                      bucketTabsList
                          .forEach((element) => element.isSelected = false);
                      bucketTabsList[index].isSelected = true;
                      //selectedLevel = levelDataList[index].type;
                    });
                  },
                  child: new TabListItem(bucketTabsList[index]),
                );
              },
            ),
          )
        : Container();
  }

  Future _navigateToSelectBucketPost() async {
    Map results = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return SelectBucketPostScreen();
    }));
  }
}
