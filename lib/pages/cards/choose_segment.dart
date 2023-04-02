import 'dart:collection';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solstice/pages/cards/edit_segment.dart';
import 'package:solstice/pages/cards/transitions.dart';
import 'package:solstice/utils/constants.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';

class ChooseSegment extends StatefulWidget {
  final XFile videoFile;
  final List<HashMap<File, File>> selectedVideoFiles;

  ChooseSegment({this.videoFile, this.selectedVideoFiles});
  @override
  _ChooseSegmentState createState() => _ChooseSegmentState();
}

class _ChooseSegmentState extends State<ChooseSegment> {
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  VideoEditorController _controller;
  ChewieController chewieController;
  File videoFile;
  final double height = 60;
  List<HashMap<File, File>> videoFiles = new List.empty(growable: true);
  List<bool> listSelected = new List.empty(growable: true);

  @override
  void initState() {
    videoFile = File(widget.videoFile.path);
    videoFiles.addAll(widget.selectedVideoFiles);

    loadVideo();
    super.initState();
  }

  Future<void> loadVideo() {
    videoController = VideoPlayerController.file(videoFile);

    _controller = VideoEditorController.file(videoFile,
        maxDuration: Duration(seconds: 30))
      ..initialize().then((_) async {

        final File cover = await _controller.extractCover();
        HashMap<File, File> mapFile = new HashMap();

        mapFile[cover] = videoFile;
        videoFiles.add(mapFile);

        for (int i = 0; i < videoFiles.length; i++) {
          listSelected.add(false);
        }

        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.segmentAppBarColor,
          centerTitle: true,
          title: Text(Constants.chooseSegment,
              style: TextStyle(color: Colors.white, fontSize: 18)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.check, color: Colors.white),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditSegmentPage(
                              videoFiles: videoFiles,
                            )));
              },
            ),
          ],
        ),
        body: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Container(height: 25, color: AppColors.segmentAppBarColor),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                        child: (_controller.initialized)
                            ?  CropGridViewer(
                              controller: _controller,
                              showGrid: false,
                            )
                            : Container()),
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
                  ],
                ),
              ),
    
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                          height: 150,
                          margin: EdgeInsets.all(10.0),
                          child: Column(
                            children: _trimSlider(),
                          )),
                      Text(
                        'Adjust drag handles to trim',
                        style: TextStyle(
                            color: AppColors.liteTextColor, fontSize: 12.0),
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        height: 85,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    videoFile = videoFiles[index][0];
                                    // listSelected.forEach((element) {element=false});
                                    listSelected[index] = true;
                                    setState(() {});
                                  },
                                  child: Container(
                                      height: 85,
                                      width: 85,
                                      margin: EdgeInsets.all(7.0),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            height: 75,
                                            width: 75,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0)),
                                                border: Border.all(
                                                    width: 2.0,
                                                    color:
                                                        AppColors.orangeColor)),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
                                              child: Image.file(
                                                videoFiles[index]
                                                    .keys
                                                    .elementAt(0),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            child: InkWell(
                                                onTap: () {
                                                  videoFiles.removeAt(index);
                                                  setState(() {});
                                                },
                                                child: SvgPicture.asset(
                                                    Constants.iconCross)),
                                            top: 0,
                                            right: 0,
                                          )
                                        ],
                                      )),
                                );
                              },
                              itemCount: videoFiles.length,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context,
                                    {"capture": "yes", "videoList": videoFiles});
                              },
                              child: Container(
                                width: 70,
                                height: 70,
                                child: DottedBorder(
                                  borderType: BorderType.RRect,
                                  color: AppColors.primaryColor,
                                  radius: Radius.circular(6),
                                  dashPattern: [3, 3, 3, 3],
                                  strokeWidth: 1.2,
                                  child: Center(
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 24,
                                      height: 24,
                                      padding: EdgeInsets.all(2.5),
                                      child: SvgPicture.asset(
                                        'assets/images/ic_plus.svg',
                                        alignment: Alignment.center,
                                        color: AppColors.primaryColor,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(formatter(Duration(seconds: start.toInt()))),
                  SizedBox(width: 10),
                  Text(formatter(Duration(seconds: end.toInt()))),
                ]),
              )
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: 10),
        child: TrimSlider(
            child: TrimTimeline(
                controller: _controller, margin: EdgeInsets.only(top: 10)),
            controller: _controller,
            height: height,
            horizontalMargin: height / 4),
      )
    ];
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  // Widget _trimSlider() {
  //   return Container(
  //     child: TrimSlider(
  //       height: 60,
  //         child: TrimTimeline(
  //           controller: _controller,
  //           margin: EdgeInsets.only(top: 10),

  //         ),
  //         controller: _controller,

  //         horizontalMargin: 10),
  //   );
  // }
}
