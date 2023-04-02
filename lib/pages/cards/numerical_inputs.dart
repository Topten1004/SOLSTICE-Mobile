import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/model/numerical_inputs_model/numeric_input_model.dart';
import 'package:solstice/model/numerical_units_model.dart';
import 'package:solstice/pages/cards/edit_segment.dart';
import 'package:solstice/utils/constants.dart';

class NumericalInputsPage extends StatefulWidget {
  final NumericInputsCallback numericInputsCallback;
  final bool showAppBar;
  final String title, description;
  List<NumericalInputsModel> numericalInputsList;
  NumericalInputsPage(
      {this.numericInputsCallback,
      this.showAppBar = false,
      this.title,
      this.description,
      this.numericalInputsList});

  @override
  _NumericalInputsPageState createState() => _NumericalInputsPageState();

  void onSaveSegment() {
    checkNumericalInputsList();
  }

  void checkNumericalInputsList() {
    for (int i = 0; i < numericalInputsList.length; i++) {
      if (numericalInputsList[i].repsCount.trim() == "0" ||
          numericalInputsList[i].repsCount.trim().isEmpty ||
          numericalInputsList[i].weightCount.trim() == "0" ||
          numericalInputsList[i].weightCount.trim().isEmpty) {
        //error message
        numericalInputsList.remove(numericalInputsList[i]);
      }

      if (numericalInputsList.length - 1 == i) {
        numericInputsCallback.getNumericInputs(numericalInputsList);
      }
    }
  }
}

TextEditingController setEditFieldController = new TextEditingController();
int listCount = 0;
List<NumericalUnitsModel> repsUnitList = new List.empty(growable: true);
List<NumericalUnitsModel> weightsUnitList = new List.empty(growable: true);
List<NumericalInputsModel> numericalInputsList = new List.empty(growable: true);
String selectedRepsUnitCustomDropDown = "Reps";
String selectedWeightUnitCustomDropDown = "lb";
int selectedWeightBottomSheet;
String selectedRepsUnitValue = "Reps";
String selectedWeightUnitValue = "lb";

