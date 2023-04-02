import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/forum_model_new.dart';
import 'package:solstice/model/stitch_routine_model.dart';
import 'package:solstice/pages/onboardingflow/Profile_user.dart';
import 'package:solstice/pages/profile/other_user_profile.dart';
import 'package:solstice/utils/constants.dart';

class FollowersListItem extends StatefulWidget {
  final int _index;
  final UserFirebaseModel _selectedItem;

  FollowersListItem(@required this._selectedItem, @required this._index);

  @override
  _FollowersListItemState createState() => _FollowersListItemState();
}

class _FollowersListItemState extends State<FollowersListItem> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: ScreenUtil().setSp(24),
        right: ScreenUtil().setSp(24),
      ),
      child: widget._selectedItem != null
          ? setViewsOnTypeBasis(widget._selectedItem, context)
          : Container(),
    );
  }

  setViewsOnTypeBasis(UserFirebaseModel selectedItem, BuildContext context) {
    return Container(
        child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile_User_Screen(
                      userID: selectedItem.userId,
                      userName: selectedItem.userName,
                      userImage: selectedItem.userImage,
                      viewType: "followers_list_item",
                    ),
                  ));
            },
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                width: MediaQuery.of(context).size.width,
                child: Row(mainAxisSize: MainAxisSize.max, children: [
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      height: 75.0,
                      width: 75.0,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          // child: selectedItem != null && selectedItem.userImage != null
                          //     ? CachedNetworkImage(
                          //         imageUrl: selectedItem.userImage,
                          //         height: 75.0,
                          //         width: 75.0,
                          //         fit: BoxFit.cover,
                          //         placeholder: (context, url) => Center(
                          //           child: SizedBox(
                          //             width: 30.0,
                          //             height: 30.0,
                          //             child: new CircularProgressIndicator(),
                          //           ),
                          //         ),
                          //         errorWidget: (context, url, error) =>
                          //             setUserDefaultCircularImage(),
                          //       )
                          //     : setUserDefaultCircularImage()
                      )),
                  SizedBox(
                    width: 5.0,
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    child: Text(
                      selectedItem != null ? selectedItem.userName : "",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  selectedItem != null
                      ? InkWell(
                          onTap: () {
                            followUnfollowCount(selectedItem, selectedItem.userId);
                          },
                          child: Container(
                            height: 30,
                            width: 95,
                            alignment: Alignment.center,
                            decoration: selectedItem != null && selectedItem.isFollow
                                ? BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                    color: Color.fromRGBO(26, 88, 231, 1))
                                : BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                    border: Border.all(color: Color.fromRGBO(26, 88, 231, 1)),
                                    color: Color.fromRGBO(235, 241, 255, 1)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  selectedItem != null && selectedItem.isFollow
                                      ? Icons.check
                                      : Icons.add,
                                  color: selectedItem != null && selectedItem.isFollow
                                      ? Colors.white
                                      : AppColors.primaryColor,
                                  size: 16,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 2),
                                  child: Text(
                                      selectedItem != null && selectedItem.isFollow
                                          ? "Followed"
                                          : "Follow",
                                      style: new TextStyle(
                                          color: selectedItem != null && selectedItem.isFollow
                                              ? Colors.white
                                              : AppColors.primaryColor,
                                          fontFamily: Constants.mediumFont,
                                          //fontWeight: FontWeight.bold,
                                          fontSize: 12.0)),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(),
                ]))));
  }

  void followUnfollowCount(selectedItem, String userId) {
    if (selectedItem.isFollow) {
      FirebaseFirestore.instance.collection(Constants.UsersFB).doc(userId).update({
        'followers': FieldValue.arrayRemove([globalUserId])
      }).then(
          (value) => {
                setState(() {
                  selectedItem.isFollow = false;
                })
              }, onError: (err) {
      });
    } else {
      FirebaseFirestore.instance.collection(Constants.UsersFB).doc(userId).update({
        'followers': FieldValue.arrayUnion([globalUserId])
      }).then(
          (value) => {
                setState(() {
                  selectedItem.isFollow = true;
                })
              }, onError: (err) {
      });
    }
  }

  setUserDefaultCircularImage() {
    return Container(
      height: 75.0,
      width: 75.0,
      child: SvgPicture.asset(
        'assets/images/ic_male_placeholder.svg',
        height: 75.0,
        width: 75.0,
        fit: BoxFit.fill,
      ),
    );
  }
}
