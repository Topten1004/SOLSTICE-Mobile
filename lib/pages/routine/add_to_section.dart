import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:solstice/model/routine_section_model.dart';
import 'package:solstice/utils/constants.dart';

class AddToSection extends StatefulWidget {
  @override
  _AddToSectionState createState() => _AddToSectionState();
}

class _AddToSectionState extends State<AddToSection> {
  List<RoutineSectionModel> routineModelList = new List.empty(growable: true);

  @override
  initState() {
    super.initState();
    getTotalSections();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 15.0, right: 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    for (int i = 0; i < routineModelList.length; i++) {
                      if (routineModelList[i].isSelected) {
                        Navigator.pop(context, {
                          "selectedSection": routineModelList[i],
                        });
                        break;
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
                    child: Text(
                      Constants.doneText,
                      style: TextStyle(
                          fontSize: 14.0,
                          color: AppColors.segmentAppBarColor,
                          fontFamily: Constants.openSauceFont,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      Constants.addToSection,
                      style: TextStyle(fontSize: 15.0, color: AppColors.lightGreyColor),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.black, size: 22),
                  onPressed: () => {Navigator.of(context).pop()},
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          InkWell(
            onTap: () {
              Navigator.pop(context, {"CreateSection": true});
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Create New Section',
                      style: TextStyle(
                          fontSize: 16.0,
                          color: AppColors.segmentAppBarColor,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(right: 10),
                      child:
                          Icon(Icons.arrow_forward_ios, color: const Color(0xffADB7C2), size: 20)),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
              child: ListView.builder(
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          unselectSections(index);
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Column(
                            //   children: [
                            //     Text("Warm up",
                            //         textAlign: TextAlign.left,
                            //         style: TextStyle(
                            //           fontFamily: Constants.openSauceFont,
                            //           fontWeight: FontWeight.w400,
                            //           fontSize: 16,
                            //           color: AppColors.darkTextColor,
                            //         )),
                            //     SizedBox(height: 10),
                            //     Text("3 cards",
                            //         textAlign: TextAlign.left,
                            //         style: TextStyle(
                            //           fontFamily: Constants.openSauceFont,
                            //           fontWeight: FontWeight.w400,
                            //           fontSize: 13,
                            //           color: AppColors.greyTextColor,
                            //         )),
                            //     Container(
                            //       height: 0.3,
                            //       width: MediaQuery.of(context).size.width,
                            //       color: AppColors.greyTextColor,
                            //     )
                            //   ],
                            // ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(routineModelList[index].title,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontFamily: Constants.openSauceFont,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: AppColors.darkTextColor,
                                      )),
                                  SizedBox(height: 10),
                                  Text(routineModelList[index].cardIds.length.toString() + " cards",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontFamily: Constants.openSauceFont,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 13,
                                        color: AppColors.greyTextColor,
                                      )),
                                  SizedBox(height: 10),
                                  Container(
                                    height: 0.1,
                                    width: MediaQuery.of(context).size.width,
                                    color: AppColors.greyTextColor,
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),
                            InkWell(
                                onTap: () {
                                  setState(() {
                                    unselectSections(index);
                                  });
                                },
                                child: Image.asset(
                                    routineModelList[index].isSelected
                                        ? Constants.selectedSectionImage
                                        : Constants.unselectedSectionImage,
                                    height: 25,
                                    width: 25)),
                            SizedBox(width: 16.0)
                            // IconButton(
                            //   icon: Icon(
                            //     Icons.check_circle_outline,
                            //   ),
                            //   color: routineModelList[index].isSelected
                            //       ? AppColors.blueColor
                            //       : AppColors.darkTextColor,

                            //   onPressed: () {
                            //     setState(() {
                            //       unselectSections(index);
                            //     });
                            //   },
                            // )
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: routineModelList.length))
        ],
      ),
    );
  }

  getTotalSections() async {
    FirebaseFirestore.instance.collection(Constants.sectionColl).get().then((value) {
      final List<DocumentSnapshot> docs = value.docs;
      docs.forEach((data) {
        RoutineSectionModel routineSectionModel = RoutineSectionModel.fromJson(data);
        routineModelList.add(routineSectionModel);
        if (data.id == value.docs[value.docs.length - 1].id) {
          setState(() {});
        }
      });
    }).catchError((onError) {
    });
  }

  void unselectSections(int selectedIndex) {
    for (int i = 0; i < routineModelList.length; i++) {
      routineModelList[i].isSelected = false;
    }
    routineModelList[selectedIndex].isSelected = true;
  }
}
