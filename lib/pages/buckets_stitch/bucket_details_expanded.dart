import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solstice/model/bucket_stitch_model.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/size_utils.dart';
import 'package:transparent_image/transparent_image.dart';

// ignore: must_be_immutable
class BucketDetailsExpanded extends StatefulWidget {
  String url;
  String bucketName;
  int indexOfHero;

  BucketDetailsExpanded(
      {@required this.url,
      @required this.bucketName,
      @required this.indexOfHero}) {}

  @override
  _BucketDetailsExpandedState createState() => _BucketDetailsExpandedState();
}

class _BucketDetailsExpandedState extends State<BucketDetailsExpanded> {
  var imageFile = null;

  TextEditingController bucketNameController = new TextEditingController();
  TextEditingController bucketTypeController = new TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  List<BucketStitchModel> bucketList = new List<BucketStitchModel>();

  @override
  void initState() {
    super.initState();
    setDefaultList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.white),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: ScreenUtil().setSp(36),
                right: ScreenUtil().setSp(36),
                top: ScreenUtil().setSp(26),
                bottom: ScreenUtil().setSp(26)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).padding.top,
                ),
                Expanded(
                  flex: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
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
                            padding: EdgeInsets.all(3),
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
                            padding:
                                EdgeInsets.only(left: ScreenUtil().setSp(20)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  " " + widget.bucketName,
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
                        InkWell(
                          onTap: () {
                            _shoEditBucketDetails(
                                widget.bucketName, widget.url, context);
                          },
                          child: Container(
                            width: 26,
                            height: 26,
                            padding: EdgeInsets.all(3),
                            child: SvgPicture.asset(
                              'assets/images/ic_edit.svg',
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Container(
                            width: 26,
                            height: 26,
                            padding: EdgeInsets.all(5),
                            child: SvgPicture.asset(
                              'assets/images/ic_plus.svg',
                              alignment: Alignment.center,
                              color: Colors.black,
                              fit: BoxFit.contain,
                            )),
                      ],
                    ),
                  ),
                ),
                setViewsOnTypeBasis(widget.indexOfHero),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.all(12),
                    child: StaggeredGridView.countBuilder(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 12,
                      itemCount: bucketList.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          child: InkWell(
                            onTap: () {},
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              child: FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: bucketList[index].image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                      staggeredTileBuilder: (index) {
                        return StaggeredTile.count(1, index.isEven ? 1.2 : 1.8);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget setViewsOnTypeBasis(int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        Expanded(
          flex: 0,
          child: Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: widget.url,
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
                SizedBox(
                  width: 10,
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
                          "Lenny Gracia",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColors.titleTextColor,
                              fontFamily: Constants.boldFont,
                              fontSize: ScreenUtil().setSp(26)),
                        ),
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                            SizedBox(width: 3),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Radio House 83th",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: AppColors.accentColor,
                                    fontFamily: Constants.regularFont,
                                    fontSize: ScreenUtil().setSp(22)),
                              ),
                            ),
                            Text(
                              "3d",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: AppColors.titleTextColor,
                                  fontFamily: Constants.mediumFont,
                                  fontSize: ScreenUtil().setSp(22)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: ScreenUtil().setSp(370),
          child: Hero(
            tag: 'imageHero$index',
            child: CachedNetworkImage(
              imageUrl: widget.url,
              imageBuilder: (context, imageProvider) => Container(
                width: MediaQuery.of(context).size.width,
                height: ScreenUtil().setSp(370),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
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
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                "This is the title for the journey",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: AppColors.titleTextColor,
                    fontFamily: Constants.boldFont,
                    fontSize: ScreenUtil().setSp(27)),
              ),
              SizedBox(height: 6),
              Text(
                "Caption for this journey, Lorem ipsum dolor",
                maxLines: 2,
                style: TextStyle(
                    color: AppColors.titleTextColor,
                    fontFamily: Constants.regularFont,
                    fontSize: ScreenUtil().setSp(23)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          child: Row(
            children: [
              InkWell(
                child: Container(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26.0),
                      color: AppColors.lightSkyBlue),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 18,
                          height: 18,
                          padding: EdgeInsets.all((1)),
                          child: SvgPicture.asset(
                            'assets/images/ic_comment.svg',
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                          )),
                      SizedBox(width: 8),
                      Text(
                        "12",
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: AppColors.titleTextColor,
                            fontFamily: Constants.boldFont,
                            fontSize: ScreenUtil().setSp(26)),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              InkWell(
                child: Container(
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border:
                            Border.all(width: 2, color: AppColors.lightSkyBlue),
                        borderRadius: BorderRadius.circular(26.0)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 18,
                            height: 18,
                            padding: EdgeInsets.all((1)),
                            child: SvgPicture.asset(
                              'assets/images/ic_heart.svg',
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                            )),
                        SizedBox(width: 8),
                        Text(
                          "25",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColors.titleTextColor,
                              fontFamily: Constants.boldFont,
                              fontSize: ScreenUtil().setSp(26)),
                        ),
                        SizedBox(width: 8),
                      ],
                    )), /*onTap: (){
                setState(() {
                  if(!isSelectedRecent){
                    isSelectedRecent = true;
                  }
                });
              },*/
              ),
              Expanded(flex: 1, child: Container()),
              InkWell(
                child: Container(
                  padding:
                      EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26.0),
                      color: AppColors.lightSkyBlue),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 18,
                          height: 18,
                          padding: EdgeInsets.all((1)),
                          child: SvgPicture.asset(
                            'assets/images/ic_bookmarked.svg',
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                          )),
                      SizedBox(width: 10),
                      Text(
                        "Stitch",
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: AppColors.primaryColor,
                            fontFamily: Constants.boldFont,
                            fontSize: ScreenUtil().setSp(26)),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  setPostDefaultImage(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: ScreenUtil().setSp(370),
      decoration: BoxDecoration(
        color: AppColors.viewLineColor,
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
    );
  }

  void setDefaultList() {
    bucketList.add(new BucketStitchModel(
      "https://www.bodybuilding.com/fun/images/2015/how-to-make-yourself-the-best-trainer-at-any-gym-facebook-box-960x540.jpg",
      "Bucket 1",
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry.  when an unknown printer took a galley of type and scrambled",
    ));
    bucketList.add(new BucketStitchModel(
      "https://images.hindustantimes.com/Images/popup/2015/7/Crunches.jpg",
      "Bucket 2",
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy",
    ));
    bucketList.add(new BucketStitchModel(
      "https://www.bodybuilding.com/fun/images/2015/how-to-make-yourself-the-best-trainer-at-any-gym-facebook-box-960x540.jpg",
      "Bucket 3",
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled",
    ));
    bucketList.add(new BucketStitchModel(
      "https://1.bp.blogspot.com/-ITDeKbpwTbk/XJePd5D2nyI/AAAAAAAAAkQ/JGEzWJ0uGCsLjo09hjNTeP7Cwndrp9x5ACEwYBhgL/s640/gym-trainer-1.jpg",
      "Bucket 4",
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled",
    ));
    bucketList.add(new BucketStitchModel(
      "https://images.hindustantimes.com/Images/popup/2015/7/Crunches.jpg",
      "Bucket 5",
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled",
    ));

    bucketList.add(new BucketStitchModel(
      "https://images.hindustantimes.com/Images/popup/2015/7/Crunches.jpg",
      "Stitch 1",
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled",
    ));
    bucketList.add(new BucketStitchModel(
      "https://www.bodybuilding.com/fun/images/2015/how-to-make-yourself-the-best-trainer-at-any-gym-facebook-box-960x540.jpg",
      "Stitch 1",
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled",
    ));
    bucketList.add(new BucketStitchModel(
        "https://1.bp.blogspot.com/-ITDeKbpwTbk/XJePd5D2nyI/AAAAAAAAAkQ/JGEzWJ0uGCsLjo09hjNTeP7Cwndrp9x5ACEwYBhgL/s640/gym-trainer-1.jpg",
        "Stitch 2",
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. "));
    bucketList.add(new BucketStitchModel(
      "https://images.hindustantimes.com/Images/popup/2015/7/Crunches.jpg",
      "Stitch 3",
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. ",
    ));
    bucketList.add(new BucketStitchModel(
      "https://www.bodybuilding.com/fun/images/2015/how-to-make-yourself-the-best-trainer-at-any-gym-facebook-box-960x540.jpg",
      "Stitch 5",
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled",
    ));
    bucketList.add(new BucketStitchModel(
        "https://1.bp.blogspot.com/-ITDeKbpwTbk/XJePd5D2nyI/AAAAAAAAAkQ/JGEzWJ0uGCsLjo09hjNTeP7Cwndrp9x5ACEwYBhgL/s640/gym-trainer-1.jpg",
        "Stitch 6",
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. "));
    bucketList.add(new BucketStitchModel(
      "https://www.bodybuilding.com/fun/images/2015/how-to-make-yourself-the-best-trainer-at-any-gym-facebook-box-960x540.jpg",
      "Stitch 7",
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled",
    ));
  }

  void _shoEditBucketDetails(
      String bucketName, String url, BuildContext context) {
    bucketNameController.text = bucketName;

    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return new Container(
              color: Colors.transparent,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: new Container(
                padding: EdgeInsets.all(ScreenUtil().setSp(40)),
                decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(25.0),
                        topRight: const Radius.circular(25.0))),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 1.0, top: 10.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: 16,
                                height: 16,
                                padding: EdgeInsets.all(2.5),
                                margin: EdgeInsets.only(right: 5),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/images/ic_cross_bottom.svg',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Edit Bucket',
                            style: TextStyle(
                                fontFamily: 'epilogue_semibold',
                                fontSize: ScreenUtil().setSp(30),
                                color: Colors.black),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Upload Bucket Thumbnail',
                            style: TextStyle(
                                fontFamily: 'epilogue_semibold',
                                fontSize: ScreenUtil().setSp(25),
                                color: Color(0xFF727272)),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      imageFile == null
                          ? InkWell(
                              onTap: () {
                                _settingModalBottomSheet(context, setState);
                              },
                              child: Container(
                                child: PhysicalModel(
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppColors.viewLineColor,
                                  elevation: 5,
                                  shadowColor: AppColors.shadowColor,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        url,
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      )),
                                ),
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                _settingModalBottomSheet(context, setState);
                              },
                              child: Container(
                                child: PhysicalModel(
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppColors.viewLineColor,
                                  elevation: 5,
                                  shadowColor: AppColors.shadowColor,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      imageFile,
                                      fit: BoxFit.cover,
                                      height: 90,
                                      width: 90,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        'Bucket Name',
                        style: TextStyle(
                            fontFamily: 'epilogue_semibold',
                            fontSize: ScreenUtil().setSp(25),
                            color: Color(0xFF727272)),
                      ),
                      TextField(
                        controller: bucketNameController,
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(30),
                            fontFamily: 'epilogue_regular'),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        'Bucket Type',
                        style: TextStyle(
                            fontFamily: 'epilogue_semibold',
                            fontSize: ScreenUtil().setSp(25),
                            color: Color(0xFF727272)),
                      ),
                      TextField(
                        controller: bucketTypeController,
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(30),
                            fontFamily: 'epilogue_regular'),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: ScreenUtil().setSp(95),
                        width: MediaQuery.of(context).size.width,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.0),
                            side: BorderSide(color: AppColors.primaryColor),
                          ),
                          color: AppColors.primaryColor,
                          onPressed: () {},
                          child: Text(
                            'Save Changes',
                            style: TextStyle(
                                fontFamily: 'epilogue_semibold',
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _settingModalBottomSheet(context, state) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Container(
              child: new Wrap(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      "Select From",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: Constants.mediumFont,
                          fontSize: 18.0),
                    ),
                  ),
                  new ListTile(
                    title: new Text('Camera',
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: Constants.regularFont,
                            fontSize: 16.0)),
                    onTap: () => {
                      FocusScope.of(context).unfocus(),
                      imageSelector(context, "camera", state),
                      Navigator.pop(context)
                    },
                  ),
                  new ListTile(
                      title: new Text('Gallery',
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: Constants.regularFont,
                              fontSize: 16.0)),
                      onTap: () => {
                            FocusScope.of(context).unfocus(),
                            imageSelector(context, "gallery", state),
                            Navigator.pop(context),
                          }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future imageSelector(
      BuildContext context, String pickerType, StateSetter state) async {
    switch (pickerType) {
      case "gallery":

        /// GALLERY IMAGE PICKER
        imageFile = await ImagePicker()
            .pickImage(source: ImageSource.gallery, imageQuality: 90);
        break;

      case "camera": // CAMERA CAPTURE CODE
        imageFile = await ImagePicker()
            .pickImage(source: ImageSource.camera, imageQuality: 90);
        break;
    }

    if (imageFile != null) {
      updated(state);
    } else {
    }
  }

  Future<Null> updated(StateSetter updateState) async {
    updateState(() {});
  }
}
