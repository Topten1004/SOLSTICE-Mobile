import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solstice/main.dart';
import 'package:solstice/model/forum_model.dart';
import 'package:solstice/model/search_algolia_model.dart';
import 'package:solstice/model/stitch_routine_model.dart';
import 'package:solstice/pages/buckets_stitch/buckets_stitch_detail_screen.dart';
import 'package:solstice/pages/buckets_stitch/routine_detail_screen.dart';
import 'package:solstice/pages/forums/forums_details_screen.dart';
import 'package:solstice/pages/home/post_detail_screen.dart';
import 'package:solstice/utils/constants.dart';

class SearchFilter extends StatefulWidget {
  final String screenType;
  SearchFilter({this.screenType});

  @override
  _SearchFilterState createState() => _SearchFilterState();
}

class _SearchFilterState extends State<SearchFilter> {
  Algolia algolia = Application.algolia;
  List<AlgoliaSearchModel> _searchList = new List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white),
          ),
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).padding.top,
              ),
              Expanded(
                flex: 0,
                child: Container(
                  padding: EdgeInsets.only(
                      left: ScreenUtil().setSp(26),
                      right: ScreenUtil().setSp(36),
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
                          margin: EdgeInsets.only(left: 5, right: 18),
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
                height: 5,
              ),
              Container(
                child: Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 25,
                          height: 25,
                          padding: EdgeInsets.all(2.5),
                          margin: EdgeInsets.only(right: 7),
                          child: SvgPicture.asset(
                            'assets/images/ic_search.svg',
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                            color: Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                height: 36,
                                child: TextField(
                                  decoration: InputDecoration(
                                    counterText: "",
                                    hintText: "Search by keyword",
                                    hintStyle: TextStyle(
                                        color: AppColors.accentColor,
                                        fontFamily:
                                        Constants.regularFont,
                                        fontSize:
                                        ScreenUtil().setSp(26)),
                                    labelStyle: TextStyle(
                                        color: AppColors.accentColor,
                                        fontFamily:
                                        Constants.regularFont,
                                        fontSize:
                                        ScreenUtil().setSp(28)),
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(
                                      fontFamily: "epilogue_medium",
                                      fontSize: 14,
                                      color: Colors.black),
                                  textAlignVertical: TextAlignVertical.center,
                                  onChanged: (text) {
                                    queryPosts(text);
                                  },
                                ),
                              ),
                              SizedBox(height: 4,)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  elevation: 5,
                  margin: EdgeInsets.only(left: 10, top: 10, right: 10),
                ),
              ),
              Expanded(
                  child: Container(
                      child: _searchList.length > 0
                          ? ListView.builder(
                              itemCount: _searchList.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    goToDetailPage(index, _searchList[index]);
                                    // Navigator.push(context,MaterialPageRoute((context) => PostDetailScreen(pos)));
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        top: 6.0,bottom: 6.0, left: 15.0, right: 15.0),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 8.0),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        color: AppColors.lightSkyBlue),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _searchList[index].title,
                                          style: TextStyle(
                                              fontSize: 15.0,fontFamily: Constants.boldFont,
                                              color: Colors.black),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          textAlign: TextAlign.start,
                                        ),
                                        SizedBox(height: 4,),
                                        Text(
                                          _searchList[index].description,
                                          style: TextStyle(
                                              fontSize: 14.0,fontFamily: Constants.regularFont,
                                              color: Colors.black),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          textAlign: TextAlign.start,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })
                          : Container(
                              child: Center(
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('No Search Result',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.black, fontFamily: Constants.mediumFont))),
                              ),
                            )))
            ],
          ),
        ],
      ),
    );
  }

  Future<void> queryPosts(String queryText) async {
    String indice;
    switch (widget.screenType) {
      case "Home":
        indice = Constants.postIndex;
        break;
      case "Stitch":
        indice = Constants.stitchIndex;
        break;
      case "Routine":
        indice = Constants.routineIndex;
        break;
      case "User":
        indice = Constants.userIndex;
        break;
      case "Group":
        indice = Constants.groupsIndex;
        break;
      case "Forum":
        indice = Constants.forumsIndex;
        break;
      default:
        break;
    }

    var query = algolia.instance.index(indice).search(queryText);
    // Perform multiple facetFilters
    if (widget.screenType == "Home") {
      query = query.setNumericFilter("active=1");
    }

    // Get Result/Objects
    var snap = await query.getObjects();

    // Checking if has [AlgoliaQuerySnapshot]
    _searchList.clear();
    for (int i = 0; i < snap.hits.length; i++) {
      if (snap.hits[i].data.containsKey("title") &&
          snap.hits[i].data.containsKey("description")) {
        AlgoliaSearchModel algoliaSearchModel =
            new AlgoliaSearchModel.fromSnapshot(
                snap.hits[i].data, snap.hits[i].objectID, "Else");
        _searchList.add(algoliaSearchModel);
      }
      if (snap.hits[i].data.containsKey("userName") &&
          snap.hits[i].data.containsKey("userEmail")) {
        AlgoliaSearchModel algoliaSearchModel =
            new AlgoliaSearchModel.fromSnapshot(
                snap.hits[i].data, snap.hits[i].objectID, "User");
        _searchList.add(algoliaSearchModel);
      }
    }
    setState(() {});
  }

  void goToDetailPage(int index, AlgoliaSearchModel searchList) {
    switch (widget.screenType) {
      case "Home":
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PostDetailScreen(
                      postIdIntent: _searchList[index].id,
                    )));
        break;

      case "Stitch":
        StitchRoutineModel stitchRoutineModel = new StitchRoutineModel(
            id: _searchList[index].id, title: _searchList[index].title);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => new BucketStitchDetailScreen(
                    bucketStitchDetailIntent: stitchRoutineModel,
                    index: index)));
        break;

      case "Routine":
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => new RoutineDetailScreen(
                      routineIDIntent: _searchList[index].id,
                    )));
        break;

      case "Group":
        break;

      case "Forum":
        // ForumFireBaseModel forumFireBaseModel = ForumFireBaseModel(title: searchList.title,id: searchList.id,);
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) =>
        //             ForumsDetailsScreen(forumItemIntent: forumFireBaseModel)));
        break;
    }
  }
}
