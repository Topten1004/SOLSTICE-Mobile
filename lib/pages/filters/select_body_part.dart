import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model_viewer/model_viewer.dart';
import 'package:solstice/utils/constants.dart';

class SelectBodyPartForFilter extends StatefulWidget {
  @override
  _SelectBodyPartForFilterState createState() =>
      _SelectBodyPartForFilterState();
}

class _SelectBodyPartForFilterState extends State<SelectBodyPartForFilter> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        child: Container(
                          height: MediaQuery.of(context).size.height/1.7,
                          width: MediaQuery.of(context).size.width,
                          child: ModelViewer(
                            src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
                            alt: "A 3D model of an astronaut",
                            ar: true,
                            iosSrc: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
                            autoRotate: true,
                            cameraControls: true,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            lable(Constants.selectBodyParts),
                            Container(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Shoulder',
                                  suffixIcon: Container(
                                    padding: EdgeInsets.symmetric(vertical: 19,horizontal: 17),
                                    width: 17,
                                    height: 17,
                                    child: SvgPicture.asset(
                                      'assets/images/ic_down_arrow.svg',
                                      fit: BoxFit.contain,color: AppColors.accentColor,),
                                  ),
                                  hintStyle: TextStyle(
                                      color: Color(0xFF727272),
                                      fontFamily: Constants.regularFont,
                                      fontSize: ScreenUtil().setSp(25)),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
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

                                },
                                color:AppColors.primaryColor,
                                textColor: Colors.white,
                                padding: EdgeInsets.all(10.0),
                                child: Text(Constants.submit,
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

  Widget lable(String lable){
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
