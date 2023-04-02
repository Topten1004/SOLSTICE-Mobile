import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/model/forum_model_new.dart';
import 'package:solstice/pages/chat/chat_users_history_model.dart';
import 'package:solstice/pages/chat/firebase_chat_screen.dart';
import 'package:solstice/pages/groups/group_details_screen.dart';
import 'package:solstice/pages/views/chat_history_user_item.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/shared_preferences.dart';

class ChatUsersHistoryScreen extends StatefulWidget {
  @override
  _ChatUsersHistoryScreenState createState() => _ChatUsersHistoryScreenState();
}

class _ChatUsersHistoryScreenState extends State<ChatUsersHistoryScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  String userIDPref = "";
  final ScrollController listScrollController = ScrollController();

  int _limit = 10;
  int _limitIncrement = 10;

  @override
  void initState() {
    super.initState();
    listScrollController.addListener(_scrollListenerPrivate);
    getPrefData();
  }

  // initialize private listing scroll listner
  _scrollListenerPrivate() {
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  // Get data from local Storage(SharedPref)
  getPrefData() {
    Future<String> userId = SharedPref.getStringFromPrefs(Constants.USER_ID);
    userId.then(
        (value) => {
              userIDPref = value,
            }, onError: (err) {
    });

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      key: _scaffoldkey,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.white),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                      right: ScreenUtil().setSp(36),
                      top: ScreenUtil().setSp(26),
                      bottom: ScreenUtil().setSp(26)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Visibility(
                        visible: false,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 22,
                            height: 22,
                            padding: EdgeInsets.all(2.5),
                            margin: EdgeInsets.only(left: 8, right: 18),
                            child: SvgPicture.asset(
                              'assets/images/ic_back.svg',
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                            ),
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
                              Text(
                                "Chats",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.titleTextColor,
                                  fontFamily: Constants.boldFont,
                                  fontSize: ScreenUtil().setSp(32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              privateGroupListing(),
            ],
          ),
        ],
      ),
    );
  }

  // private group listing
  Widget privateGroupListing() {
    return Flexible(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(Constants.ChatsFB)
            .orderBy('timestamp', descending: true)
            .where('users', arrayContains: globalUserId)
            .limit(_limit)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor)),
            );
          } else {
            return snapshot.data.docs.isNotEmpty
                ? ListView(
                    padding: EdgeInsets.zero,
                    controller: listScrollController,
                    children: <Widget>[
                      MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView.builder(
                          reverse: false,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            List rev = snapshot.data.docs.toList();

                            List<String> usersList = List.from(rev[index].data()['users']);
                            ChatHistoryUsersModel message =
                                ChatHistoryUsersModel.fromSnapshot(rev[index]);

                            return FutureBuilder(
                                future: loadUser(usersList),
                                builder: (BuildContext context,
                                    AsyncSnapshot<UserFirebaseModel> userFirebase) {
                                  message.userFirebaseModel = userFirebase.data;
                                  return new InkWell(
                                    splashColor: AppColors.primaryColor,
                                    onTap: () {
                                      setState(() {
                                        //_postDetailTapped(message.postId);

                                        if (message.userFirebaseModel != null) {
                                          String chatRoomId = Constants.getChatRoomId(
                                              globalUserId, message.userFirebaseModel.userId);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => ChatFirebase(
                                                        receiverIdIntent:
                                                            message.userFirebaseModel.userId,
                                                        chatRoomIdIntent: chatRoomId,
                                                      )));
                                        }
                                      });
                                    },
                                    child: new ChatHistoryUserItem(
                                        key: ValueKey(message.roomId), chatHistoryItem: message),
                                  );
                                });
                          },
                          itemCount: snapshot.data.docs.length,
                          //controller: listScrollController,
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Container(
                      child: Text(
                        "No chat available",
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(26),
                            fontFamily: Constants.regularFont,
                            height: 1.3,
                            letterSpacing: 0.8),
                      ),
                    ),
                  );
          }
        },
      ),
    );
  }

  // for getting user detail
  Future<UserFirebaseModel> loadUser(List<String> usersList) async {
    String receiverId = "";
    if (usersList != null && usersList.length > 0) {
      if (usersList[0] != globalUserId) {
        receiverId = usersList[0];
      } else {
        receiverId = usersList[1];
      }
    }

    DocumentSnapshot ds =
        await FirebaseFirestore.instance.collection(Constants.UsersFB).doc(receiverId).get();
    if (ds != null)

      // return ds;

      return Future.delayed(Duration(milliseconds: 200), () => UserFirebaseModel.fromSnapshot(ds));
  }
}
