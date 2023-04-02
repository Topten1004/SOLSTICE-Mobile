import 'package:cached_network_image/cached_network_image.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/forum_model.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/utils/size_utils.dart';

class ForumListItem extends StatefulWidget {
  final ForumFireBaseModel _selectedItem;

  ForumListItem(this._selectedItem);

  @override
  _ForumListItemState createState() => _ForumListItemState();
}

class _ForumListItemState extends State<ForumListItem> {
//class  extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: ScreenUtil().setSp(16),
        right: ScreenUtil().setSp(16),
      ),
      child: widget._selectedItem != null
          ? setViewsOnTypeBasis(widget._selectedItem, context)
          : Container(),
    );
  }

  setViewsOnTypeBasis(ForumFireBaseModel selectedItem, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
            flex: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(ScreenUtil().setSp(20)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  selectedItem != null
                      ? CachedNetworkImage(
                          // imageUrl: (selectedItem.createdByImage.contains("https:") ||
                          //         selectedItem.createdByImage.contains("http:"))
                          //     ? selectedItem.createdByImage
                          //     : UrlConstant.BaseUrlImg + selectedItem.createdByImage,
                          imageUrl: UrlConstant.BaseUrlImg +
                              selectedItem.createdByImage,
                          imageBuilder: (context, imageProvider) => Container(
                            width: Dimens.imageSize25(),
                            height: Dimens.imageSize25(),
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
                          placeholder: (context, url) =>
                              Constants().setUserDefaultCircularImage(),
                          errorWidget: (context, url, error) =>
                              Constants().setUserDefaultCircularImage(),
                        )
                      : Constants().setUserDefaultCircularImage(),
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.all(ScreenUtil().setSp(12)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              selectedItem.createdByImage != null
                                  ? " ${selectedItem.createdByImage}"
                                  : " ",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: AppColors.titleTextColor,
                                  fontFamily: Constants.boldFont,
                                  fontSize: ScreenUtil().setSp(26)),
                            ),
                            SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    width: 16,
                                    height: 16,
                                    child: SvgPicture.asset(
                                      'assets/images/ic_marker.svg',
                                      alignment: Alignment.center,
                                      fit: BoxFit.fill,
                                      color: AppColors.accentColor,
                                    )),
                                SizedBox(width: 3),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    widget._selectedItem.postAddress,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: AppColors.accentColor,
                                        fontFamily: Constants.regularFont,
                                        fontSize: ScreenUtil().setSp(22)),
                                  ),
                                ),
                                Text(
                                  widget._selectedItem.timestamp,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: AppColors.titleTextColor,
                                      fontFamily: Constants.mediumFont,
                                      fontSize: ScreenUtil().setSp(22)),
                                ),
                              ],
                            ),
                          ]),
                    ),
                  ),
                ],
              ),
            )),
        Container(
          margin: EdgeInsets.only(
              top: ScreenUtil().setSp(26),
              bottom: ScreenUtil().setSp(26),
              right: ScreenUtil().setSp(20),
              left: ScreenUtil().setSp(20)),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget._selectedItem.description,
                  maxLines: 2,
                  style: TextStyle(
                      color: AppColors.titleTextColor,
                      fontFamily: Constants.regularFont,
                      fontSize: ScreenUtil().setSp(23)),
                ),
              ]),
        ),
        Container(
          margin: EdgeInsets.only(
              right: ScreenUtil().setSp(20),
              left: ScreenUtil().setSp(20),
              bottom: ScreenUtil().setSp(36)),
          child: Row(
            children: [
              InkWell(
                child: Container(
                    padding: EdgeInsets.only(top: 6, bottom: 6),
                    alignment: Alignment.center,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 18,
                            height: 18,
                            padding: EdgeInsets.all((1)),
                            child: SvgPicture.asset(
                              'assets/images/ic_comment.svg',
                              alignment: Alignment.center,
                              color: AppColors.accentColor,
                              fit: BoxFit.contain,
                            )),
                        SizedBox(width: 8),
                        Text(
                          "_0" + " " + Constants.comments,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColors.titleTextColor,
                              fontFamily: Constants.lightFont,
                              fontSize: ScreenUtil().setSp(24)),
                        ),
                        SizedBox(width: 8),
                      ],
                    )), /*onTap: (){
                setState(() {
                  if(!isSelectedRecent){
                    isSelectedRecent = true;
                  }
                });
              },*/
              ),
              SizedBox(
                width: 10,
              ),
              InkWell(
                child: Container(
                    padding: EdgeInsets.only(top: 4, bottom: 4),
                    alignment: Alignment.center,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 18,
                            height: 18,
                            padding: EdgeInsets.all((1.5)),
                            child: SvgPicture.asset(
                              'assets/images/ic_heart.svg',
                              alignment: Alignment.center,
                              color: AppColors.accentColor,
                              fit: BoxFit.contain,
                            )),
                        SizedBox(width: 8),
                        Text(
                          "0" + " " + Constants.likes,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColors.titleTextColor,
                              fontFamily: Constants.lightFont,
                              fontSize: ScreenUtil().setSp(24)),
                        ),
                        SizedBox(width: 8),
                      ],
                    )), /*onTap: (){
                setState(() {
                  if(!isSelectedRecent){
                    isSelectedRecent = true;
                  }
                });
              },*/
              ),
              Expanded(flex: 1, child: Container()),
            ],
          ),
        )
      ],
    );
  }

  setPostDefaultImage(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: ScreenUtil().setSp(370),
      decoration: BoxDecoration(
        color: AppColors.viewLineColor,
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
    );
  }
}
