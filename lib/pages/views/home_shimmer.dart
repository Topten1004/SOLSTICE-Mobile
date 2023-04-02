import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:solstice/utils/constants.dart';

class HomeShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: ScreenUtil().setSp(16),right: ScreenUtil().setSp(16),),
      child: _shimmerLayoutHome(context),
    );
  }

  _shimmerLayoutHome(context){
    return Shimmer.fromColors(
      baseColor: Colors.grey[200],
      highlightColor: Colors.grey[300],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  flex: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width ,
                    margin: EdgeInsets.all( ScreenUtil().setSp(20)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: ScreenUtil().setSp(80),
                          width: ScreenUtil().setSp(80),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.all( ScreenUtil().setSp(12)),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    height: 15,
                                    width: MediaQuery.of(context).size.width/4,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 3),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          width: 14,height: 14,
                                          child: SvgPicture.asset(
                                            'assets/images/ic_marker.svg',
                                            alignment: Alignment.center,
                                            fit: BoxFit.fill,
                                            color: AppColors.accentColor,
                                          )
                                      ),
                                      SizedBox(width: 3),
                                      Container(
                                        height: 10,
                                        width: 30,
                                        color: Colors.grey,
                                      ),
                                      Spacer(),
                                      Container(
                                        height: 10,
                                        width: 12,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ]
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: ScreenUtil().setSp(370),
                margin: EdgeInsets.only(
                    left: ScreenUtil().setSp(20),
                    right: ScreenUtil().setSp(20)),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(20)
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                margin: EdgeInsets.only(top: ScreenUtil().setSp(26),bottom: ScreenUtil().setSp(26),right: ScreenUtil().setSp(36),left: ScreenUtil().setSp(36)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                     Container(
                       height: 15,
                       width: MediaQuery.of(context).size.width,
                       color: Colors.grey,
                     ),
                      SizedBox(height: 6),
                      Container(
                        height: 15,
                        width: MediaQuery.of(context).size.width/3,
                        color: Colors.grey,
                      ),

                    ]
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                margin: EdgeInsets.only(right: ScreenUtil().setSp(20),left: ScreenUtil().setSp(20),bottom: ScreenUtil().setSp(36)),
                child: Row(
                  children: [
                    InkWell(
                      child: Container(
                          padding: EdgeInsets.only(left: 10,right: 10,top: 6,bottom: 6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26.0),color: AppColors.lightSkyBlue),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  width: 18,height: 18,
                                  padding: EdgeInsets.all((1)),
                                  child: SvgPicture.asset(
                                    'assets/images/ic_comment.svg',
                                    alignment: Alignment.center,
                                    fit: BoxFit.contain,
                                  )
                              ),
                              SizedBox(width: 8),

                              Text(
                                "",
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: AppColors.titleTextColor,
                                    fontFamily: Constants.boldFont,
                                    fontSize: ScreenUtil().setSp(26)),
                              ),
                              SizedBox(width: 8),

                            ],
                          )
                      ),/*onTap: (){
                setState(() {
                  if(!isSelectedRecent){
                    isSelectedRecent = true;
                  }
                });
              },*/
                    ),
                    SizedBox(width: 10,),
                    InkWell(
                      child: Container(
                          padding: EdgeInsets.only(left: 10,right: 10,top: 4,bottom: 4),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border.all(width: 2,color: AppColors.lightSkyBlue),
                              borderRadius: BorderRadius.circular(26.0)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  width: 18,height: 18,
                                  padding: EdgeInsets.all((1)),
                                  child: SvgPicture.asset(
                                    'assets/images/ic_heart.svg',
                                    alignment: Alignment.center,
                                    fit: BoxFit.contain,
                                  )
                              ),
                              SizedBox(width: 8),

                              Text(
                                "",
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: AppColors.titleTextColor,
                                    fontFamily: Constants.boldFont,
                                    fontSize: ScreenUtil().setSp(26)),
                              ),
                              SizedBox(width: 8),

                            ],
                          )
                      ),/*onTap: (){
                setState(() {
                  if(!isSelectedRecent){
                    isSelectedRecent = true;
                  }
                });
              },*/
                    ),

                    Expanded(
                        flex: 1,
                        child: Container()
                    ),
                    InkWell(
                      child: Container(
                          padding: EdgeInsets.only(left: 12,right: 12,top: 6,bottom: 6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26.0),color: AppColors.lightSkyBlue),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  width: 18,height: 18,
                                  padding: EdgeInsets.all((1)),
                                  child: SvgPicture.asset( 'assets/images/ic_bookmarked.svg'
                                    ,
                                    alignment: Alignment.center,
                                    fit: BoxFit.contain,
                                  )
                              ),
                              SizedBox(width: 10),

                              Text(
                              Constants.save,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontFamily: Constants.boldFont,
                                    fontSize: ScreenUtil().setSp(26)),
                              ),
                              SizedBox(width: 8),

                            ],
                          )
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
