import 'package:solstice/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';



class BlankScreen extends StatefulWidget {
  @override
  _BlankScreenState createState() => new _BlankScreenState();
}

class _BlankScreenState  extends State<BlankScreen> {

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(color: Colors.white),
        ),
        Stack(
          children: <Widget>[
            Center(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(

                      child: Text(
                        'Coming Soon',
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 24.0,
                            fontFamily: 'rubikregular',
                            color: AppColors.primaryColor),
                      ),
                    ),



                  ],
                ),
              ),
            ),


          ],
        )
      ],
    ),
  );
}
}


