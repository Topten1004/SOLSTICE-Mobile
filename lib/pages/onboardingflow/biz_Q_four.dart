import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solstice/model/forum_model_new.dart';
import 'package:solstice/pages/onboardingflow/biz_Q_three.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/utils/constants.dart';

class BizQ4Screen extends StatefulWidget {
  const BizQ4Screen({Key key}) : super(key: key);

  @override
  _BizQ4ScreenState createState() => _BizQ4ScreenState();
}

class _BizQ4ScreenState extends State<BizQ4Screen> {
  bool asthetics = false;
  TextEditingController productDescController = new TextEditingController();
  List<String> productLinks = new List();
  List<TextEditingController> productWidgetList = new List();
  var urlPattern =
      (r"((https?:www\.)|(https?:\/\/)|(www\.)|(a-zA-Z))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    productWidgetList.add(TextEditingController());
  }

  bool validateUrl(String hyperlink) {
    var match = new RegExp(urlPattern, caseSensitive: false);

    return match.hasMatch(hyperlink);
  }

  Widget productWidget(int index) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 11,
      ),
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(left: 24, right: 24, top: 25),
            height: 56,
            // width: MediaQuery.of(context).size.width*0.80,
            decoration: BoxDecoration(
                border: Border.all(color: Color(0XFFE8E8E8), width: 1),
                borderRadius: BorderRadius.circular(8)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 40, right: 133),
            child: Container(
              height: 17,
              width: 89,
              child: Center(
                child: Utils.text('Product Link', Utils.fontfamily,
                    Color(0xFF1E263C), FontWeight.w400, 14),
              ),
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 25, right: 35, left: 45),
            child: TextField(
              onChanged: (value) {
                setState(() {});
              },
              controller: productWidgetList[index],
              decoration: new InputDecoration(
                border: InputBorder.none,
                focusColor: Color(0xFFB9BAC8),
                hintText: 'www.sanfranchronicle.com',
                suffix: validateUrl(productWidgetList[index].text.toString())
                    ? ImageIcon(
                        AssetImage(Utils.tickIcon),
                        size: 16,
                        color: Color(0xFF00B227),
                      )
                    : Container(
                        width: 2,
                      ),
                hintStyle: TextStyle(
                    fontFamily: Utils.fontfamily,
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                    color: Color(0XFFB9BAC8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
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
              child:
                  Image.asset("assets/images/help.png", height: 26, width: 26)),
        )
      ],
    );
    return SafeArea(
      child: Scaffold(
        appBar: appBar,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(children: [
            SizedBox(height: 40),
            Text(
              'Tell us more\n about your brand',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xFF1F1F1F),
                  fontWeight: FontWeight.normal,
                  fontFamily: Utils.fontfamily,
                  fontSize: 24),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 19, left: 48, right: 47),
              child: Text(
                'Tell us what type of users you are looking\n to connect with on the Solstice platform.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF868686),
                  fontFamily: Utils.fontfamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(height: 13),
            ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return productWidget(index);
              },
              itemCount: productWidgetList.length,
              shrinkWrap: true,
            ),
            SizedBox(height: 13),
            InkWell(
              onTap: () {
                productWidgetList.add(TextEditingController());
                setState(() {});
              },
              child: Text(
                'Add Another Product Link',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: Utils.fontfamily,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF283646),
                    fontSize: 15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 52, left: 24, right: 24, bottom: 34),
              child: InkWell(
                onTap: () {
                  saveBusinessData();
                },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFF283646),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF434344).withOpacity(0.07),
                        spreadRadius: 1,
                        blurRadius: 13,
                        offset: Offset(0, 15), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Center(
                      child: Utils.text('Continue', Utils.fontfamily,
                          Color(0xFFFFFFFF), FontWeight.w400, 18)),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Utils.saveSkipScreenName('BizQ4Screen', context);
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 40),
                child: Utils.text('Skip for now', Utils.fontfamily,
                    Utils.buttonColor, FontWeight.w600, 15),
              ),
            )
          ]),
        ),
      ),
    );
  }

  saveBusinessData() {
    for (int i = 0; i < productWidgetList.length; i++) {
      if (productWidgetList[i].text.toString().isNotEmpty) {
        productLinks.add(productWidgetList[i].text.toString());
      }
    }
    BusinessProducts businessProducts = new BusinessProducts(
        productDescription: productDescController.text.toString(),
        productLinks: productLinks);
    FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(globalUserId)
        .update({
      'businessProducts': businessProducts.toJson(),
      'profileComplete': 0
    }).then((docRef) {
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) => BizQ3Screen()));
    });
  }
}
