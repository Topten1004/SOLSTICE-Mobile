import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solstice/pages/cards/test_video_trim.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/get_permissions.dart';
import 'package:video_player/video_player.dart';

class CardCamera extends StatefulWidget {
  final int mediaType; //1=image, 2=video

  CardCamera({this.mediaType});

  @override
  _CardCameraState createState() => _CardCameraState();
}

class _CardCameraState extends State<CardCamera> with WidgetsBindingObserver {
  CameraController controller;
  bool enableAudio = true;
  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  XFile imageFile;
  XFile videoFile;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  bool isVideoRecording = false;
  bool isVideo = false;
  Timer _timer;
  int _start = 30;
  bool isPlaying = false;
  List<HashMap<File, File>> videoFiles = new List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    isVideo = widget.mediaType == 2;
    // enableAudio = widget.mediaType == 2;

    WidgetsBinding.instance.addObserver(this);
    if (Platform.isIOS) {
      requestCameraPermission();
    } else {
      setCameraDescription();
    }
  }

  requestCameraPermission() async {
    GetImagePermission getPermission = GetImagePermission.camera();
    await getPermission.getPermission(context);
    if (getPermission.granted) {
      GetImagePermission getPermissionMicroPhone =
          GetImagePermission.microphone();
      await getPermissionMicroPhone.getPermission(context);
      if (getPermissionMicroPhone.granted) {
        setCameraDescription();
      }
    }
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    disposeController();
    if (_timer != null) {
      _timer.cancel();
    }

    super.dispose();
  }

  disposeController() {
    if (videoController != null) {
      videoController.pause();
      videoController.dispose();
      videoController = null;
    }
    if (controller != null) {
      controller.dispose();
      controller = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final CameraController cameraController = controller;

    // // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // setCameraDescription();
      if (cameraController != null) {
        onNewCameraSelected(cameraController.description);
      }
    }
  }

  void setCameraDescription() {
    CameraDescription description = CameraDescription(
        name: "0",
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90);
    onNewCameraSelected(description);
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.low,
      enableAudio: enableAudio,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {
      }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  void logError(String code, String message) {
    if (message != null) {
    } else {
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((XFile file) {
      if (mounted) {
        setState(() {
          imageFile = file;
          videoController?.dispose();
          videoController = null;
        });
        if (file != null) showInSnackBar('Picture saved to ${file.path}');
      }
    });
  }

  Future<XFile> takePicture() async {
    final CameraController cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light));
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: AppColors.blueColor,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 10.0,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: SvgPicture.asset(
                        "assets/images/arrow_left.svg",
                        width: 30.0,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            Constants.addVideo,
                            style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            Constants.addVideoInstr,
                            style: TextStyle(
                                fontSize: 11.0,
                                color: AppColors.textColor,
                                fontWeight: FontWeight.w400),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
                child: Container(
              color: Colors.black,
              child: videoFile != null
                  ? videoFileUI()
                  : Stack(fit: StackFit.expand, children: [
                      _cameraPreviewWidget(),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          height: 100,
                          width: MediaQuery.of(context).size.width,
                          color: Color(0X222222AB).withAlpha(67),
                          padding: EdgeInsets.all(20.0),
                          child: Stack(
                            children: [
                              InkWell(
                                onTap: () async {
                                  var videoGalleryFile = await ImagePicker()
                                      .pickVideo(source: ImageSource.gallery);
                                  if (videoGalleryFile != null) {
                                    videoFile =
                                        new XFile(videoGalleryFile.path);
                                    videoController = VideoPlayerController
                                        .file(File(videoFile.path))
                                      ..initialize().then((value) {
                                        videoController.play();
                                        isPlaying = true;
                                      });

                                    setState(() {});
                                  }
                                },
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        Constants.galleryAddIcon,
                                        height: 28,
                                        width: 28,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          Constants.gallery,
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    if (!isVideo) {
                                      onTakePictureButtonPressed();
                                    }
                                  },
                                  onScaleEnd: (onScaleEndDetail) {
                                    if (isVideo) {
                                      if (isVideoRecording) {
                                        isVideoRecording = false;
                                        onStopButtonPressed();
                                      }
                                    }
                                  },
                                  onScaleStart: (onScaleStardDetail) {
                                  },
                                  onScaleUpdate: (onScaleUpdate) {
                                  },
                                  onTapDown: (onTapDownDetail) {
                                    if (isVideo) {
                                      if (!isVideoRecording) {
                                        isVideoRecording = true;

                                        onVideoRecordButtonPressed();
                                      }
                                    }
                                  },
                                  onTapUp: (onTapUpDetail) {
                                    if (isVideoRecording) {
                                      isVideoRecording = false;
                                      onStopButtonPressed();
                                    }
                                  },
                                  child: SvgPicture.asset(
                                    Constants.captureIcon,
                                    color: isVideoRecording
                                        ? Colors.red
                                        : Colors.white,
                                    height: isVideoRecording ? 90 : 60,
                                    width: isVideoRecording ? 90 : 60,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  '00:$_start',
                                  style: TextStyle(
                                      fontSize: 12.0, color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ]),
            )),
          ],
        ),
      ),
    );
  }

  Widget videoFileUI() {
    return InkWell(
      onTap: () {
        if (isPlaying) {
          _stopVideoPlayer();
        } else {
          _startVideoPlayer();
        }
        isPlaying = !isPlaying;
      },
      child: Stack(
        children: [
         if(videoController!=null) Container(
            child: Center(
              child: AspectRatio(
                  aspectRatio: videoController.value.size != null
                      ? videoController.value.aspectRatio
                      : 1.0,
                  child: VideoPlayer(videoController)),
            ),
          ),
          Center(
            child: SvgPicture.asset(Constants.playIcon),
          ),
          Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        videoFile = null;
                        if (videoController != null) {
                          videoController.pause();
                          // videoController.dispose();
                        }
                        setState(() {});
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                            color: Colors.white,
                          ),
                          child: Text(
                            Constants.discard,
                            style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        disposeController();

                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => VideoEditor(file: File(videoFile.path),selectedVideoFiles: videoFiles,)));
                        var object = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VideoEditor(
                                      selectedVideoFiles: videoFiles,
                                      file: File(videoFile.path),
                                    )));
                        if (object != null) {
                          if (object["capture"] == "Yes") {
                            // videoFiles.addAll(object["videoList"]);
                            if (videoController != null) {
                              videoController.play();
                            }
                            videoFile = null;
                            setState(() {});
                          } else {
                            Navigator.pop(context, {
                              // "numberList": object["numberList"],
                              "mediaList": object["mediaList"]
                            });
                          }
                        }
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                            color: AppColors.cardTextColor,
                          ),
                          child: Row(
                            children: [
                              Text(
                                Constants.next,
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                              Icon(Icons.arrow_forward, color: Colors.white)
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }

  void onVideoRecordButtonPressed() {
    _start = 30;
    startTimer();
    startVideoRecording().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  void onStopButtonPressed() {
    _timer.cancel();
    stopVideoRecording().then((file) {
      if (mounted) setState(() {});
      if (file != null) {
        // showInSnackBar('Video recorded to ${file.path}');
        videoFile = file;
        videoController = VideoPlayerController.file(File(videoFile.path));
        // _startVideoPlayer();
      }
    });
  }

  void _stopVideoPlayer() {
    if (videoController != null) {
      videoController.pause();
    }
  }

  Future<void> _startVideoPlayer() async {
    if (videoFile == null) {
      return;
    }

    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController.removeListener(videoPlayerListener);
      }
    };
    videoController.addListener(videoPlayerListener);
    await videoController.setLooping(false);
    await videoController.initialize();

    if (mounted) {
      setState(() {
        imageFile = null;
      });
    }
    await videoController.play();
  }

  Future<XFile> stopVideoRecording() async {
    final CameraController cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return Container();
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          controller,
        ),
      );
    }
  }
}
