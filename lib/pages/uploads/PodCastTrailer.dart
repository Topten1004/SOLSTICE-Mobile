import 'package:flutter/material.dart' ;
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/pages/uploads/UploadLogoForm.dart';
import 'package:solstice/utils/constants.dart' ;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart' ;

class PodCastTrailer extends StatefulWidget {
  const PodCastTrailer({Key key}):super(key:key) ;

  _PodCastTrailerState createState() => _PodCastTrailerState() ;
}

class _PodCastTrailerState extends State<PodCastTrailer> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>() ;

  List<String> images = new List<String>.empty(growable: true);

  final CarouselController _carouselController = CarouselController();

  final fixedLengthList = List<int>.filled(3, 0);
  int _currentScence = 0 ;

  void initState() {
    super.initState() ;

    images.add("assets/images/group_image.png") ;
    images.add("assets/images/static_card_image.png") ;
    images.add("assets/images/static_card_image.png") ;
  }

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
                padding: EdgeInsets.only(top : 35),
                child: Text(
                  "Select Trailer",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color : Colors.black,
                      fontSize: 25
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Text(
                  "Growing Up in MIA 00:00 - 30:00",
                  style: TextStyle(
                      color: Colors.black45,
                      fontSize : 15
                  ),
                ),
              ),
              Container(
                margin : EdgeInsets.only(top : 20, left :40, right : 40),
                child : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        child : Text(
                            "00:00:24",
                            style : TextStyle(
                                color : Color(0xFF101836),
                                fontWeight: FontWeight.bold
                            )
                        )
                    ),
                    Container(
                      child: Text(
                          "00:00:29",
                          style : TextStyle(
                              color : Color(0xFF101836),
                              fontWeight: FontWeight.bold
                          )
                      ),
                    )
                  ],
                ),
              ),
              Container(
                  margin: EdgeInsets.only(top : 15, bottom: 15),
                  child: CarouselSlider(
                      options: CarouselOptions(
                        height: 100,
                        enableInfiniteScroll: false,
                        viewportFraction: 0.55,
                        autoPlay: false,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentScence = index ;
                          });
                        },
                      ),
                      carouselController: _carouselController,
                      items: images.map((item) => Container(
                        child: Center(
                            child: Image.asset(item, fit: BoxFit.cover, width: 200, height: 80,)
                        ),
                      )).toList()
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
                  margin: EdgeInsets.only(left : 20, right : 20, top : 30),
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => UploadLogoForm()));
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

              },
              child: Container(
                padding : EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        child : Text("Chapter $itemIndex")
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
      ),
    );
  }
}