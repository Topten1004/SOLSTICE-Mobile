import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solstice/pages/home_screen.dart';
import 'package:solstice/utils/constants.dart';

class Utils {
  static Color buttonColor = const Color(0xFF283646);
  static Color backgroundColor = const Color(0xFFE5E5E59);
  static Color borderColor = const Color(0xFF338BEF);
  static Color signinColor = const Color(0xFFFFFFFF);
  static Color registerTextColor = const Color(0xFF338BEF);
  static Color homescreensubtitle = const Color(0xFF2E2E2E);
  static Color homescreentitle = const Color(0xFF2E2E2E);
  static Color backArrowButton = const Color(0xFF283646);
  static Color profiletypeTextColor = const Color(0xFF0A0A0A);
  static Color subtitleColor = const Color(0xFF868686);
  static Color individualcolor = const Color(0xFF868686);
  static Color locationTextcolor = const Color(0xFF000000);
  static Color notNowColor = const Color(0xFF338BEF);
  static const String assetsPath = 'assets/images/';

  static const String loactionServiceImage = assetsPath + 'geolocation.png';
  static const String pushnotificationImage = assetsPath + 'pushnotification.png';
  static const String geoLoactiontwoImage = assetsPath + 'undraw_connected_world_wuay 1.png';
  static const String clouduploadIcon = assetsPath + 'cloud-upload - simple-line-icons.png';

  static const String arrowleftIcon = assetsPath + 'arrow-left.png';
  static const String dataanylaticalImage = assetsPath + 'data&analytic.png';
  static const String helpIcon = assetsPath + 'fi_help-circle.png';
  static const String maleIcon = assetsPath + 'maleicon.png';
  static const String femaleIcon = assetsPath + 'femaleIcon.png';
  static const String otherIcon = assetsPath + 'otherIcon.png';
  static const String teamIcon = assetsPath + 'teamicon.png';
  static const String lockIcon = assetsPath + 'lockicon.png';
  static const String gymIcon = assetsPath + 'gymicon.png';
  static const String tickIcon = assetsPath + 'tickIcon.png';
  static const String untickIcon = assetsPath + 'untickIcon.png';
  static const String solsciteImage = assetsPath + 'solsticeImage.png';
  static const String sendotpScreenlogo = assetsPath + 'sendotpsolcites.png';
  static const String deleteimage = assetsPath + 'Delete.jpg';
  static const String unionIcon = assetsPath + 'UnionIcon.png';
  static const String shareIcon = assetsPath + 'shareIcon.png';

  static String fontfamily = 'assets/fonts/FontsFree-Net-SFProText-Regular.ttf';
  static String fontfamilyInter = 'assets/fonts/Inter-Regular.ttf';

  static text(String text, String fontfamily, Color color, FontWeight fontWeight, double fontsize) {
    return Text(
      text,
      style: TextStyle(
          fontFamily: fontfamily, color: color, fontWeight: fontWeight, fontSize: fontsize),
    );
  }

  static button(String fontfamily, String text, color) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Color(color)),
      child: Center(
        child: Text(text,
            style: TextStyle(
                fontFamily: fontfamily, fontWeight: FontWeight.w600, color: Color(color))),
      ),
    );
  }

  static saveSkipScreenName(String name, BuildContext context) {
    FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(globalUserId)
        .update({'last_skipped_page': name, 'profileComplete': 0}).then((docRef) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => HomeScreen(
                    currentIndex: 0,
                  )),
          (route) => false);
    });
  }
}
