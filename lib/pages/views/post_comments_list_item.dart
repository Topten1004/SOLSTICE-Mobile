
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/model/commments_model.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/utils/size_utils.dart';


class PostCommentsListItem extends StatelessWidget {
  final CommentsModel _selectedItem;

  PostCommentsListItem(this._selectedItem);

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: ScreenUtil().setSp(16),right: ScreenUtil().setSp(16),),
      child: setViewsOnTypeBasis(_selectedItem,context),

    );
  }

  setViewsOnTypeBasis(CommentsModel selectedItem, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[

        Expanded(
            flex: 0,
            child: Container(
              width: MediaQuery.of(context).size.width ,
              margin: EdgeInsets.only(top: ScreenUtil().setSp(20),bottom: ScreenUtil().setSp(20)),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: (selectedItem.userImage.contains("https:") || selectedItem.userImage.contains("http:")) ? selectedItem.userImage:
                    UrlConstant.BaseUrlImg+selectedItem.userImage,
                    imageBuilder: (context, imageProvider) => Container(
                      width: ScreenUtil().setSp(70),
                      height: ScreenUtil().setSp(70),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.all(Radius.circular(50.0)),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => setUserDefaultCircularImage(),
                    errorWidget: (context, url, error) => setUserDefaultCircularImage(),
                  ),

                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.only(left: ScreenUtil().setSp(20),right:ScreenUtil().setSp(12) ,
                          top: ScreenUtil().setSp(6),bottom: ScreenUtil().setSp(6)),

                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[

                            SizedBox(height: 8),

                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[

                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      selectedItem.userName,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: AppColors.titleTextColor,
                                          fontFamily: Constants.boldFont,
                                          fontSize: ScreenUtil().setSp(26)),),
                                  ),


                                  Text(
                                    _selectedItem.commentTime,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: AppColors.titleTextColor,
                                        fontFamily: Constants.mediumFont,
                                        fontSize: ScreenUtil().setSp(22)),
                                  ),



                                ]
                            ),

                            SizedBox(height:16),

                            Text(
                              _selectedItem.comment,
                              maxLines: 2,
                              style: TextStyle(
                                  color: AppColors.titleTextColor,
                                  fontFamily: Constants.regularFont,
                                  fontSize: ScreenUtil().setSp(23)),
                            ),
                            SizedBox(height: 16),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              color: AppColors.viewLineColor,
                              height: 0.8,
                            ),

                          ]
                      ),
                    ),
                  ),

                ],
              ),
            )
        ),

      ],
    );
  }

  setUserDefaultCircularImage() {
    return Container(
      width: ScreenUtil().setSp(70),
      height: ScreenUtil().setSp(70),
      child: SvgPicture.asset(
        'assets/images/ic_male_placeholder.svg',
        width: ScreenUtil().setSp(70),
        height: ScreenUtil().setSp(70),
        fit: BoxFit.fill,
      ),

    );
  }
}

