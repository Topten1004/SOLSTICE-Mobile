import 'package:cached_network_image/cached_network_image.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/model/commments_model.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/model/tabs_models.dart';
import 'package:solstice/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/utils/size_utils.dart';

class TabListItem extends StatelessWidget {
  final TabsModel _selectedItem;
  final bool blackText;

  TabListItem(this._selectedItem, {this.blackText = false});

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: setViewsOnTypeBasis(_selectedItem, context),
    );
  }

  setViewsOnTypeBasis(TabsModel selectedItem, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(
            height: ScreenUtil().setSp(150),
            margin: EdgeInsets.only(
              right: ScreenUtil().setSp(16),
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26.0),
              color: selectedItem.isSelected
                  ? (blackText ? AppColors.blueColor : AppColors.primaryColor)
                  : Colors.transparent,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: ScreenUtil().setSp(145),
                  minHeight: ScreenUtil().setSp(50),
                  maxHeight: ScreenUtil().setSp(50)),
              child: Center(
                child: Wrap(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        left: ScreenUtil().setSp(16),
                        right: ScreenUtil().setSp(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        selectedItem.tabTitle,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: selectedItem.isSelected
                                ? Colors.white
                                : (blackText
                                    ? AppColors.darkTextColor
                                    : AppColors.blueColor),
                            fontSize: ScreenUtil().setSp(24)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
