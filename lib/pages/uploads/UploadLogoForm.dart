import 'package:flutter/material.dart' ;
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/pages/uploads/PodCastWallet.dart';
import 'package:solstice/pages/uploads/UploadStatus.dart';
import 'package:solstice/utils/constants.dart' ;

class UploadLogoForm extends StatefulWidget {
  const UploadLogoForm({Key key}):super(key:key) ;

  _UploadLogoFormState createState() => _UploadLogoFormState() ;
}

class _UploadLogoFormState extends State<UploadLogoForm> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>() ;

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

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar,
        key : _scaffoldKey,
        body : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                child: Text(
                    "Sundays Podcast:",
                    style : TextStyle(
                      fontFamily: Utils.fontfamilyInter,
                      fontSize: 25,
                      color: Colors.black
                    )
                ),
              ),
              Container(
                  alignment: Alignment.center,
                  width : MediaQuery.of(context).size.width,
                  child : Text(
                    "(Enter Text)",
                    style: TextStyle(
                      fontFamily: Utils.fontfamilyInter,
                      color: Colors.black,
                      fontSize: 25
                    ),
                  )
              ),
              Container(
                margin: EdgeInsets.only(left : 40, right:40, top:50),
                child: Stack(
                  children: [
                    TextField(
                      minLines: 10,
                      maxLines: 10,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (value) {

                        setState(() {});
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText : "  Describe Your Product  ",
                          labelStyle: TextStyle(
                              fontFamily: Utils.fontfamilyInter,
                              color : Color(0xFF141636),
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),
                          hintText: 'eg. CoalBeans are workout supplements that help people work out better.',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          contentPadding: EdgeInsets.all(25.0),
                    )),
                    Positioned(bottom: 0,right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: Image.asset(Utils.tickIcon, height: 20, width: 20,), onPressed: () {}),
                          ]
                      )
                    )
                  ],
                )
              ),
              Container(
                margin : EdgeInsets.only(top : 30, left : 40, right : 40),
                width: MediaQuery.of(context).size.width - 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: new Border.all(
                      width: 1.0, color: Colors.black),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom : 20),
                      child : Text(
                        "Upload Product Logo",
                        style: TextStyle(
                            color : Colors.black,
                            fontFamily: Constants.fontInter,
                            fontSize: 20
                        ),
                      )
                    ),
                    Container(
                      child: Icon(Icons.cloud_upload_outlined, color: Colors.black, size: 60),
                    ),
                    SizedBox(
                      height: 40,
                    )
                  ],
                ),
              ),
              Container(
                  margin: EdgeInsets.only(left : 20, right : 20, top : 40),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                            color: Color(0xff283646).withOpacity(0.32),
                            blurRadius: 3.0,
                            spreadRadius: 3),
                      ],
                      color: Color(0xFF283646)
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PodCastWallet())) ;
                    },
                    child : Container(
                        width: MediaQuery.of(context).size.width - 80,
                        child: Center(
                          child: Utils.text(
                              'Continue', Utils.fontfamily, Color(0xFFFFFFFF), FontWeight.w400, 20),
                        )
                    ),
                  )
              )
            ],
          ),
        )
    );
  }
}