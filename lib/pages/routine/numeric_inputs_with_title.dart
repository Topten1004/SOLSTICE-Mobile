import 'dart:collection';
import 'dart:io';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/model/numerical_inputs_model/numeric_input_model.dart';
import 'package:solstice/model/numerical_units_model.dart';
import 'package:solstice/pages/cards/test_video_trim.dart';
import 'package:solstice/utils/constants.dart';

class NumericInputsWithTitle extends StatefulWidget {
  List<SetNumbers> setNumbersList;
  List<File> fileList;
  HashMap<File, File> videoFiles;
  String title, description, cardType;
  NumericInputsWithTitle(
      {this.setNumbersList,
      this.title,
      this.description,
      this.cardType,
      this.fileList,
      this.videoFiles});
  @override
  _NumericInputsWithTitleState createState() => _NumericInputsWithTitleState();
}

class _NumericInputsWithTitleState extends State<NumericInputsWithTitle> {
  List<NumericalInputsModel> numericalInputsList = new List.empty(growable: true);
  List<Asset> images = List<Asset>.empty(growable: true);
  List<File> _files = new List.empty(growable: true);

  String selectedRepsUnitCustomDropDown = "Reps";

  String selectedWeightUnitCustomDropDown = "lb";

  int selectedWeightBottomSheet;

  String selectedRepsUnitValue = "Reps";

  String selectedWeightUnitValue = "lb";

  List<NumericalUnitsModel> repsUnitList = new List.empty(growable: true);
  List<NumericalUnitsModel> weightsUnitList = new List.empty(growable: true);

