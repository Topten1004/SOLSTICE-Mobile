import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solstice/model/post_card_model.dart';
import 'package:solstice/pages/home/card_reorder_item.dart';
import 'package:solstice/pages/views/card_detail.dart';
import 'package:solstice/pages/views/home_post_list_item.dart';
import 'package:solstice/utils/constants.dart';

class AddCardSheet extends StatefulWidget {
  List<String> imageList;
  AddCardSheet({this.imageList});

  @override
  _AddCardSheetState createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<AddCardSheet> {
  List<PostCardModel> cardList = new List();

  PageController pageController = new PageController();

  bool isCardBtnEnable = false;
  int imagePageIndex = 0;
  List<String> imageList = new List();
  String postId;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Container(
      child: SafeArea(
        child: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Wrap(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(left: 20, right: 20),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(
                                  top: ScreenUtil().setSp(25),
                                  bottom: ScreenUtil().setSp(15)),
                              height: ScreenUtil().setSp(45),
                              alignment: Alignment.center,
                              child: Text(
                                Constants.postJourney,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.titleTextColor,
                                    fontFamily: Constants.boldFont,
                                    fontSize: ScreenUtil().setSp(28)),
                              ),
                            ),
                            SizedBox(height: ScreenUtil().setSp(12)),
                            Card(
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25))),
                              child: Stack(
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height /
                                        100 *
                                        25,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(25.0),
                                      ),
                                    ),
                                    child: PageView.builder(
                                        itemCount: imageList.length,
                                        controller: pageController,
                                        onPageChanged: (pos) {
                                          this.imagePageIndex = pos;
                                        },
                                        itemBuilder: (context, indexView) {
                                          imagePageIndex = indexView;

                                          return Hero(
                                            tag: 'homePageImage' +
                                                indexView.toString(),
                                            child: CachedNetworkImage(
                                              imageUrl: imageList[indexView],
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  //borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              placeholder: (context, url) =>

                                                  setPostDefaultImage(
                                                          context),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      setPostDefaultImage(
                                                              context),
                                            ),
                                          );
                                        }),
                                  ),
                                  Positioned(
                                    right: 10,
                                    top: 0,
                                    bottom: 0,
                                    child: Visibility(
                                      maintainAnimation: true,
                                      maintainSize: false,
                                      maintainState: true,
                                      child: InkWell(
                                        onTap: () {
                                          pageController.nextPage(
                                              duration:
                                                  Duration(milliseconds: 100),
                                              curve: Curves.ease);
                                        },
                                        child: Center(
                                          child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                              ),
                                              width: 25,
                                              height: 25,
                                              child: SvgPicture.asset(
                                                Constants.rightArrow,
                                                fit: BoxFit.contain,
                                                color: Colors.black,
                                              )),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'title',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: AppColors.titleTextColor,
                                  fontFamily: Constants.boldFont,
                                  fontSize: ScreenUtil().setSp(27)),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'description',
                              maxLines: 2,
                              style: TextStyle(
                                  color: AppColors.titleTextColor,
                                  fontFamily: Constants.regularFont,
                                  fontSize: ScreenUtil().setSp(23)),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'goal',
                              maxLines: 2,
                              style: TextStyle(
                                  color: AppColors.titleTextColor,
                                  fontFamily: Constants.regularFont,
                                  fontSize: ScreenUtil().setSp(23)),
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    Constants.addACard,
                                    style: TextStyle(
                                        color: AppColors.blackColor[500],
                                        fontFamily: Constants.semiBoldFont,
                                        fontSize: ScreenUtil().setSp(24)),
                                  ),
                                  Expanded(
                                    child: Container(),
                                  ),
                                  InkWell(
                                      onTap: () async {
                                        if (cardList.length <= 6) {
                                          // var object =
                                          // await showModalBottomSheet(
                                          //     isScrollControlled: true,
                                          //     context: context,
                                          //     shape:
                                          //         RoundedRectangleBorder(
                                          //       borderRadius:
                                          //           BorderRadius.only(
                                          //               topLeft: Radius
                                          //                   .circular(
                                          //                       30.0),
                                          //               topRight: Radius
                                          //                   .circular(
                                          //                       30.0)),
                                          //     ),
                                          //     builder: (BuildContext
                                          //         context) {
                                          //       return CardDetail(
                                          //         postId: postId,
                                          //       );
                                          //     });
                                          var object = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CardDetail(
                                                        postId: postId,
                                                        indexKey:
                                                            cardList.length,
                                                      )));

                                          if (object != null) {
                                            PostCardModel cardModel =
                                                object["cardObject"];
                                            cardList.add(cardModel);
                                            setState(() {});
                                          }
                                        } else {
                                          Constants().errorToast(context,
                                              'You can select maximum 6 cards');
                                        }
                                      },
                                      child: Container(
                                          height: ScreenUtil().setSp(80),
                                          child: DottedBorder(
                                              borderType: BorderType.RRect,
                                              color: AppColors.primaryColor,
                                              radius: Radius.circular(40),
                                              dashPattern: [3, 3, 3, 3],
                                              strokeWidth: 1.2,
                                              child: Center(
                                                  child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                    SizedBox(
                                                      width: 10.0,
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: 18,
                                                      height: 18,
                                                      padding:
                                                          EdgeInsets.all(1.5),
                                                      child: SvgPicture.asset(
                                                        'assets/images/ic_plus.svg',
                                                        alignment:
                                                            Alignment.center,
                                                        color: AppColors
                                                            .primaryColor,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      Constants.addCard,
                                                      style: TextStyle(
                                                        fontSize: ScreenUtil()
                                                            .setSp(24),
                                                        color: AppColors
                                                            .primaryColor,
                                                        fontFamily: Constants
                                                            .semiBoldFont,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10.0,
                                                    ),
                                                  ]))))),
                                ]),
                            /*ReorderableList(
                              onReorder: _onReorder,
                              itemCount: cardList.length,
                              itemBuilder: (context, index) {
                                return CardReorderItem(
                                  isFirst: index == 0,
                                  isLast: index == cardList.length - 1,
                                  postCardModel: cardList[index],
                                  index: index,
                                );
                              },
                            ),*/
                            // Container(
                            //     child: cardList.length > 0
                            //         ? ListView.builder(
                            //             itemCount: cardList.length,
                            //             shrinkWrap: true,
                            //             physics:
                            //                 NeverScrollableScrollPhysics(),
                            //             itemBuilder: (BuildContext context,
                            //                 int positon) {
                            //               return CardReorderItem(
                            //                 isFirst: positon == 0,
                            //                 isLast: positon ==
                            //                     cardList.length - 1,
                            //                 postCardModel:
                            //                     cardList[positon],
                            //                 index: positon,
                            //               );
                            //             })
                            //         : Container()),
                            SizedBox(height: ScreenUtil().setSp(32)),
                            Container(
                              color: Colors.transparent,
                              margin: EdgeInsets.only(top: 20),
                              width: MediaQuery.of(context).size.width,
                              height: ScreenUtil().setSp(100),
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40.0),
                                    side: BorderSide(
                                        color: isCardBtnEnable == true
                                            ? AppColors.primaryColor
                                            : AppColors.accentColor)),
                                onPressed: () {
                                  setState(() {
                                    // continueCretePost();
                                  });
                                },
                                color: isCardBtnEnable == true
                                    ? AppColors.primaryColor
                                    : AppColors.accentColor,
                                textColor: Colors.white,
                                padding: EdgeInsets.all(10.0),
                                child: Text(Constants.continueTxt,
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(28),
                                      fontFamily: Constants.semiBoldFont,
                                    )),
                              ),
                            ),
                            SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ],
                  ));
            },
          ),
        ),
      ),
    );
  }

  static setPostDefaultImage(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: ScreenUtil().setSp(370),
      decoration: BoxDecoration(
        color: AppColors.viewLineColor,
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(
      () {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final PostCardModel item = cardList.removeAt(oldIndex);
        cardList.insert(newIndex, item);
      },
    );
  }
}
