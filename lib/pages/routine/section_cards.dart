import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/model/feed_model.dart';
import 'package:solstice/model/forum_model.dart';
import 'package:solstice/model/routine_section_model.dart';
import 'package:solstice/pages/cards/card_item.dart';
import 'package:solstice/utils/constants.dart';

class SectionCards extends StatefulWidget {
  final List<String> sectionList;
  FeedModel feedModel;
  bool fromFeed = false;
  bool expandFeed = false;
  String userName;
  SectionCards({this.sectionList, this.userName, this.feedModel, this.fromFeed, this.expandFeed});

  @override
  _SectionCardsState createState() => _SectionCardsState();
}

class _SectionCardsState extends State<SectionCards> with AutomaticKeepAliveClientMixin {
  List<RoutineSectionModel> rountineSectionList = new List();
  List<CardModel> newCardList = new List();
  // RoutineSectionModel routineSectionModel;
  bool isUpdated = false;
  int sectionIndex = 0, cardIndex = 0;
  RoutineSectionModel sectionModel;
  @override
  void initState() {
    super.initState();
    getSectionAndCards();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> getSectionAndCards() async {
    newCardList.clear();
    // for (int s = 0; s < widget.sectionList.length; s++) {
    await FirebaseFirestore.instance
        .collection(Constants.sectionColl)
        .doc(widget.sectionList[sectionIndex])
        .get()
        .then((value) async {
      sectionModel = RoutineSectionModel.fromJson(value);

      for (int j = 0; j < sectionModel.cardIds.length; j++) {
        await FirebaseFirestore.instance
            .collection(Constants.cardsColl)
            .doc(sectionModel.cardIds[j])
            .get()
            .then((cardValue) async {
          CardModel cardModel = CardModel.fromJson(cardValue);

          await FirebaseFirestore.instance
              .collection(Constants.UsersFB)
              .doc(cardModel.createdBy)
              .get()
              .then((userValue) {
            UserFirebaseModel firebaseModel = UserFirebaseModel.fromSnapshot(userValue);

            cardModel.userFirebaseModel = firebaseModel;
            newCardList.add(cardModel);

            if (j == sectionModel.cardIds.length - 1) {
              sectionModel.cardList.addAll(newCardList);
              rountineSectionList.add(sectionModel);

              if (sectionIndex == widget.sectionList.length - 1) {
                setState(() {});
              } else {
                sectionIndex += 1;
                getSectionAndCards();
              }
            }
          });
        });
      }
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return rountineSectionList.length > 0
        ? Container(
            margin: EdgeInsets.only(top: 20),
            child: ListView.builder(
              shrinkWrap: true,
              primary: false,
              itemBuilder: (context, index) {
                return SectionItem(
                  feedModel: widget.feedModel,
                  fromFeed: widget.fromFeed,
                  index: index,
                  size: widget.sectionList.length,
                  expandFeed: widget.expandFeed,
                  routineSectionModel: rountineSectionList[index],
                  userName: widget.userName,
                );
              },
              itemCount: rountineSectionList.length > 2 &&
                      !widget.feedModel.routineModel.expandRoutine &&
                      widget.fromFeed
                  ? 2
                  : rountineSectionList.length,
            ),
          )
        : Container(
            margin: EdgeInsets.only(top: 20),
            child: Center(
              child: SizedBox(
                  height: 40,
                  width: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  )),
            ),
          );
  }

// Load routine Sections from section collection
  Future<RoutineSectionModel> loadSections(String sectionId) async {
    DocumentSnapshot ds =
        await FirebaseFirestore.instance.collection(Constants.sectionColl).doc(sectionId).get();
    if (ds != null)

      // return ds;

      return Future.delayed(Duration(milliseconds: 100), () => RoutineSectionModel.fromJson(ds));
  }

  Future<CardModel> loadCards(String cardID) async {
    DocumentSnapshot ds =
        await FirebaseFirestore.instance.collection(Constants.cardsColl).doc(cardID).get();
    if (ds != null)

      // return ds;

      return Future.delayed(Duration(milliseconds: 100), () => CardModel.fromJson(ds));
  }
}

class SectionItem extends StatelessWidget {
  bool fromFeed;
  RoutineSectionModel routineSectionModel;
  int index, size;
  FeedModel feedModel;
  String userName;
  bool expandFeed;
  SectionItem(
      {this.fromFeed,
      this.routineSectionModel,
      this.index,
      this.size,
      this.userName,
      this.expandFeed,
      this.feedModel});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 15.0,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 20.0,
                    height: 20.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.bordergrey, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        color: Colors.white),
                    child: Text(
                      '${(index + 1).toInt()}',
                      style: TextStyle(fontSize: 12, color: AppColors.darkTextColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    height: fromFeed
                        ? ((
                                // feedModel.routineModel.expandRoutine &&
                                routineSectionModel.showCards)
                            ? ((routineSectionModel.cardIds.length) * 105).toDouble()
                            : feedModel.routineModel.expandRoutine
                                ? 20
                                : 7.0)
                        : ((routineSectionModel.cardIds.length) * 105).toDouble(),
                    width: 2.0,
                    color: (index < size - 1) ? AppColors.viewColor : Colors.white,
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        routineSectionModel.showCards = !routineSectionModel.showCards;

                        setState(() {});
                        if (routineSectionModel.showCards) {
                          // isUpdated = true;
                        }
                        routineSectionModel.selectedIndex = -1;
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 13.0),
                              child: Text.rich(TextSpan(
                                  text: routineSectionModel.title,
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      color: AppColors.darkTextColor,
                                      fontWeight: FontWeight.w600),
                                  children: <InlineSpan>[
                                    TextSpan(
                                      text: ' ',
                                      style: TextStyle(
                                          fontSize: 10.0,
                                          color: AppColors.greyTextColor,
                                          fontWeight: FontWeight.w400),
                                    )
                                  ])),
                            ),
                          ),
                          fromFeed
                              ? Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                      child: Text(
                                        routineSectionModel.cardIds.length > 1
                                            ? '${routineSectionModel.cardIds.length} Cards'
                                            : '${routineSectionModel.cardIds.length} Card',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: AppColors.greyTextColor,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                    SvgPicture.asset(
                                      routineSectionModel.showCards
                                          ? Constants.upArrow
                                          : Constants.downArrow,
                                      height: 25.0,
                                      width: 25.0,
                                      color: AppColors.lightGreyColor,
                                    )
                                  ],
                                )
                              : Container(
                                  child: Image.asset(
                                  Constants.menuIcon,
                                  height: 24.0,
                                  width: 24.0,
                                )),
                          SizedBox(
                            width: 15.0,
                          )
                        ],
                      ),
                    ),
                    if (!fromFeed ||
                        (routineSectionModel.showCards
                        // &&feedModel.routineModel.expandRoutine
                        ) ||
                        (routineSectionModel.showCards &&
                            feedModel.routineModel.sectionIds.length < 2))
                      Container(
                        height: routineSectionModel.cardIds != null
                            ? ((routineSectionModel.cardIds.length) * 105).toDouble()
                            : 105,
                        margin: EdgeInsets.only(right: 2.0),
                        child: ListView.builder(
                          primary: false,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, indexCard) {
                            return Container(
                              child: CardItem(
                                viewType: "dragView",
                                cardModel: routineSectionModel.cardList[indexCard],
                                index: indexCard,
                                cardList: routineSectionModel.cardIds.length,
                                createMode: false,
                                isEditMode: false,
                                userName: routineSectionModel
                                    .cardList[indexCard].userFirebaseModel.userName,
                                feedModel: feedModel,
                                numberValue: indexCard + 1,
                              ),
                            );
                          },
                          itemCount: routineSectionModel.cardList.length,
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
}
