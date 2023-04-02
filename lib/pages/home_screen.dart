import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:solstice/pages/buckets_stitch/buckets_stitch_tab_screen.dart';
import 'package:solstice/pages/chat/chat_users_history_screen.dart';
import 'package:solstice/pages/feeds/feed_listing.dart';
import 'package:solstice/pages/forums/forum_tab_screen.dart';
import 'package:solstice/pages/groups/groups_tab_screen.dart';
import 'package:solstice/pages/onboardingflow/Profile_user.dart';
import 'package:solstice/pages/profile/profile_tab_screen.dart';
import 'package:solstice/utils/constants.dart';

class HomeScreen extends StatefulWidget {
  int currentIndex = 0;
  HomeScreen({this.currentIndex});
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;

    _tabController =
        TabController(vsync: this, initialIndex: _currentIndex, length: _Tab.values.length);
    getPostStaticImage();

    if (globalUserId != null) {
      getUnSeenChatsCount();
    }
  }

  Future<void> getUnSeenChatsCount() async {
    var snapshots = await FirebaseFirestore.instance
        .collection(Constants.ChatsFB)
        .where('users', arrayContains: globalUserId)
        //.where('unSeenCount.$globalUserId', isGreaterThan: 0)
        .snapshots();
    snapshots.listen((querySnapshot) {
      // globals.unreadMsgCountDietitianSide = querySnapshot.docs.length;

      int unSeenChats = 0;
      try {
        for (int i = 0; i < querySnapshot.docs.length; i++) {
          if (querySnapshot.docs[i].data().containsKey("unSeenCount")) {
            int unseenCount = querySnapshot.docs[i]['unSeenCount'][globalUserId];
            unseenCount = unseenCount > 0 ? 1 : 0;
            unSeenChats = unSeenChats + unseenCount;
          }
        }
      } catch (e) {}

      globalUserUnSeenChats = unSeenChats;

      if (mounted) {
        setState(() {});
      }
    });
  }

  void getPostStaticImage() {
    FirebaseFirestore.instance
        .collection(Constants.settingsCollec)
        .get()
        .then((value) => defaultPostImage = value.docs.first.data()["post_image"]);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
        // we set our instantiated TabController as the controller
        children: <Widget>[
          // the order must correspond to the order given below in bottomNavigationBar
          // HomeTabScreen(),
          FeedListing(),
          BucketStitchTabScreen(),
          GroupsTabScreen(),
          // ForumsTabScreen(),
          ChatUsersHistoryScreen(),

          Profile_User_Screen(
            userID: globalUserId,
            userName: globalUserName,
            userImage: globaUserProfileImage,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.lightGreyColor,
        type: BottomNavigationBarType.fixed,
        onTap: onTappedBar,
        currentIndex: _currentIndex,
        items: _Tab.values
            .map((_Tab tab) => BottomNavigationBarItem(
                title: Text(
                  _getTitleForCurrentTab(tab),
                  style:
                      TextStyle(fontSize: ScreenUtil().setSp(25), fontFamily: 'poppins_semibold'),
                ),
                // set the title of the tab icon
                icon: Image.asset(
                  _getAssetForTab(tab),
                  width: ScreenUtil().setSp(44),
                  height: ScreenUtil().setSp(44),
                ))) // set the icon of the tab
            .toList(),
      ),
    );
  }

  void onTappedBar(int index) {
    _currentIndex = index;

    _tabController.animateTo(index);

    if (mounted) setState(() {});
  }

  /// Get the asset icon for the given tab
  String _getAssetForTab(_Tab tab) {
    // check if the given tab parameter is the current active tab
    final active = tab == _Tab.values[_currentIndex];
    // now given the tab param get its icon considering the fact that if it is active or not
    if (tab == _Tab.TAB1) {
      return active ? 'assets/images/ic_home_active.png' : 'assets/images/ic_home_unactive.png';
    } else if (tab == _Tab.TAB2) {
      return active ? 'assets/images/ic_grid_active.png' : 'assets/images/ic_grid_unactive.png';
    } else if (tab == _Tab.TAB3) {
      return active ? 'assets/images/ic_group_active.png' : 'assets/images/ic_group_unactive.png';
    } else if (tab == _Tab.TAB4) {
      return active ? 'assets/images/ic_chat_active.png' : 'assets/images/ic_chat_unactive.png';
    } else if (tab == _Tab.TAB5) {
      return active ? 'assets/images/ic_person_active.png' : 'assets/images/ic_person_unactive.png';
    }
  }

  String _getTitleForCurrentTab(_Tab tab) {
    if (tab == _Tab.TAB1) {
      return 'Home';
    } else if (tab == _Tab.TAB2) {
      return 'Grid';
    } else if (tab == _Tab.TAB3) {
      return 'Groups';
    } else if (tab == _Tab.TAB4) {
      return 'Chat';
    } else if (tab == _Tab.TAB5) {
      return 'Person';
    }
  }
}

enum _Tab {
  TAB1,
  TAB2,
  TAB3,
  TAB4,
  TAB5,
}
