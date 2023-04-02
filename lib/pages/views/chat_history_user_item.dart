import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/pages/chat/chat_users_history_model.dart';
import 'package:solstice/utils/constants.dart';

class ChatHistoryUserItem extends StatefulWidget {
  final ChatHistoryUsersModel chatHistoryItem;
  ChatHistoryUserItem({Key key, @required this.chatHistoryItem})
      : super(key: key);

  @override
  _ChatHistoryUserItemState createState() => _ChatHistoryUserItemState();
}

class _ChatHistoryUserItemState extends State<ChatHistoryUserItem> {
  bool isDataFetched = false;



  @override
  Widget build(BuildContext context) {

    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Container(
          padding: EdgeInsets.only(top: 6.0, bottom: 12.0),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  (widget.chatHistoryItem != null &&
                      widget.chatHistoryItem.userFirebaseModel != null &&
                      widget.chatHistoryItem.userFirebaseModel.userImage != null &&
                      widget.chatHistoryItem.userFirebaseModel.userImage != "null" &&
                      widget.chatHistoryItem.userFirebaseModel.userImage != "")
                      ? setUserImage(widget.chatHistoryItem.userFirebaseModel.userImage)
                      : setUserDefaultCircularImage(),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                      Text(
                        widget.chatHistoryItem != null &&
                            widget.chatHistoryItem.userFirebaseModel != null
                            ? "" + widget.chatHistoryItem.userFirebaseModel.userName.toString()
                            : "",
                        style: TextStyle(
                            fontFamily: 'epilogue_semibold',
                            fontSize: ScreenUtil().setSp(27)),
                      ),
                      SizedBox(height: 2,),

                      Text(

                        widget.chatHistoryItem.msgFrom == globalUserId ?
                        widget.chatHistoryItem.msgType == 1 ? "You: Image": "You: " +widget.chatHistoryItem.lastMsg :
                        widget.chatHistoryItem.msgType == 1 ? "Image": widget.chatHistoryItem.lastMsg,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(26),
                          height: 1.5,
                          letterSpacing: 0.8,
                          fontFamily: 'epilogue_regular',
                        ),
                      ),
                    ],),
                  ),


                  Column(children: [
                    Text(
                      Constants.getTime(widget.chatHistoryItem.timestamp),
                      style: TextStyle(
                          fontFamily: 'epilogue_regular',
                          fontSize: ScreenUtil().setSp(22)),
                    ),
                    widget.chatHistoryItem != null && widget.chatHistoryItem.unSeenMsgCount != null && widget.chatHistoryItem.unSeenMsgCount > 0 ?Container(
                      padding: EdgeInsets.only(top: 4,bottom:2,right:8,left:8),
                      margin: EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: AppColors.primaryColor,
                      ),
                      child: Text(widget.chatHistoryItem.unSeenMsgCount > 999 ? "999+":
                      widget.chatHistoryItem.unSeenMsgCount.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: Constants.regularFont,
                            fontSize: 12),
                      ),
                    ):Container(
                      padding: EdgeInsets.only(top: 4,bottom:2,right:8,left:8),
                      margin: EdgeInsets.only(top: 5),
                    ),
                  ],)
                ],
              ),
              Container(
                margin: EdgeInsets.only(left: 67),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    SizedBox(
                      height: 12,
                    ),
                    Container(
                      height: 1.0,
                      color: AppColors.viewLineColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  setUserDefaultCircularImage() {
    return Container(
      width: 55,
      height: 55,
      child: SvgPicture.asset(
        'assets/images/ic_male_placeholder.svg',
        width: 55,
        height: 55,
        fit: BoxFit.fill,
      ),
    );
  }

  setUserImage(String userImageUrl) {
    return CachedNetworkImage(
      imageUrl:
          (userImageUrl.contains("https:") || userImageUrl.contains("http:"))
              ? userImageUrl
              : UrlConstant.BaseUrlImg + userImageUrl,
      imageBuilder: (context, imageProvider) => Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(50.0)),
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => setUserDefaultCircularImage(),
      errorWidget: (context, url, error) => setUserDefaultCircularImage(),
    );
  }
}
