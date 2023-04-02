import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/model/post_model.dart';
import 'package:solstice/model/stitch_routine_model.dart';
import 'package:solstice/model/stitch_routine_selection_model.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';

class SelectStitchPostForRoutineScreen extends StatefulWidget {

  final String stitchIDIntent;

  const SelectStitchPostForRoutineScreen({Key key, @required this.stitchIDIntent})
      : super(key: key);


  @override
  _SelectStitchPostForRoutineScreenState createState() => _SelectStitchPostForRoutineScreenState();
}

class _SelectStitchPostForRoutineScreenState extends State<SelectStitchPostForRoutineScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  String userIDPref = "";
  final ScrollController listScrollController = ScrollController();
  int _limit = 20;

  StitchRoutineSelectionModel stitchModel = new StitchRoutineSelectionModel();
  String stitchTitle = "";
  List<PostFeedModel> postsList = new List();

  bool isLoading = false;
  int selectedPosts = 0;
  var _nomore = false;
  var _isFetching = false;
  DocumentSnapshot _lastDocument;

  List<String> postsStrList = new List<String>();




  @override
  void initState() {
    super.initState();
    listScrollController.addListener(_scrollListener);
    getPrefData();
    //getStiitches();
    getStitchDetail(widget.stitchIDIntent);


  }

  Future<String> getStitchDetail(String groupId) async {
    isLoading = true;

    FirebaseFirestore.instance
        .collection(Constants.stitchCollection).doc(groupId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (mounted) {
        setState(() {
          if (documentSnapshot.exists){
            try{
              stitchModel = StitchRoutineSelectionModel.fromSnapshot(documentSnapshot);

              isLoading = false;
              if (stitchModel != null) {
                postsStrList = stitchModel.post_ids;
                stitchTitle = stitchModel.title;
                _fetchPosts(postsStrList);

              }

            }catch(e){
              isLoading = false;
            }
          }else{
            isLoading = false;
          }

        });
      }
    });



  }

  void _fetchPosts(List<String> postsStrList) async {

    if(postsStrList.length>0){
      isLoading = true;
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Constants.posts).where("post_id", whereIn: postsStrList).orderBy('created_at',descending: true).limit(_limit).get();


      if(querySnapshot.docs.length>0) {
        _lastDocument = querySnapshot.docs.last;

        isLoading = false;

        for (final DocumentSnapshot snapshot in querySnapshot.docs) {
          PostFeedModel stitchRoutineModel = new PostFeedModel.fromSnapshot(snapshot);
          postsList.add(stitchRoutineModel);
        }
      }else{
        isLoading = false;
      }
    }

    setState(() {});
    // your logic here
  }

  Future<Null> _fetchFromLast() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constants.posts).where("post_id", whereIn: postsStrList).orderBy('created_at',descending: true).startAfter([_lastDocument['created_at']]).limit(_limit).get();
    if (querySnapshot.docs.length < 1) {
      _nomore = true;
      return;
    }
    _lastDocument = querySnapshot.docs.last;
    for (final DocumentSnapshot snapshot in querySnapshot.docs) {
      PostFeedModel stitchRoutineModel = new PostFeedModel.fromSnapshot(snapshot);
      postsList.add(stitchRoutineModel);
    }
    setState(() {});
  }

  void _scrollListener() async {
    if (_nomore) return;
    if (listScrollController.position.pixels == listScrollController.position.maxScrollExtent && _isFetching == false) {
      _isFetching = true;
      await _fetchFromLast();
      _isFetching = false;
    }
  }

  getPrefData() {
    Future<String> userId = SharedPref.getStringFromPrefs(Constants.USER_ID);
    userId.then((value) =>
    {
      userIDPref = value,
    }, onError: (err) {
    });


    if (mounted)
      setState(() {

      });
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
                height: MediaQuery
                    .of(context)
                    .padding
                    .top,
              ),
              Expanded(
                flex: 0,
                child: Container(
                  padding: EdgeInsets.only(
                      left: ScreenUtil().setSp(36),
                      right: ScreenUtil().setSp(36),
                      top: ScreenUtil().setSp(26),
                      bottom: ScreenUtil().setSp(26)),
                  child: Row(
                    children: <Widget>[

                      InkWell(
                        onTap: () {
                          setState(() {
                            Navigator.pop(context);
                          });
                        },
                        child: Container(
                            width: 22,
                            height: 22,
                            padding: EdgeInsets.all(2.5),
                            margin: EdgeInsets.only(left: 5,right: 8),
                            child: SvgPicture.asset(
                              'assets/images/ic_back.svg',
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                            )),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(stitchTitle != null ? stitchTitle : "",
                            style: TextStyle(
                              color: AppColors.titleTextColor,
                              fontFamily: Constants.boldFont,
                              fontSize: ScreenUtil().setSp(32),
                            ),
                          ),
                        ),
                      ),
                       Container(

                        margin: EdgeInsets.only(right: 5),

                         child: Text("Done",
                           style: TextStyle(
                             color: selectedPosts > 0 ? AppColors.primaryColor : AppColors.accentColor,
                             fontFamily: Constants.mediumFont,
                             fontSize: ScreenUtil().setSp(28),
                           ),
                         ),
                       ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: isLoading ? Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor)
                  ),
                ): postsList.length > 0
                    ? postsListing(context, postsList)
                    : Center(child:Container(
                  child: Text(
                    "No stitch available",style: TextStyle(
                      fontSize: ScreenUtil().setSp(26),
                      fontFamily: Constants.regularFont,
                      height: 1.3,
                      letterSpacing: 0.8),
                  ),
                ),)
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget postsListing(BuildContext context, postsListing) {
    return ListView(
      padding: EdgeInsets.zero,
      controller: listScrollController,
      children: <Widget>[
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: postsListing.length,
            primary: false,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return RoutinePostView(
                postsListing[index],
                context,
                index,
              );
            },
          ),
        ),
      ],
    );
  }


  Widget RoutinePostView(PostFeedModel selectedItem, BuildContext context, int index) {
    return StatefulBuilder(builder: (context, setState) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: () {
              /*if (fromPostPage) {
                selectedItem.isSelected = !selectedItem.isSelected;
                for (int i = 0; i < stitchListing.length - 1; i++) {
                  if (_index != i) {
                    stitchListing[i].isSelected = false;
                  }
                }
              } else {
                _postDetailTapped(selectedItem, _index,context,setState);
              }*/

              //goToStitchPosts(selectedItem.id);
              //setState(() {});
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(
                  left: ScreenUtil().setSp(30),
                  right: ScreenUtil().setSp(20),
                  top: ScreenUtil().setSp(20),
                  bottom: ScreenUtil().setSp(20)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: selectedItem.mediaList.first.mediaType=="Image" ? selectedItem.mediaList.first.url : selectedItem.mediaList.first.thumbnail,
                    imageBuilder: (context, imageProvider) => Container(
                      width: ScreenUtil().setSp(150),
                      height:  ScreenUtil().setSp(150),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => setPostDefaultImage(context),
                    errorWidget: (context, url, error) =>
                        setPostDefaultImage(context),
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.only(left: ScreenUtil().setSp(20)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Hero(
                              tag: 'titleOfItem$index',
                              child: Text(
                                selectedItem.title,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: AppColors.titleTextColor,
                                    fontFamily: Constants.boldFont,
                                    fontSize: ScreenUtil().setSp(27)),
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(selectedItem.description != null ? selectedItem.description : "",
                              maxLines: 4,
                              style: TextStyle(
                                  color: AppColors.lightGreyColor,
                                  fontFamily: Constants.regularFont,
                                  fontSize: ScreenUtil().setSp(25)),
                            ),
                          ]),
                    ),
                  ),
                 /* Visibility(
                    visible: selectedItem.isSelected,
                    child: Container(
                      width: 24,
                      height: 24,
                      padding: EdgeInsets.all(2.5),
                      child: SvgPicture.asset(
                        Constants.checkIcon,
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )*/
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
  setPostDefaultImage(BuildContext context) {
    return Container(
      width: ScreenUtil().setSp(150),
      height: ScreenUtil().setSp(150),
      decoration: BoxDecoration(
        color: AppColors.viewLineColor,
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
    );
  }




}
