import 'package:flutter/material.dart' ;
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/pages/uploads/PodCastVerify.dart';
import 'package:solstice/utils/constants.dart' ;
import 'package:card_swiper/card_swiper.dart';

class PodCastInfo extends StatefulWidget {
  const PodCastInfo({Key key}):super(key : key) ;

  _PodCastInfoState createState() => _PodCastInfoState() ;
}

class _PodCastInfoState extends State<PodCastInfo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>() ;

  List<String> images = new List<String>.empty(growable: true);

  void initState() {
    super.initState();

    images.add("assets/images/swiper1.png") ;
    images.add("assets/images/swiper2.png") ;
    images.add("assets/images/swiper1.png") ;
  }

  Widget build(BuildContext context) {
    var appBar = AppBar(
      backgroundColor: Colors.white,
      title: Center(
        child: Text(
          "Sundays Podcast",
          style: TextStyle(
            color: Color(0xFF09193E),
            fontSize: 17,
          ),
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
               Container(
                 margin: EdgeInsets.only(top : 20, bottom: 20),
                width : MediaQuery.of(context).size.width,
                height: 300,
                child:  Swiper(
                  itemBuilder: (BuildContext context, int index) {
                    return Image.asset(images[index]) ;
                  },
                  axisDirection: AxisDirection.right,
                  itemCount: 3,
                  itemWidth: 300.0,
                  layout: SwiperLayout.STACK,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20, left: 20, right:20),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: ' Product Price ',
                    labelStyle: TextStyle(
                      color : Color(0xFF0C132D),
                      fontSize : 20,
                      fontWeight : FontWeight.bold
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment : MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding:EdgeInsets.only(left : 10),
                            child: Text(
                                "\$5000",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color:Colors.black
                              ),
                            ),
                          ),
                          Container(
                            padding:EdgeInsets.only(right : 10),
                            child: Text(
                              "USD",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black54
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children:[
                          Row(
                            children: [
                              Image.asset('assets/images/ether_logo.png', height: 25, width:25),
                              Container(
                                margin: EdgeInsets.only(right: 10),
                                child: Text(
                                  "0.557 ETH",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1739BF),
                                    fontFamily: Utils.fontfamilyInter,
                                    fontSize: 18
                                  ),
                                ),
                              )
                            ],
                          )]
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20, left: 20, right:20),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: ' Wallet Sync ID ',
                    labelStyle: TextStyle(
                      color : Color(0xFF0C132D),
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Container(
                    margin:EdgeInsets.only(left : 10, top: 20, bottom: 20),
                    child: Text(
                      "Address",
                      style: TextStyle(
                        color : Color(0xFF2E50AA)
                      ),
                    ),
                  )
                )
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PodCastVerify()));
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