class _NumericalInputsPageState extends State<NumericalInputsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    numericalInputsList = widget.numericalInputsList;
    repsUnitList.add(new NumericalUnitsModel("Reps", "(reps)"));
    repsUnitList.add(new NumericalUnitsModel("Weight", "(lb)"));
    repsUnitList.add(new NumericalUnitsModel("Time", "(mm:ss)"));
    repsUnitList.add(new NumericalUnitsModel("Seconds", "(sec)"));
    repsUnitList.add(new NumericalUnitsModel("Miles", "(mi)"));
    repsUnitList.add(new NumericalUnitsModel("Yards", "(yd)"));
    repsUnitList.add(new NumericalUnitsModel("Meters", "(m)"));
    repsUnitList.add(new NumericalUnitsModel("Feet", "(ft)"));
    repsUnitList.add(new NumericalUnitsModel("Watts", "(W)"));
    repsUnitList.add(new NumericalUnitsModel("RPE", "(rpe)"));
    repsUnitList.add(new NumericalUnitsModel("Calories", "(cal)"));
    repsUnitList.add(new NumericalUnitsModel("Inches (Height)", "(in)"));
    repsUnitList.add(new NumericalUnitsModel("Inches (Distance)", "(dist)"));
    repsUnitList.add(new NumericalUnitsModel("Velocity (m/s)", "(vel.)"));
    repsUnitList.add(new NumericalUnitsModel("Other", "(other)"));

    // weightsUnitList.add(new NumericalUnitsModel("None", "(none)"));
    weightsUnitList.add(new NumericalUnitsModel("Reps", "(reps)"));
    weightsUnitList.add(new NumericalUnitsModel("Weight", "(lb)"));
    weightsUnitList.add(new NumericalUnitsModel("Linear Weight Progression", "(lwp)"));
    weightsUnitList.add(new NumericalUnitsModel("Seconds", "(sec)"));
    weightsUnitList.add(new NumericalUnitsModel("Miles", "(mi)"));
    weightsUnitList.add(new NumericalUnitsModel("Yards", "(yd)"));
    weightsUnitList.add(new NumericalUnitsModel("Meters", "(m)"));
    weightsUnitList.add(new NumericalUnitsModel("Feet", "(ft)"));
    weightsUnitList.add(new NumericalUnitsModel("RPE", "(rpe)"));
    weightsUnitList.add(new NumericalUnitsModel("Calories", "(cal)"));
    weightsUnitList.add(new NumericalUnitsModel("Inches (Height)", "(in)"));
    weightsUnitList.add(new NumericalUnitsModel("Inches (Distance)", "(dist)"));
    weightsUnitList.add(new NumericalUnitsModel("Velocity (m/s)", "(vel.)"));
    weightsUnitList.add(new NumericalUnitsModel("Other", "(other)"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    if (widget.showAppBar)
                      Container(
                          padding: EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    numericalInputsList.clear();
                                  },
                                  icon: Icon(
                                    Icons.arrow_back,
                                    size: 24.0,
                                  )),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  numericalInputsList.clear();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(Constants.cancel,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: Constants.openSauceFont,
                                          color: AppColors.primaryColor)),
                                ),
                              )
                            ],
                          )),
                    if (!widget.showAppBar) SizedBox(height: 50),
                    Container(
                      alignment: widget.showAppBar ? Alignment.centerLeft : Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(Constants.addNumbers,
                          style: TextStyle(
                              color: AppColors.darkTextColor,
                              fontFamily: "open_saucesans_regular",
                              fontWeight: FontWeight.w700,
                              fontSize: widget.showAppBar ? 24 : 17)),
                    ),
                    SizedBox(height: 50),
                    Container(
                      margin: EdgeInsets.only(left: 15, right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 0),
                            child: Text(Constants.numberOfSets,
                                style: TextStyle(
                                    color: AppColors.darkTextColor,
                                    fontFamily: "open_saucesans_regular",
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16)),
                          ),
                          Container(
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (numericalInputsList.length != 0) {
                                      numericalInputsList.remove(
                                          numericalInputsList[numericalInputsList.length - 1]);
                                      setState(() {});
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: AppColors.segmentAppBarColor,
                                      border: Border.all(color: AppColors.segmentAppBarColor),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.asset("assets/images/fi_minus.png",
                                        height: 20, width: 20),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Container(
                                    height: 30,
                                    padding: EdgeInsets.only(left: 18, right: 18),
                                    child: Center(
                                      child: Text(
                                        numericalInputsList.length.toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: "roboto_regular",
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                        color: AppColors.lightBlue,
                                        borderRadius: BorderRadius.all(Radius.circular(5.0)))),
                                SizedBox(width: 20),
                                InkWell(
                                  onTap: () {
                                    numericalInputsList.add(new NumericalInputsModel(
                                      "",
                                      selectedRepsUnitValue,
                                      "",
                                      selectedWeightUnitValue,
                                      "",
                                      selectedRepsUnitCustomDropDown,
                                      selectedWeightUnitCustomDropDown,
                                    ));
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: AppColors.segmentAppBarColor,
                                      border: Border.all(color: AppColors.segmentAppBarColor),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.asset("assets/images/fi_plus.png",
                                        height: 20, width: 20),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                            margin: EdgeInsets.only(top: 30, left: 10, right: 10),
                            child: setsList()),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        numericalInputsList.add(new NumericalInputsModel(
                          "",
                          selectedRepsUnitValue,
                          "",
                          selectedWeightUnitValue,
                          "",
                          selectedRepsUnitCustomDropDown,
                          selectedWeightUnitCustomDropDown,
                        ));
                        setState(() {});
                      },
                      child: Container(
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 20, right: 0),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.lightGreyColor),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                  child: Text("+",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: "open_saucesans_regular",
                                          fontWeight: FontWeight.w500))),
                            ),
                            Container(
                                margin: EdgeInsets.only(left: 20, right: 0),
                                child: Text(Constants.addSet,
                                    style: TextStyle(
                                        color: AppColors.cardTextColor,
                                        fontSize: 16,
                                        fontFamily: "roboto_regular",
                                        fontWeight: FontWeight.w500))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.showAppBar)
                Container(
                  color: Colors.transparent,
                  margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                  width: MediaQuery.of(context).size.width,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    onPressed: () {
                      for (int i = 0; i < numericalInputsList.length; i++) {
                        if (numericalInputsList[i].repsCount.trim() == "0" ||
                                numericalInputsList[i].repsCount.trim().isEmpty
                            // ||
                            // numericalInputsList[i].weightCount.trim() == "0" ||
                            // numericalInputsList[i].weightCount.trim().isEmpty
                            ) {
                          //error message
                          numericalInputsList.remove(numericalInputsList[i]);
                        }

                        if (numericalInputsList.length - 1 == i) {
                          List<SetNumbers> setNumbersList = new List.empty(growable: true);
                          numericalInputsList.forEach((element) {
                            setNumbersList.add(SetNumbers(
                                unitInput: element.repsCount,
                                unit: element.repsUnit,
                                weightInput: element.weightCount,
                                weight: element.weightUnit));
                          });

                          Navigator.pop(context, {
                            "numericInputs": setNumbersList,
                            "title": widget.title,
                            "desc": widget.description,
                            "numericalInputsList": numericalInputsList,
                          });
                          // setNumbersList.clear();
                          // numericalInputsList.clear();
                        }
                      }
                    },
                    color: AppColors.darkTextColor,
                    textColor: Colors.white,
                    padding: EdgeInsets.all(12.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(Constants.doneText.toUpperCase(),
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            fontFamily: "open_saucesans_regular",
                          )),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget setsList() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.lightGreyColor),
                        shape: BoxShape.circle,
                      ),
                      child: Text((index + 1).toString(),
                          style:
                              TextStyle(fontFamily: "roboto_regular", fontWeight: FontWeight.w500)),
                    ),
                    Container(
                      height: 40,
                      child: DottedLine(
                          direction: Axis.vertical,
                          lineThickness: 1.0,
                          dashLength: 4.0,
                          dashColor: AppColors.lightGreyColor),
                    ),
                  ],
                ),
                Container(
                    height: 42,
                    width: 42,
                    child: TextField(
                      keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                      onChanged: (v) {
                        numericalInputsList[index].repsCount = v;
                      },
                      maxLength: 3,
                      controller: TextEditingController(text: numericalInputsList[index].repsCount),
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textInputAction: TextInputAction.go,
                      decoration: InputDecoration(
                          hintText: "0",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 7.0),
                          hintStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontFamily: "roboto_regular",
                              fontSize: 16),
                          // counterStyle: TextStyle(
                          //   height: double.minPositive,
                          // ),
                          counterText: ""),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontFamily: "roboto_regular",
                          fontSize: 16),
                    ),
                    decoration: BoxDecoration(
                        color: AppColors.viewsBg,
                        borderRadius: BorderRadius.all(Radius.circular(5.0)))),
                InkWell(
                  onTap: () {
                    showBottomSheet(index);
                  },
                  child: Container(
                      // width: 90,
                      padding: EdgeInsets.only(left: 0),
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          Text(
                            numericalInputsList[index].repsUnit.toString().length > 4
                                ? numericalInputsList[index].repsUnit.substring(0, 4) + '..'
                                : numericalInputsList[index].repsUnit,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: "open_saucesans_regular",
                                color: AppColors.darkTextColor,
                                fontWeight: FontWeight.w500),
                          ),
                          IconButton(
                            icon: Icon(Icons.keyboard_arrow_down, color: AppColors.darkTextColor),
                            onPressed: () {
                              showBottomSheet(index);
                            },
                          ),
                        ],
                      )),
                ),
                Container(
                    padding: EdgeInsets.only(bottom: 1),
                    height: 42,
                    width: 42,
                    child: TextField(
                      keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                      controller:
                          TextEditingController(text: numericalInputsList[index].weightCount),
                      onChanged: (v) {
                        numericalInputsList[index].weightCount = v;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      maxLength: 3,
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.go,
                      decoration: InputDecoration(
                          hintText: "0",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontFamily: "roboto_regular",
                              fontSize: 16),
                          contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 7.0),
                          // counterStyle: TextStyle(
                          //   height: double.minPositive,
                          // ),
                          counterText: ""),
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "roboto_regular",
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
                    ),
                    decoration: BoxDecoration(
                        color: AppColors.viewsBg,
                        borderRadius: BorderRadius.all(Radius.circular(5.0)))),
                InkWell(
                  onTap: () {
                    showBottomSheetWeight(index);
                  },
                  child: Container(
                      // width: 90,

                      color: Colors.transparent,
                      child: Row(
                        children: [
                          Text(
                            numericalInputsList[index].weightUnit.toString().length > 4
                                ? numericalInputsList[index].weightUnit.substring(0, 4) + '..'
                                : numericalInputsList[index].weightUnit,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: "open_saucesans_regular",
                                color: AppColors.darkTextColor,
                                fontWeight: FontWeight.w500),
                          ),
                          IconButton(
                            icon: Icon(Icons.keyboard_arrow_down, color: AppColors.darkTextColor),
                            onPressed: () {
                              showBottomSheetWeight(index);
                            },
                          ),
                        ],
                      )),
                ),
              ],
            ));
      },
      itemCount: numericalInputsList.length,
    );
  }

  void showBottomSheet(sIndex) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              selectedRepsUnitCustomDropDown = repsUnitList[index]
                                  .shortName
                                  .replaceAll("(", "")
                                  .replaceAll(")", "");
                              numericalInputsList[sIndex].repsUnit = repsUnitList[index]
                                  .shortName
                                  .replaceAll("(", "")
                                  .replaceAll(")", "");
                              Navigator.pop(context);
                              setState(() {});
                            },
                            child: Container(
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Center(
                                  child: Text(
                                      repsUnitList[index].title +
                                          " " +
                                          repsUnitList[index].shortName,
                                      style: TextStyle(
                                        color: AppColors.darkTextColor,
                                        fontSize: 16,
                                        fontFamily: "epilogue_medium",
                                      )),
                                ),
                              ),
                            ),
                          ),
                          Container(
                              padding: EdgeInsets.only(left: 30, right: 30),
                              child: Divider(
                                color: AppColors.darkTextColor.withOpacity(0.5),
                              ))
                        ],
                      );
                    },
                    itemCount: repsUnitList.length,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showBottomSheetWeight(swIndex) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              selectedWeightUnitCustomDropDown = weightsUnitList[index]
                                  .shortName
                                  .replaceAll("(", "")
                                  .replaceAll(")", "");
                              numericalInputsList[swIndex].weightUnit = weightsUnitList[index]
                                  .shortName
                                  .replaceAll(")", "")
                                  .replaceAll(")", "");
                              Navigator.pop(context);
                              setState(() {});
                            },
                            child: Container(
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Center(
                                  child: Text(
                                      weightsUnitList[index].title +
                                          " " +
                                          weightsUnitList[index].shortName,
                                      style: TextStyle(
                                        color: AppColors.darkTextColor,
                                        fontSize: 16,
                                        fontFamily: "epilogue_medium",
                                      )),
                                ),
                              ),
                            ),
                          ),
                          Container(
                              padding: EdgeInsets.only(left: 30, right: 30),
                              child: Divider(
                                color: AppColors.darkTextColor.withOpacity(0.5),
                              ))
                        ],
                      );
                    },
                    itemCount: weightsUnitList.length,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
