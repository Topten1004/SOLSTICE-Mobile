import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/model/forum_model_new.dart';
import 'package:solstice/model/stitch_routine_model.dart';
import 'package:solstice/pages/profile/other_user_profile.dart';
import 'package:solstice/pages/views/followers_list_item.dart';
import 'package:solstice/utils/constants.dart';
import 'package:flutter_screenutil/screenutil.dart';

class FollowersListingScreen extends StatefulWidget {
  String userId;
  FollowersListingScreen({this.userId});
  @override
  _FollowersListingScreenState createState() => _FollowersListingScreenState();
}

class _FollowersListingScreenState extends State<FollowersListingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  String userID;
  @override
  void initState() {
    // TODO: implement initState
    userID = widget.userId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
        key: _scaffoldkey,
        body: Stack(children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.white),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).padding.top,
              ),
              Expanded(
                flex: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(
                      left: ScreenUtil().setSp(20),
                      right: ScreenUtil().setSp(20),
                      top: ScreenUtil().setSp(26),
                      bottom: ScreenUtil().setSp(26)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 22,
                          height: 22,
                          padding: EdgeInsets.all(2.5),
                          margin: EdgeInsets.only(left: 8),
                          child: SvgPicture.asset(
                            'assets/images/ic_back.svg',
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.all(ScreenUtil().setSp(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Followers",
                                  style: TextStyle(
                                    color: AppColors.titleTextColor,
                                    fontFamily: Constants.boldFont,
                                    fontSize: ScreenUtil().setSp(32),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 22,
                        padding: EdgeInsets.all(2.5),
                        margin: EdgeInsets.only(right: 8),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("Users")
                        .doc(userID)
                        .snapshots(),
                    builder: (context, snapshot) {
                      var followersList = snapshot.data["followers"];

                      // if (followersList.length==0) {
                      //   return Center(
                      //     child: CircularProgressIndicator(
                      //         valueColor:
                      //             AlwaysStoppedAnimation<Color>(
                      //                 AppColors.primaryColor)),
                      //   );
                      // }
                      if (followersList.length == 0) {
                        return Center(
                            child: Text(
                          'No Followers',
                          style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                              fontFamily: Constants.mediumFont),
                          textAlign: TextAlign.center,
                        ));
                      }
                      return followersListing(context, followersList);
                    }),
              )
            ],
          )
        ]));
  }

  Future<UserFirebaseModel> loadUser(userId) async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(userId)
        .get();
    if (ds != null)
      return Future.delayed(Duration(milliseconds: 100),
          () => UserFirebaseModel.fromSnapshot(ds));
  }

  Widget followersListing(BuildContext context, List followersList) {
    return ListView(
      padding: EdgeInsets.zero,
      //controller: listScrollController,
      children: <Widget>[
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            // itemCount: snapshots.data.docs.length,
            itemCount: followersList.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              // List stitchList = snapshots.data.docs.reversed.toList();

              return FutureBuilder(
                  future: loadUser(followersList[index]),
                  builder: (BuildContext context,
                      AsyncSnapshot<UserFirebaseModel> userFirebase) {
                    UserFirebaseModel userModel = userFirebase.data;
                    if (userFirebase != null) {
                      if (userModel != null && userModel.followers != null)
                        for (int i = 0; i < userModel.followers.length; i++) {
                          if (userModel.followers[i] == globalUserId) {
                            userModel.isFollow = true;
                            break;
                          }
                        }
                    }
                    return userFirebase != null
                        ? new InkWell(
                            //highlightColor: Colors.red,
                            splashColor: AppColors.primaryColor,
                            onTap: () {
                              setState(() {});
                            },
                            child: new FollowersListItem(userModel, index),
                          )
                        : Container(); /*  */
                  });
            },
          ),
        ),
      ],
    );
  }
}
