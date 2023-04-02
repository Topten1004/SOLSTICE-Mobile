import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/main.dart';
import 'package:solstice/model/forum_model.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/model/search_algolia_model.dart';
import 'package:solstice/pages/views/home_post_list_item.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/size_utils.dart';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<PostModel> selectedList = new List<PostModel>();
  bool isNearBySelected = false;

  Completer<GoogleMapController> _controller = Completer();
  Algolia algolia = Application.algolia;
  List<AlgoliaSearchModel> _searchList = new List.empty(growable: true);

  static const LatLng _center = const LatLng(45.521563, -122.677433);
// Algolia algolia = Application.algolia;
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  void initState() {
    super.initState();

    setDefaultList();
  }

// void searchMethods(queryString) async{

//     ///
//     /// Perform Query
//     ///
//     AlgoliaQuery query = algolia.instance.index('Posts').query(queryString);

//     // Perform multiple facetFilters
//     query = query.facetFilter('active:1');

//     // Get Result/Objects
//     AlgoliaQuerySnapshot snap = await query.getObjects();

//     // Checking if has [AlgoliaQuerySnapshot]
// }
  void setDefaultList() {
    selectedList.add(new PostModel(
        "Joanne Kathrine",
        "http://i.imgur.com/QSev0hg.jpg",
        "https://www.bodybuilding.com/fun/images/2015/how-to-make-yourself-the-best-trainer-at-any-gym-facebook-box-960x540.jpg",
        "Radio House 83th",
        "3d",
        "This is the title for the journey",
        "Caption for this journey, Lorem ipsum dolor",
        "8",
        "4",
        true,
        true));
    selectedList.add(new PostModel(
        "Grace Aguri",
        "http://i.imgur.com/QSev0hg.jpg",
        "https://1.bp.blogspot.com/-ITDeKbpwTbk/XJePd5D2nyI/AAAAAAAAAkQ/JGEzWJ0uGCsLjo09hjNTeP7Cwndrp9x5ACEwYBhgL/s640/gym-trainer-1.jpg",
        "Video House 74th",
        "8d",
        "This is the title for the journey",
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled",
        "100",
        "40",
        false,
        false));
    selectedList.add(new PostModel(
        "Joanne Kathrine",
        "http://i.imgur.com/QSev0hg.jpg",
        "https://images.hindustantimes.com/Images/popup/2015/7/Crunches.jpg",
        "Radio House 83th",
        "3d",
        "This is the title for the journey",
        "Caption for this journey, Lorem ipsum dolor",
        "8",
        "4",
        true,
        true));
    selectedList.add(new PostModel(
        "Grace Aguri",
        "http://i.imgur.com/QSev0hg.jpg",
        "https://1.bp.blogspot.com/-ITDeKbpwTbk/XJePd5D2nyI/AAAAAAAAAkQ/JGEzWJ0uGCsLjo09hjNTeP7Cwndrp9x5ACEwYBhgL/s640/gym-trainer-1.jpg",
        "Video House 74th",
        "8d",
        "This is the title for the journey",
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled",
        "100",
        "40",
        false,
        false));
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                zoomControlsEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 11.0,
                ),
              ),
            ),
            Column(
              children: [
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
                        bottom: 0.0),
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
                            margin: EdgeInsets.only(left: 10, right: 18),
                            child: SvgPicture.asset(
                              'assets/images/ic_back.svg',
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Text(
                          'Explore',
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "epilogue_medium",
                              fontSize: 17),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: ScreenUtil().setSp(126),
                  child: Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 25,
                            height: 25,
                            padding: EdgeInsets.all(2.5),
                            margin: EdgeInsets.only(right: 5),
                            child: SvgPicture.asset(
                              'assets/images/ic_search.svg',
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                              color: Colors.blue,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Search by keyword",
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                    fontFamily: "epilogue_medium",
                                    fontSize: 14,
                                    color: Colors.black),
                                onChanged: (text) {
                                  exploreResult(text);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    elevation: 5,
                    margin: EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              child: SingleChildScrollView(
                child: Container(
                  //color: Colors.black38.withOpacity(0.6),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      isNearBySelected == true
                          ? Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      isNearBySelected = false;
                                    });
                                  },
                                  child: Container(
                                    child: Card(
                                      semanticContainer: true,
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            10.0, 15.0, 10.0, 15.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'See Nearby',
                                              style: TextStyle(
                                                  fontFamily: "epilogue_medium",
                                                  fontSize: 14,
                                                  color: Colors.blue),
                                            ),
                                            RotationTransition(
                                              turns: new AlwaysStoppedAnimation(
                                                  90 / 360),
                                              child: Container(
                                                width: 17,
                                                height: 17,
                                                padding: EdgeInsets.all(2.5),
                                                margin:
                                                    EdgeInsets.only(right: 5),
                                                child: SvgPicture.asset(
                                                  'assets/images/ic_back.svg',
                                                  alignment: Alignment.center,
                                                  fit: BoxFit.contain,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                      ),
                                      elevation: 5,
                                      margin: EdgeInsets.all(10),
                                    ),
                                  ),
                                ),
                                Card(
                                  margin: EdgeInsets.zero,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        0.0, 10.0, 0.0, 0.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              0.0, 5.0, 5.0, 0.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              InkWell(
                                                onTap: () {},
                                                child: Container(
                                                  width: 19,
                                                  height: 19,
                                                  padding: EdgeInsets.all(2.5),
                                                  margin: EdgeInsets.only(
                                                      left: 0, right: 18),
                                                  child: SvgPicture.asset(
                                                    'assets/images/ic_arrow_left.svg',
                                                    alignment: Alignment.center,
                                                    fit: BoxFit.contain,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {},
                                                child: RotationTransition(
                                                  turns:
                                                      new AlwaysStoppedAnimation(
                                                          180 / 360),
                                                  child: Container(
                                                    width: 20,
                                                    height: 20,
                                                    margin: EdgeInsets.only(
                                                        left: 10, right: 0),
                                                    padding:
                                                        EdgeInsets.all(2.5),
                                                    child: SvgPicture.asset(
                                                      'assets/images/ic_arrow_left.svg',
                                                      alignment:
                                                          Alignment.center,
                                                      fit: BoxFit.contain,
                                                      color: AppColors
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              2,
                                          child: PageView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: selectedList.length,
                                            itemBuilder: (context, position) {
                                              // return exploreListUi(context, position,
                                              //     selectedList[position]);
                                              return new InkWell(
                                                //highlightColor: Colors.red,
                                                splashColor:
                                                    AppColors.primaryColor,
                                                onTap: () {},
                                                // child: new HomePostListItem(selectedList[position],position),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(25.0),
                                      topRight: Radius.circular(25.0),
                                    ),
                                  ),
                                  elevation: 5,
                                ),
                              ],
                            )
                          : InkWell(
                              onTap: () {
                                setState(() {
                                  isNearBySelected = true;
                                });
                              },
                              child: Container(
                                child: Card(
                                  semanticContainer: true,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        10.0, 15.0, 10.0, 15.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'See Nearby',
                                          style: TextStyle(
                                              fontFamily: "epilogue_medium",
                                              fontSize: 14,
                                              color: Colors.blue),
                                        ),
                                        RotationTransition(
                                          turns: new AlwaysStoppedAnimation(
                                              270 / 360),
                                          child: Container(
                                            width: 17,
                                            height: 17,
                                            padding: EdgeInsets.all(2.5),
                                            margin: EdgeInsets.only(right: 5),
                                            child: SvgPicture.asset(
                                              'assets/images/ic_back.svg',
                                              alignment: Alignment.center,
                                              fit: BoxFit.contain,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  elevation: 5,
                                  margin: EdgeInsets.all(10),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget exploreListUi(context, position, ForumModel selectedItem) {
    return Container(
      margin: EdgeInsets.only(right: 10.0),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: (selectedItem.userImage.contains("https:") ||
                        selectedItem.userImage.contains("http:"))
                    ? selectedItem.userImage
                    : UrlConstant.BaseUrlImg + selectedItem.userImage,
                imageBuilder: (context, imageProvider) => Container(
                  width: Dimens.imageSize25(),
                  height: Dimens.imageSize25(),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) =>
                    Constants().setUserDefaultCircularImage(),
                errorWidget: (context, url, error) =>
                    Constants().setUserDefaultCircularImage(),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      " " + selectedItem.userName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppColors.titleTextColor,
                          fontFamily: Constants.boldFont,
                          fontSize: ScreenUtil().setSp(26)),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            width: 16,
                            height: 16,
                            child: SvgPicture.asset(
                              'assets/images/ic_marker.svg',
                              alignment: Alignment.center,
                              fit: BoxFit.fill,
                              color: AppColors.accentColor,
                            )),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "" + selectedItem.locationName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColors.accentColor,
                              fontFamily: Constants.regularFont,
                              fontSize: ScreenUtil().setSp(22)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Spacer(),
              Container(
                child: Text(
                  selectedItem.postTime,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColors.titleTextColor,
                      fontFamily: Constants.mediumFont,
                      fontSize: ScreenUtil().setSp(22)),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          CachedNetworkImage(
            imageUrl: (selectedItem.userImage.contains("https:") ||
                    selectedItem.userImage.contains("http:"))
                ? selectedItem.userImage
                : UrlConstant.BaseUrlImg + selectedItem.userImage,
            imageBuilder: (context, imageProvider) => Container(
              width: MediaQuery.of(context).size.width,
              height: Dimens.imageSize120(),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) =>
                Constants().setUserDefaultCircularImage(),
            errorWidget: (context, url, error) =>
                Constants().setUserDefaultCircularImage(),
          ),
          SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This is the title for the journey',
                  style: TextStyle(
                      fontFamily: 'epilogue_semibold',
                      fontSize: ScreenUtil().setSp(26),
                      color: Colors.black),
                ),
                Text(
                  'Caption for this journey, Lorem ipsum dolor',
                  style: TextStyle(
                      fontFamily: 'epilogue_light',
                      fontSize: ScreenUtil().setSp(26),
                      color: Colors.black),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Container(
                width: 70,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      child: SvgPicture.asset(
                        'assets/images/ic_comment.svg',
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      '25',
                      style: TextStyle(
                          fontFamily: 'epilogue_semibold', color: Colors.black),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                width: 70,
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                        width: 1.0,
                        color: AppColors.primaryColor.withOpacity(0.2))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      child: SvgPicture.asset(
                        'assets/images/ic_comment.svg',
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      '25',
                      style: TextStyle(
                          fontFamily: 'epilogue_semibold', color: Colors.black),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Add to Stitch',
                      style: TextStyle(
                          fontFamily: 'epilogue_semibold',
                          color: AppColors.primaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void exploreResult(String text) async {
    var query = algolia.instance.index(Constants.postIndex).search(text);
    // Perform multiple facetFilters
    query = query.setAroundLatLng('${_center.latitude},${_center.longitude}');

    // Get Result/Objects
    var snap = await query.getObjects();
  }
}
