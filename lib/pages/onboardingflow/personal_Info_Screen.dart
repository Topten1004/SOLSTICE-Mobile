import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solstice/pages/onboardingflow/intrests_screen_updated.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/utils/constants.dart';

class PersonalinfoScreen extends StatefulWidget {
  const PersonalinfoScreen({Key key}) : super(key: key);

  @override
  _PersonalinfoScreenState createState() => _PersonalinfoScreenState();
}

class _PersonalinfoScreenState extends State<PersonalinfoScreen> {
  TextEditingController livingController = new TextEditingController();
  TextEditingController trainController = new TextEditingController();
  TextEditingController supplementsController = new TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
              child: Image.asset("assets/images/help.png", height: 26, width: 26)),
        )
      ],
    );
    return SafeArea(
      child: Scaffold(
        appBar: appBar,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 91, right: 90),
              child: Text(
                'Tell us a little bit about yourself',
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
                'For Solstice’s algorithms to curate useful workouts & relevant content, we need to know some details about you',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFF868686),
                    fontFamily: Utils.fontfamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    margin: EdgeInsets.only(left: 29, right: 28),
                    height: MediaQuery.of(context).size.height * 0.12,
                    // width: MediaQuery.of(context).size.width*0.80,
                    decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFE8E8E8), width: 1),
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 13, left: 45),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Utils.text('What do you do for a living?', Utils.fontfamily,
                        Color(0xFF1E263C), FontWeight.w400, 14),
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40, right: 70, left: 40),
                  child: TextField(
                    controller: livingController,
                    decoration: new InputDecoration.collapsed(
                      focusColor: Color(0xFFB9BAC8),
                      hintText: 'eg. Chief Marketing Officer at Solstice',
                      hintStyle: TextStyle(
                          fontFamily: Utils.fontfamily,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0XFFB9BAC8)),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Container(
                      margin: EdgeInsets.only(left: 29, right: 28),
                      height: MediaQuery.of(context).size.height * 0.12,
                      // width: MediaQuery.of(context).size.width*0.80,
                      decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFE8E8E8), width: 1),
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 13, left: 45),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Utils.text('Where do you usually train?', Utils.fontfamily,
                          Color(0xFF1E263C), FontWeight.w400, 14),
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40, right: 70, left: 40),
                    child: TextField(
                      controller: trainController,
                      decoration: new InputDecoration.collapsed(
                          focusColor: Color(0xFFB9BAC8),
                          hintText: 'eg. Equinox gyms, home treadmill, etc.',
                          hintStyle: TextStyle(
                            fontFamily: Utils.fontfamily,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0XFFB9BAC8),
                          )),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Container(
                      margin: EdgeInsets.only(left: 29, right: 28),
                      height: MediaQuery.of(context).size.height * 0.12,
                      // width: MediaQuery.of(context).size.width*0.80,
                      decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFE8E8E8), width: 1),
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 13,
                      left: 45,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Utils.text('Do you take any supplements?', Utils.fontfamily,
                          Color(0xFF1E263C), FontWeight.w400, 14),
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40, right: 70, left: 40),
                    child: TextField(
                      controller: supplementsController,
                      decoration: new InputDecoration.collapsed(
                        focusColor: Color(0xFFB9BAC8),
                        hintText: 'eg. Whey protein, GNC vitamins, etc.',
                        hintStyle: TextStyle(
                            fontFamily: Utils.fontfamily,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0XFFB9BAC8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 76),
              child: InkWell(
                onTap: () {
                  saveData();
                },
                child: Container(
                  height: 56,
                  width: MediaQuery.of(context).size.width * 0.90,
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
                      child: Utils.text(
                          'Continue', Utils.fontfamily, Color(0xFFFFFFFF), FontWeight.w400, 18)),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Utils.saveSkipScreenName("PersonalinfoScreen", context);
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 34, bottom: 40),
                child: Utils.text(
                    'Skip for now', Utils.fontfamily, Utils.buttonColor, FontWeight.w600, 15),
              ),
            )
          ]),
        ),
      ),
    );
  }

  saveData() {
    FirebaseFirestore.instance.collection(Constants.UsersFB).doc(globalUserId).update({
      'profileComplete': 0,
      "livingDesc": livingController.text.toString(),
      "trainDesc": trainController.text.toString(),
      "supplements": supplementsController.text.toString(),
    }).then((docRef) {
      goToNext();
    });
  }

  goToNext() {
    Navigator.push(
        context, MaterialPageRoute(builder: (BuildContext context) => IntrestsScreenUpdated()));
  }
}
