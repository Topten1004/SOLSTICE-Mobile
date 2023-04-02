import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:solstice/apiservice/api_call.dart';
import 'package:solstice/apiservice/url_string.dart';
import 'package:solstice/pages/chat/full_image_screen.dart';
import 'package:solstice/utils/constants.dart';

class ChatFirebase extends StatelessWidget {
  final String receiverIdIntent;
  final String chatRoomIdIntent;
  ChatFirebase(
      {Key key,
      @required this.receiverIdIntent,
      @required this.chatRoomIdIntent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatScreen(
          receiverIdIntent: receiverIdIntent,
          chatRoomIdIntent: chatRoomIdIntent),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String receiverIdIntent;
  final String chatRoomIdIntent;

  ChatScreen(
      {Key key,
      @required this.receiverIdIntent,
      @required this.chatRoomIdIntent})
      : super(key: key);

  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({
    Key key,
  });

  String chatRoomId = "";
  String receiverId = "";
  String senderId = "";
  String receiverName = "";
  String receiverImage = "";

  String receiverFBToken = "";

  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  int _limit = 30;
  int _limitIncrement = 30;
  bool _isShowCamera = true;

  File _selectedImageFile;
  String _selectedImageUrl = "";
  String tokenPref = "";
  bool _isShowLoader = false;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  // Scroll listner for chat history list
  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  // get data from previous screen and process in current screen
  void setIntentData() {
    senderId = globalUserId;

    if (widget.chatRoomIdIntent != null) {
      chatRoomId = widget.chatRoomIdIntent;
      globalCurrentChatRoomId = chatRoomId;
    }

    if (widget.receiverIdIntent != null) {
      receiverId = widget.receiverIdIntent;
      //updateChatData();
      updateChatCount();
      getReceiverFbToken(receiverId);
    }
  }

  @override
  void dispose() {
    globalCurrentChatRoomId = "";

    super.dispose();
  }

  // get Receiver firebase Token
  Future<String> getReceiverFbToken(String reciverId) async {
    FirebaseFirestore.instance
        .collection(Constants.UsersFB)
        .doc(reciverId)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      Map<String, dynamic> mapObject = documentSnapshot.data();
      if (mounted) {
        setState(() {
          try {
            if (mapObject.containsKey("token")) {
              receiverFBToken = documentSnapshot['token'];
            }

            receiverName = documentSnapshot['userName'];
            receiverImage = documentSnapshot['userImage'];
          } catch (e) {}
        });
      }
    }).onError((e) => print(e));
  }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    setIntentData();
    //isLoading = false;
    _selectedImageUrl = '';

