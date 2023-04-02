import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solstice/utils/constants.dart';

class PrivacyPolicy extends StatefulWidget {
  @override
  _PrivacyPolicyState createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
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
          SingleChildScrollView(
            child: Column(
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
                                  "Privacy Policy",
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
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(
                      left: 30,
                      right: ScreenUtil().setSp(36),
                      top: ScreenUtil().setSp(26),
                      bottom: ScreenUtil().setSp(26)),
                  child: SingleChildScrollView(
                    child: Text(
                      'Caption for this journey, Lorem ipsum dolor\nLorem ipsum dolor sit amet, consectetur'
                      '\nadipiscing elit, sed do eiusmod tempor\nincididunt ut labore et dolore magna\n'
                      'aliqua. Ut enim ad minim veniam, quis\nnostrud exercitation ullamco '
                      'laboris nisi ut\naliquip ex ea commodo consequat.\n\nDuis aute irure '
                      'dolor in reprehenderit in\nvoluptate velit esse cillum dolore eu '
                      'fugiat\nnulla pariatur. Excepteur sint occaecat\ncupidatat non proident,'
                      ' sunt in culpa qui\nofficia deserunt mollit anim id est laborum.',
                      textAlign: TextAlign.start,
                      softWrap: false,
                      style: TextStyle(
                          fontFamily: 'epilogue_regular',
                          fontSize: ScreenUtil().setSp(26),
                          height: 1.3),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(
                      left: 30,
                      right: ScreenUtil().setSp(36),
                      top: ScreenUtil().setSp(26),
                      bottom: ScreenUtil().setSp(26)),
                  child: SingleChildScrollView(
                    child: Text(
                      'Caption for this journey, Lorem ipsum dolor\nLorem ipsum dolor sit amet, consectetur'
                          '\nadipiscing elit, sed do eiusmod tempor\nincididunt ut labore et dolore magna\n'
                          'aliqua. Ut enim ad minim veniam, quis\nnostrud exercitation ullamco '
                          'laboris nisi ut\naliquip ex ea commodo consequat.\n\nDuis aute irure '
                          'dolor in reprehenderit in\nvoluptate velit esse cillum dolore eu '
                          'fugiat\nnulla pariatur. Excepteur sint occaecat\ncupidatat non proident,'
                          ' sunt in culpa qui\nofficia deserunt mollit anim id est laborum.',
                      textAlign: TextAlign.start,
                      softWrap: false,
                      style: TextStyle(
                          fontFamily: 'epilogue_regular',
                          fontSize: ScreenUtil().setSp(26),
                          height: 1.3),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(
                      left: 30,
                      right: ScreenUtil().setSp(36),
                      top: ScreenUtil().setSp(26),
                      bottom: ScreenUtil().setSp(26)),
                  child: SingleChildScrollView(
                    child: Text(
                      'Caption for this journey, Lorem ipsum dolor\nLorem ipsum dolor sit amet, consectetur'
                          '\nadipiscing elit, sed do eiusmod tempor\nincididunt ut labore et dolore magna\n'
                          'aliqua. Ut enim ad minim veniam, quis\nnostrud exercitation ullamco '
                          'laboris nisi ut\naliquip ex ea commodo consequat.\n\nDuis aute irure '
                          'dolor in reprehenderit in\nvoluptate velit esse cillum dolore eu '
                          'fugiat\nnulla pariatur. Excepteur sint occaecat\ncupidatat non proident,'
                          ' sunt in culpa qui\nofficia deserunt mollit anim id est laborum.',
                      textAlign: TextAlign.start,
                      softWrap: false,
                      style: TextStyle(
                          fontFamily: 'epilogue_regular',
                          fontSize: ScreenUtil().setSp(26),
                          height: 1.3),
                    ),
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
