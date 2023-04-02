import 'package:flutter/material.dart' ;
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/pages/uploads/UploadStatus.dart';
import 'package:solstice/utils/constants.dart' ;

class UploadFileForm extends StatefulWidget {
  const UploadFileForm({Key key}):super(key :key) ;

  _UploadFileForm createState() => _UploadFileForm() ;
}

class _UploadFileForm extends State<UploadFileForm> {

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
                  "Upload Product",
                  style : TextStyle(
                    fontFamily: Utils.fontfamilyInter,
                    fontSize: 25
                  )
                ),
              ),
              Container(
                margin : EdgeInsets.only(top : 40),
                alignment: Alignment.center,
                width : MediaQuery.of(context).size.width,
                child : Text(
                  "Upload your file, let's SOLS do the work,",
                  style: TextStyle(
                    color: Colors.black45
                  ),
                )
              ),
              Container(
                  alignment: Alignment.center,
                  width : MediaQuery.of(context).size.width,
                  child : Text(
                      "and sell to your community securley.",
                    style: TextStyle(
                      color : Colors.black45
                    ),
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
                      child: Icon(Icons.cloud_upload_outlined, color: Colors.black, size: 60),
                    ),
                    Container(
                      child : Text(
                        "Choose File",
                        style: TextStyle(
                          color : Colors.black45,
                          fontFamily: Constants.fontInter,
                          fontSize: 17
                        ),
                      )
                    ),
                    SizedBox(
                      height: 40,
                    )
                  ],
                ),
              ),
              Container(
                margin : EdgeInsets.only(top: 60),
                padding: EdgeInsets.only(left : 40),
                alignment: Alignment.centerLeft,
                child: Text(
                  "Other ways to upload:",
                  style: TextStyle(
                    fontFamily: Constants.fontInter,
                    fontSize : 18,
                    color: Color(0xFF09193E),
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Container(
                margin : EdgeInsets.only(top : 20, left : 40, right : 40),
                padding: EdgeInsets.only(top: 20, bottom : 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.75,0.99,],
                    colors: <Color>[
                      Color(0xFFFFFF),
                      Color(0xFFe6e3e0),
                    ],
                  ),
                  border: Border(
                      bottom: BorderSide(
                          width: 1.0,
                          color : Color(0xFFe6e3e0)
                      )
                  )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      padding : EdgeInsets.only(left : 15, right: 15, top : 10, bottom: 10),
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        border: Border.all(
                          width: 1.0,
                          color : Color(0xFFe6e3e0)
                        ),
                        color: Colors.white
                      ),
                      child: Center(
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceAround,
                         children: [
                           Image.asset('assets/images/dropbox.png', height: 30,width: 30,),
                           Text(
                             "Dropbox",
                             style: TextStyle(
                                 fontWeight: FontWeight.bold,
                                 color: Color(0xFF0E1345)
                             ),
                           ),
                         ],
                       )
                      )
                    ),
                    Container(
                      padding : EdgeInsets.only(left : 15, right: 15, top : 10, bottom: 10),
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        border: Border.all(
                            width: 1.0,
                            color : Color(0xFFe6e3e0)
                        ),
                        color: Colors.white
                      ),
                      child : Center(
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceAround,
                         children: [
                           Image.asset('assets/images/drive.png', height: 30,width: 30,),
                           Text(
                             "Drive",
                             style: TextStyle(
                                 fontWeight: FontWeight.bold,
                                 color: Color(0xFF0E1345)
                             ),
                           ),
                         ],
                       )
                      )
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => UploadStatus())) ;
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