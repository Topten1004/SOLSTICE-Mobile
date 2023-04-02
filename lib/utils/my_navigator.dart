import 'package:flutter/material.dart';

class MyNavigator {
  static void goToLogin(BuildContext context) {
    //  Navigator.pushNamed(context, "/Login");
    Navigator.pushNamedAndRemoveUntil(context, "/Login", (r) => false);
  }


  static void goToWelcome(BuildContext context) {
    //  Navigator.pushNamed(context, "/Login");
    Navigator.pushNamedAndRemoveUntil(context, "/Welcome", (r) => false);
  }

  static void goToRegister(BuildContext context) {
    Navigator.pushNamed(context, "/Register");
  }

  static void goToAboutYou(BuildContext context) {
    //Navigator.pushNamed(context, "/AboutYouScreen");
    Navigator.pushNamedAndRemoveUntil(context, "/AboutYouScreen", (r) => false);
  }

  static void goToOtpVerification(BuildContext context) {
    Navigator.pushNamed(context, "/OtpVerification");
  }

  static void goToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, "/Home", (r) => false);
    // Navigator.pushReplacementNamed(context, "/Home");
  }

  static void goToProfileSetting(BuildContext context) {
    Navigator.pushNamed(context, "/ProfileSettingScreen");
  }

  static void goToGroupDetails(BuildContext context) {
    Navigator.pushNamed(context, "/GroupDetailsScreen");
  }

  static void goToForumsDetails(BuildContext context) {
    Navigator.pushNamed(context, "/ForumsDetailsScreen");
  }

  static void goToFollowersListing(BuildContext context) {
    Navigator.pushNamed(context, "/FollowersListingScreen");
  }
}
