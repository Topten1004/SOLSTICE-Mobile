import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
// import 'package:video_trimmer/video_trimmer.dart';

class VideoTrimmer extends StatefulWidget {
  final File videoFile;
  VideoTrimmer({this.videoFile});

  @override
  _VideoTrimmerState createState() => _VideoTrimmerState();
}

class _VideoTrimmerState extends State<VideoTrimmer> {
  // final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;
  String newVideoPath = "";

  Future<String> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    String _value;

    // // await _trimmer
    // //     .saveTrimmedVideo(
    // //   startValue: _startValue,
    // //   endValue: _endValue,
    // //   // customVideoFormat: '.MOV',
    // //   // outputFormat: FileFormat.mov,
    // //   // storageDir: StorageDir.temporaryDirectory
    // // )
    // //     .then((value) {
    //   setState(() {
    //     _progressVisibility = false;
    //     _value = value;
    //   });
    // });

    return _value;
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

  void _loadVideo() {
    
    // _trimmer.loadVideo(videoFile: widget.videoFile);
    final bytes = widget.videoFile.lengthSync();
    final kb = bytes / 1024;
    final mb = kb / 1024;
  }

  @override
  void initState() {
    super.initState();

    _loadVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            Visibility(
              visible: _progressVisibility,
              child: LinearProgressIndicator(
                backgroundColor: Colors.red,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: RaisedButton(
                elevation: 2.0,
                onPressed: _progressVisibility
                    ? null
                    : () async {
                        _saveVideo().then((outputPath) async {
                          Navigator.pop(context, {"videoPath": outputPath});
                        });
                      },
                child: Text(
                  "Continue",
                  style: TextStyle(fontSize: 14.0, color: Colors.black),
                ),
                color: Colors.white,
              ),
            ),
            // Expanded(
            //   child:
            //       Container(height: 200, child: VideoViewer(trimmer: _trimmer)),
            // ),
            // Center(
            //   child: TrimEditor(
            //     trimmer: _trimmer,
            //     circleSize: 15.0,
            //     viewerHeight: 50.0,
            //     fit: BoxFit.cover,
            //     viewerWidth: MediaQuery.of(context).size.width,
            //     // maxVideoLength: Duration(seconds: 180),
            //     circlePaintColor: Colors.amber,

            //     onChangeStart: (value) {
            //       _startValue = value;
            //     },
            //     onChangeEnd: (value) {
            //       _endValue = value;
            //     },
            //     onChangePlaybackState: (value) {
            //       setState(() {
            //         _isPlaying = value;
            //       });
            //     },
            //   ),
            // ),
            TextButton(
              child: _isPlaying
                  ? Icon(
                      Icons.pause,
                      size: 80.0,
                      color: Colors.white,
                    )
                  : Icon(
                      Icons.play_arrow,
                      size: 80.0,
                      color: Colors.white,
                    ),
              onPressed: () async {
                // bool playbackState = await _trimmer.videPlaybackControl(
                //   startValue: _startValue,
                //   endValue: _endValue,
                // );
                // setState(() {
                //   _isPlaying = playbackState;
                // });
              },
            )
          ],
        ),
      ),
    );
  }

  // get video thumbnail
  getThumbnail(File videofile) async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: videofile.path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxWidth: 384,
      // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 100,
    );

    return fileName;
  }

  void moveFileToNewPath(String outputPath, String newVideoPath) {
    // moveFile(File(outputPath), newVideoPath).then((value) {
    getThumbnail(File(outputPath)).then((value) async {

      // Directory tempDir = await getTemporaryDirectory();
      // String tempPath = tempDir.path;
      // var filePath = tempPath +
      //     '/${DateTime.now().millisecondsSinceEpoch.toString()}.jpeg';
      // file_01.tmp is dump file, can be anything
      // await File(filePath).writeAsBytes(value).then((thumbFile) {

      //   Navigator.pop(context, {"videoPath": outputPath});
      // });
    });
    // });
  }
}
