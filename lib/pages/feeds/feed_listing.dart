import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/model/feed_model.dart';
import 'package:solstice/model/forum_model.dart';
import 'package:solstice/model/routine_model.dart';
import 'package:solstice/model/tabs_models.dart';
import 'package:solstice/pages/feeds/card_feed_item.dart';
import 'package:solstice/pages/onboardingflow/biz_Q_four.dart';
import 'package:solstice/pages/onboardingflow/biz_Q_one.dart';
import 'package:solstice/pages/onboardingflow/gender_selection.dart';
import 'package:solstice/pages/onboardingflow/personal_Info_Screen.dart';
import 'package:solstice/pages/onboardingflow/profiletypescreen.dart';
import 'package:solstice/pages/routine/routine_name.dart';
import 'package:solstice/pages/views/tab_list_item.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/shared_preferences.dart';

class FeedListing extends StatefulWidget {
  @override
  _FeedListingState createState() => _FeedListingState();
}

class _FeedListingState extends State<FeedListing>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  List<TabsModel> categoriesList = new List<TabsModel>.empty(growable: true);
  String selectedTab = "All";
  String categoryId = "";

  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    categoriesList.add(TabsModel("All", true));
    getCategories();
    // addCategoriesToFeed();
    super.initState();
  }

  addCategoriesToFeed() {
    FirebaseFirestore.instance.collection(Constants.feedsColl).get().then((value) {
      value.docs.forEach((element) {
        FirebaseFirestore.instance
            .collection(Constants.routineFeedCollection)
            .doc(element.data()["item_id"])
            .get()
            .then((value) {
          RoutineModel routineModel = RoutineModel.fromJson(value);
          List<String> categoriesList = new List.empty(growable: true);
          categoriesList.clear();
          for (int i = 0; i < routineModel.categoryList.length - 1; i++) {
            categoriesList.add(routineModel.categoryList[i].title);
            if (i == routineModel.categoryList.length - 1) {
              FirebaseFirestore.instance.collection(Constants.feedsColl).doc("1fOADKmRwnZv2r0KXhmu")
                  // .doc(element.id)
                  .set({"category_list": categoriesList}, SetOptions(merge: true));

            }
          }
        });
      });
    });
  }

  void getCategories() async {
    var collectionReference =
        FirebaseFirestore.instance.collection(Constants.trainingCategories).get();
    collectionReference.then((value) {
      final List<DocumentSnapshot> docs = value.docs;
      docs.forEach((data) {
        final Map<String, dynamic> dataMap = data.data();
        categoriesList.add(TabsModel(dataMap["title"], false, id: data.id));
        if (data.id == value.docs[value.docs.length - 1].id) {
          setState(() {});
        }
      });
    }).catchError((onError) {
    });
  }

  Widget suggestedWidget() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Suggested For You',
              style: TextStyle(
                  fontSize: 18.0, color: AppColors.darkTextColor, fontWeight: FontWeight.w700),
              textAlign: TextAlign.start,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Text(
                'Because you like $selectedTab',
                style: TextStyle(
                    fontSize: 11.0, color: AppColors.greyTextColor, fontWeight: FontWeight.w400),
                textAlign: TextAlign.start,
              ),
            )
          ],
        ));
  }

  void navigateTo(BuildContext context, Widget selectedpage) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => selectedpage));
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              headerLayout(),
              Container(
                width: MediaQuery.of(context).size.width,
                height: ScreenUtil().setSp(54),
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: categorieList(),
              ),
              SizedBox(
                height: 10.0,
              ),
              // suggestedWidget(),
              if (profileCompleteStatus == 0) bannerWidget(),
              Expanded(
                  child: Container(
                child: selectedTab == "All" ? feedWidget() : feedWidgetWithCategory(selectedTab),
                color: Colors.grey[100],
              ))
            ],
          ),
        ),
      ),
    );
  }

  Widget feedWidget() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(Constants.feedsColl)
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor)),
            );
          }
          if (snapshot.data.docs.length == 0) {
            return Center(
                child: Card(
                    elevation: 4.0,
                    child: Text(
                      'No Feeds',
                      style: TextStyle(fontSize: 14.0, color: Colors.black),
                      textAlign: TextAlign.center,
                    )));
          }

          return feedWidgetItem(snapshot);
          // return Container();
        });
  }

  void refreshFilters(categoryTitle) {
    for (int i = 0; i < categoriesList.length; i++) {
      categoriesList[i].isSelected = false;
      if (categoriesList[i].tabTitle.toLowerCase() == categoryTitle.toString().toLowerCase()) {
        categoriesList[i].isSelected = true;
        selectedTab = categoriesList[i].tabTitle;
        categoryId = categoriesList[i].id;
      }
    }
    feedWidgetWithCategory(categoryTitle);
    setState(() {});
  }

  Widget feedWidgetWithCategory(categoryTitle) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(Constants.feedsColl)
            // .orderBy("timestamp", descending: true)
            .where("category_list", arrayContains: categoryTitle)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor)),
            );
          }
          if (snapshot.data.docs.length == 0) {
            return Center(
                child: Card(
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                      child: Text(
                        'No Feeds',
                        style: TextStyle(fontSize: 14.0, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    )));
          }

          return feedWidgetItem(snapshot);
          // return inViewListWidget(snapshot);
        });
  }

  Widget feedWidgetItem(var snapshot) {
    return ListView.builder(
      itemCount: snapshot.data.docs.length,
      itemBuilder: (BuildContext context, int index) {
        List rev = snapshot.data.docs.toList();
        FeedModel feedModel = FeedModel.fromJson(rev[index]);

        return FutureBuilder(
            future: loadRoutine(rev[index].data()["item_id"]),
            builder: (BuildContext context, AsyncSnapshot<RoutineModel> routineModel) {
              feedModel.routineModel = routineModel.data;

              if (feedModel.routineModel == null) {
                return Container();
              }

              return FutureBuilder(
                future: loadUser(rev[index].data()["user_id"]),
                builder: (BuildContext context, AsyncSnapshot<UserFirebaseModel> userModel) {
                  feedModel.userFirebaseModel = userModel.data;
                  return Container(
                      color: Colors.grey[100],
                      padding: EdgeInsets.only(bottom: 1.2),
                      child: CardFeedItem(
                        feedModel: feedModel,
                        isInView: false,
                        filterCategory: refreshFilters,
                      ));
                },
              );
            });
      },
    );
  }

  Widget inViewListWidget(snapshot) {
    return Stack(children: [
      InViewNotifierList(
        scrollDirection: Axis.vertical,
        initialInViewIds: ['0'],
        isInViewPortCondition: (double deltaTop, double deltaBottom, double viewPortDimension) {
          return deltaTop < (0.5 * viewPortDimension) && deltaBottom > (0.5 * viewPortDimension);
        },
        itemCount: snapshot.data.docs.length,
        builder: (BuildContext context, int index) {
          List rev = snapshot.data.docs.toList();
          FeedModel feedModel = FeedModel.fromJson(rev[index]);

          return InViewNotifierWidget(
              id: '$index',
              builder: (BuildContext context, bool isInView, Widget child) {
                return feedModel.type == "Card"
                    ? FutureBuilder(
                        future: loadCards(rev[index].data()["item_id"]),
                        builder: (BuildContext context, AsyncSnapshot<CardModel> cardModel) {
                          feedModel.cardData = cardModel.data;

                          if (feedModel.cardData == null) {
                            return Container();
                          }
                          return FutureBuilder(
                            future: loadUser(rev[index].data()["user_id"]),
                            builder:
                                (BuildContext context, AsyncSnapshot<UserFirebaseModel> userModel) {
                              feedModel.userFirebaseModel = userModel.data;
                              if (userModel.data == null) {
                                return Container();
                              }
                              return Container(
                                  color: Colors.grey[100],
                                  padding: EdgeInsets.only(bottom: 1.2),
                                  child: CardFeedItem(
                                    feedModel: feedModel,
                                    isInView: isInView,
                                    filterCategory: refreshFilters,
                                  ));
                            },
                          );
                        })
                    : FutureBuilder(
                        future: loadRoutine(rev[index].data()["item_id"]),
                        builder: (BuildContext context, AsyncSnapshot<RoutineModel> routineModel) {
                          feedModel.routineModel = routineModel.data;

                          if (feedModel.routineModel == null) {
                            return Container();
                          }

                          return FutureBuilder(
                            future: loadUser(rev[index].data()["user_id"]),
                            builder:
                                (BuildContext context, AsyncSnapshot<UserFirebaseModel> userModel) {
                              feedModel.userFirebaseModel = userModel.data;
                              return Container(
                                  color: Colors.grey[100],
                                  padding: EdgeInsets.only(bottom: 1.2),
                                  child: CardFeedItem(
                                    feedModel: feedModel,
                                    isInView: isInView,
                                    filterCategory: refreshFilters,
                                  ));
                            },
                          );
                        });
              });
        },
      ),
      IgnorePointer(
        ignoring: true,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            height: 100.0,
            color: Colors.transparent,
          ),
        ),
      ),
    ]);
  }

  Widget bannerWidget() {
    return InkWell(
      onTap: () {
        goToProfileComplete();
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
        child: Row(
          children: [
            Expanded(
                child: InkWell(
              onTap: () {
                goToProfileComplete();
              },
              child: Text(
                Constants.profileInComplete,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.liteColorTxt,
                ),
              ),
            )),
            InkWell(
              onTap: () {
                goToProfileComplete();
              },
              child: Container(
                margin: EdgeInsets.only(left: 5.0),
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                decoration: BoxDecoration(
                    color: AppColors.segmentAppBarColor,
                    borderRadius: BorderRadius.all(Radius.circular(2.8))),
                child: Text(
                  Constants.completeProfile,
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 5.0),
              child: Image.asset(
                Constants.uncheckBox,
                height: 15.0,
                width: 15.0,
              ),
            )
          ],
        ),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.black),
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(4.19))),
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
      ),
    );
  }

  void goToProfileComplete() {
    FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(globalUserId)
        .get()
        .then((querySnapshot) {
      String lsp = querySnapshot.data()['last_skipped_page'];

      switch (lsp) {
        case "GenderSelectionScreen":
          navigateTo(context, GenderSelectionScreen());
          break;
        case "PersonalinfoScreen":
          navigateTo(context, PersonalinfoScreen());

          break;
        case "ProfileTypeScreen":
          navigateTo(context, ProfileTypeScreen());

          break;
        case "BizQ1Screen":
          navigateTo(context, BizQ1Screen());

          break;
        case "BizQ4Screen":
          navigateTo(context, BizQ4Screen());

          break;
        default:
          navigateTo(context, ProfileTypeScreen());
          break;
      }
    });
  }

  Widget feedListWidget(snapshot) {
    return Container(
      child: ListView.builder(
        itemBuilder: (context, index) {
          List rev = snapshot.data.docs.toList();
          FeedModel feedModel = FeedModel.fromJson(rev[index]);

          return FutureBuilder(
              future: loadCards(rev[index].data()["item_id"]),
              builder: (BuildContext context, AsyncSnapshot<CardModel> cardModel) {
                feedModel.cardData = cardModel.data;

                if (feedModel.cardData == null) {
                  return Container();
                }
                return FutureBuilder(
                    future: loadUser(rev[index].data()["user_id"]),
                    builder: (BuildContext context, AsyncSnapshot<UserFirebaseModel> userModel) {
                      feedModel.userFirebaseModel = userModel.data;
                      return Container(
                          color: Colors.grey[100],
                          padding: EdgeInsets.only(bottom: 1.2),
                          child: CardFeedItem(
                            feedModel: feedModel,
                          ));
                    });
              });
        },
        itemCount: snapshot.data.docs.length,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
      ),
    );
  }

  // for getting user detail
  Future<UserFirebaseModel> loadUser(userId) async {
    DocumentSnapshot ds =
        await FirebaseFirestore.instance.collection(Constants.UsersFB).doc(userId).get();
    if (ds != null)

      // return ds;

      return Future.delayed(Duration(milliseconds: 100), () => UserFirebaseModel.fromSnapshot(ds));
  }

  Future<CardModel> loadCards(String cardID) async {
    DocumentSnapshot ds =
        await FirebaseFirestore.instance.collection(Constants.cardsColl).doc(cardID).get();
    if (ds != null)

      // return ds;

      return Future.delayed(Duration(milliseconds: 100), () => CardModel.fromJson(ds));
  }

  Future<RoutineModel> loadRoutine(String routineId) async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection(Constants.routineFeedCollection)
        .doc(routineId)
        .get();
    if (ds != null)

      // return ds;

      return Future.delayed(Duration(milliseconds: 100), () => RoutineModel.fromJson(ds));
  }

  Widget headerLayout() {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  child: Image.asset(
                    Constants.solsticeImage,
                    height: 32,
                  ),
                ),

                // Text(
                //   'Hi, $globalUserName',
                //   style: TextStyle(
                //       fontSize: 24, color: AppColors.darkTextColor, fontWeight: FontWeight.w600),
                // ),
                // SizedBox(
                //   height: 5.0,
                // ),
                // Text(
                //   DateFormat('MMMM dd').format(DateTime.now()),
                //   style: TextStyle(
                //       fontSize: 16, color: AppColors.greyTextColor, fontWeight: FontWeight.w400),
                // )
              ],
            ),
          ),
          InkWell(
            onTap: () {
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => CreateRoutineName()));
            },
            child: Container(
              child: SvgPicture.asset(
                Constants.searchIcon,
                height: 40.0,
                width: 40.0,
              ),
              margin: EdgeInsets.symmetric(horizontal: 5.0),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CreateRoutineName()));
            },
            child: Container(
              child: SvgPicture.asset(
                Constants.addIcon,
                height: 40.0,
                width: 40.0,
              ),
              margin: EdgeInsets.all(5.0),
            ),
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }

  Widget categorieList() {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              categoriesList.forEach((element) => element.isSelected = false);
              categoriesList[index].isSelected = true;
              selectedTab = categoriesList[index].tabTitle;
              categoryId = categoriesList[index].id;
              feedWidgetWithCategory(selectedTab);
              setState(() {});
            },
            child: Container(
              child: TabListItem(
                categoriesList[index],
                blackText: true,
              ),
            ),
          );
        },
        itemCount: categoriesList.length);
  }

  // tabs
  Widget tabLayout() {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(bottom: 20),
      height: 35,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: categoriesList == null ? 0 : categoriesList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return new InkWell(
            //highlightColor: Colors.red,
            splashColor: AppColors.primaryColor,
            onTap: () {
              setState(() {
                categoriesList.forEach((element) => element.isSelected = false);
                categoriesList[index].isSelected = true;
                selectedTab = categoriesList[index].tabTitle;
              });
            },
            child: Container(
                child: new TabListItem(
              categoriesList[index],
              blackText: true,
            )),
          );
        },
      ),
    );
  }
}

class VideoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        InViewNotifierList(
          scrollDirection: Axis.vertical,
          initialInViewIds: ['0'],
          isInViewPortCondition: (double deltaTop, double deltaBottom, double viewPortDimension) {
            return deltaTop < (0.5 * viewPortDimension) && deltaBottom > (0.5 * viewPortDimension);
          },
          itemCount: 10,
          builder: (BuildContext context, int index) {
            return Container(
              width: double.infinity,
              height: 300.0,
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(vertical: 50.0),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return InViewNotifierWidget(
                    id: '$index',
                    builder: (BuildContext context, bool isInView, Widget child) {
                      return CardFeedItem(
                        isInView: isInView,
                        // url:
                        //     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4'
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            height: 1.0,
            color: Colors.redAccent,
          ),
        )
      ],
    );
  }
}
