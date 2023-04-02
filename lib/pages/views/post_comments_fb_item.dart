import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/Posts/post_comments_model.dart';
import 'package:solstice/model/Posts/post_comments_model.dart';
import 'package:solstice/model/forum_model.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/pages/profile/other_user_profile.dart';
import 'package:solstice/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/utils/size_utils.dart';

class PostCommentsFbItem extends StatefulWidget {
  final PostCommentsFireBaseModel postCommentItem;
  PostCommentsFbItem({Key key, @required this.postCommentItem})
      : super(key: key);

  @override
  _PostCommentsFbItemState createState() => _PostCommentsFbItemState();
}

class _PostCommentsFbItemState extends State<PostCommentsFbItem> {
  bool isDataFetched = false;
  UserFirebaseModel userItem;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //groupItem = widget.groupItem;

    if (!isDataFetched) {
      loadUser(widget.postCommentItem.uid);
      isDataFetched = true;
    }
  }

  Future<void> loadUser(String createdBy) async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(createdBy)
        .get();
    if (ds != null) {
      userItem = UserFirebaseModel.fromSnapshot(ds);

      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
/*

    if(postCommentItemTemp != null){
      if(postCommentItemTemp.id != widget.postCommentItem.id){
        loadUser(widget.postCommentItem.commentBy);
        getForumsLikesDislikes();
        getCommentsCount();
        isDataFetched = true;
      }
    }
*/

    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Container(
          padding: EdgeInsets.only(top: 16.0, bottom: 0.0),
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: () {
                  if (globalUserId != userItem.userId) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtherUserProfile(
                            userID: userItem.userId,
                            userName: userItem.userName,
                            userImage: userItem.userImage,
                          ),
                        ));
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    (userItem != null &&
                            userItem.userImage != null &&
                            userItem.userImage != "null" &&
                            userItem.userImage != "")
                        ? setUserImage(userItem.userImage)
                        : setUserDefaultCircularImage(),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      userItem != null
                          ? " " + userItem.userName.toString()
                          : "",
                      style: TextStyle(
                          fontFamily: 'epilogue_semibold',
                          fontSize: ScreenUtil().setSp(27)),
                    ),
                    Spacer(),
                    Text(
                      Constants.getTime(widget.postCommentItem.timestamp),
                      style: TextStyle(
                          fontFamily: 'epilogue_regular',
                          fontSize: ScreenUtil().setSp(22)),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: ScreenUtil().setSp(70) + 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      "" + widget.postCommentItem.comment,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26),
                        height: 1.5,
                        letterSpacing: 0.8,
                        fontFamily: 'epilogue_regular',
                      ),
                    ),
                    SizedBox(
                      height: 16,
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

  setUserImage(String userImageUrl) {
    return CachedNetworkImage(
      imageUrl:
          (userImageUrl.contains("https:") || userImageUrl.contains("http:"))
              ? userImageUrl
              : UrlConstant.BaseUrlImg + userImageUrl,
      imageBuilder: (context, imageProvider) => Container(
        width: ScreenUtil().setSp(70),
        height: ScreenUtil().setSp(70),
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
