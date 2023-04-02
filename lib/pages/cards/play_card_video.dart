import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:solstice/utils/constants.dart';
import 'package:video_player/video_player.dart';

class PlayCardVideo extends StatefulWidget {
  final String videoFile;
  String title, description;
  int index;
  PlayCardVideo({this.videoFile, this.title, this.description, this.index});

  @override
  _PlayCardVideoState createState() => _PlayCardVideoState();
}

class _PlayCardVideoState extends State<PlayCardVideo> {
  ChewieController chewieController;
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    initializePlayer(widget.videoFile);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    chewieController.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StatefulBuilder(builder: (BuildContext context, StateSetter st) {
        return Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: chewieController != null
                  ? FittedBox(
                      fit: BoxFit.fitWidth,
                      child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          child: Stack(
                            children: [
                              Chewie(
                                controller: chewieController,
                              ),
                            ],
                          )),
                    )
                  : Container(
                      height: 25,
                      width: 25.0,
                      child: SizedBox(
                        height: 25,
                        width: 25.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                        ),
                      ),
                    ),
            ),
            Container(
              height: 2,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF434344).withOpacity(0.07),
                    spreadRadius: 1,
                    blurRadius: 13,
                    offset: Offset(0, 15), // changes position of shadow
                  ),
                ],
              ),
            ),
            Container(
                height: 90,
                color: Color(0xFFFFFFFF),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 15),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontFamily: "open_saucesans_regular",
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Row(
                        children: [
                          InkWell(
                              onTap: () {},
                              child: Image.asset(Constants.previous,
                                  height: 15, width: 15)),
                          SizedBox(width: 5),
                          InkWell(
                              onTap: () {
                                st(() {
                                  if (chewieController != null &&
                                      chewieController.isPlaying) {
                                    chewieController.pause();
                                  } else {
                                    chewieController.play();
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(10.0),
                                child: Image.asset(
                                    chewieController != null &&
                                            chewieController.isPlaying
                                        ? Constants.pause
                                        : Constants.play,
                                    height: 15,
                                    width: 15),
                              )),
                          SizedBox(width: 5),
                          InkWell(
                              onTap: () {},
                              child: Image.asset(Constants.forward,
                                  height: 15, width: 15)),
                          SizedBox(width: 15),
                        ],
                      ),
                    )
                  ],
                )),
          ],
        ));
      }),
    );
  }

  void showImportBottomSheet() {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter st) {
            return Container(
                child: Column(
              children: [
                Expanded(
                  child: Container(
                      child: Chewie(
                    controller: chewieController,
                  )),
                ),
                Container(
                    height: 90,
                    color: Color(0xFFFFFFFF).withOpacity(0.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  "Bicep Curls",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontFamily: "open_saucesans_regular",
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              SizedBox(height: 10),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Part 2',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: AppColors.greyTextColor,
                                      fontSize: 14.0,
                                      fontFamily: "open_saucesans_regular",
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Row(
                            children: [
                              InkWell(
                                  onTap: () {},
                                  child: Image.asset(Constants.previous,
                                      height: 15, width: 15)),
                              SizedBox(width: 15),
                              InkWell(
                                  onTap: () {
                                    st(() {
                                      if (chewieController != null &&
                                          chewieController.isPlaying) {
                                        chewieController.pause();
                                      } else {
                                        chewieController.play();
                                      }
                                    });
                                  },
                                  child: Image.asset(
                                      chewieController != null &&
                                              chewieController.isPlaying
                                          ? Constants.pause
                                          : Constants.play,
                                      height: 15,
                                      width: 15)),
                              SizedBox(width: 15),
                              InkWell(
                                  onTap: () {},
                                  child: Image.asset(Constants.forward,
                                      height: 15, width: 15)),
                              SizedBox(width: 15),
                            ],
                          ),
                        )
                      ],
                    )),
              ],
            ));
          });
        });
  }

  void disposeController() {
    if (_controller != null) {
      _controller.pause();
    }
    if (chewieController != null) {
      chewieController.pause();
    }
  }

  Future<void> initializePlayer(String videoUrl) async {
    _controller = VideoPlayerController.network(videoUrl);
    await _controller.initialize();
    chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: false,
      allowMuting: false,
      allowFullScreen: false,
      allowPlaybackSpeedChanging: false,
      showControls: false,
      fullScreenByDefault: false,
    );
    setState(() {});

    var totallength = 100;
    var framsesCount = 4;
    var segmentLength = 30;
    int startingPoint = 0;

    // for (startingPoint; startingPoint < totallength; startingPoint++) {
    //   if (lastIndex) {
    //     startingPoint = 30;
    //     totalLength = -30;
    //     if(frames)
    //     for()
    //   }
    // }
  }
}
