import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/dialog_callback.dart';

class Utilities {
  static void show(BuildContext context) {
    Loader.show(
      context,
      //isAppbarOverlay: true,
      //isBottomBarOverlay: true,
      progressIndicator: const CircularProgressIndicator(),
      themeData: Theme.of(context)
          .copyWith(accentColor: AppColors.defaultAppColor[500]),
      overlayColor: const Color(0x99E8EAF6),
    );
  }

  static var httpClient = new HttpClient();
  static Future<File> downloadFile(String url, String filename) async {
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  static void hide() {
    Loader.hide();
  }

  static String getMessageTime(Timestamp timestamp) {
    var now = Timestamp.now().toDate();
    var format = DateFormat('hh:mm a');
    var formatDate = DateFormat('dd MMM yyyy');

    print('date ${timestamp.toDate()}');
    var diff = now.difference(timestamp.toDate());
    var time = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(timestamp.toDate());
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' d';
      } else {
        time = diff.inDays.toString() + ' d';
      }
    } else {
      if (diff.inDays == 7) {
        time = (diff.inDays / 7).floor().toString() + ' w';
      } else {
        time = formatDate.format(timestamp.toDate());
      }
    }

    return time;
  }

  static String timeAgoSinceDate(Timestamp dateString,
      {bool numericDates = true}) {
    final date2 = DateTime.now();
    final difference = date2.difference(dateString.toDate());

    if (difference.inDays > 8) {
      return DateFormat('dd/MM/yyyy').format(dateString.toDate());
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1week' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1d ago' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours}h ago';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1h ago' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1 min' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds}s';
    } else {
      return 'Just now';
    }
  }

  static void confirmDeleteDialog(context, String title, String message,
      DialogCallBack dialogCallBack, int code) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            child: Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 30),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: AppColors.viewLineColor)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        margin: EdgeInsets.only(top: 62, right: 30, left: 30),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: Constants.mediumFont,
                              fontSize: ScreenUtil().setSp(36)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 12, right: 30, left: 30),
                        alignment: Alignment.center,
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.blackColor[100],
                              fontFamily: Constants.regularFont,
                              fontSize: ScreenUtil().setSp(28)),
                        ),
                      ),
                      SizedBox(
                        height: 100.0,
                        width: 200,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                                child: GestureDetector(
                              onTap: () {
                                // Navigator.pop(context, true);
                              },
                              child: Container(
                                color: Colors.transparent,
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: 42,
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(
                                          color: AppColors.redColor)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    // Navigator.pop(context);
                                  },
                                  color: AppColors.redColor,
                                  textColor: Colors.white,
                                  padding: EdgeInsets.all(4.0),
                                  child: Text("No",
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontFamily: 'rubikregular')),
                                ),
                              ),
                            )),
                            SizedBox(
                              width: 40,
                            ),
                            Expanded(
                                child: GestureDetector(
                              onTap: () {
                                // Navigator.pop(context, true);
                              },
                              child: Container(
                                color: Colors.transparent,
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: 42,
                                child: FlatButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(
                                          color: AppColors.redColor)),
                                  color: Colors.white,
                                  textColor: AppColors.redColor,
                                  padding: EdgeInsets.all(4.0),
                                  onPressed: () {
                                    Navigator.of(context).pop();

                                    //deleteForumFromDb();
                                    dialogCallBack.onOkClick(code);
                                  },
                                  child: Text(
                                    "Yes",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: 'rubikregular',
                                    ),
                                  ),
                                ),
                              ),
                            )),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.topCenter,
                  height: 100,
                  child: Container(
                    alignment: Alignment.center,
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: new Image.asset(
                      'assets/images/ic_question_green.png',
                      width: 45.0,
                      color: AppColors.redColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
