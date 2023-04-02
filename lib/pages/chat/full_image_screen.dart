
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:solstice/utils/constants.dart';


class fullImageScreenView extends StatefulWidget {
  String messageFromName;
  String messageTime;
  String imageIntent;

  fullImageScreenView({Key key, this.messageFromName, this.messageTime,this.imageIntent}) : super(key: key);

  @override
  _fullImageScreenViewState createState() => _fullImageScreenViewState();
}

class _fullImageScreenViewState extends State<fullImageScreenView> {


  String messageTime = "";
  String messageFromName = "";
  String imageIntent = "";
  @override
  void initState() {
    super.initState();

    try{
      messageFromName = widget.messageFromName != null ? widget.messageFromName : "";
      messageTime = widget.messageTime != null ? widget.messageTime : "";
      imageIntent = widget.imageIntent != null ? widget.imageIntent : "";
    }catch(e){}

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
      body: Stack(
        children: <Widget>[

      Container(

      child: PhotoView(
        minScale: PhotoViewComputedScale.contained * 1.1,
        maxScale: PhotoViewComputedScale.covered * 1.8,
        initialScale: PhotoViewComputedScale.contained * 1.1,
          backgroundDecoration: BoxDecoration(
          color: Colors.white),
      imageProvider:
      CachedNetworkImageProvider(imageIntent),
    ),
      ),

          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                color: Colors.white,
                height: MediaQuery.of(context).padding.top,
              ),
              Expanded(
                flex: 0,
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(top:ScreenUtil().setSp(24),bottom:ScreenUtil().setSp(16),
                      left:ScreenUtil().setSp(16),right:ScreenUtil().setSp(16)),
                  child: Row(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              messageFromName,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: Constants.boldFont,
                                  fontSize: 16.0),
                            ),
                            SizedBox(
                              height: 5,
                            ),

                            Text(messageTime=="" ? "" :getMsgTime(
                              messageTime),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: Constants.mediumFont,
                                  fontSize: 12.0),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                )
              ),
            /*  Container(
                width: MediaQuery.of(context).size.width,
                height: 1.0,
                color: AppColors.viewLineColor,
              ),*/
              Expanded(
                flex: 1,
                child:Container()
                ,
              )

            ],
          ),
        ],
      ),
    );
  }

  static String getMsgTime(String timeStampValue) {
    int timestamp = 0;
    if(timeStampValue != null && timeStampValue != "null" && timeStampValue != ""){
      timestamp = int.parse(timeStampValue);
    }

    var finalFormatedDate = '';
    var finalFormatedTime = "";
    var format = DateFormat('dd.MM.yyyy, HH:mm');
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp /** 1000*/);
    var timeFormat = DateFormat('HH:mm');

    finalFormatedDate = format.format(date);
    finalFormatedTime = timeFormat.format(date);

    final now = DateTime.now().toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    //final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final aDate = DateTime(date.year, date.month, date.day);
    if(aDate == today) {
      finalFormatedDate = "Today, "+finalFormatedTime/*"היום"*/;
    } else if(aDate == yesterday) {
      finalFormatedDate = "Yesterday, "+finalFormatedTime/*"אתמול"*/;
    }
    return finalFormatedDate;
  }

}