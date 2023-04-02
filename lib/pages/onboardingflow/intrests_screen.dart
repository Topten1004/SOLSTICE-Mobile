import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solstice/model/select_filter_model.dart';
import 'package:solstice/pages/onboardingflow/intrests_SubcategoryScreen.dart';
import 'package:solstice/pages/onboardingflow/utils.dart';
import 'package:solstice/utils/constants.dart';

class IntrestsScreen extends StatefulWidget {
  const IntrestsScreen({Key key}) : super(key: key);

  @override
  _IntrestsScreenState createState() => _IntrestsScreenState();
}

class _IntrestsScreenState extends State<IntrestsScreen> {
  bool asthetics = false;
  List<SelectFilterModel> categoriesList = new List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  void getCategories() async {
    var collectionReference =
        FirebaseFirestore.instance.collection(Constants.trainingCategories).get();
    collectionReference.then((value) {
      final List<DocumentSnapshot> docs = value.docs;
      docs.forEach((data) {
        SelectFilterModel selectFilterModel = SelectFilterModel.fromJson(data.data());
        selectFilterModel.id = data.id;
        categoriesList.add(selectFilterModel);
        if (data.id == value.docs[value.docs.length - 1].id) {
          setState(() {});
        }
      });
    }).catchError((onError) {
    });
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
              child: Image.asset("assets/images/help.png", height: 26, width: 26)),
        )
      ],
    );
    return SafeArea(
        child: Scaffold(
            appBar: appBar,
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
                child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 91, right: 90),
                child: Text(
                  'Tell us about\nyour interests',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xFF1F1F1F),
                      fontWeight: FontWeight.normal,
                      fontFamily: Utils.fontfamily,
                      fontSize: 24),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 19, left: 48, right: 47),
                child: Text(
                  'Which activities do you spend the most \ntime on? What matters most to you? Select \nall that apply.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF868686),
                    fontFamily: Utils.fontfamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
                child: Container(
                  child: Wrap(
                      alignment : WrapAlignment.spaceEvenly,
                      children: [
                    for (int i = 0; i < categoriesList.length; i++)
                      InkWell(
                        onTap: () {
                          setState(() {
                            categoriesList[i].isSelected = !categoriesList[i].isSelected;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12, right: 3, left: 0),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            height: 39,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(color: Colors.blue, width: 1),
                                color: categoriesList[i].isSelected
                                    ? AppColors.blueColor
                                    : Colors.white),
                            child: Text(
                              categoriesList[i].title,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: Utils.fontfamilyInter,
                                  fontSize: 14,
                                  color: categoriesList[i].isSelected
                                      ? Colors.white
                                      : AppColors.blueColor),
                            ),
                          ),
                        ),
                      ),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 24, right: 24),
                    //   child: Container(
                    //     child: Wrap(
                    //       children: [
                    //         Padding(
                    //           padding: const EdgeInsets.only(
                    //             top: 29,
                    //           ),
                    //           child: Container(
                    //             padding: EdgeInsets.all(10),
                    //             height: 39,
                    //             decoration: BoxDecoration(
                    //                 borderRadius: BorderRadius.circular(40),
                    //                 border: Border.all(color: Colors.blue, width: 2),
                    //                 color: false ? Colors.white : Colors.blue),
                    //             child: Text(
                    //               'Aesthetics',
                    //               style: TextStyle(
                    //                   fontWeight: FontWeight.w600,
                    //                   fontFamily: Utils.fontfamilyInter,
                    //                   fontSize: 14,
                    //                   color: asthetics == false ? Colors.white : Colors.white),
                    //             ),
                    //           ),
                    //         ),
                    //         SizedBox(
                    //           width: 5,
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.only(top: 29),
                    //           child: Container(
                    //             padding: EdgeInsets.all(10),
                    //             height: 39,
                    //             decoration: BoxDecoration(
                    //               borderRadius: BorderRadius.circular(25),
                    //               border: Border.all(color: Colors.blue, width: 1),
                    //             ),
                    //             child: Text(
                    //               'Weight Lifting',
                    //               style: TextStyle(
                    //                 fontWeight: FontWeight.w400,
                    //                 fontFamily: Utils.fontfamilyInter,
                    //                 color: Colors.blue,
                    //                 fontSize: 14,
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //         SizedBox(
                    //           width: 5,
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.only(top: 29),
                    //           child: Container(
                    //             padding: EdgeInsets.all(10),
                    //             height: 39,
                    //             decoration: BoxDecoration(
                    //                 borderRadius: BorderRadius.circular(40),
                    //                 border: Border.all(color: Colors.blue, width: 2),
                    //                 color: false ? Colors.white : Colors.blue),
                    //             child: Text(
                    //               'Injury Rehab',
                    //               style: TextStyle(
                    //                   fontWeight: FontWeight.w600,
                    //                   fontFamily: Utils.fontfamilyInter,
                    //                   fontSize: 14,
                    //                   color: asthetics == false ? Colors.white : Colors.white),
                    //             ),
                    //           ),
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.only(top: 11),
                    //           child: Container(
                    //             padding: EdgeInsets.all(10),
                    //             height: 39,
                    //             decoration: BoxDecoration(
                    //                 borderRadius: BorderRadius.circular(40),
                    //                 border: Border.all(color: Colors.blue, width: 2),
                    //                 color: false ? Colors.white : Colors.blue),
                    //             child: Text(
                    //               'Athletic Training',
                    //               style: TextStyle(
                    //                   fontWeight: FontWeight.w600,
                    //                   fontFamily: Utils.fontfamilyInter,
                    //                   fontSize: 14,
                    //                   color: asthetics == false ? Colors.white : Colors.white),
                    //             ),
                    //           ),
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.only(top: 11, left: 5),
                    //           child: Container(
                    //             padding: EdgeInsets.all(10),
                    //             height: 39,
                    //             decoration: BoxDecoration(
                    //               borderRadius: BorderRadius.circular(25),
                    //               border: Border.all(color: Colors.blue, width: 1),
                    //             ),
                    //             child: Text(
                    //               'Sport-Specific Training',
                    //               style: TextStyle(
                    //                 fontWeight: FontWeight.w400,
                    //                 fontFamily: Utils.fontfamilyInter,
                    //                 color: Colors.blue,
                    //                 fontSize: 14,
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.only(top: 11),
                    //           child: Container(
                    //             padding: EdgeInsets.all(10),
                    //             height: 39,
                    //             decoration: BoxDecoration(
                    //               borderRadius: BorderRadius.circular(25),
                    //               border: Border.all(color: Colors.blue, width: 1),
                    //             ),
                    //             child: Text(
                    //               'Weight Loss',
                    //               style: TextStyle(
                    //                 fontWeight: FontWeight.w400,
                    //                 fontFamily: Utils.fontfamilyInter,
                    //                 color: Colors.blue,
                    //                 fontSize: 14,
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.only(top: 11, left: 5),
                    //           child: Container(
                    //             padding: EdgeInsets.all(10),
                    //             height: 39,
                    //             decoration: BoxDecoration(
                    //                 borderRadius: BorderRadius.circular(40),
                    //                 border: Border.all(color: Colors.blue, width: 2),
                    //                 color: false ? Colors.white : Colors.blue),
                    //             child: Text(
                    //               'General Health',
                    //               style: TextStyle(
                    //                   fontWeight: FontWeight.w600,
                    //                   fontFamily: Utils.fontfamilyInter,
                    //                   fontSize: 14,
                    //                   color: asthetics == false ? Colors.white : Colors.white),
                    //             ),
                    //           ),
                    //         ),
                    //         Padding(
                    //             padding: const EdgeInsets.only(top: 11, left: 5),
                    //             child: Container(
                    //               padding: EdgeInsets.all(10),
                    //               height: 39,
                    //               decoration: BoxDecoration(
                    //                 borderRadius: BorderRadius.circular(25),
                    //                 border: Border.all(color: Colors.blue, width: 1),
                    //               ),
                    //               child: Text(
                    //                 'Running',
                    //                 style: TextStyle(
                    //                   fontWeight: FontWeight.w400,
                    //                   fontFamily: Utils.fontfamilyInter,
                    //                   color: Colors.blue,
                    //                   fontSize: 14,
                    //                 ),
                    //               ),
                    //             )),
                    //         Padding(
                    //           padding: const EdgeInsets.only(top: 11),
                    //           child: Container(
                    //             padding: EdgeInsets.all(10),
                    //             height: 39,
                    //             decoration: BoxDecoration(
                    //                 borderRadius: BorderRadius.circular(40),
                    //                 border: Border.all(color: Colors.blue, width: 2),
                    //                 color: false ? Colors.white : Colors.blue),
                    //             child: Text(
                    //               'Meditation',
                    //               style: TextStyle(
                    //                   fontWeight: FontWeight.w600,
                    //                   fontFamily: Utils.fontfamilyInter,
                    //                   fontSize: 14,
                    //                   color: asthetics == false ? Colors.white : Colors.white),
                    //             ),
                    //           ),
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.only(top: 11, left: 5),
                    //           child: Container(
                    //             padding: EdgeInsets.all(10),
                    //             height: 39,
                    //             decoration: BoxDecoration(
                    //               borderRadius: BorderRadius.circular(25),
                    //               border: Border.all(color: Colors.blue, width: 1),
                    //             ),
                    //             child: Text(
                    //               'Flexibility & Mobility',
                    //               style: TextStyle(
                    //                 fontWeight: FontWeight.w400,
                    //                 fontFamily: Utils.fontfamilyInter,
                    //                 color: Colors.blue,
                    //                 fontSize: 14,
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.only(top: 11, left: 5),
                    //           child: Container(
                    //             padding: EdgeInsets.all(10),
                    //             height: 39,
                    //             decoration: BoxDecoration(
                    //                 borderRadius: BorderRadius.circular(40),
                    //                 border: Border.all(color: Colors.blue, width: 2),
                    //                 color: false ? Colors.white : Colors.blue),
                    //             child: Text(
                    //               'Other',
                    //               style: TextStyle(
                    //                   fontWeight: FontWeight.w600,
                    //                   fontFamily: Utils.fontfamilyInter,
                    //                   fontSize: 14,
                    //                   color: asthetics == false ? Colors.white : Colors.white),
                    //             ),
                    //           ),
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.only(
                    //             top: 25,
                    //           ),
                    //           child: Stack(
                    //             children: [
                    //               Container(
                    //                 margin: EdgeInsets.only(left: 8, right: 8, top: 25),
                    //                 height: MediaQuery.of(context).size.height * 0.08,
                    //                 // width: MediaQuery.of(context).size.width*0.80,
                    //                 decoration: BoxDecoration(
                    //                     border: Border.all(color: Color(0XFFE8E8E8), width: 1),
                    //                     borderRadius: BorderRadius.circular(8)),
                    //               ),
                    //               Padding(
                    //                 padding: const EdgeInsets.only(top: 15, left: 20, right: 133),
                    //                 child: Container(
                    //                   height: 17,
                    //                   width: 153,
                    //                   child: Center(
                    //                     child: Utils.text('Other (Please Specify)', Utils.fontfamily,
                    //                         Color(0xFF1E263C), FontWeight.w400, 14),
                    //                   ),
                    //                   color: Colors.white,
                    //                 ),
                    //               ),
                    //               Padding(
                    //                 padding: const EdgeInsets.only(top: 45, right: 70, left: 28),
                    //                 child: TextField(
                    //                   decoration: new InputDecoration.collapsed(
                    //                     focusColor: Color(0xFFB9BAC8),
                    //                     hintText: 'Marathon Training, Race Training',
                    //                     hintStyle: TextStyle(
                    //                         fontFamily: Utils.fontfamily,
                    //                         fontWeight: FontWeight.w400,
                    //                         fontSize: 14,
                    //                         color: Color(0XFFB9BAC8)),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    Padding(
                        padding: const EdgeInsets.only(
                          top: 25,
                        ),
                        child: Stack(children: [
                          Container(
                            margin: EdgeInsets.only(left: 8, right: 8, top: 25),
                            height: MediaQuery.of(context).size.height * 0.08,
                            // width: MediaQuery.of(context).size.width*0.80,
                            decoration: BoxDecoration(
                                border: Border.all(color: Color(0XFFE8E8E8), width: 1),
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15, left: 20, right: 133),
                            child: Container(
                              height: 17,
                              width: 153,
                              child: Center(
                                child: Utils.text('Other (Please Specify)', Utils.fontfamily,
                                    Color(0xFF1E263C), FontWeight.w400, 14),
                              ),
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 45, right: 70, left: 28),
                            child: TextField(
                              decoration: new InputDecoration.collapsed(
                                focusColor: Color(0xFFB9BAC8),
                                hintText: 'Marathon Training, Race Training',
                                hintStyle: TextStyle(
                                    fontFamily: Utils.fontfamily,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Color(0XFFB9BAC8)),
                              ),
                            ),
                          )
                        ])),
                    Padding(
                      padding: const EdgeInsets.only(top: 130, left: 24, right: 24),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => IntrestSubcategoryScreen()));
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
                              child: Utils.text('Continue', Utils.fontfamily, Color(0xFFFFFFFF),
                                  FontWeight.w400, 18)),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 34, bottom: 40),
                        child: Utils.text('Skip for now', Utils.fontfamily, Utils.buttonColor,
                            FontWeight.w600, 15),
                      ),
                    )
                  ]),
                ),
              )
            ]))));
  }
}
