import 'package:flutter/material.dart' ;
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/pages/nfts/NFTProducts.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/utils/constants.dart' ;
import 'package:card_swiper/card_swiper.dart';

class ProductPrice extends StatefulWidget {
  const ProductPrice({Key key}):super(key: key) ;

  _ProductPriceState createState() => _ProductPriceState();
}

class _ProductPriceState extends State<ProductPrice> {

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>() ;

  List<String> images = new List<String>.empty(growable: true);

  double _percentValue = 70.0 ;

  void initState() {
    super.initState();

    images.add("assets/images/swiper1.png") ;
    images.add("assets/images/swiper2.png") ;
    images.add("assets/images/swiper1.png") ;
  }

  Widget build(BuildContext context) {

    var _percent = double.parse((_percentValue).toStringAsFixed(2));

    var appBar = AppBar(
      backgroundColor: Colors.white,
      title: Center(
        child: Text(
          "Price Your Product",
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
                padding: EdgeInsets.only(top:20, bottom: 20, left: 15, right: 15),
                margin: EdgeInsets.only(left : 20, right: 20, bottom: 25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border : Border.all(color: Color(0xFF324AC4), width: 1.0)
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
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top : 5),
                          child: Text(
                            "Items",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black54
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
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top : 5),
                          child: Text(
                            "Owners",
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black54
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
                                color: Colors.black54
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
                                color: Colors.black54
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                  margin: EdgeInsets.only(top: 20, left: 20, right:20, bottom: 30),
                  child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: ' Royalty % ',
                        labelStyle: TextStyle(
                            color : Color(0xFF0C132D),
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                              child: Slider(
                                value: _percentValue,
                                min: 0,
                                max: 100,
                                activeColor: Color(0xFF377CCE),
                                inactiveColor: Colors.black12,
                                onChanged: (val) {
                                  setState(() {
                                    _percentValue = val ;
                                  });
                                },
                              )
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left : 25),
                                child: Text(
                                  "$_percent%",
                                  style: TextStyle(
                                    color : Color(0xFF377CCE)
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(right : 25),
                                child: Text(
                                  "\$5 USD",
                                  style: TextStyle(
                                    color: Color(0xFF0DA020)
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      )
                  )
              ),
              Container(
                  margin: EdgeInsets.only(left : 20, right : 20, top : 20),
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NFTProduct()));
                    },
                    child : Container(
                        width: MediaQuery.of(context).size.width - 80,
                        child: Center(
                          child: Utils.text(
                              'List Product', Utils.fontfamily, Color(0xFFFFFFFF), FontWeight.w400, 20),
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