
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/forum_model.dart';
import 'package:solstice/model/groups/groups_model.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/utils/size_utils.dart';


class GroupFbItem extends StatefulWidget {
  final GroupsFireBaseModel groupItem;
  final String appUserId;
  final int index;

  GroupFbItem({Key key, @required this.groupItem, @required this.appUserId, @required this.index})
      : super(key: key);

  @override
  _GroupFbItemState createState() => _GroupFbItemState();
}

class _GroupFbItemState extends State<GroupFbItem> {


  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width ,
              margin: EdgeInsets.only(left:ScreenUtil().setSp(20),right:ScreenUtil().setSp(20),top:ScreenUtil().setSp(0)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: (widget.groupItem.image.contains("https:") || widget.groupItem.image.contains("http:")) ? widget.groupItem.image:
                    UrlConstant.BaseUrlImg+widget.groupItem.image,
                    imageBuilder: (context, imageProvider) => Container(
                      width: ScreenUtil().setSp(150),
                      height: ScreenUtil().setSp(150),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.all(Radius.circular(12.0)),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => setPostDefaultImage(context),
                    errorWidget: (context, url, error) => setPostDefaultImage(context),
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.only(left: ScreenUtil().setSp(20)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              widget.groupItem.title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: AppColors.titleTextColor,
                                  fontFamily: Constants.boldFont,
                                  fontSize: ScreenUtil().setSp(27)),),
                            SizedBox(height: 8),
                            Text(
                              widget.groupItem.description,
                              maxLines: 4,
                              style: TextStyle(
                                  color: AppColors.lightGreyColor,
                                  fontFamily: Constants.regularFont,
                                  fontSize: ScreenUtil().setSp(25)),
                            ),
                          ]
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )

    );
  }

  setPostDefaultImage(BuildContext context) {
    return Container(
      width: ScreenUtil().setSp(150),
      height: ScreenUtil().setSp(150),
      decoration: BoxDecoration(
        color: AppColors.viewLineColor,
        borderRadius:
        BorderRadius.all(Radius.circular(12.0)),
      ),
    );
  }



}

