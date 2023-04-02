import 'package:flutter/material.dart' ;
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/pages/uploads/PodCastAdjust.dart';
import 'package:solstice/utils/constants.dart' ;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart' ;

class UploadStatus extends StatefulWidget {
  const UploadStatus({Key key}):super(key : key) ;

  _UploadStatusState createState() => _UploadStatusState() ;
}

class _UploadStatusState extends State<UploadStatus> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>() ;
  final CarouselController _carouselController = CarouselController();

  final fixedLengthList = List<int>.filled(3, 0);
  int _currentScence = 0 ;

  Widget build(BuildContext context) {
    var appBar = AppBar(
      backgroundColor: Colors.white,
      title: Text(
        "Title your masterpiece",
        style: TextStyle(
          color: Color(0xFF09193E),
          fontSize: 17,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.primaryColor, size: 28),
        // onPressed: () {},
        onPressed: () => Navigator.of(context).pop(),
      ),
      elevation: 0,
      actions: [
        Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Icon(Icons.cloud_upload_outlined, color: Colors.black45, size: 30))
        )
      ],
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,
      key : _scaffoldKey,
      body : SingleChildScrollView(
        child: Column(
          children: [
            SingleChildScrollView(
              child: Container(
                height: 300,
                child: solsList(context),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top : 30),
              child: Text(
                "Upload Almost Complete",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color : Colors.black,
                  fontSize: 25
                ),
              ),
            ),
            Container(
              child: Text(
                "Chapters 6,7 and 8.",
                style: TextStyle(
                  color: Colors.black45,
                  fontSize : 15
                ),
              ),
            ),
            Container(
                child: CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentScence = index ;
                      });
                    },
                  ),
                  carouselController: _carouselController,
                  items: fixedLengthList.map((item) => CircularPercentIndicator(
                    radius: 140.0,
                    lineWidth: 17.0,
                    percent: 0.76,
                    animation: true,
                    animationDuration: 1200,
                    center: new Text(
                      "76.0%",
                      style:
                      new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                    progressColor: Colors.blueAccent,
                    circularStrokeCap: CircularStrokeCap.round,
                  )).toList(),
                )
            ),
            DotsIndicator(
              dotsCount: 3,
              position: _currentScence.toDouble(),
              decorator: DotsDecorator(
                size: const Size.square(9.0),
                activeSize: const Size.square(9.0),
                activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              ),
              onTap: (position){
                setState(() {
                  _currentScence = position.toInt();
                  _carouselController.animateToPage(position.toInt());
                });
              },
            ),
            Container(
              margin: EdgeInsets.only(left : 20, right : 20, top: 10),
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PodCastAdjust())) ;
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
      ));
  }

  Widget solsList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top : BorderSide(color: Color(0xFFE2DEDE), width: 1.0),
          bottom : BorderSide(color: Color(0xFFE2DEDE), width: 1.0),
        )
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: 10,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index){
          var itemIndex = index + 1 ;
          return InkWell(
              onTap: () {
                _displayDialog(context, itemIndex) ;
              },
              child: Container(
                padding : EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        child : Text("SOL $itemIndex")
                    ),
                    Container(
                      child: Row(
                        children: [
                          SizedBox(
                              height: 7,
                              width: 12,
                              child: ImageIcon(
                                AssetImage(Utils.tickIcon),
                                color: Color(0xFF00B227),
                              )),
                          Container(
                              padding : EdgeInsets.only(left : 15),
                              child : Text(
                                "30:00",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              )
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      )
    );
  }

  Future<void> _displayDialog(BuildContext context, int itemIndex) async {
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(context)
            .modalBarrierDismissLabel,
        barrierColor: Colors.black.withOpacity(0),
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext,
            Animation animation,
            Animation secondaryAnimation) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState)
              {
                return Center(
                  child: Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width - 60,
                    height: 300,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.bordergrey, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        color: Colors.black.withOpacity(0.8)),
                    child: Column(
                      children: [
                        Container(
                          child: DefaultTextStyle(
                            child: Text("Segment"),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color : Colors.white
                            ),
                          ),
                        ),
                        Container(
                          margin : EdgeInsets.only(top : 10),
                          child: DefaultTextStyle(
                            child: Text("SOL$itemIndex"),
                            style: TextStyle(
                              color : Colors.white,
                              fontSize: 20
                            ),
                          ),
                        ),
                        Container (
                          padding : EdgeInsets.only(top : 50, bottom : 50),
                          child: DefaultTextStyle(
                            child: Text("00:00 - 30:00"),
                            style: TextStyle(
                              color : Colors.green,
                              fontSize: 45
                            ),
                          ),
                        )
                      ],
                    ),
                    // color: Colors.black.withOpacity(0.8),
                  ),
                );
              });
        }).then((exit) {
      if(exit == null) {
        print("5555555555555555");

      }
      if(exit) {
        print("6666666666666");

      } else {
        print("4444444444444444");

      }
    });
  }
}