import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share/share.dart';
import 'package:solstice/model/feed_model.dart';
import 'package:solstice/pages/routine/share_to_group.dart';
import 'package:solstice/utils/constants.dart';

const BUNDLE_IDENTIFIER_ANDROID = "com.solstice.";
const BUNDLE_IDENTIFIER_IOS = "com.solstice.com";
const APP_STORE_ID = "123456789";
const URI_PREFIX_FIREBASE = "https://solsticeapp.page.link";
const DEFAULT_FALLBACK_URL_ANDROID = "https://solsticeapp.page.link";
// const DEFAULT_FALLBACK_URL_ANDROID = "https://play.google.com/store/apps";

const DEFAULT_FALLBACK_URL_IOS = "";

class ShareRoutine extends StatelessWidget {
  String selectedValue = "";
  String feedId;
  FeedModel feedModel;
  ShareRoutine({this.feedId, this.feedModel});
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          child: Column(
            children: [
              Stack(
                children: [
                  Positioned(
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.black, size: 24),
                      onPressed: () => {Navigator.of(context).pop()},
                    ),
                    right: 0,
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        Constants.shareRoutine,
                        style: TextStyle(fontSize: 14.0, color: AppColors.lightGreyColor),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              InkWell(
                onTap: () {
                  selectedValue = "Feed";
                  setState(() {});
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 5.0),
                        child: Image.asset(
                          Constants.solsFeedIcon,
                          height: 24.0,
                          width: 24.0,
                        ),
                      ),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
                              child: Text(
                                'SOLS Feed',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.darkTextColor),
                              )),
                          Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
                              child: Text(
                                'Something about feed here',
                                style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.lightGreyColor),
                              ))
                        ],
                      )),
                      SizedBox(
                        width: 10.0,
                      ),
                      Center(
                        child: Image.asset(
                          selectedValue == "Feed"
                              ? Constants.circleCheckIcon
                              : Constants.uncheckIcon,
                          height: 30.0,
                          width: 30.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 1.0,
                color: AppColors.viewLineColor,
              ),
              InkWell(
                onTap: () {
                  selectedValue = "Group";
                  setState(() {});
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 5.0),
                        child: Image.asset(
                          Constants.groupIcon,
                          height: 24.0,
                          width: 24.0,
                        ),
                      ),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
                              child: Text(
                                'Groups',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.darkTextColor),
                              )),
                          Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
                              child: Text(
                                'Choose groups in which you want to share the routine.',
                                style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.lightGreyColor),
                              ))
                        ],
                      )),
                      SizedBox(
                        width: 10.0,
                      ),
                      Center(
                        child: Image.asset(
                          selectedValue == "Group"
                              ? Constants.circleCheckIcon
                              : Constants.uncheckIcon,
                          height: 30.0,
                          width: 30.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 1.0,
                color: AppColors.viewLineColor,
              ),
              InkWell(
                onTap: () {
                  selectedValue = "External";
                  setState(() {});
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 5.0),
                        child: Image.asset(
                          Constants.groupIcon,
                          height: 24.0,
                          width: 24.0,
                        ),
                      ),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
                              child: Text(
                                'External',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.darkTextColor),
                              )),
                          Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
                              child: Text(
                                'Share the routine externally',
                                style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.lightGreyColor),
                              ))
                        ],
                      )),
                      SizedBox(
                        width: 10.0,
                      ),
                      Center(
                        child: Image.asset(
                          selectedValue == "External"
                              ? Constants.circleCheckIcon
                              : Constants.uncheckIcon,
                          height: 30.0,
                          width: 30.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 3,
              ),
              Container(
                color: Colors.transparent,
                margin: EdgeInsets.symmetric(vertical: 20.0),
                width: MediaQuery.of(context).size.width,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  onPressed: () {
                    if (selectedValue == "") {
                      Constants().errorToast(context, "Please select one item");
                    } else {
                      // Navigator.pop(context, {"sectionName": sectionName});
                      shareToFeed(context);
                    }
                  },
                  color: AppColors.darkTextColor,
                  textColor: Colors.white,
                  padding: EdgeInsets.all(12.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(Constants.next.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          fontFamily: "open_saucesans_regular",
                        )),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Share Routine To Feed
  shareToFeed(context) {
    if (selectedValue == "Feed") {
      shareFeedToFeed(context);
    } else if (selectedValue == "Group") {
      shareFeedToGroup(context);
    } else if (selectedValue == "External") {
      createDynamicLink(true, context);
    }
  }

  shareFeedToFeed(context) {
    FeedModel model = feedModel;
    model.sharedBy = globalUserId;
    model.sharedByUsernName = globalUserName;
    FirebaseFirestore.instance.collection(Constants.feedsColl).add(model.toJson()).then((value) {
      Navigator.pop(context);
      Constants().successToast(context, "Feed shared to feeds");
    });
  }

  shareFeedToGroup(context) async {
    var object = await showModalBottomSheet(
      context: context,
      enableDrag: false,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          child: ShareToGroup(
            feedId: feedId,
          ),
          height: MediaQuery.of(context).size.height * 0.64,
        );
      },
    );
    if (object != null) {
      if (object["finish"] == "yes") {
        Navigator.pop(context);
        Constants().successToast(context, "Feed shared to group");
      }
    }
  }

  Future<void> createDynamicLink(bool short, BuildContext context) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: URI_PREFIX_FIREBASE,
      link: Uri.parse(DEFAULT_FALLBACK_URL_ANDROID + "?feedId=" + feedId),
      androidParameters: AndroidParameters(
        packageName: BUNDLE_IDENTIFIER_ANDROID,
        minimumVersion: 1,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: BUNDLE_IDENTIFIER_IOS,
        minimumVersion: '1',
        appStoreId: APP_STORE_ID,
      ),
    );

    Uri url;
    // url = await parameters.buildUrl();
    final ShortDynamicLink shortLink = await parameters.buildShortLink();
    url = shortLink.shortUrl;
    // if (short) {
    //   final ShortDynamicLink shortLink = await parameters.buildShortLink();
    //   url = shortLink.shortUrl;
    // } else {
    //   url = await parameters.buildUrl();
    // }
    Navigator.pop(context);

    final RenderBox box = context.findRenderObject();
    Share.share(url.toString(), sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    // setState(() {});
  }
}
