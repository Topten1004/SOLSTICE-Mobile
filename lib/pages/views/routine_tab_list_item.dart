import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/stitch_routine_model.dart';
import 'package:solstice/utils/constants.dart';

class RoutineTabListItem extends StatelessWidget {
  final StitchRoutineModel _selectedItem;
  final int _index;

  RoutineTabListItem(
    @required this._selectedItem,
    @required this._index,
  );

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: ScreenUtil().setSp(16),
        right: ScreenUtil().setSp(16),
      ),
      child: setViewsOnTypeBasisUI(_selectedItem, context),
    );
  }

  setViewsOnTypeBasisUI(StitchRoutineModel selectedItem, BuildContext context) {
    return StatefulBuilder(builder: (contet, setState) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(
                left: ScreenUtil().setSp(20),
                right: ScreenUtil().setSp(20),
                top: ScreenUtil().setSp(0),
                bottom: ScreenUtil().setSp(50)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: (selectedItem.image.contains("https:") ||
                          selectedItem.image.contains("http:"))
                      ? selectedItem.image
                      : UrlConstant.BaseUrlImg + selectedItem.image,
                  imageBuilder: (context, imageProvider) => Container(
                    width: ScreenUtil().setSp(150),
                    height: ScreenUtil().setSp(150),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => setPostDefaultImage(context),
                  errorWidget: (context, url, error) =>
                      setPostDefaultImage(context),
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
                          Hero(
                            tag: 'titleOfItem$_index',
                            child: Text(
                              selectedItem.title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: AppColors.titleTextColor,
                                  fontFamily: Constants.boldFont,
                                  fontSize: ScreenUtil().setSp(27)),
                            ),
                          ),
                          Visibility(
                              visible: true,
                              maintainAnimation: true,
                              maintainSize: false,
                              maintainState: true,
                              child: SizedBox(height: 8)),
                          Visibility(
                            visible: true,
                            maintainAnimation: true,
                            maintainSize: false,
                            maintainState: true,
                            child: Text(
                              _selectedItem.description,
                              maxLines: 4,
                              style: TextStyle(
                                  color: AppColors.lightGreyColor,
                                  fontFamily: Constants.regularFont,
                                  fontSize: ScreenUtil().setSp(25)),
                            ),
                          ),
                        ]),
                  ),
                ),
                Visibility(
                  visible: _selectedItem.isSelected,
                  child: Container(
                    width: 24,
                    height: 24,
                    padding: EdgeInsets.all(2.5),
                    child: SvgPicture.asset(
                      Constants.checkIcon,
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      );
    });
  }

  setPostDefaultImage(BuildContext context) {
    return Container(
      width: ScreenUtil().setSp(150),
      height: ScreenUtil().setSp(150),
      decoration: BoxDecoration(
        color: AppColors.viewLineColor,
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
    );
  }
}
