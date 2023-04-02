import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/bucket_stitch_model.dart';
import 'package:solstice/model/stitch_routine_model.dart';
import 'package:solstice/pages/buckets_stitch/buckets_stitch_detail_screen.dart';
import 'package:solstice/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';

class BucketStitchListItem extends StatelessWidget {
  final StitchRoutineModel _selectedItem;
  List<StitchRoutineModel> stitchListing;
  final int _index;
  bool fromPostPage;
  Function refreshList;
  bool routinePost;

  BucketStitchListItem(@required this._selectedItem, @required this._index,
      {this.fromPostPage, this.stitchListing, this.refreshList,this.routinePost});

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

  Future _postDetailTapped(StitchRoutineModel postDetail, int _index,
      BuildContext context, setState) async {
    Map results = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return BucketStitchDetailScreen(
            bucketStitchDetailIntent: postDetail,
            index: _index,
          );
        },
      ),
    );

    if (results != null && results.containsKey('update')) {
      var _isUpdate = "";
      setState(() {
        _isUpdate = results['update'];
        if (_isUpdate == "yes") {
          //getDataFromApi(true);
        }
      });
    }
  }

  setViewsOnTypeBasisUI(StitchRoutineModel selectedItem, BuildContext context) {
    return StatefulBuilder(builder: (contet, setState) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: () {
              if (fromPostPage) {
                selectedItem.isSelected = !selectedItem.isSelected;
                if (refreshList != null) {
                  refreshList(_index);
                }
              } else {
                _postDetailTapped(selectedItem, _index, context, setState);
              }
              setState(() {});
            },
            child: Container(
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
                   fromPostPage ? Card(
                                      elevation: 0.8,
                                      borderOnForeground: true,
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            selectedItem.title.substring(0, 1),
                                            style: TextStyle(fontSize: 18.0, color: Colors.black),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )) :  
                                      
                                      
                                      
                    CachedNetworkImage(
                      imageUrl: (selectedItem.image.contains("https:") ||
                              selectedItem.image.contains("http:"))
                          ? selectedItem.image
                          : UrlConstant.BaseUrlImg + selectedItem.image,
                      imageBuilder: (context, imageProvider) => Container(
                        width: fromPostPage
                            ? ScreenUtil().setSp(70)
                            : ScreenUtil().setSp(150),
                        height: fromPostPage
                            ? ScreenUtil().setSp(70)
                            : ScreenUtil().setSp(150),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) =>
                          setPostDefaultImage(context),
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
                           if(!routinePost) Visibility(
                                visible: !fromPostPage,
                                maintainAnimation: true,
                                maintainSize: false,
                                maintainState: true,
                                child: SizedBox(height: 8)),
                           if(!routinePost) Visibility(
                              visible: !fromPostPage,
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
                    visible: fromPostPage && _selectedItem.isSelected,
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
                  ),
                  if(!routinePost && fromPostPage)
                    Container(
                      child: Image.asset(
                        _selectedItem.isPublic
                            ? Constants.publicIcon
                            : Constants.privateIcon,
                        color: Colors.grey,
                        width: 20.0,
                        height: 20.0,
                      ),
                    )
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  setPostDefaultImage(BuildContext context) {
    return Container(
      width: fromPostPage ? ScreenUtil().setSp(70) : ScreenUtil().setSp(150),
      height: fromPostPage ? ScreenUtil().setSp(70) : ScreenUtil().setSp(150),
      decoration: BoxDecoration(
        color: AppColors.viewLineColor,
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
    );
  }
}