    readLocal();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        //isShowSticker = false;
      });
    }
  }

  readLocal() async {
    setState(() {});
  }

  // on send button hit data to firestore. if type is 1 its image msg otherwise its text msg
  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.text = "";
      _isShowCamera = true;

      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(chatRoomId)
          .collection(chatRoomId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      updateChatUnseenCount(content, type);

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': senderId,
            'idTo': receiverId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });

      sendPushNotification(content, type);

      try {
        listScrollController.animateTo(0.0,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      } catch (e) {}
    }
  }

  void sendPushNotification(content, int type) {
    var dataPayload = jsonEncode({
      'to': receiverFBToken,
      'data': {
        "type": "message",
        "priority": "high",
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "sound": "default",
        "senderId": senderId,
        "chatRoomId": chatRoomId,
        'image': type == 1 ? content : globaUserProfileImage,
      },
      'notification': {
        'title': globalUserName + " send you a message",
        'body': type == 1 ? "Image" : content,
        'image': type == 1 ? content : globaUserProfileImage,
        "badge": "1",
        "sound": "default"
      },
    });

    ApiCall.sendPushMessage(receiverFBToken, dataPayload);
  }

  Future<void> updateChatUnseenCount(String content, int type) async {
    /*var a = await Firestore.instance.collection(Constants.ChatsFB).doc(chatRoomId).collection(chatRoomId).doc(receiverId).get();
    if(a.exists){
      Firestore.instance.collection(Constants.ChatsFB).doc(chatRoomId).collection(chatRoomId).doc(receiverId).update({'unSeenCount': FieldValue.increment(1),'isSeen':false});
      //return a;
    }
    if(!a.exists){
      Firestore.instance.collection(Constants.ChatsFB).doc(chatRoomId).collection(chatRoomId).doc(receiverId).set({'unSeenCount': 0,'isSeen':true});
     // return null;
    }


    if(senderId != globalUserId){
      Firestore.instance.collection(Constants.ChatsFB).doc(chatRoomId).update({'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),'content': content, 'type': type,'idFrom': senderId,'unSeenCount': FieldValue.increment(1),'isSeen':false});
    }else{
      Firestore.instance.collection(Constants.ChatsFB).doc(chatRoomId).update({'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),'content': content, 'type': type,'idFrom': senderId,});
    }*/

    List<String> userList = new List<String>();
    userList.add(globalUserId);
    userList.add(receiverId);

    var a = await FirebaseFirestore.instance
        .collection(Constants.ChatsFB)
        .doc(chatRoomId)
        .get();
    if (a.exists) {
      FirebaseFirestore.instance
          .collection(Constants.ChatsFB)
          .doc(chatRoomId)
          .set({
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'lastMsg': content,
        'msgType': type,
        'msgFrom': senderId,
        "msgTo": receiverId,
        'unSeenCount': {
          receiverId: FieldValue.increment(1),
        }
      }, SetOptions(merge: true));
      //return a;
    }
    if (!a.exists) {
      FirebaseFirestore.instance
          .collection(Constants.ChatsFB)
          .doc(chatRoomId)
          .set({
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'lastMsg': content,
        'msgType': type,
        'msgFrom': senderId,
        "msgTo": receiverId,
        'users': userList,
        'unSeenCount': {
          senderId: 0,
          receiverId: FieldValue.increment(1),
        }
      });
      // return null;
    }

    if (mounted) setState(() {});
  }

  String constructFCMPayload(String token) {
    return jsonEncode({
      'token': token,
      'data': {
        'via': 'FlutterFire Cloud Messaging!!!',
        'count': 1.toString(),
      },
      'notification': {
        'title': 'Hello FlutterFire!',
        'body': 'This notification (#$token) was created via FCM!',
      },
    });
  }

  // show data badge in chat history l
  Widget dateLayout(DocumentSnapshot document) {
    Map<String, dynamic> mapObject = document.data();
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(top: 18.0, bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: 0.8,
              color: AppColors.receiverMsgColor,
            ),
            Container(
              padding: EdgeInsets.all(3),
              constraints: new BoxConstraints(
                minWidth: 75.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16)),
                color: AppColors.receiverMsgColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding:
                        EdgeInsets.only(left: 6, top: 3, bottom: 3, right: 6),
                    child: Text(
                      setFormattedDate(mapObject['timestamp']),
                      style: TextStyle(
                          fontFamily: Constants.regularFont, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  static String setFormattedDate(String timeStampValue) {
    int timestamp = 0;
    if (timeStampValue != null &&
        timeStampValue != "null" &&
        timeStampValue != "") {
      timestamp = int.parse(timeStampValue);
    }

    var finalFormatedDate = '';
    var format = DateFormat('dd.MM.yyyy');
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp /** 1000*/);
    finalFormatedDate = format.format(date);

    final now = DateTime.now().toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    //final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final aDate = DateTime(date.year, date.month, date.day);
    if (aDate == today) {
      finalFormatedDate = "TODAY" /*"היום"*/;
    } else if (aDate == yesterday) {
      finalFormatedDate = "YESTERDAY" /*"אתמול"*/;
    }
    /*else {
      finalFormatedDate = dateFormated;
    }*/
    return finalFormatedDate;
  }

  // if msg is image. then user can click on it and open full image
  Future _onImageClick(
      String messageFromId, String imageUrl, String msgTimeStamp) async {
    String msgFromNameFinal =
        messageFromId == globalUserId ? "You" : receiverName;

    Map results = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      //return ObjectiveSelectionUserScreen(logDataIntent : logData,logDateIntent : selectedDate,objectiveCountIntent :objectivesCount);
      return fullImageScreenView(
          messageFromName: msgFromNameFinal,
          messageTime: msgTimeStamp,
          imageIntent: imageUrl);
    }));

    if (results != null && results.containsKey('update')) {}
  }

  bool checkLastIndexBedge(int index) {
    if ((listMessage != null && listMessage.length > 0) &&
        (index + 1) == listMessage.length) {
      return true;
    } else {
      return false;
    }
  }

  // change server datatime to local formatted time
  String getDateFromServerDate(String timeStampValue) {
    int timestamp = 0;
    if (timeStampValue != null &&
        timeStampValue != "null" &&
        timeStampValue != "") {
      timestamp = int.parse(timeStampValue);
    }
    var finalFormatedDate = '';
    var now = DateTime.now();
    var format = DateFormat('dd.MM.yyyy');
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    finalFormatedDate = format.format(date);
    return finalFormatedDate;
  }

  Future<bool> onBackPress() {
    Navigator.pop(context);

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: ModalProgressHUD(
        inAsyncCall: _isShowLoader,
        // demo of some additional parameters
        opacity: 0.6,
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        ),
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: SafeArea(
            child: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(color: Colors.white),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // List of messages
                    Expanded(
                      flex: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(ScreenUtil().setSp(16)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                setState(() {
                                  onBackPress();
                                });
                              },
                              child: Container(
                                  width: 22,
                                  height: 22,
                                  padding: EdgeInsets.all(2.5),
                                  margin: EdgeInsets.only(left: 10, right: 18),
                                  child: SvgPicture.asset(
                                    'assets/images/ic_back.svg',
                                    alignment: Alignment.center,
                                    fit: BoxFit.contain,
                                  )),
                            ),
                            CachedNetworkImage(
                              imageUrl: (receiverImage.contains("https:") ||
                                      receiverImage.contains("http:"))
                                  ? receiverImage
                                  : UrlConstant.BaseUrlImg + receiverImage,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                width: ScreenUtil().setSp(70),
                                height: ScreenUtil().setSp(70),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50.0)),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) =>
                                  setUserDefaultCircularImage(),
                              errorWidget: (context, url, error) =>
                                  setUserDefaultCircularImage(),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.all(ScreenUtil().setSp(12)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      receiverName != null
                                          ? " " + receiverName
                                          : "",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: AppColors.titleTextColor,
                                          fontFamily: Constants.boldFont,
                                          fontSize: ScreenUtil().setSp(28)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    buildListMessage(),

                    // Input content
                    buildInput(),
                  ],
                ),

                // Loading
                // buildLoading()
              ],
            ),
          ),
        ),
      ),
      onWillPop: onBackPress,
    );
  }

  // set user default placeholder
  setUserDefaultCircularImage() {
    return Container(
      width: ScreenUtil().setSp(70),
      height: ScreenUtil().setSp(70),
      child: SvgPicture.asset(
        'assets/images/ic_male_placeholder.svg',
        width: ScreenUtil().setSp(70),
        height: ScreenUtil().setSp(70),
        fit: BoxFit.fill,
      ),
    );
  }

  // add message input layout
  Widget buildInput() {
    return Expanded(
      flex: 0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(
            left: ScreenUtil().setSp(16),
            right: ScreenUtil().setSp(16),
            top: ScreenUtil().setSp(10),
            bottom: ScreenUtil().setSp(10)),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              offset: Offset(1.0, 0.0), //(x,y)
              blurRadius: 5.0,
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _isShowCamera == true
                    ? GestureDetector(
                        onTap: () {
                          bottomSheetforImage();
                        },
                        child: Container(
                          padding: EdgeInsets.all(2),
                          margin: EdgeInsets.only(left: 6),
                          width: 26,
                          height: 26,
                          child: Icon(
                            Icons.photo_camera,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                        ),
                      )
                    : Container(),
                Container(width: ScreenUtil().setSp(20)),
                Expanded(
                  flex: 1,
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 200),
                    child: TextFormField(
                      maxLength: 1200,
                      //focusNode: _commentEtFocus,
                      cursorColor: AppColors.primaryColor,
                      controller: textEditingController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,

                      onChanged: (v) {
                        setState(() {
                          if (textEditingController.value.text.isEmpty ||
                              textEditingController.text == "") {
                            _isShowCamera = true;
                          } else {
                            _isShowCamera = false;
                          }
                        });
                      },
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: "Type a message...",
                        hintStyle: TextStyle(
                            color: AppColors.accentColor,
                            fontFamily: Constants.mediumFont,
                            fontSize: ScreenUtil().setSp(24)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    var msg = textEditingController.text.trim();

                    if (msg.isNotEmpty) {
                      onSendMessage(msg, 0);
                    }

                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: Container(
                    width: 22,
                    height: 22,
                    padding: EdgeInsets.all(1.0),
                    margin: EdgeInsets.only(right: 10, left: 10),
                    child: SvgPicture.asset(
                      'assets/images/ic_send.svg',
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // bottom sheet for select image from camera and gallery
  bottomSheetforImage() {
    showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.whiteColor[400],
        elevation: 4.0,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text(
                    "Select From",
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: Constants.mediumFont,
                        fontSize: 18.0),
                  ),
                ),
                ListTile(
                  onTap: () {
                    getImage(ImageSource.camera);
                    Navigator.of(context).pop(context);
                  },
                  /*leading: Icon(
                    Icons.camera,
                    color: AppColors.appGreyColor[400],
                    size: Dimens.iconSize06(),
                  ),*/
                  title: Text(
                    "Camera",
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: Constants.regularFont,
                        fontSize: 16.0),
                  ),
                ),
                ListTile(
                  onTap: () {
                    getImage(ImageSource.gallery);
                    Navigator.of(context).pop(context);
                  },
                  /*leading: Icon(
                    Icons.photo,
                    color: AppColors.appGreyColor[400],
                    size: Dimens.iconSize06(),
                  ),*/
                  title: Text(
                    "Gallery",
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: Constants.regularFont,
                        fontSize: 16.0),
                  ),
                ),
                /*Container(
                  margin: EdgeInsets.all(Dimens.height15()),
                  width: SizeConfig.screenWidth,
                  child: imageButton(),
                ),*/
              ],
            ),
          );
        });
  }

  // get image path from crop lib
  getImage(ImageSource source) async {
    XFile image = await ImagePicker().pickImage(source: source);
    File cropped = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
        maxHeight: 700,
        maxWidth: 700,
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: AndroidUiSettings(
          toolbarColor: AppColors.whiteColor[500],
          toolbarTitle: "Crop image",
          backgroundColor: AppColors.whiteColor[500],
        ));
    setState(() {
      if (cropped != null) {
        _selectedImageFile = cropped;
        //_selectedImageUrl = _selectedImageFile.path.toString();
        _isShowLoader = true;
        uploadMsgImage();
      } else {
        //_selectedImageUrl = image.path.toString();
      }
    });
  }

  // upload file to firebase storage
  Future<void> uploadMsgImage() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var reference =
        FirebaseStorage.instance.ref().child("chatImages").child(fileName);
    UploadTask uploadTask = reference.putFile(_selectedImageFile);

    uploadTask.whenComplete(() {
      reference.getDownloadURL().then((downloadUrl) {
        _selectedImageUrl = downloadUrl;
        setState(() {
          _isShowLoader = false;
          onSendMessage(_selectedImageUrl, 1);
        });
      });
    }).catchError((onError) {
      setState(() {
        _isShowLoader = false;
      });
      Constants().errorToast(context, "This file is not an image");
    }).onError((error, stackTrace) {
      setState(() {
        _isShowLoader = false;
      });
      Constants().errorToast(context, "This file is not an image");
    });
  }

  // build message items with type basis
  Widget buildListMessage() {
    return Flexible(
      child: chatRoomId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryColor)))
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(chatRoomId)
                  .collection(chatRoomId)
                  .orderBy('timestamp', descending: true)
                  .limit(_limit)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor)));
                } else {
                  listMessage.clear();
                  listMessage.addAll(snapshot.data.docs);
                  //updateChatCount();
                  return snapshot.data.docs.isNotEmpty
                      ? ListView.builder(
                          padding: EdgeInsets.only(top: 6, bottom: 10),
                          itemBuilder: (context, index) => chatItem(
                              index,
                              snapshot.data.docs[index],
                              (index < snapshot.data.docs.length - 1 &&
                                      index >= 0)
                                  ? snapshot.data.docs[index + 1]
                                  : null),
                          itemCount: snapshot.data.docs.length,
                          reverse: true,
                          controller: listScrollController,
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                'assets/images/ic_chat_unactive.png',
                                width: ScreenUtil().setSp(100),
                                height: ScreenUtil().setSp(100),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "No chat found!!\nType a message to start a chat",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(26),
                                    color: AppColors.accentColor,
                                    fontFamily: Constants.regularFont,
                                    height: 1.3,
                                    letterSpacing: 0.8),
                              ),
                            ],
                          ),
                        );
                }
              },
            ),
    );
  }

  Future<void> updateChatCount() async {
    FirebaseFirestore.instance
        .collection(Constants.ChatsFB)
        .doc(chatRoomId)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      if (mounted) {
        Map<String, dynamic> mapObject = documentSnapshot.data();
        if (documentSnapshot.exists && mapObject.containsKey("unSeenCount")) {
          try {
            int unseenCount = documentSnapshot['unSeenCount'][globalUserId];
            if (unseenCount > 0) {
              Future.delayed(const Duration(milliseconds: 200), () {
                FirebaseFirestore.instance
                    .collection(Constants.ChatsFB)
                    .doc(chatRoomId)
                    .set({
                  'unSeenCount': {
                    globalUserId: 0,
                  }
                }, SetOptions(merge: true));
                if (mounted) setState(() {});
              });
            }
          } catch (e) {}

          if (mounted) {
            setState(() {});
          }
        }
      }
    });
  }

  Widget chatItem(
      int index, DocumentSnapshot document, DocumentSnapshot nextDocument) {
    Map<String, dynamic> mapObject = document.data();
    Map<String, dynamic> nextMapObject = nextDocument!=null ? nextDocument.data() : null;
    if (mapObject['idFrom'] == senderId) {
      // Right (my message)
      return Container(
        child: Column(
          children: <Widget>[
            /*((nextDocument != null && getDateFromServerDate(nextDocument.data()['timestamp']) !=
                getDateFromServerDate(document.data()['timestamp'])) ? dateLayout(document) : Container() ),
*/

            ((nextDocument != null &&
                    getDateFromServerDate(nextMapObject['timestamp']) !=
                        getDateFromServerDate(nextMapObject['timestamp']))
                ? dateLayout(document)
                : checkLastIndexBedge(index)
                    ? dateLayout(document)
                    : Container()),
            Row(
              children: <Widget>[
                mapObject['type'] == 0
                    // Text
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(
                                  left: 75, right: 16.0, top: 2.0),
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(26)),
                                color: AppColors.primaryColor,
                              ),
                              // margin: const EdgeInsets.only(left: 10.0),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 14, top: 8, bottom: 8, right: 14),
                                child: Text(
                                  mapObject['content'],
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: Constants.regularFont,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  bottom: 2, left: 16, right: 16, top: 1),
                              child: Text(
                                getMsgTime(mapObject['timestamp']),
                                style: TextStyle(
                                    fontFamily: Constants.regularFont,
                                    fontSize: 10,
                                    color: AppColors.mediumGrey),
                              ),
                            ),
                          ],
                        ))
                    : mapObject['type'] == 1
                        // Image
                        ? Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 75, right: 16.0, top: 2.0),
                                  child: FlatButton(
                                    child: Material(
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            Container(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    AppColors.primaryColor),
                                          ),
                                          width: 135,
                                          height: 140,
                                          padding: EdgeInsets.all(70.0),
                                          decoration: BoxDecoration(
                                            color: AppColors.viewLineColor,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20.0),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          width: 135,
                                          height: 140,
                                          padding: EdgeInsets.all(70.0),
                                          decoration: BoxDecoration(
                                            color: AppColors.viewLineColor,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20.0),
                                            ),
                                          ),
                                        ),
                                        imageUrl: mapObject['content'],
                                        width: 135,
                                        height: 140,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0)),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                    onPressed: () {
                                      _onImageClick(
                                          mapObject['idFrom'],
                                          mapObject['content'],
                                          mapObject['timestamp']);
                                    },
                                    padding: EdgeInsets.all(0),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      bottom: 2, left: 16, right: 16, top: 1),
                                  child: Text(
                                    getMsgTime(mapObject['timestamp']),
                                    style: TextStyle(
                                        fontFamily: Constants.regularFont,
                                        fontSize: 10,
                                        color: AppColors.mediumGrey),
                                  ),
                                ),
                              ],
                            ),
                            //margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                          )
                        // Sticker
                        : Container(),
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),
          ],
        ),
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            /*((nextDocument != null && getDateFromServerDate(nextDocument.data()['timestamp']) ==
                getDateFromServerDate(document.data()['timestamp'])) ? Container() : dateLayout(document) ),*/

            ((nextDocument != null &&
                    getDateFromServerDate(nextMapObject['timestamp']) !=
                        getDateFromServerDate(mapObject['timestamp']))
                ? dateLayout(document)
                : checkLastIndexBedge(index)
                    ? dateLayout(document)
                    : Container()),
            Row(
              children: <Widget>[
                mapObject['type'] == 0
                    //text
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(3),
                              margin: EdgeInsets.only(
                                  right: 75, left: 16.0, top: 2.0),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(26)),
                                color: AppColors.receiverMsgColor,
                              ),
                              child: Stack(children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 14, top: 8, bottom: 8, right: 14),
                                  child: Text(
                                    mapObject['content'] /*+"\n\n $index"*/,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontFamily: Constants.regularFont,
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  bottom: 2, left: 16, right: 16, top: 1),
                              child: Text(
                                getMsgTime(mapObject['timestamp']),
                                style: TextStyle(
                                    fontFamily: Constants.regularFont,
                                    fontSize: 10,
                                    color: AppColors.mediumGrey),
                              ),
                            ),
                          ],
                        ),
                      )
                    : mapObject['type'] == 1
                        ? Container(
                            //image

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  padding:
                                      EdgeInsets.only(right: 16.0, top: 2.0),
                                  child: FlatButton(
                                    child: Material(
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            Container(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    AppColors.primaryColor),
                                          ),
                                          width: 135,
                                          height: 140,
                                          padding: EdgeInsets.all(70.0),
                                          decoration: BoxDecoration(
                                            color: AppColors.viewLineColor,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20.0),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          width: 135,
                                          height: 140,
                                          padding: EdgeInsets.all(70.0),
                                          decoration: BoxDecoration(
                                            color: AppColors.viewLineColor,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20.0),
                                            ),
                                          ),
                                        ),
                                        imageUrl: mapObject['content'],
                                        width: 135,
                                        height: 140,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0)),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                    onPressed: () {
                                      _onImageClick(
                                          mapObject['idFrom'],
                                          mapObject['content'],
                                          mapObject['timestamp']);
                                    },
                                    padding: EdgeInsets.all(0),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      bottom: 2, right: 16, top: 1),
                                  child: Text(
                                    getMsgTime(mapObject['timestamp']),
                                    style: TextStyle(
                                        fontFamily: Constants.regularFont,
                                        fontSize: 10,
                                        color: AppColors.mediumGrey),
                                  ),
                                ),
                              ],
                            ),
                            margin: EdgeInsets.only(left: 10.0),
                          )
                        : Container(),
              ],
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      );
    }
  }

  static String getMsgTime(String timeStampValue) {
    int timestamp = 0;
    if (timeStampValue != null &&
        timeStampValue != "null" &&
        timeStampValue != "") {
      timestamp = int.parse(timeStampValue);
    }
    var time = '';
    var now = DateTime.now();
    var format = DateFormat('HH:mm');
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp /* * 1000*/);
    var diff = now.difference(date);
    time = format.format(date);

    return time;
  }
}
