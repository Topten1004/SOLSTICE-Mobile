import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solstice/pages/onboardingflow/biz_Q_four.dart';
import 'package:solstice/pages/onboardingflow/biz_Q_three.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/utils/constants.dart';

class BizQ1Screen extends StatefulWidget {
  const BizQ1Screen({Key key}) : super(key: key);

  @override
  _BizQ1ScreenState createState() => _BizQ1ScreenState();
}

class _BizQ1ScreenState extends State<BizQ1Screen> {
  bool gymSelected = true;
  bool teamSelected = false;
  bool brandSelected = false;
  String selectedValue = "Gym";
  TextEditingController pageAdminController = new TextEditingController();
  TextEditingController websiteController = new TextEditingController();
  var urlPattern =
      (r"((https?:www\.)|(https?:\/\/)|(www\.)|(a-zA-Z))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([
      //This line is used for showing the bottom bar
    ]);
  }

  bool validateUrl(String hyperlink) {
    var match = new RegExp(urlPattern, caseSensitive: false);

    return match.hasMatch(hyperlink);
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
        // onPressed: () {},
        onPressed: () => Navigator.of(context).pop(),
      ),
      elevation: 0,
      actions: [
        Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child:
                  Image.asset("assets/images/help.png", height: 26, width: 26)),
        )
      ],
    );
    return Scaffold(
      appBar: appBar,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              'Tell us a little bit\nabout yourself',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xFF1F1F1F),
                  fontWeight: FontWeight.normal,
                  fontFamily: Utils.fontfamily,
                  fontSize: 24),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 19, left: 48, right: 47),
            child: Text(
              'For Solstice’s algorithms to curate useful workouts & relevant content, we need \nto know some details about you',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF868686),
                fontFamily: Utils.fontfamily,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 24, right: 24),
            child: Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  SizedBox(width: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          gymSelected = true;
                          teamSelected = false;
                          brandSelected = false;
                          selectedValue = "Gym";
                          setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 29,
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(10),
                            height: 46,
                            width: 149,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                border:
                                    Border.all(color: Colors.blue, width: 1),
                                color: gymSelected
                                    ? AppColors.blueColor
                                    : Colors.white),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 25),
                                  child: ImageIcon(
                                    AssetImage(Utils.gymIcon),
                                    color: gymSelected
                                        ? Colors.white
                                        : AppColors.blueColor,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 25),
                                  child: Text(
                                    'Gym',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontFamily: Utils.fontfamilyInter,
                                        fontSize: 14,
                                        color: !gymSelected
                                            ? AppColors.blueColor
                                            : Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          gymSelected = false;
                          teamSelected = true;
                          brandSelected = false;
                          selectedValue = "Team";
                          setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 29),
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(10),
                            height: 46,
                            width: 149,
                            decoration: BoxDecoration(
                              color: teamSelected
                                  ? AppColors.blueColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.blue, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: ImageIcon(
                                    AssetImage(Utils.teamIcon),
                                    color: !teamSelected
                                        ? Color(0xFF338BEF)
                                        : Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Text(
                                    'Team',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontFamily: Utils.fontfamilyInter,
                                      color: !teamSelected
                                          ? AppColors.blueColor
                                          : Colors.white,
                                      fontSize: 14,
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
                  SizedBox(
                    width: 5,
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      gymSelected = false;
                      teamSelected = false;
                      brandSelected = true;
                      selectedValue = "Brand";
                      setState(() {});
                    },
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 11),
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(10),
                          height: 46,
                          width: 149,
                          decoration: BoxDecoration(
                            color: brandSelected
                                ? AppColors.blueColor
                                : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.blue, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: ImageIcon(
                                  AssetImage(Utils.lockIcon),
                                  color: !brandSelected
                                      ? Color(0xFF338BEF)
                                      : Colors.white,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Text(
                                  'Brand',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontFamily: Utils.fontfamilyInter,
                                    color: !brandSelected
                                        ? AppColors.blueColor
                                        : Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 25,
                    ),
                    child: Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 8, right: 8, top: 25),
                          height: 56,
                          // width: MediaQuery.of(context).size.width*0.80,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color(0XFFE8E8E8), width: 1),
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 15, left: 20, right: 133),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Utils.text('Website', Utils.fontfamily,
                                Color(0xFF1E263C), FontWeight.w400, 14),
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 25, right: 35, left: 28),
                          child: TextField(
                            controller: websiteController,
                            onChanged: (value) {
                              setState(() {});
                            },
                            decoration: new InputDecoration(
                              border: InputBorder.none,
                              focusColor: Color(0xFFB9BAC8),
                              hintText: 'www.solstice.com',
                              suffix:
                                  validateUrl(websiteController.text.toString())
                                      ? SizedBox(
                                          height: 7,
                                          width: 12,
                                          child: ImageIcon(
                                            AssetImage(Utils.tickIcon),
                                            color: Color(0xFF00B227),
                                          ))
                                      : Container(
                                          width: 2,
                                        ),
                              hintStyle: TextStyle(
                                  fontFamily: Utils.fontfamily,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14,
                                  color: Color(0XFFB9BAC8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 8, right: 8, top: 30),
                        height: 56,
                        // width: MediaQuery.of(context).size.width*0.80,
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: Color(0XFFE8E8E8), width: 1),
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                          left: 20,
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Utils.text('Page Admins', Utils.fontfamily,
                              Color(0xFF1E263C), FontWeight.w400, 14),
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 45, right: 50, left: 28),
                        child: TextField(
                          controller: pageAdminController,
                          decoration: new InputDecoration.collapsed(
                            focusColor: Color(0xFFB9BAC8),
                            hintText: 'Search users',
                            hintStyle: TextStyle(
                                fontFamily: Utils.fontfamily,
                                fontWeight: FontWeight.w300,
                                fontSize: 14,
                                color: Color(0XFFB9BAC8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 34),
            child: InkWell(
              onTap: () {
                saveInfo();
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xFF283646),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF434344).withOpacity(0.07),
                      spreadRadius: 1,
                      blurRadius: 13,
                      offset: Offset(0, 15), // changes position of shadow
                    ),
                  ],
                ),
                child: Center(
                    child: Utils.text('Continue', Utils.fontfamily,
                        Color(0xFFFFFFFF), FontWeight.w400, 18)),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Utils.saveSkipScreenName('BizQ1Screen',context);
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 40),
              child: Utils.text('Skip for now', Utils.fontfamily,
                  Utils.buttonColor, FontWeight.w600, 15),
            ),
          )
        ]),
      ),
    );
  }

  void saveInfo() {
    FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(globalUserId)
        .update({
      'businessType': selectedValue,
      'pageAdmin': pageAdminController.text.toString(),
      'website': websiteController.text.toString(),
      'profileComplete': 0
    }).then((docRef) {
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) => BizQ4Screen()));
    });
  }
}
