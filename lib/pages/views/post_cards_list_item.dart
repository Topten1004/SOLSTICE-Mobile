import 'dart:collection';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/cards_fb_model.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/pages/home/save_to_routine.dart';
import 'package:solstice/pages/home/save_to_stitch.dart';
import 'package:solstice/pages/views/card_detail.dart';
import 'package:solstice/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/utils/dialog_callback.dart';
import 'package:solstice/utils/utilities.dart';

class PostCardsListItem extends StatelessWidget implements DialogCallBack {
  final CardsFbModel cardItem;
  final String createdBy, postId;
  final PostFeedModel postFeedModel;

  PostCardsListItem(
      {Key key,
      @required this.cardItem,
      this.createdBy,
      this.postId,
      this.postFeedModel})
      : super(key: key);
  String cardId;
  var state;

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: ScreenUtil().setSp(32),
        right: ScreenUtil().setSp(32),
      ),
      child: StatefulBuilder(
        builder: (context, setState) {
          return setViewsOnTypeBasis(cardItem, context, setState);
        },
      ),
    );
  }

  setViewsOnTypeBasis(
      CardsFbModel selectedItem, BuildContext context, setState) {
    
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(
          top: ScreenUtil().setSp(10), bottom: ScreenUtil().setSp(16)),
      child: Container(
        padding: EdgeInsets.only(
            left: ScreenUtil().setSp(20),
            right: ScreenUtil().setSp(20),
            top: ScreenUtil().setSp(12),
            bottom: ScreenUtil().setSp(12)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              offset: Offset(0.0, 4.0), //(x,y)
              blurRadius: 8.0,
            ),
          ],
        ),
        child: Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          actions: [
            if (createdBy == globalUserId)
              IconSlideAction(
                caption: 'Edit',
                color: Colors.blue,
                icon: Icons.delete,
                onTap: () => {
                  cardId = selectedItem.id,
                  state = setState,
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CardDetail(
                                postId: postId,
                                indexKey: 0,
                                selectedItem: selectedItem,
                                postVideoFilesMap: HashMap(),
                              )))
                },
              ),
          ],
          secondaryActions: <Widget>[
            if (createdBy == globalUserId)
              IconSlideAction(
                caption: 'Delete',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () => {
                  cardId = selectedItem.id,
                  state = setState,
                  Utilities.confirmDeleteDialog(context, Constants.deleteCard,
                      Constants.deleteCardConfirmDes, this, 1),
                },
              ),
          ],
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: (selectedItem.image.contains("https:") ||
                            selectedItem.image.contains("http:"))
                        ? selectedItem.image
                        : UrlConstant.BaseUrlImg + selectedItem.image,
                    imageBuilder: (context, imageProvider) => Container(
                      width: ScreenUtil().setSp(120),
                      height: ScreenUtil().setSp(120),
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
                  if (selectedItem.mediaType == 2)
                    Icon(Icons.play_circle_fill_outlined, color: Colors.white)
                ],
              ),
              SizedBox(
                width: 4,
              ),
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.all(ScreenUtil().setSp(12)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          selectedItem.title,
                          maxLines: 2,
                          style: TextStyle(
                              color: AppColors.titleTextColor,
                              fontFamily: Constants.boldFont,
                              fontSize: ScreenUtil().setSp(26)),
                        ),
                      ]),
                ),
              ),
              InkWell(
                  onTap: () {
                    setState(() {
                      savePostToStitch(context, "Stitch");
                    });
                  },
                  child: Container(
                      padding:
                          EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26.0),
                          color: AppColors.lightSkyBlue),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: 18,
                              height: 18,
                              padding: EdgeInsets.all((1)),
                              child: SvgPicture.asset(
                                // _selectedItem.isSaved ? 'assets/images/ic_bookmarked.svg':
                                'assets/images/ic_bookmark.svg',
                                alignment: Alignment.center,
                                fit: BoxFit.contain,
                              )),
                          SizedBox(width: 7),
                          Text(
                            "Stitch",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: AppColors.primaryColor,
                                fontFamily: Constants.boldFont,
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenUtil().setSp(24)),
                          ),
                          SizedBox(width: 3),
                        ],
                      ))),
              SizedBox(
                width: 8,
              ),
              InkWell(
                  onTap: () {
                    savePostToStitch(context, "Routine");
                  },
                  child: Container(
                      padding:
                          EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26.0),
                          color: AppColors.lightSkyBlue),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: 18,
                              height: 18,
                              padding: EdgeInsets.all((1)),
                              child: SvgPicture.asset(
                                // _selectedItem.isSaved ? 'assets/images/ic_bookmarked.svg':
                                'assets/images/ic_bookmark.svg',
                                alignment: Alignment.center,
                                fit: BoxFit.contain,
                              )),
                          SizedBox(width: 7),
                          Text(
                            "Routine",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: AppColors.primaryColor,
                                fontFamily: Constants.boldFont,
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenUtil().setSp(24)),
                          ),
                          SizedBox(width: 3),
                        ],
                      ))),
            ],
          ),
        ),
      ),
    );
  }

  setPostDefaultImage(BuildContext context) {
    return Container(
      width: ScreenUtil().setSp(120),
      height: ScreenUtil().setSp(120),
      decoration: BoxDecoration(
        color: AppColors.viewLineColor,
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
    );
  }

  Future<void> savePostToStitch(context, String saveTo) async {
    Utilities.show(context);
    var postId = DateTime.now().millisecondsSinceEpoch.toString();
    var documentReference =
        FirebaseFirestore.instance.collection(Constants.posts).doc(postId);
    List<HashMap<String, dynamic>> mediaMapList = new List();
    if (mediaMapList.length == 0) {
      HashMap<String, dynamic> map = new HashMap();
      map["thumbnail"] = cardItem.image;
      map["url"] = cardItem.mediaType == 2 ? cardItem.videoUrl : cardItem.image;
      map["type"] = cardItem.mediaType == 2 ? "video" : "Image";
      mediaMapList.add(map);
    }

    PostFeedModel postFeedModel = new PostFeedModel(
        active: 0,
        createdAt: Timestamp.now(),
        commentCount: 0,
        description: cardItem.description,
        title: cardItem.title,
        postId: postId,
        createdBy: globalUserId,
        mediaMapList: mediaMapList,
        isCardPost: true,
        latitude: "0.0",
        isPublic: true,
        longitude: "0.0",
        location: " ",
        likeCount: 0,
        upatedAt: Timestamp.now());

    documentReference
        .set(postFeedModel.toMap())
        .then((value) {})
        .catchError((exc) {
    });
    Utilities.hide();
    if (saveTo == "Stitch") {
      var object = await showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0)),
          ),
          builder: (BuildContext context) {
            return SaveToStitch();
          });

      if (object != null) {
        var stichId = object["stitch_id"];
        addStitchToPost(context, stichId, postId);
      }
    } else {
      var object = await showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0)),
          ),
          builder: (BuildContext context) {
            return SaveToRoutine();
          });

      if (object != null) {
        var routineId = object["routine_id"];
        addRoutineToPost(context, routineId, postId);
      }
    }
  }

  void addStitchToPost(BuildContext context, stichId, postId) {
    FirebaseFirestore.instance
        .collection(Constants.stitchCollection)
        .doc(stichId)
        .update({
          'post_ids': FieldValue.arrayUnion([postId])
        })
        .then((value) =>
            Constants().successToast(context, "Post added to stitch"))
        .onError((error, stackTrace) => print('onError $error'));
  }

  void addRoutineToPost(BuildContext context, routineId, postId) {
    FirebaseFirestore.instance
        .collection(Constants.routineCollection)
        .doc(routineId)
        .collection(Constants.posts)
        .add({'post_id': postId, 'complete': 0}).then((value) =>
            Constants().successToast(context, "Post added to routine"));
  }

  @override
  void onOkClick(int code) {
    deleteCard();
  }

// Delete Card
  void deleteCard() {
    FirebaseFirestore.instance
        .collection(Constants.posts)
        .doc(postId)
        .collection(Constants.cardsColl)
        .doc(cardId)
        .delete();
    state(() {});
  }
}
