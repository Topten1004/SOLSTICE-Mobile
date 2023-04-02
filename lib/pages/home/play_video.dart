import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solstice/utils/constants.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class PlayVideo extends StatefulWidget {
  final String videoUrl;
  PlayVideo({this.videoUrl});

  @override
  _PlayVideoState createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  VideoPlayerController _controller;
  bool showProgress = false;
  ChewieController chewieController;
  // FlickManager flickManager;
  @override
  void initState() {
    super.initState();

    initializePlayer();
  }

  Future<void> initializePlayer() async {
    _controller = VideoPlayerController.network(widget.videoUrl);
    

    await _controller.initialize();

    chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: false,
      allowMuting: true,
      allowFullScreen: true,

      allowPlaybackSpeedChanging: true,
      showControls: true,
      deviceOrientationsOnEnterFullScreen: [DeviceOrientation.landscapeLeft],
      fullScreenByDefault: false,
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
    );
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (_controller != null) {
      _controller.dispose();
    }
    if (chewieController != null) {
      chewieController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(top: 10, left: 8),
                child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
              (chewieController != null)
                  ? Expanded(
                      child: Container(
                          color: Colors.black,
                          child: Chewie(
                            controller: chewieController,
                          )))
                  : Container(
                      color: Colors.black,
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height-130,
                      child: SizedBox(
                        width: 30.0,
                        height: 30.0,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor),
                        ),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
