import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/forum_model.dart';
import 'package:solstice/model/groups/groups_model.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/model/routine_post_model.dart';
import 'package:solstice/pages/home/post_detail_screen.dart';
import 'package:solstice/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/utils/dialog_callback.dart';
import 'package:solstice/utils/size_utils.dart';
import 'package:solstice/utils/utilities.dart';

class RoutinePostItem extends StatefulWidget {
  final RoutinePostModel groupItem;

  final int index;

  RoutinePostItem({Key key, @required this.groupItem, @required this.index})
      : super(key: key);

  @override
  _RoutinePostItemState createState() => _RoutinePostItemState();
}

class _RoutinePostItemState extends State<RoutinePostItem>
    implements DialogCallBack {
  RoutinePostModel groupItem;

  @override
  void initState() {
    // TODO: implement initState
    groupItem = widget.groupItem;

    super.initState();
  }

  void _OnGoToGroupDetail() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return PostDetailScreen(
        postIdIntent: groupItem.postFeedModel.postId,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: InkWell(
          onDoubleTap: () {
            completeRoutine();
          },
          onTap: () {
            setState(() {
              _OnGoToGroupDetail();
            });
          },
          child: groupItem.postFeedModel != null
              ? Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  secondaryActions: <Widget>[
                    if (groupItem.postFeedModel.createdBy == globalUserId)
                      IconSlideAction(
                        caption: 'Delete',
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () => {
                          Utilities.confirmDeleteDialog(
                              context,
                              Constants.deletePost,
                              Constants.deletePostConfirmDes,
                              this,1),
                        },
                      ),
                  ],
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(
                        left: ScreenUtil().setSp(20),
                        right: ScreenUtil().setSp(20),
                        top: ScreenUtil().setSp(0)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CachedNetworkImage(
                              imageUrl: groupItem.postFeedModel.mediaList.first
                                          .mediaType ==
                                      "Image"
                                  ? groupItem.postFeedModel.mediaList.first.url
                                  : groupItem
                                      .postFeedModel.mediaList.first.thumbnail,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
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
                              placeholder: (context, url) =>
                                  setPostDefaultImage(context),
                              errorWidget: (context, url, error) =>
                                  setPostDefaultImage(context),
                            ),
                            if (groupItem
                                    .postFeedModel.mediaList.first.mediaType ==
                                "video")
                              Icon(
                                Icons.play_circle_fill_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                          ],
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin:
                                EdgeInsets.only(left: ScreenUtil().setSp(20)),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Hero(
                                    tag: 'titleOfItem${widget.index}',
                                    child: Text(
                                      groupItem.postFeedModel.title,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: AppColors.titleTextColor,
                                          fontFamily: Constants.boldFont,
                                          fontSize: ScreenUtil().setSp(27)),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    groupItem.postFeedModel.description,
                                    maxLines: 4,
                                    style: TextStyle(
                                        color: AppColors.lightGreyColor,
                                        fontFamily: Constants.regularFont,
                                        fontSize: ScreenUtil().setSp(25)),
                                  ),
                                ]),
                          ),
                        ),
                        Visibility(
                          visible: groupItem.complete == 1,
                          maintainAnimation: true,
                          maintainSize: false,
                          maintainState: true,
                          child: Container(
                              child: Image.asset("assets/images/bi_check.png"),
                              height: 28.0),
                        ),
                        Visibility(
                          visible: groupItem.complete == 0,
                          maintainAnimation: true,
                          maintainSize: false,
                          maintainState: true,
                          child: Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0)),
                                  border: Border.all(
                                      width: 2.5,
                                      color: AppColors.primaryColor
                                          .withOpacity(0.75)),
                                  color: Colors.white),
                              child: Center(
                                child: Text(
                                  '${widget.index + 1}',
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      color: AppColors.primaryColor
                                          .withOpacity(0.75),
                                      fontFamily: Constants.mediumFont),
                                  textAlign: TextAlign.center,
                                ),
                              )),
                        )
                      ],
                    ),
                  ),
                )
              : Container(),
        ));
  }

  void completeRoutine() {
    int complete = groupItem.complete;
    Utilities.show(context);
    FirebaseFirestore.instance
        .collection(Constants.routineCollection)
        .doc(groupItem.routineId)
        .collection(Constants.posts)
        .doc(groupItem.id)
        .update({
      "complete": complete == 1 ? 0 : 1,
    }).then((value) {
      setState(() {
        groupItem.complete = complete == 1 ? 0 : 1;
      });

      Utilities.hide();
    }).catchError((err) {
      Utilities.hide();
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

  @override
  void onOkClick(int code) {
    deletePostInRoutine();
  }

  void deletePostInRoutine() {
    FirebaseFirestore.instance
        .collection(Constants.routineCollection)
        .doc(widget.groupItem.routineId)
        .collection(Constants.posts)
        .doc(groupItem.id)
        .delete();
    setState(() {});
  }
}
