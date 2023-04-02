import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:solstice/pages/cards/edit_segment.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class NFTSegment extends StatefulWidget {
  final String videoUrl ;

  NFTSegment({Key key, this.videoUrl});

  _NFTSegmentState createState() => _NFTSegmentState() ;
}

class _NFTSegmentState extends State<NFTSegment> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>() ;

  bool _isFullScreen = false ;
  List<String> images = new List<String>.empty(growable: true);

  VideoPlayerController _controller;
  ChewieController chewieController;

  double videoContainerRatio = 0.5;

  int currentDurationInSecond = 0;
  int _minTwoDigitValue = 10;

  double _maxVideoLength = 0.0 ;

  bool keepAlive = true;
  @override
  bool get wantKeepAlive => keepAlive;

  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    if (chewieController == null) {
      initializePlayer(widget.videoUrl);
    }

    images.add("assets/images/swiper1.png") ;
    images.add("assets/images/swiper2.png") ;
    images.add("assets/images/swiper1.png") ;

    _controller.addListener(
          () => setState(() => currentDurationInSecond = _controller.value.position.inMilliseconds),
    );
  }

  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    if (chewieController != null) {
      chewieController.dispose();
    }
    super.dispose();
  }

  Future<void> initializePlayer(String videoUrl) async {
    _controller = VideoPlayerController.network(videoUrl);
    await _controller.initialize();

    setState(() {
      _maxVideoLength = _controller.value.duration.inMilliseconds.toDouble();
      print("_maxVideoLength$_maxVideoLength") ;
    });

    chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: true,
      allowMuting: true,
      allowFullScreen: false,
      allowPlaybackSpeedChanging: false,
      showControls: false,
      fullScreenByDefault: false,
    );
  }

  String checkTimer(){
    Duration duration = Duration(milliseconds: currentDurationInSecond.round());

    String nowTime = [duration.inHours, duration.inMinutes, duration.inSeconds]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':');

    return nowTime ;
  }

  Widget videoWidget() {
      return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return Container(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 120,
                    color: Colors.black,
                    child: Stack(
                      children: [
                        Chewie(controller: chewieController),
                        Positioned(
                          left: 10,
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width - 20,
                          child: Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  stops: [
                                    0.30,
                                    0.95,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Color(0xFF0f0f0f).withOpacity(0.9),
                                    Color(0xFF919191).withOpacity(0.2),
                                  ],
                                )
                            ),
                          ),
                        ),
                        Positioned(
                            width: MediaQuery.of(context).size.width,
                            top : 0,
                            child : Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        // width: groupWidth ?? 150,
                                        height: 100,
                                        margin: EdgeInsets.only(left : 20, right : 20),
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: 3,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return Align(
                                              widthFactor: 0.5,
                                              child: CircleAvatar(
                                                radius : 18,
                                                child: CircleAvatar(
                                                    radius: 18,
                                                    backgroundImage: AssetImage(images[index])
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Container(
                                          child : Text(
                                              "View all 23 Owners",
                                              style : TextStyle(
                                                  color : Colors.white
                                              )
                                          )
                                      )
                                    ],
                                  ),
                                  IconButton(icon: Icon(Icons.bookmark_add_outlined , color: Colors.white, size: 30),
                                      onPressed: () {

                                      })
                                ],
                              ),
                            )
                        ),
                        Positioned(
                            bottom: 60,
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(left : 20),
                                      child:
                                      IconButton(icon: Icon(chewieController.isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline , color: Colors.white, size: 30),
                                          onPressed: () {
                                            setState(() {
                                              if(chewieController.isPlaying)  {
                                                chewieController.pause();
                                              }
                                              else {
                                                chewieController.play();
                                              }
                                            });
                                          })
                                  ),
                                  Container(
                                      width : MediaQuery.of(context).size.width - 150,
                                      child: SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                            trackHeight: 0.8,
                                            thumbColor: Colors.transparent,
                                            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0.0)
                                        ),
                                        child: Slider(
                                          value: currentDurationInSecond.toDouble(),
                                          min: 0,
                                          max: _maxVideoLength,
                                          activeColor: Color(0xFF71CD9D),
                                          inactiveColor: Colors.white54,
                                          onChanged: (val) {
                                            setState(() {
                                              currentDurationInSecond = val.toInt() ;
                                              chewieController.seekTo(Duration(milliseconds: val.round())) ;
                                            });
                                          },
                                        ),
                                      )
                                  ),
                                  Container(
                                    child: Text(
                                      checkTimer(),
                                      style: TextStyle(
                                        color : Colors.white
                                      ),
                                    ),
                                  )
                                ]
                            )
                        ),
                        Positioned(
                            bottom: 20,
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(left: 20),
                                      child : Row(
                                        children: [
                                          IconButton(icon: Icon(Icons.splitscreen_outlined , color: Colors.white, size: 30),
                                              onPressed: () {

                                              }),
                                          IconButton(icon: Icon(CupertinoIcons.add_circled , color: Colors.white, size: 30),
                                              onPressed: () {

                                              })
                                        ],
                                      )
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(right : 20),
                                    child: IconButton(icon: Icon(CupertinoIcons.viewfinder , color: Colors.white, size: 30), onPressed: () {
                                      setState(() {
                                      });
                                    }),
                                  )
                                ]
                            )
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      });
  }

  Widget build(BuildContext context) {
    var appBar = AppBar(
      backgroundColor: Colors.black,
      title: Center(
        child: Text(
          "< NFT Product Name >",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
        // onPressed: () {},
        onPressed: () => Navigator.of(context).pop(),
      ),
      elevation: 0,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: appBar,
      key : _scaffoldKey,
      body :
        SingleChildScrollView(
            child: Column(
              children: [
                chewieController == null
                    ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 100,
                    child: Center(
                      child: SpinKitWave(color: Colors.white, type: SpinKitWaveType.start),
                    )
                )
                    :  videoWidget(),
              ],
            )
        )
    );
  }
}