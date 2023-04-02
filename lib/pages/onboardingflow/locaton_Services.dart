import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';

import 'personal_Info_Screen.dart';

class LocationServicesScreen extends StatefulWidget {
  // const LocationServicesScreen { Key? key }) : super(key: key);

  @override
  _LocationServicesScreenState createState() => _LocationServicesScreenState();
}

class _LocationServicesScreenState extends State<LocationServicesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Image(
                image: AssetImage(Utils.loactionServiceImage),
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
                  color: Utils.signinColor,
                ),
                height: MediaQuery.of(context).size.height * 0.40,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 45),
                      child: Text(
                        'Location Services',
                        style: TextStyle(
                            fontFamily: Utils.fontfamily,
                            fontSize: 15,
                            color: Utils.locationTextcolor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 21, left: 46, right: 46),
                      child: Center(
                          child: Text(
                        'In order for the app’s features to work at it’s best, we need your permission to enable location services.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: Utils.fontfamily,
                            fontSize: 16,
                            color: Utils.subtitleColor,
                            fontWeight: FontWeight.w400),
                      )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => PersonalinfoScreen()));
                        },
                        child: Container(
                          height: 55,
                          width: 251,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10), color: Color(0xFF283646)),
                          child: Center(
                              child: Text(
                            'Enable Location Services',
                            style: TextStyle(
                                fontFamily: Utils.fontfamily,
                                fontWeight: FontWeight.w600,
                                color: Utils.signinColor),
                          )),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                        ),
                        child: Utils.text(
                            'Not Now', Utils.fontfamily, Utils.notNowColor, FontWeight.w400, 14),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