  TextEditingController titleController = new TextEditingController();
  TextEditingController descController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getUnitsData();
  }

  void getUnitsData() {
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
    titleController.text = widget.title;
    descController.text = widget.description;
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setStateBottomSheet) {
        return SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.only(left: 25, right: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          setStateBottomSheet(() {});

                          Navigator.pop(context, {
                            "numericInputs": widget.setNumbersList,
                            "title": titleController.text.toString(),
                            "desc": descController.text.toString()
                          });

                          // widget.setNumbersList.clear();
                        },
                        child: Text("Done",
                            style: TextStyle(
                                color: AppColors.cardTextColor,
                                fontFamily: "open_saucesans_regular",
                                fontWeight: FontWeight.w700,
                                fontSize: 17)),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                          // widget.setNumbersList.clear();
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 0),
                Container(
                  alignment: Alignment.center,
                  child: TextField(
                      textAlign: TextAlign.center,
                      controller: titleController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintText: titleController.text,
                          hintStyle: TextStyle(
                              color: AppColors.greyTextColor,
                              fontFamily: "open_saucesans_regular",
                              fontWeight: FontWeight.w700,
                              fontSize: 17),
                          labelText: titleController.text),
                      onChanged: (v) {},
                      // controller: ,
                      style: TextStyle(
                          color: AppColors.darkTextColor,
                          fontFamily: "open_saucesans_regular",
                          fontWeight: FontWeight.w700,
                          fontSize: 17)),
                ),
                Container(
                  alignment: Alignment.center,
                  child: TextField(
                      textAlign: TextAlign.center,
                      controller: descController,
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: Constants.addDescription,
                        hintStyle: TextStyle(
                            color: AppColors.greyTextColor,
                            fontFamily: "open_saucesans_regular",
                            fontWeight: FontWeight.w400,
                            fontSize: 13),
                      ),
                      onChanged: (value) {},
                      maxLines: 2,
                      style: TextStyle(
                          color: AppColors.darkTextColor,
                          fontFamily: "open_saucesans_regular",
                          fontWeight: FontWeight.w400,
                          fontSize: 13)),
                ),
                if (widget.cardType == "Image" || widget.cardType == "Video")
                  InkWell(
                    onTap: () async {
                      //
                      if (widget.cardType == "Image") {
                        pickImages();
                      } else if (widget.cardType == "Video") {
                        //   var object = await Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => VideoEditor(
                        //             selectedVideoFiles: widget.videoFiles.,
                        //             file: widget.videoFiles[0]
                        //                 [widget.videoFiles[0].keys.elementAt(0)]),
                        //       ));
                        //   if (object != null) {
                        //     if (object["capture"] == "yes") {
                        //       widget.videoFiles.addAll(object["videoList"]);
                        //       // videoFile = null;
                        //       setState(() {});
                        //     } else {
                        //       Navigator.pop(context, {
                        //         "numberList": object["numberList"],
                        //         "mediaList": object["mediaList"]
                        //       });
                        //     }
                      }
                      // }
                    },
                    child: Text(widget.cardType == "Image" ? "Add Images" : "",
                        style: TextStyle(
                            color: AppColors.cardTextColor,
                            fontFamily: "open_saucesans_regular",
                            fontWeight: FontWeight.w400,
                            fontSize: 13)),
                  ),
                SizedBox(height: 20),
                if (widget.cardType == "Image" )
                  widget.fileList.length > 0 
                      ? Container(
                          child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                height: 70,
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
                                child: ListView.builder(
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {},
                                      child: Container(
                                          height: 85,
                                          width: 85,
                                          margin: EdgeInsets.symmetric(horizontal: 0.0),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                height: 80,
                                                width: 60,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(Radius.circular(10.0)),
                                                    border: Border.all(
                                                        width: 2.0,
                                                        color: AppColors.cardTextColor)),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.all(Radius.circular(10.0)),
                                                  child: Image.file(
                                                    widget.cardType == "Image"
                                                        ? File(widget.fileList[index].path)
                                                        : widget.videoFiles.keys.elementAt(0),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: widget.cardType == "Video" ? true : false,
                                                child: Image.asset(Constants.cardVideo,
                                                    height: 20, width: 20),
                                              ),
                                              Positioned(
                                                child: InkWell(
                                                    onTap: () {
                                                      widget.cardType == "Image"
                                                          ? widget.fileList.removeAt(index)
                                                          : widget.videoFiles.clear();
                                                      // videoFiles.removeAt(index);
                                                      setState(() {});
                                                    },
                                                    child: SvgPicture.asset(Constants.iconCross,
                                                        height: 20, width: 20)),
                                                top: 0,
                                                right: 3,
                                              )
                                            ],
                                          )),
                                    );
                                  },
                                  itemCount: widget.cardType == "Image"
                                      ? widget.fileList.length
                                      : widget.videoFiles.length,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                ),
                              ),
                            ),
                          ],
                        ))
                      : Container(),
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
                                if (widget.setNumbersList.length != 0) {
                                  widget.setNumbersList
                                    ..remove(
                                        widget.setNumbersList[widget.setNumbersList.length - 1]);
                                  setStateBottomSheet(() {});
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
                                    widget.setNumbersList.length.toString(),
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
                                widget.setNumbersList.add(new SetNumbers(
                                  unit: selectedRepsUnitValue,
                                  unitInput: "",
                                  weight: selectedWeightUnitValue,
                                  weightInput: "",
                                  // "0",
                                  // selectedRepsUnitValue,
                                  // "0",
                                  // selectedWeightUnitValue,
                                  // "",
                                  // selectedRepsUnitCustomDropDown,
                                  // selectedWeightUnitCustomDropDown,
                                ));
                                setStateBottomSheet(() {});
                              },
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppColors.segmentAppBarColor,
                                  border: Border.all(color: AppColors.segmentAppBarColor),
                                  shape: BoxShape.circle,
                                ),
                                child:
                                    Image.asset("assets/images/fi_plus.png", height: 20, width: 20),
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
                        child: setsList(widget.setNumbersList)),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setStateBottomSheet(() {});
                  },
                  child: InkWell(
                    onTap: () {
                      widget.setNumbersList.add(new SetNumbers(
                        unit: selectedRepsUnitValue,
                        unitInput: "",
                        weight: selectedWeightUnitValue,
                        weightInput: "",
                      )
                          // numericalInputsList.add(new NumericalInputsModel(
                          //   "0",
                          //   selectedRepsUnitValue,
                          //   "0",
                          //   selectedWeightUnitValue,
                          //   "",
                          //   selectedRepsUnitCustomDropDown,
                          //   selectedWeightUnitCustomDropDown,
                          // )
                          );
                      setStateBottomSheet(() {});
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
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget setsList(List<SetNumbers> setList) {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Container(
        child: ListView.builder(
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
                              style: TextStyle(
                                  fontFamily: "roboto_regular", fontWeight: FontWeight.w500)),
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
                        // padding: EdgeInsets.only(bottom: 1),
                        height: 42,
                        width: 42,
                        child: TextField(
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: false, signed: true),
                          onChanged: (v) {
                            setList[index].unitInput = v;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          maxLength: 3,
                          controller: TextEditingController(text: setList[index].unitInput),
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.go,
                          decoration: InputDecoration(
                              hintText: "0",
                              hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "roboto_regular",
                                  fontSize: 16),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 7.0),
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
                        showBottomSheet(index, setState, setList);
                      },
                      child: Container(
                          // width: 90,
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              Text(
                                setList[index].unit.toString().length > 4
                                    ? setList[index].unit.substring(0, 4) + '..'
                                    : setList[index].unit,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: "open_saucesans_regular",
                                    color: AppColors.darkTextColor,
                                    fontWeight: FontWeight.w500),
                              ),
                              IconButton(
                                icon:
                                    Icon(Icons.keyboard_arrow_down, color: AppColors.darkTextColor),
                                onPressed: () {
                                  showBottomSheet(index, setState, setList);
                                },
                              ),
                            ],
                          )),
                    ),
                    Container(
                        // padding: EdgeInsets.only(bottom: 1),
                        height: 42,
                        width: 42,
                        child: TextField(
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: false, signed: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          controller: TextEditingController(text: setList[index].weightInput),
                          onChanged: (v) {
                            setList[index].weightInput = v;
                          },
                          maxLength: 3,
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                              hintText: "0",
                              contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 7.0),
                              hintStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "roboto_regular",
                                  fontSize: 16),
                              border: InputBorder.none,
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
                        showBottomSheetWeight(index, setState, setList);
                      },
                      child: Container(
                          // width: 90,

                          color: Colors.transparent,
                          child: Row(
                            children: [
                              Text(
                                setList[index].weight.toString().length > 4
                                    ? setList[index].weight.substring(0, 4) + '..'
                                    : setList[index].weight,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: "open_saucesans_regular",
                                    color: AppColors.darkTextColor,
                                    fontWeight: FontWeight.w500),
                              ),
                              IconButton(
                                icon:
                                    Icon(Icons.keyboard_arrow_down, color: AppColors.darkTextColor),
                                onPressed: () {
                                  showBottomSheetWeight(index, setState, setList);
                                },
                              ),
                            ],
                          )),
                    ),
                  ],
                ));
          },
          itemCount: setList.length,
        ),
      );
    });
  }

  void showBottomSheet(sIndex, setState, List<SetNumbers> setList) {
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
                              setList[sIndex].unit = repsUnitList[index]
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

  void showBottomSheetWeight(swIndex, setState, List<SetNumbers> setList) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter st) {
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
                                  setList[swIndex].weight = weightsUnitList[index]
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
      },
    );
  }

  Future<void> pickImages() async {
    List<Asset> resultList = List<Asset>();

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: false,
        selectedAssets: images,
        materialOptions: MaterialOptions(
          actionBarTitle: "Select Images",
        ),
      );
    } on Exception catch (e) {
    }

    // setState(() {
    images = resultList;
    getAbsolutePath();
    // });
  }

  getAbsolutePath() async {
    List<File> files = [];
    for (Asset asset in images) {
      final filePath = await getImageFileFromAssets(asset);
      files.add(filePath);
    }
    // Navigator.pop(context);
    if (!mounted) return;
    setState(() {
      _files = files;

      // _files = widget.fileList;
      widget.fileList.addAll(_files);
      // mediaFile = files[0];
      if (_files != null && _files.length > 0) {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => EditSegmentPage(
        //               imageFiles: _files,
        //               viewType: "Image",
        //               videoFiles: [],
        //             ))).then((value) {
        //   if (value != null) {
        //     setNumbersList = value["numberList"];
        //     // numericalInputsList = value;
        //   }
        // });
        ;
      }
    });
  }

  Future<File> getImageFileFromAssets(Asset asset) async {
    final byteData = await asset.getByteData();

    final tempFile = File("${(await getTemporaryDirectory()).path}/${asset.name}");
    final file = await tempFile.writeAsBytes(
      byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );

    return file;
  }
}
