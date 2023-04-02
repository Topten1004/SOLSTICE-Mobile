import 'package:flutter/material.dart' ;
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/pages/nfts/NFTSegment.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/utils/constants.dart' ;
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';

class NFTProduct extends StatefulWidget {
  const NFTProduct({Key key}):super(key: key) ;

  _NFTProductState createState() => _NFTProductState() ;
}

class _NFTProductState extends State<NFTProduct>  with TickerProviderStateMixin {

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>() ;

  List<String> images = new List<String>.empty(growable: true);

  double _percentValue = 86.0 ;
  int _currentProduct = 0 ;

  void initState() {
    super.initState();

    images.add("assets/images/swiper1.png") ;
    images.add("assets/images/swiper2.png") ;
    images.add("assets/images/swiper1.png") ;
  }

  Widget build(BuildContext context) {
    var _percent = double.parse((_percentValue).toStringAsFixed(2));
    var appBar = AppBar(
      backgroundColor: Colors.black,
      title: Center(
        child: Text(
          "NFT Products",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
        // onPressed: () {},
        onPressed: () => Navigator.of(context).pop(),
      ),
      elevation: 0,
    );

    return Scaffold(
          backgroundColor: Colors.black,
          appBar: appBar,
          key : _scaffoldKey,
          body : SingleChildScrollView(
            child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(top : 20, bottom: 20),
                    width : MediaQuery.of(context).size.width,
                    height: 300,
                    child:  Swiper(
                      itemBuilder: (BuildContext context, int index) {
                        return Image.asset(images[index]) ;
                      },
                      onIndexChanged: (index) {
                        setState(() {
                          _currentProduct = index ;
                        });
                      },
                      axisDirection: AxisDirection.right,
                      itemCount: 3,
                      itemWidth: 300.0,
                      layout: SwiperLayout.STACK,
                    ),
                  ),
                  Positioned(bottom: 20,right: 100,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: Icon(CupertinoIcons.viewfinder , color: Colors.white, size: 30), onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => NFTSegment(videoUrl: "https://firebasestorage.googleapis.com:443/v0/b/solstice-d447d.appspot.com/o/CardVideos%2F1641432017423?alt=media&token=2bd3b9d6-02b7-4ad6-8087-d43bde7c6e99",)));
                            }),
                          ]
                      )
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(left : 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Text(
                        "Sunday's PodCast",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    Container(
                      child: IconButton(
                        icon: Icon(CupertinoIcons.heart, color: AppColors.primaryColor, size: 28),
                        // onPressed: () {},
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left : 10, right : 60),
                child: Text(
                  "eg. CoolBeans are workout supplements that help people work out better.",
                  style: TextStyle(
                    color : Colors.white70
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width : MediaQuery.of(context).size.width - 58,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                              trackHeight: 0.8,
                              thumbColor: Colors.transparent,
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0.0)
                          ),
                          child: Slider(
                            value: _percentValue,
                            min: 0,
                            max: 100,
                            activeColor: Color(0xFF71CD9D),
                            inactiveColor: Colors.white54,
                            onChanged: (val) {
                              setState(() {

                              });
                            },
                          ),
                        )
                    ),
                    Container(
                      child: Text(
                        "$_percent%",
                        style: TextStyle(
                          color: Color(0xFF71CD9D),
                          fontSize: 13
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              DefaultTabController(
                  length: 3, // length of tabs
                  initialIndex: 0,
                  child: Column( children: [
                    Container(
                      child: TabBar(
                        labelColor: Colors.white,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                        ),
                        unselectedLabelColor: Colors.white54,
                        tabs: [
                          Tab(text: 'Content'),
                          Tab(text: 'Details'),
                          Tab(text: 'Owners'),
                        ],
                      ),
                    ),
                    Container(
                        height: 170,
                        decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: Colors.grey, width: 0.5))
                        ),
                        child: new TabBarView(children: [
                          solsList(context),
                          Column(
                            children : [
                              Container(
                                padding: EdgeInsets.only(top:20, left: 15, right: 15, bottom: 20),
                                margin: EdgeInsets.only(left : 20, right: 20, top: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  border : Border.all(color: Color(0xFF4762EE), width: 2.0),
                                  color: Color(0xFF091528),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          child: Text(
                                            "3.77K",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Colors.white
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(top : 5),
                                          child: Text(
                                            "Items",
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white54
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                          child: Text(
                                            "1.24K",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Colors.white
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(top : 5),
                                          child: Text(
                                            "Owners",
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white54
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset('assets/images/ether_logo.png', height: 20 , width: 20,),
                                            Container(
                                              child: Text(
                                                "0.89",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.white
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(top : 5),
                                          child: Text(
                                            "Floor price",
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white54
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset('assets/images/ether_logo.png', height: 20 , width: 20,),
                                            Container(
                                              child: Text(
                                                "674",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.white
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(top : 5),
                                          child: Text(
                                            "Traded",
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white54
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          Column(
                            children : [
                              Row(
                                children: [
                                  Container(
                                    // width: groupWidth ?? 150,
                                    height: 100,
                                    margin: EdgeInsets.only(left : 20, right : 20),
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: 3,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return Align(
                                          widthFactor: 0.5,
                                          child: CircleAvatar(
                                            radius : 20,
                                            child: CircleAvatar(
                                                radius: 20,
                                                backgroundImage: AssetImage(images[index])
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Container(
                                    child : Text(
                                      "View all 23 Owners",
                                      style : TextStyle(
                                        color : Colors.white
                                      )
                                    )
                                  )
                                ],
                              )
                            ]
                          )
                        ])
                    )
                  ])
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0xFF71CD9D).withOpacity(0.8),
                  blurRadius: 15.0,
                  spreadRadius: -6.0,
                  offset: Offset(0.0, 5)// changes position of shadow
              ),
            ],
          ),
          child: RawMaterialButton(
            elevation: 2.0,
            shape: RoundedRectangleBorder(borderRadius : BorderRadius.all(Radius.circular(30)) ),
            fillColor: Color(0xFF71CD9D),
            onPressed: (){},
            child: Text(
              "OWN",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontFamily: Utils.fontfamilyInter
              ),
            ),
            constraints: BoxConstraints.tightFor(
              width: 150.0,
              height: 50.0,
            ),
          ),
        ),
    );
  }

  Widget solsList(BuildContext context) {
    return Container(
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
                        child : Text(
                          "SOL $itemIndex",
                          style : TextStyle(
                            color: Color(0xFF6394E8),
                            fontWeight: FontWeight.bold,
                            fontSize: 15
                          )
                        )
                    ),
                    Container(
                      child: Row(
                        children: [
                          Container(
                              padding : EdgeInsets.only(left : 15),
                              child : Text(
                                "30:00",
                                style: TextStyle(
                                  color: Color(0xFF6394E8),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15
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
        separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.white54),
      ),
    );
  }
}