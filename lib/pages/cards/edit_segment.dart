import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solstice/model/cards_model.dart';
import 'package:solstice/model/numerical_inputs_model/numeric_input_model.dart';
import 'package:solstice/model/tabs_models.dart';
import 'package:solstice/pages/cards/numerical_inputs.dart';
import 'package:solstice/pages/cards/transitions.dart';
import 'package:solstice/pages/views/tab_list_item.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/utilities.dart';
import 'package:video_editor/video_editor.dart';

import 'package:path/path.dart' as path;

class EditSegmentPage extends StatefulWidget {
  final List<HashMap<File, File>> videoFiles;
  final List<File> imageFiles;
  final String viewType;

  EditSegmentPage({this.videoFiles, this.imageFiles, this.viewType});

  @override
  _EditSegmentState createState() => _EditSegmentState();
}

TextEditingController setEditFieldController = new TextEditingController();
int listCount = 0;

class _EditSegmentState extends State<EditSegmentPage>
    implements NumericInputsCallback {
  List<HashMap<File, File>> videoFiles = new List.empty(growable: true);
  List<TabsModel> segmentTabs = new List<TabsModel>.empty(growable: true);
  String selectedBottomTab;
  VideoEditorController _controller;
  List<SetNumbers> setNumbersList = new List.empty(growable: true);

  int videoIndex = 0;
  NumericalInputsPage numericalInputs;
  bool isTrimmed = false;
  @override
  void initState() {
    super.initState();
    if (widget.viewType != null &&
        widget.viewType != "" &&
        widget.viewType == "Image") {
      selectedBottomTab = "Numbers";

      segmentTabs.add(TabsModel("Numbers", true));
    } else {
      videoFiles.addAll(widget.videoFiles);
      selectedBottomTab = "Thumbnail";

      segmentTabs.add(TabsModel("Thumbnail", true));
      segmentTabs.add(TabsModel("Trim", false));

      loadVideo();
      for (int i = 0; i < videoFiles.length; i++) {
      }
    }
  }

  void disposeController() {
    if (_controller != null) {
      // _controller.dispose();
      _controller = null;
    }
  }

  void loadVideo() {
    // videoController = VideoPlayerController.file(videoFile);
    disposeController();

    _controller = VideoEditorController.file(
        videoFiles[videoIndex][videoFiles[videoIndex].keys.elementAt(0)],
        maxDuration: Duration(seconds: 30),
        trimStyle: TrimSliderStyle(
            dotRadius: 10, lineWidth: 3, positionLineColor: Colors.blue))
      ..initialize().then((_) async {
        if (isTrimmed) {
          final File cover = await _controller.extractCover();
          String dir = path.dirname(cover.path);
          String newPath = path.join(dir, "Cover_Index" + '$videoIndex.jpg');
          File coverNew = await File(cover.path).copy(newPath);
          HashMap<File, File> mapFile = new HashMap();
          mapFile[coverNew] = videoFiles[videoIndex][videoFiles[videoIndex].keys.elementAt(0)];
          videoFiles[videoIndex] = mapFile;
          isTrimmed = false;
        }

        setState(() {});
      }).catchError((onError) {
      });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.segmentAppBarColor,
        centerTitle: true,
        title: Text(Constants.editSegment,
            style: TextStyle(
                color: Colors.white,
                fontFamily: "open_saucesans_regular",
                fontWeight: FontWeight.w700,
                fontSize: 18)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            disposeController();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.white),
            onPressed: () {
              // if (numericalInputs != null) {
              //   numericalInputs.onSaveSegment();

              // }
              Navigator.pop(context, {"mediaList": videoFiles});
            },
          ),
        ],
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 70,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
              color: AppColors.segmentAppBarColor,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      videoIndex = index;
                      loadVideo();
                    },
                    child: Container(
                      height: 65,
                      width: 65,
                      margin: EdgeInsets.symmetric(
                        horizontal: 3.0,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          border: Border.all(
                              width: videoIndex == index ? 2.0 : 0.0,
                              color: Colors.white),
                          color: AppColors.segmentAppBarColor),
                      padding: EdgeInsets.all(3.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        child: Image.file(
                          widget.viewType == "Image"
                              ? widget.imageFiles[index]
                              : videoFiles[index].keys.elementAt(0),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
                itemCount: widget.viewType == "Image"
                    ? widget.imageFiles.length
                    : videoFiles.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
              ),
            ),
            Expanded(
                child: Container(
              child: selectedTabLayout(),
            )),
            tabLayout()
          ],
        ),
      ),
    );
  }

  Widget selectedTabLayout() {
    if (selectedBottomTab == "Thumbnail") {
      return thumbnailLayout();
    } else if (selectedBottomTab == "Trim") {
      return trimLayout();
    } else if (selectedBottomTab == "Numbers") {
      return numericalInputs = NumericalInputsPage(
        numericInputsCallback: this,
      );
    } else {
      return Container();
    }
  }

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: _controller.video,
        builder: (_, __) {
          final duration = _controller.video.value.duration.inSeconds;
          final pos = _controller.trimPosition * duration;
          final start = _controller.minTrim * duration;
          final end = _controller.maxTrim * duration;
          return Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt()))),
              Expanded(child: SizedBox()),
              OpacityTransition(
                visible: _controller.isTrimming,
                child: Row(children: [
                  Text(formatter(Duration(seconds: start.toInt()))),
                  SizedBox(width: 10),
                  Text(formatter(Duration(seconds: end.toInt()))),
                ]),
              ),
              Text(
                formatter(Duration(seconds: duration.toInt())),
                style: TextStyle(fontSize: 14.0, color: Colors.black),
              ),
            ]),
          );
        },
      ),
      Container(
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        child: TrimSlider(
            // child: TrimTimeline(
            //   controller: _controller,
            // ),
            controller: _controller,
            horizontalMargin: 10),
      )
    ];
  }

  Widget trimLayout() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              child: Stack(alignment: Alignment.center, children: [
                if (_controller.initialized)
                  CropGridViewer(
                    controller: _controller,
                    showGrid: false,
                  ),
                AnimatedBuilder(
                  animation: _controller.video,
                  builder: (_, __) => OpacityTransition(
                    visible: !_controller.isPlaying,
                    child: GestureDetector(
                      onTap: _controller.video.play,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.play_arrow, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          Container(
            height: 0.5,
            color: Colors.black12,
          ),
          SizedBox(
            height: 30,
          ),
          InkWell(
            onTap: () {
              Utilities.show(context);
              _exportVideo(videoIndex);
            },
            child: Stack(alignment: Alignment.center, children: [
              Text(
                Constants.trimVideo,
                style: TextStyle(
                    color: AppColors.darkTextColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              Positioned(
                  top: 0,
                  right: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      Constants.doneText,
                      style: TextStyle(fontSize: 12.0, color: Colors.blue),
                    ),
                  ))
            ]),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            Constants.videoLength,
            style: TextStyle(color: AppColors.liteTextColor, fontSize: 12.0),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 10,
          ),
          if (_controller.initialized)
            Expanded(
              flex: 1,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _trimSlider()),
            ),
          SizedBox(
            height: 10,
          ),
          Text(
            Constants.adjustDragHandles,
            style: TextStyle(color: AppColors.liteTextColor, fontSize: 12.0),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  void _exportVideo(int selectedIndex) async {
    Future.delayed(Duration(milliseconds: 1000));
    //NOTE: To use [-crf 17] and [VideoExportPreset] you need ["min-gpl-lts"] package
    await _controller
        .exportVideo(
      onProgress: (statics) {},
    )
        .then((value) async {
      isTrimmed = true;
      HashMap<File, File> mapFileUpdated = new HashMap();
      mapFileUpdated[videoFiles[videoIndex].keys.elementAt(0)] = null;
      mapFileUpdated[videoFiles[videoIndex].keys.elementAt(0)] = value;
      videoFiles[selectedIndex] = mapFileUpdated;

      loadVideo();
      Utilities.hide();
      setState(() {});
    });

    Future.delayed(Duration(milliseconds: 1000));
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  Widget thumbnailLayout() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              child: Stack(
                children: [
                  if (_controller.initialized)
                    CoverViewer(controller: _controller)
                ],
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Text(
            Constants.chooseThumbnail,
            style: TextStyle(
                color: AppColors.darkTextColor,
                fontSize: 16.0,
                fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 30,
          ),
          if (_controller.initialized) Container(child: _coverSelection()),
          SizedBox(
            height: 10,
          ),
          Text(
            Constants.selectThumb,
            style: TextStyle(color: AppColors.liteTextColor, fontSize: 12.0),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget _coverSelection() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3.0),
        color: Colors.black38.withOpacity(0.2),
        child: CoverSelection(
          controller: _controller,
          nbSelection: 10,
          
        ));
  }

  // tabs
  Widget tabLayout() {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(bottom: 20),
      height: 35,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: segmentTabs == null ? 0 : segmentTabs.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return new InkWell(
            //highlightColor: Colors.red,
            splashColor: AppColors.primaryColor,
            onTap: () {
              setState(() {
                segmentTabs.forEach((element) => element.isSelected = false);
                segmentTabs[index].isSelected = true;
                selectedBottomTab = segmentTabs[index].tabTitle;
              });
            },
            child: Container(
                width: MediaQuery.of(context).size.width / 4,
                child: new TabListItem(
                  segmentTabs[index],
                  blackText: false,
                )),
          );
        },
      ),
    );
  }

  @override
  void getNumericInputs(List<NumericalInputsModel> numericInputsList) {
    numericInputsList.forEach((element) {
      setNumbersList.add(SetNumbers(
          unitInput: element.repsCount,
          unit: element.repsUnit,
          weightInput: element.weightCount,
          weight: element.weightUnit));
    });
    if (setNumbersList.length > 0) {
      getDataBackToCard();
    } else {
      Constants().errorToast(context, "Please add set numbers");
    }
  }

  void getDataBackToCard() {
    Navigator.pop(
        context, {"numberList": setNumbersList, "mediaList": videoFiles});
  }
}

class NumericInputsCallback {
  void getNumericInputs(List<NumericalInputsModel> numericInputsList) {}
}
