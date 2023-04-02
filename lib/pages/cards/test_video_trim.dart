import 'dart:collection';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart' as path;
import 'package:solstice/pages/cards/edit_segment.dart';
import 'package:solstice/pages/cards/transitions.dart';
import 'package:solstice/utils/constants.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';

class VideoEditor extends StatefulWidget {
  final List<HashMap<File, File>> selectedVideoFiles;
  VideoEditor({Key key, @required this.file, this.selectedVideoFiles})
      : super(key: key);

  final File file;

  @override
  _VideoEditorState createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;
  double singleFrame = 30;
  double initialFrame = 0.0;
  bool _exported = false;
  String _exportText = "";
  VideoEditorController _controller;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  File exportedFile;
  File videoFile;
  File initialThumb;

  // VideoEditorController newController;
  List<HashMap<File, File>> videoFiles = new List.empty(growable: true);
  List<bool> listSelected = new List.empty(growable: true);

  @override
  void initState() {
    videoFile = File(widget.file.path);
    initializePlayController(0);
    // divideVideoSegments(widget.file);

    // videoFiles.addAll(widget.selectedVideoFiles);

    super.initState();
  }

  disposeController() {
    
    if (videoController != null) {
      videoController.dispose();
      videoController = null;
    }
  }

  initializePlayController(index) {
    _controller = VideoEditorController.file(widget.file,
        maxDuration: Duration(seconds: 30))
      ..initialize().then((_) async {
        final File cover = await _controller.extractCover();
        var videoDuration = _controller.videoDuration.inSeconds;
        double loopIndex = videoDuration / 30;
        String dir = path.dirname(cover.path);
        String newPath = path.join(dir, "Cover_0_" + '$index.jpg');
        File coverNew = await File(cover.path).copy(newPath);

        HashMap<File, File> mapFile = new HashMap();
        mapFile[coverNew] = videoFile;
        initialThumb = coverNew;
        videoFiles.add(mapFile);
        listSelected.add(true);

        for (int i = 0; i < loopIndex - 1; i++) {
          listSelected.add(false);
          HashMap<File, File> mapFileNew = new HashMap();
          String dir = path.dirname(cover.path);
          String newPath = path.join(dir, "Cover_0_$i" + '$index.jpg');
          File coverNewPath = await File(cover.path).copy(newPath);

String dir2 = path.dirname(videoFile.path);
          String newVideoPath = path.join(dir2, "Video_0_$i" + '$index.mp4');
          File videoNewPath = await File(videoFile.path).copy(newVideoPath);

          // String dir = path.dirname(coverNew.path);
          // String newPath = path.join(dir, 'Cover_abc.jpg');
          // coverNew.rename(newPath);
          mapFileNew[coverNewPath] = videoNewPath;
          videoFiles.add(mapFileNew);
        }
        setState(() {});
      });
  }

  Future<File> moveFile(File sourceFile, String newPath) async {
    try {
      // prefer using rename as it is probably faster
      return await sourceFile.rename(newPath);
    } on FileSystemException catch (e) {
      // if rename fails, copy the source file and then delete it
      final newFile = await sourceFile.copy(newPath);
      await sourceFile.delete();
      return newFile;
    }
  }

  Future<void> divideVideoSegments(File file) async {
    // Utilities.show(context);
    // newController =
    //     VideoEditorController.file(file, maxDuration: Duration(seconds: 30))
    //       ..initialize().then((value) {
    //         setState(() {});
    //         var videoDuration = newController.videoDuration.inSeconds;

    //         if (videoDuration > 30) {
    //           double loopIndex = videoDuration / 30;
    //           for (int i = 0; i < loopIndex; i++) {
    //             initialFrame = singleFrame + 1;
    //             singleFrame = videoDuration - singleFrame;
    //             _exportVideo(newController).then((value) async {
    //               File cover = await newController.extractCover();
    //               HashMap<File, File> segmentFile = new HashMap();
    //               segmentFile[cover] = value;
    //               videoFiles.add(segmentFile);
    //               if (i == loopIndex) {
    //                 // Utilities.hide();
    //                 setState(() {
    //                   initializePlayController(0);
    //                 });
    //               }
    //             }).catchError((onError) {
    //               //  Utilities.hide();
    //             });
    //           }
    //         }
    //       });
  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    disposeController();
    super.dispose();
  }

