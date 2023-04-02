import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solstice/utils/constants.dart';
import 'package:transparent_image/transparent_image.dart';

class SelectBucketPostScreen extends StatefulWidget {
  @override
  _SelectBucketPostScreenState createState() => _SelectBucketPostScreenState();
}

class BucketStitchModel2 {
  String image;
  String title;
  String description;
  bool isSelected;

  BucketStitchModel2(this.image, this.title, this.description, this.isSelected);
}

class _SelectBucketPostScreenState extends State<SelectBucketPostScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<BucketStitchModel2> bucketList = new List<BucketStitchModel2>();
  int howManyItemSelected = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    bucketList.add(new BucketStitchModel2(
        "https://www.bodybuilding.com/fun/images/2015/how-to-make-yourself-the-best-trainer-at-any-gym-facebook-box-960x540.jpg",
        "Stitch A",
        "Lorem Ipsum is simply dummy text of the printing",
        false));
    bucketList.add(new BucketStitchModel2(
        "https://images.hindustantimes.com/Images/popup/2015/7/Crunches.jpg",
        "Stitch B",
        "Lorem Ipsum is simply dummy text of typesetting industry.",
        false));
    bucketList.add(new BucketStitchModel2(
        "https://www.bodybuilding.com/fun/images/2015/how-to-make-yourself-the-best-trainer-at-any-gym-facebook-box-960x540.jpg",
        "Stitch C",
        "Lorem Ipsum is simply dummy text of typesetting industry.",
        false));
    bucketList.add(new BucketStitchModel2(
        "https://1.bp.blogspot.com/-ITDeKbpwTbk/XJePd5D2nyI/AAAAAAAAAkQ/JGEzWJ0uGCsLjo09hjNTeP7Cwndrp9x5ACEwYBhgL/s640/gym-trainer-1.jpg",
        "Stitch D",
        "Lorem Ipsum is simply dummy text of typesetting industry.",
        false));
    bucketList.add(new BucketStitchModel2(
        "https://1.bp.blogspot.com/-ITDeKbpwTbk/XJePd5D2nyI/AAAAAAAAAkQ/JGEzWJ0uGCsLjo09hjNTeP7Cwndrp9x5ACEwYBhgL/s640/gym-trainer-1.jpg",
        "Stitch E",
        "Lorem Ipsum is simply dummy text of typesetting industry.",
        false));
    bucketList.add(new BucketStitchModel2(
        "https://images.hindustantimes.com/Images/popup/2015/7/Crunches.jpg",
        "Stitch F",
        "Lorem Ipsum is simply dummy text of typesetting industry.",
        false));

    bucketList.add(new BucketStitchModel2(
        "https://www.bodybuilding.com/fun/images/2015/how-to-make-yourself-the-best-trainer-at-any-gym-facebook-box-960x540.jpg",
        "Stitch A",
        "Lorem Ipsum is simply dummy text of the printing",
        false));
    bucketList.add(new BucketStitchModel2(
        "https://images.hindustantimes.com/Images/popup/2015/7/Crunches.jpg",
        "Stitch B",
        "Lorem Ipsum is simply dummy text of typesetting industry.",
        false));
    bucketList.add(new BucketStitchModel2(
        "https://www.bodybuilding.com/fun/images/2015/how-to-make-yourself-the-best-trainer-at-any-gym-facebook-box-960x540.jpg",
        "Stitch C",
        "Lorem Ipsum is simply dummy text of typesetting industry.",
        false));
    bucketList.add(new BucketStitchModel2(
        "https://1.bp.blogspot.com/-ITDeKbpwTbk/XJePd5D2nyI/AAAAAAAAAkQ/JGEzWJ0uGCsLjo09hjNTeP7Cwndrp9x5ACEwYBhgL/s640/gym-trainer-1.jpg",
        "Stitch D",
        "Lorem Ipsum is simply dummy text of typesetting industry.",
        false));

    bucketList.add(new BucketStitchModel2(
        "https://1.bp.blogspot.com/-ITDeKbpwTbk/XJePd5D2nyI/AAAAAAAAAkQ/JGEzWJ0uGCsLjo09hjNTeP7Cwndrp9x5ACEwYBhgL/s640/gym-trainer-1.jpg",
        "Stitch E",
        "Lorem Ipsum is simply dummy text of typesetting industry.",
        false));
    bucketList.add(new BucketStitchModel2(
        "https://images.hindustantimes.com/Images/popup/2015/7/Crunches.jpg",
        "Stitch F",
        "Lorem Ipsum is simply dummy text of typesetting industry.",
        false));
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
                top: ScreenUtil().setSp(26), bottom: ScreenUtil().setSp(0)),
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
                                    "Stitch B",
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
                          Text(
                            "Select All",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontFamily: 'epilogue_regular',
                              fontSize: ScreenUtil().setSp(25),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 12, right: 12, top: 12),
                        child: StaggeredGridView.countBuilder(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          itemCount: bucketList.length,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              child: Material(
                                child: InkWell(
                                  hoverColor:  Colors.brown.withOpacity(0.5),
                                  splashColor: Colors.brown.withOpacity(0.5),
                                  focusColor:  Colors.brown.withOpacity(0.5),
                                  highlightColor:  Colors.brown.withOpacity(0.5),
                                  onTap: () {
                                    setState(() {
                                      if (bucketList[index].isSelected == true) {
                                        bucketList[index].isSelected = false;
                                        howManyItemSelected = howManyItemSelected - 1;
                                      } else {
                                        bucketList[index].isSelected = true;
                                        howManyItemSelected = howManyItemSelected + 1;
                                      }
                                    });
                                  },
                                  child: Stack(
                                    fit: StackFit.passthrough,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(15)),
                                        child: FadeInImage.memoryNetwork(
                                          placeholder: kTransparentImage,
                                          image: bucketList[index].image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 10,
                                        right: 10,
                                        child: Container(
                                          width: 25,
                                          height: 24,
                                          child: SvgPicture.asset(
                                            bucketList[index].isSelected == false
                                                ? 'assets/images/uncheck.svg'
                                                : 'assets/images/checkbox.svg',
                                            alignment: Alignment.center,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          staggeredTileBuilder: (index) {
                            return StaggeredTile.count(
                                1, index.isEven ? 1.2 : 1.8);
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
                                  '$howManyItemSelected Post selected',
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
}
