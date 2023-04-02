import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:solstice/pages/onboardingflow/geoLoaction_two.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/pages/onboardingflow/welcomeScreen.dart';
import 'package:solstice/utils/constants.dart';

class PushNotificationScreen extends StatefulWidget {
  const PushNotificationScreen({Key key}) : super(key: key);

  @override
  _PushNotificationScreenState createState() => _PushNotificationScreenState();
}

class _PushNotificationScreenState extends State<PushNotificationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  Future<String> permissionStatusFuture;

  var permGranted = "granted";
  var permDenied = "denied";
  var permUnknown = "unknown";
  var permProvisional = "provisional";
  @override
  initState() {
    super.initState();
    // permissionStatusFuture = getCheckNotificationPermStatus();
  }

  /// Checks the notification permission status
  // Future<String> getCheckNotificationPermStatus() {
  //   return NotificationPermissions.getNotificationPermissionStatus().then((status) {
  //     switch (status) {
  //       case PermissionStatus.denied:
  //         return permDenied;
  //       case PermissionStatus.granted:
  //         return permGranted;
  //       case PermissionStatus.unknown:
  //         return permUnknown;
  //       case PermissionStatus.provisional:
  //         return permProvisional;
  //       default:
  //         return null;
  //     }
  //   });
  // }

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
                image: AssetImage(Utils.pushnotificationImage),
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
                height: MediaQuery.of(context).size.height * 0.38,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 45),
                      child: Text(
                        'Push Notifications',
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
                        'In order for the app to work, it will require the permission to access location.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: Utils.fontfamily,
                            fontSize: 16,
                            color: Color(0xFF868686),
                            fontWeight: FontWeight.normal),
                      )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: InkWell(
                        onTap: () async {
                          checkCameraPermission();
                          // permissionStatusFuture = getCheckNotificationPermStatus();
                          // Navigator.push(context,
                          //     MaterialPageRoute(builder: (BuildContext context) => GeoLocation()));
                        },
                        child: Container(
                          height: 55,
                          width: 251,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10), color: Color(0xFF283646)),
                          child: Center(
                              child: Text(
                            'Allow Push Notifications',
                            style: TextStyle(
                                fontFamily: Utils.fontfamily,
                                fontWeight: FontWeight.w600,
                                color: Utils.signinColor),
                          )),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Utils.text(
                              'Not Now', Utils.fontfamily, Utils.notNowColor, FontWeight.w400, 14)),
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

  void checkCameraPermission() async {
    final status = await Permission.notification.request();
    if (status == PermissionStatus.granted) {
      Constants.showSnackBarWithMessage(
          "Permission already granted", _scaffoldkey, context, Colors.green[700]);
      Future.delayed(const Duration(milliseconds: 1000), () {
        _scaffoldkey.currentState.removeCurrentSnackBar();

        Navigator.push(
            context, MaterialPageRoute(builder: (BuildContext context) => GeoLocation()));
      });
    } else if (status == PermissionStatus.denied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.notification,
      ].request();
    } else if (status == PermissionStatus.permanentlyDenied) {
      showDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
                title: Text(""),
                content: Text(""),
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
