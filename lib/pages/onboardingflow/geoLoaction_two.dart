import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:solstice/model/forum_model.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/shared_preferences.dart';

import '../search_location.dart';
import 'data_analytic.dart';
import 'injury_History_Screen.dart';

class GeoLocation extends StatefulWidget {
  const GeoLocation({Key key}) : super(key: key);

  @override
  _GeoLocationState createState() => _GeoLocationState();
}

class _GeoLocationState extends State<GeoLocation> {
  Position currentLocation;
  LatLng currentLatLng;
  double latitude;
  double longitude;
  String location = Constants.selectLocation;

  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Image(
                image: AssetImage(Utils.geoLoactiontwoImage),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular((20.0)),
                    topRight: Radius.circular(20.0),
                  ),
                  color: Color(0xFFFFFFFF),
                ),
                height: MediaQuery.of(context).size.height * 0.35,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 45),
                      child: Text(
                        'Confirm Your Location',
                        style: TextStyle(
                            fontFamily: Utils.fontfamily,
                            fontSize: 15,
                            color: Color(0xFF000000),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 21, left: 46, right: 46),
                      child: Center(
                          child: Text(
                        'In order for the app’s features to work at it’s best, confirm your location.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: Utils.fontfamily,
                            fontSize: 14,
                            color: Color(0xFF868686),
                            fontWeight: FontWeight.w400),
                      )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: InkWell(
                        onTap: () {
                          checkLocationPermission();
                          // Navigator.push(context,
                          //     MaterialPageRoute(builder: (BuildContext context) => Dataanalytic()));
                        },
                        child: Container(
                          height: 55,
                          width: 251,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10), color: Color(0xFF283646)),
                          child: Center(
                              child: Text(
                            'Use Current Location',
                            style: TextStyle(
                                fontFamily: Utils.fontfamily,
                                fontWeight: FontWeight.w600,
                                color: Utils.signinColor,
                                fontSize: 15),
                          )),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        var res = await Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) => SearchLocation()));
                        if (res != null) {
                          saveData(res['lat'], res['lng'], res['address']);
                        }
                      },
                      child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Utils.text('I’ll Enter My Location', Utils.fontfamily,
                              Utils.notNowColor, FontWeight.w400, 14)),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void saveData(String lat, String lng, String address) {
    FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(globalUserId)
        .update({'location_lat': lat, 'location_long': lng, 'address': address}).then((docRef) {
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Dataanalytic()));
    });
  }

  getUserLocation() async {
    currentLocation = await locateUser();
    currentLatLng = LatLng(currentLocation.latitude, currentLocation.longitude);
    //globals.currentLatLng = currentLatLng;
    try {
      latitude = currentLatLng.latitude;
      longitude = currentLatLng.longitude;
      List<Placemark> placemarks =
          await placemarkFromCoordinates(currentLocation.latitude, currentLocation.longitude);
      Placemark place = placemarks[0];
      location = "${place.locality}, ${place.country}";
      saveData(latitude.toString(), longitude.toString(), location);
    } catch (e) {
    }
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  void checkLocationPermission() async {
    final status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      _scaffoldkey.currentState.removeCurrentSnackBar();
      Constants.showSnackBarWithMessage(
          "Permission already granted", _scaffoldkey, context, Colors.green[700]);
      getUserLocation();
    } else if (status == PermissionStatus.denied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
      ].request();
    } else if (status == PermissionStatus.permanentlyDenied) {
      showDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
                title: Text("Location permission"),
                content: Text("SOLSTICE needs to access the location permission."),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text("Deny"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoDialogAction(
                      child: Text("settings"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        openAppSettings();
                      }),
                ],
              ));
    }
  }
}
