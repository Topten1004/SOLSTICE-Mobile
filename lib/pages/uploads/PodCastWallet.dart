import 'package:flutter/material.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/pages/uploads/PodCastInfo.dart';
import 'package:solstice/utils/constants.dart' ;

class PodCastWallet extends StatefulWidget {
  const PodCastWallet({Key key}):super (key: key) ;

  _PodCastWalletState createState() => _PodCastWalletState() ;
}

class _PodCastWalletState extends State<PodCastWallet> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>() ;

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
      child : Column(
       children: [
         Center(
           child: Image.asset('assets/wallet/wallet.png'),
         ),
         Container(
           margin:EdgeInsets.only(top : 20),
           child: Text(
             "Connect with Wallet",
             style: TextStyle(
               fontSize: 27,
               color: Color(0xFF2264D7),
               fontWeight: FontWeight.bold
             ),
           ),
         ),
         Center(
           child: Container(
             margin : EdgeInsets.only(left : 60, right: 60, top: 25),
             child: Text(
               "Connect to one of our wallet provider"
             ),
           ),
         ),
         Center(
           child: Container(
             margin : EdgeInsets.only(left : 60, right: 60, top : 10),
             child: Text(
                 "or create a new one"
             ),
           ),
         ),
          Container(
            margin: EdgeInsets.only(left : 30, right: 30, top : 20),
            padding: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
            border:Border.all(color : Color(0xFFBDBDBD)),
            borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            child: ListView(
              shrinkWrap: true,
              children:<Widget>[
                InkWell(
                  onTap: () {

                  },
                  child: Container(
                    padding : EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/wallet/metamask.png'),
                            Container(
                                padding : EdgeInsets.only(left : 10),
                                child: Text(
                                  "Metamask",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D1440)
                                  ),
                                )
                            )
                          ],
                        ),
                        Container(
                          child: Text("Poplular"),
                        )
                      ],
                    ),
                  ),
                ),
                Divider(),
                InkWell(
                  onTap: () {

                  },
                  child: Container(
                    padding : EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/wallet/trust.png'),
                            Container(
                                padding: EdgeInsets.only(left : 10),
                                child: Text(
                                "Trust Wallet",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D1440)
                                ),
                              )
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(),
                InkWell(
                  onTap: () {

                  },
                  child: Container(
                    padding : EdgeInsets.only(left: 4, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/wallet/ethereum.png'),
                            Container(
                              padding: EdgeInsets.only(left : 5),
                              child: Text(
                                "Enter Ethereum Address",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D1440)
                                ),
                              )
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PodCastInfo())) ;
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
      )
    ));
  }
}