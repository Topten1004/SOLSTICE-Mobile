import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:solstice/utils/constants.dart';

class SearchLocation extends StatefulWidget {
  @override
  _SearchLocationState createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  GooglePlace googlePlace;

  final FocusNode _cardNoFocus = new FocusNode();
  TextEditingController searchGroupsController = new TextEditingController();
  bool _isSearcedBoxBlank = true;
  List<SearchedLocationModel> _searchResult = new List();
  double latitude = 0.0, longitude = 0.0;

  @override
  void initState() {
    String apiKey = Constants.googleMapApiKey;
    googlePlace = GooglePlace(apiKey);
    super.initState();
    searchGroupsController.text = "";
    getCurrentLocation();
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  void getCurrentLocation() async {
    var currentLocation = await locateUser();

    try {
      latitude = currentLocation.latitude;
      longitude = currentLocation.longitude;
    } catch (ex) {
    }
    nearBySearch();
  }

  void nearBySearch() async {
//    var result = await googlePlace.autocomplete.get(value);
    var results = await googlePlace.search.getNearBySearch(
      Location(lat: latitude, lng: longitude),
      50000,
    );

    if (results != null) {
      if (results.results.length > 0) {
        var predictions = results.results;
        for (int i = 0; i < predictions.length; i++) {
          _searchResult.add(SearchedLocationModel(
              id: predictions[i].placeId,
              title: predictions[i].name,
              latitude: predictions[i].geometry.location.lat,
              longitude: predictions[i].geometry.location.lng,
              image: ''));
        }
        setState(() {});
      }
    }
  }

  void autoCompleteSearch(String value) async {
    _searchResult.clear();

    if (value != null && value != "") {
      var result = await googlePlace.autocomplete.get(value);
      if (result != null && result.predictions != null) {
        setState(() {

          for (int i = 0; i < result.predictions.length; i++) {
            _searchResult.add(SearchedLocationModel(
                id: result.predictions[i].placeId,
                title: result.predictions[i].description,
                image: ''));
          }

        });
      } else {
      }
    }
    if (mounted) {
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
      key: _scaffoldkey,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.white),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 22,
                          height: 22,
                          padding: EdgeInsets.all(2.5),
                          margin: EdgeInsets.only(left: 10, right: 16),
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
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.0),
                              color: AppColors.lightSkyBlue,
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                                          child: TextFormField(
                                            maxLength: 30,
                                            focusNode: _cardNoFocus,
                                            cursorColor: AppColors.primaryColor,
                                            controller: searchGroupsController,
                                            keyboardType: TextInputType.text,
                                            textInputAction: TextInputAction.search,
                                            onChanged: (v) {
                                              setState(() {
                                                if (searchGroupsController.value.text
                                                    .trim()
                                                    .isEmpty) {
                                                  _isSearcedBoxBlank = true;
                                                } else {
                                                  _isSearcedBoxBlank = false;
                                                }
                                              });

                                              autoCompleteSearch(
                                                  searchGroupsController.value.text.trim());
                                            },
                                            decoration: InputDecoration(
                                              counterText: "",
                                              hintText: "Search location",
                                              hintStyle: TextStyle(
                                                  color: AppColors.accentColor,
                                                  fontFamily: Constants.regularFont,
                                                  fontSize: ScreenUtil().setSp(26)),
                                              labelStyle: TextStyle(
                                                  color: AppColors.accentColor,
                                                  fontFamily: Constants.regularFont,
                                                  fontSize: ScreenUtil().setSp(28)),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                _isSearcedBoxBlank == true
                                    ? Expanded(
                                        flex: 0,
                                        child: Container(
                                            margin: const EdgeInsets.fromLTRB(8, 0, 16, 0),
                                            child: Icon(Icons.search,
                                                size: 21, color: AppColors.blackColor[100])),
                                      )
                                    : Expanded(
                                        flex: 0,
                                        child: InkWell(
                                          child: Container(
                                            margin: const EdgeInsets.fromLTRB(8, 0, 16, 0),
                                            child: Icon(
                                              Icons.close,
                                              size: 21,
                                              color: AppColors.blackColor[100],
                                            ),
                                          ),
                                          onTap: () {
                                            searchGroupsController.text = "";
                                            _isSearcedBoxBlank = true;
                                            FocusScope.of(context).unfocus();
                                            autoCompleteSearch("");
                                          },
                                        ),
                                      ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              Expanded(
                  child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _searchResult == null ? 0 : _searchResult.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        return new InkWell(
                          //highlightColor: Colors.red,
                          splashColor: AppColors.primaryColor,
                          onTap: () {
                            setState(() {
                              // _GroupDetailbuttonTapped(_searchResult[index]);

                              getPlaceDetail(_searchResult[index]);
                            });
                          },
                          child: LocationItem(_searchResult[index]),
                        );
                      },
                    ),
                  ),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> getPlaceDetail(SearchedLocationModel location) async {
    var result = await googlePlace.details.get(location.id);
    if (result != null && result.result != null && mounted) {

      location.latitude = result.result.geometry.location.lat;
      location.longitude = result.result.geometry.location.lng;

      /*latitude = result.result.geometry.location.lat;
      longitude = result.result.geometry.location.lng;
      locationIcon = result.result.photos.first.photoReference;
      ratingTotal = result.result.userRatingsTotal;
      userRating = result.result.rating;*/

      searchGroupsController.clear();
      Navigator.of(context).pop({
        "lat": location.latitude.toString(),
        "lng": location.longitude.toString(),
        "address": location.title.toString(),
      });

      // Navigator.of(context).pop({'update': "yes", "returnData": location});
    }
  }

  Widget LocationItem(SearchedLocationModel searchResult) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              Container(
                width: 20,
                height: 20,
                child: SvgPicture.asset(
                  'assets/images/ic_marker.svg',
                  fit: BoxFit.contain,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                flex: 1,
                child: Container(
                  child: Text(
                    searchResult.title,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(26),
                      fontFamily: Constants.regularFont,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SearchedLocationModel {
  String id, title, image;
  double latitude, longitude;
  SearchedLocationModel({this.id, this.title, this.image, this.latitude, this.longitude});
}
