import 'package:flutter/material.dart';
import 'package:solstice/pages/onboardingflow/locaton_Services.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';

class IntrestSubcategoryScreen extends StatefulWidget {
  const IntrestSubcategoryScreen({Key key}) : super(key: key);

  @override
  _IntrestSubcategoryScreenState createState() => _IntrestSubcategoryScreenState();
}

class _IntrestSubcategoryScreenState extends State<IntrestSubcategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(children: [
            Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop() ;
                    },
                    child: ImageIcon(AssetImage(Utils.arrowleftIcon)),
                  ),
                  ImageIcon(AssetImage(Utils.helpIcon)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 91, right: 90),
              child: Text(
                'Tell us about your interests',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFF1F1F1F),
                    fontWeight: FontWeight.normal,
                    fontFamily: Utils.fontfamily,
                    fontSize: 24),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 19, left: 47, right: 47),
              child: Text(
                'Want to be more specific about your \ninterests? Tell us more about the ones you selected on the previous screen.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFF868686),
                    fontFamily: Utils.fontfamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
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
                    padding: const EdgeInsets.only(top: 14, left: 45, right: 133),
                    child: Container(
                      height: 17,
                      width: 90,
                      child: Center(
                        child: Utils.text(
                            'Aesthetics', Utils.fontfamily, Color(0xFF1E263C), FontWeight.w400, 14),
                      ),
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, right: 70, left: 55),
                    child: TextField(
                      decoration: new InputDecoration.collapsed(
                        focusColor: Color(0xFFB9BAC8),
                        hintText: 'Separate sub-categories by commas',
                        hintStyle: TextStyle(
                            fontFamily: Utils.fontfamily,
                            fontWeight: FontWeight.w400,
                            fontSize: 8,
                            color: Color(0XFFB9BAC8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
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
                    padding: const EdgeInsets.only(top: 14, left: 45, right: 133),
                    child: Container(
                      height: 17,
                      width: 90,
                      child: Center(
                        child: Utils.text('Injury Rehab', Utils.fontfamily, Color(0xFF1E263C),
                            FontWeight.w400, 14),
                      ),
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, right: 70, left: 50),
                    child: TextField(
                      decoration: new InputDecoration.collapsed(
                        focusColor: Color(0xFFB9BAC8),
                        hintText: 'Separate sub-categories by commas',
                        hintStyle: TextStyle(
                            fontFamily: Utils.fontfamily,
                            fontWeight: FontWeight.w400,
                            fontSize: 8,
                            color: Color(0XFFB9BAC8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
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
                    padding: const EdgeInsets.only(top: 14, left: 45, right: 133),
                    child: Container(
                      height: 17,
                      width: 101,
                      child: Center(
                        child: Utils.text('General Health', Utils.fontfamily, Color(0xFF1E263C),
                            FontWeight.w400, 14),
                      ),
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, right: 70, left: 50),
                    child: TextField(
                      decoration: new InputDecoration.collapsed(
                        focusColor: Color(0xFFB9BAC8),
                        hintText: 'Separate sub-categories by commas',
                        hintStyle: TextStyle(
                            fontFamily: Utils.fontfamily,
                            fontWeight: FontWeight.w400,
                            fontSize: 8,
                            color: Color(0XFFB9BAC8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 34),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => LocationServicesScreen()));
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.08,
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
            Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 40),
              child: Utils.text(
                  'Skip for now', Utils.fontfamily, Utils.buttonColor, FontWeight.w600, 15),
            )
          ]),
        ),
      ),
    );
  }
}