  // void _openCropScreen() => context.to(CropScreen(controller: _controller));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            onPressed: () async {
              disposeController();
              var object = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EditSegmentPage(videoFiles: videoFiles)));
              if (object != null) {
                Navigator.pop(context, {
                  // "numberList": object["numberList"],
                  "mediaList": object["mediaList"],
                  "capture": "No"
                });
              }
            },
          ),
        ],
      ),
      body: videoFiles.length > 0
          ? _controller.initialized
              ? SafeArea(
                  child: Container(
                  child: Column(children: [
                    Container(height: 25, color: AppColors.segmentAppBarColor),
                    Expanded(
                      child: Stack(alignment: Alignment.center, children: [
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
                                child:
                                    Icon(Icons.play_arrow, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    Expanded(
                      child: Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _trimSlider())),
                    ),

                    // ValueListenableBuilder(
                    //   valueListenable: _isExporting,
                    //   builder: (_, bool export, __) => OpacityTransition(
                    //     visible: export,
                    //     child: AlertDialog(
                    //       backgroundColor: Colors.white,
                    //       title: ValueListenableBuilder(
                    //         valueListenable: _exportingProgress,
                    //         builder: (_, double value, __) =>
                    //             TextDesigned(
                    //           "Exporting video ${(value * 100).ceil()}%",
                    //           color: Colors.black,
                    //           bold: true,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // )
                  ]),
                ))
              : Center(child: CircularProgressIndicator())
          : Center(child: CircularProgressIndicator()),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

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
        height: 100,
        width: MediaQuery.of(context).size.width,
        child: TrimSlider(
            // child: TrimTimeline(controller: _controller),
            controller: _controller,
            height: height,
            horizontalMargin: height / 4),
      ),
      Text(
        Constants.adjustDragHandles,
        style: TextStyle(color: AppColors.liteTextColor, fontSize: 12.0),
        textAlign: TextAlign.center,
      ),
      SingleChildScrollView(
        child: Container(
          height: 85,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ListView.builder(
                shrinkWrap: true,
                primary: false,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      // videoFile = videoFiles[index][0];

                      for (int i = 0; i < listSelected.length; i++) {
                        listSelected[i] = false;
                      }

                      listSelected[index] = true;
                      setState(() {});
                    },
                    child: Container(
                        height: 85,
                        width: 85,
                        margin: EdgeInsets.symmetric(horizontal: 7.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 75,
                              width: 75,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  border: Border.all(
                                      width: listSelected[index] ? 3.0 : 2.0,
                                      color: listSelected[index]
                                          ? AppColors.segmentAppBarColor
                                          : AppColors.orangeColor)),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                child: Image.file(
                                  videoFiles[index].keys.elementAt(0),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              child: InkWell(
                                  onTap: () {
                                    videoFiles.removeAt(index);
                                    if (videoFiles.length == 0) {
                                      Navigator.pop(context);
                                    }
                                    setState(() {});
                                  },
                                  child: SvgPicture.asset(Constants.iconCross)),
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
                  listSelected.add(false);
                  videoFiles.add(videoFiles[0]);
                  setState(() {});
                },
                child: Container(
                  width: 60,
                  height: 60,
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
      ),
    ];
  }

  Widget _coverSelection() {
    return Container(
        margin: EdgeInsets.only(top: 10),
        color: Colors.black12,
        child: CoverSelection(
          controller: _controller,
          height: height,
          nbSelection: 8,
        ));
  }

  Future<File> _exportVideo() async {
    //NOTE: To use [-crf 17] and [VideoExportPreset] you need ["min-gpl-lts"] package
    Future.delayed(Duration(milliseconds: 1000));
    exportedFile = await _controller
        .exportVideo(
      preset: VideoExportPreset.medium,
      onProgress: (statics) {
        _exportingProgress.value =
            statics.time / _controller.video.value.duration.inMilliseconds;
      },
    )
        .catchError((onError) {
    }).then((value) {
    });
    _isExporting.value = false;

    if (exportedFile != null) {
      _exportText = "Video success export!";
    } else {
      _exportText = "Error on export video :(";
    }

    setState(() => _exported = true);
    Future.delayed(Duration(milliseconds: 1000));
    return exportedFile;
  }

  Widget _customSnackBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SwipeTransition(
        visible: _exported,
        direction: SwipeDirection.fromBottom,
        child: Container(
          height: height,
          width: double.infinity,
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: Text(
              _exportText,
            ),
          ),
        ),
      ),
    );
  }
}
