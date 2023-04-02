import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:algolia/algolia.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:rxdart/subjects.dart';
import 'package:solstice/pages/cards/create_card.dart';
import 'package:solstice/pages/chat/firebase_chat_screen.dart';
import 'package:solstice/pages/feeds/routine_detail.dart';
import 'package:solstice/pages/forums/forums_details_screen.dart';
import 'package:solstice/pages/groups/group_details_screen.dart';
import 'package:solstice/pages/home/post_detail_screen.dart';
import 'package:solstice/pages/home_screen.dart';
import 'package:solstice/pages/login_register_fb/login_fb.dart';
import 'package:solstice/pages/login_register_fb/register_fb.dart';
import 'package:solstice/pages/new_login_register/about_you_screen_new.dart';
import 'package:solstice/pages/onboardingflow/welcomeScreen.dart';
import 'package:solstice/pages/profile/followers_listing_new_screen.dart';
import 'package:solstice/pages/profile/other_user_profile.dart';
import 'package:solstice/pages/profile/profile_setting_screen.dart';
import 'package:solstice/pages/register_login/otp_verification.dart';
import 'package:solstice/pages/routine/create_routine.dart';
import 'package:solstice/pages/routine/routine_name.dart';
import 'package:solstice/utils/constants.dart';
import 'package:solstice/utils/screen_utils.dart';
import 'package:solstice/utils/share_service.dart';
import 'package:solstice/utils/shared_preferences.dart';

List<CameraDescription> cameras = [];

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();

const MethodChannel platform = MethodChannel('dexterx.dev/flutter_local_notifications_example');

class ReceivedNotification {
  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

String selectedNotificationPayload;

var routes = <String, WidgetBuilder>{
  "/Welcome": (BuildContext context) => WelcomeScreen(),
  "/Login": (BuildContext context) => LoginFbScreen(),
  "/Register": (BuildContext context) => RegisterFbScreen(),
  "/AboutYouScreen": (BuildContext context) => AboutYouNewScreen(),
  "/Home": (BuildContext context) => HomeScreen(
        currentIndex: 0,
      ),
  "/ProfileSettingScreen": (BuildContext context) => ProfileSettingScreen(),
  "/OtpVerification": (BuildContext context) => OtpVerficationScreen(
        openFromLogin: false,
      ),
  "/GroupDetailsScreen": (BuildContext context) => GroupDetailsScreen(),
  "/FollowersListingScreen": (BuildContext context) => FollowersListingNewScreen(),
};

Future<void> _firebaseMessagingBackgroundHandler() async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call initializeApp before using other Firebase services.
  await Firebase.initializeApp();
  //print('Handling a background message ${message.messageId}');
}

class Application {
  static final Algolia algolia = Algolia.init(
    applicationId: Constants.appId,
    apiKey: Constants.ApiKey,
  );
}

// and to test that runZonedGuarded() catches the error
//const _kShouldTestAsyncErrorOnInit = false;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");
  String token = "";
  bool isLoggedIn = false;

  bool isProfileSetup = false;

  LatLng currentLatLng;
  Position currentLocation;

  User _firebaseUser;
  // firebase notification

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile> _sharedFiles;
  String _sharedText;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    initFirebaseNotification();
    //_configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
    _getFirebaseUser();

    getPrefData();
    // initializeNotification();
    retrieveLink();

    // Create the share service
    // ShareService()
    //   ..onDataReceived = _handleSharedData
    //   ..getSharedData().then(_handleSharedData);
  }

  /// Handles any shared data we may receive.
  void _handleSharedData(String sharedData) {
    setState(() {
      _sharedText = sharedData;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("in resume");
      retrieveLink();
    }
  }

  void retrieveLink() async {
    await Future.delayed(Duration(seconds: 3));
    final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;
    if (deepLink != null && Platform.isAndroid) {
      // print("IN getInitialLink METHOD.......");
      // myController.passUri(deepLink);
      // newVoicesCallback.passUriNewVoice(deepLink);
      // this.deepLink = deepLink;
        final queryParams = deepLink.queryParameters;

      print("IN getInitialLink METHOD.DEEP ANDROID LINK...... $deepLink");
       if (queryParams.length > 0) {
          var feedId = queryParams['feedId'];

          print("feedId... " + feedId);
          if (feedId != null && feedId.isNotEmpty) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => RoutineDetail(null, null, true, feedId)));
          }
        }
        print("IN ON LINK METHOD.DEEP LINK...... $deepLink");
    }
    FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;
      if (deepLink != null) {
        // print("IN ON LINK METHOD.......");
        // myController.passUri(deepLink);
        // newVoicesCallback.passUriNewVoice(deepLink);
        // this.deepLink = deepLink;
        final queryParams = deepLink.queryParameters;
        print("queryParams... " + queryParams.length.toString());

        if (queryParams.length > 0) {
          var feedId = queryParams['feedId'];

          print("feedId... " + feedId);
          if (feedId != null && feedId.isNotEmpty) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => RoutineDetail(null, null, true, feedId)));
          }
        }
        print("IN ON LINK METHOD.DEEP LINK IOS...... $deepLink");
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  getPrefData() {
    Future<bool> status = SharedPref.getBool(Constants.LOGINSTATUS);
    status.then((value) => {isLoggedIn = value, print("Splash value status::: $value")},
        onError: (err) {
      print("Error occured :: $err");
    });
    Future<String> userId = SharedPref.getStringFromPrefs(Constants.USER_ID);
    userId.then((value) => {globalUserId = value, print("Splash value userId ::: $value")},
        onError: (err) {
      print("Error occured :: $err");
    });
    Future<String> userName = SharedPref.getStringFromPrefs(Constants.USER_NAME);
    userName.then((value) => {globalUserName = value, print("Splash value userName::: $value")},
        onError: (err) {
      print("Error occured :: $err");
    });
    Future<dynamic> completeProfile = SharedPref.getIntFromPrefs(Constants.PROFILE_COMEPLETE);
    completeProfile.then(
        (value) => {profileCompleteStatus = value, print("Splash value completeProfile::: $value")},
        onError: (err) {
      print("Error occured :: $err");
      profileCompleteStatus = 0;
    });
    Future<String> profileImage = SharedPref.getStringFromPrefs(Constants.PROFILE_IMAGE);
    profileImage.then(
        (value) => {globaUserProfileImage = value, print("Splash value profileImage::: $value")},
        onError: (err) {
      print("Error occured :: $err");
    });

    setState(() {});

    // function to check data shared by other apps.
    checkSharedData();
  }

  void checkSharedData() {
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
        // if (_sharedText != null && _sharedText != "") {
        //   navigateToCreateCard(_sharedText);
        // }
        print("Shared:" + (_sharedFiles?.map((f) => f.path).join(",") ?? ""));
      });
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
        // if (_sharedText != null && _sharedText != "") {
        //   navigateToCreateCard(_sharedText);
        // }
        print("Shared:" + (_sharedFiles?.map((f) => f.path).join(",") ?? ""));
      });
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        _sharedText = value;
        if (_sharedText != null && _sharedText != "") {
          if(!_sharedText.contains("https://solsticeapp.page.link/")){
          navigateToCreateCard(_sharedText);
          }
        }
        print("Shared: $_sharedText");
      });
    }, onError: (err) {
      print("getLinkStream error: $err");
    });
    ReceiveSharingIntent.getInitialText().then((String value) {
      setState(() {
        _sharedText = value;
        if (_sharedText != null && _sharedText != "") {
          if(!_sharedText.contains("https://solsticeapp.page.link/")){
          navigateToCreateCard(_sharedText);
          }
        }
        print("Shared: $_sharedText");
      });
    });
  }

  void navigateToCreateCard(String dataToShare) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreateRoutineName(
                  sharedData: dataToShare,
                )));
  }

  @override
  void dispose() {
    // _connectivitySubscription.cancel();
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  Future<void> _getFirebaseUser() async {
    this._firebaseUser = await FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      print("payload On click $payload");
      //String payloadData = json.encode(payload);

      var response = json.decode(payload) as Map;

      print("payload On click1 $response");

      if (response != null) {
        goToChatFromLocalNotification(response);
      }

      /*if(payload == "BOOKING"){
 this.navigatorKey.currentState.pushAndRemoveUntil(
  MaterialPageRoute(builder: (context) => BookingScreen()),
   (Route<dynamic> route) => false,
   );
 }*/
    });
  }

  void goToChatFromLocalNotification(Map payloadData) {
    try {
      print('payloadData $payloadData');
      if (payloadData['type'] == 'follow') {
        print('payloadData ${payloadData['type']}');
        navigatorKey.currentState.push(
          MaterialPageRoute(
            builder: (_) => OtherUserProfile(
              userID: payloadData['userId'],
              userName: payloadData['userName'],
              userImage: payloadData['userImage'],
            ),
          ),
        );
      }
      if (payloadData['type'] == 'savePostToStitchRoutine' ||
          payloadData['type'] == "likePost" ||
          payloadData['type'] == "commentPost") {
        navigatorKey.currentState.push(
          MaterialPageRoute(
            builder: (_) => PostDetailScreen(postIdIntent: payloadData['postId']),
          ),
        );
      }

      if (payloadData['type'] == 'likeForum' || payloadData['type'] == "commentForum") {
        navigatorKey.currentState.push(
          MaterialPageRoute(
            builder: (_) => ForumsDetailsScreen(forumIdIntent: payloadData['forumId']),
          ),
        );
      }

      if (payloadData['type'] == 'message') {
        navigatorKey.currentState.push(
          MaterialPageRoute(
            builder: (_) => ChatFirebase(
              receiverIdIntent: payloadData['senderId'],
              chatRoomIdIntent: payloadData['chatRoomId'],
            ),
          ),
        );
      }
    } catch (e) {
      print("payload click error $e");
    }

    /*try{
      ChatRoomModel chatRoomModel = new ChatRoomModel();
      chatRoomModel.senderId = payloadData["receiverId"];
      chatRoomModel.senderName = payloadData["receiverName"];
      chatRoomModel.senderImage = payloadData["receiverImage"];
      chatRoomModel.chatRoomId = payloadData["chatRoomId"];
      chatRoomModel.receiverId = payloadData["senderId"];
      chatRoomModel.receiverName = payloadData["senderName"];
      chatRoomModel.receiverImage = payloadData["senderImage"];
      chatRoomModel.groupId = payloadData["groupId"];
      chatRoomModel.groupName = payloadData["groupName"];
      chatRoomModel.groupImage = payloadData["groupImage"];
      chatRoomModel.dietitianId = payloadData["dietitianId"];
      chatRoomModel.dietitianName = payloadData["dietitianName"];
      globals.chatRoomModel = chatRoomModel;
      print("data>>${jsonEncode(chatRoomModel)}");
      navigatorKey.currentState.push(
        MaterialPageRoute(builder: (_) => ChatFirebase(
          chatRoomModelIntent: globals.chatRoomModel,
        )),
      );
    }catch(e){
      print("onNotificationClickError: $e");

    }*/
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            SizeConfig().init(constraints, orientation);
            return MaterialApp(
              // return MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,

              title: "Solstice",
              home: isLoggedIn
                  ? HomeScreen(
                      currentIndex: 0,
                    )
                  : WelcomeScreen(),

              theme: ThemeData(
                  unselectedWidgetColor: AppColors.appGreyColor[700],
                  accentColor: AppColors.accentColor,
                  cursorColor: AppColors.primaryColor,
                  primaryColor: AppColors.primaryColor,
                  primaryColorBrightness: Brightness.dark,
                  errorColor: Colors.redAccent,
                  fontFamily: Constants.openSauceFont
                  // canvasColor: Colors.transparent,
                  ),

              routes: routes,
            );
          },
        );
      },
    );
  }

  void initFirebaseNotification() {
    // _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("onMessage: $message");
    //     // showNotification(message);

    //     try {
    //       final type = message['data']['type'] ?? "";
    //       if (type == "message") {
    //         final chatRoomId = message['data']['chatRoomId'] ?? "";
    //         if (chatRoomId != globalCurrentChatRoomId) {
    //           final image = message['data']['image'] ?? "";
    //           if (image != null && image != "") {
    //             _showBigPictureNotification(message);
    //           } else {
    //             showNotification(message);
    //           }
    //         }
    //       } else {
    //         final image = message['data']['image'] ?? "";
    //         if (image != null && image != "") {
    //           _showBigPictureNotification(message);
    //         } else {
    //           showNotification(message);
    //         }
    //       }
    //     } catch (e) {
    //       print("onMessage error: $message");
    //     }
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("onLaunch: $message");

    //     try {
    //       String data = json.encode(message['data']);
    //       var payloadMap = json.decode(data) as Map;
    //       if (payloadMap != null) {
    //         goToChatFromLocalNotification(payloadMap);
    //       }

    //       /*String payloadData = json.encode(message['data']);
    //       if(payloadData != null && payloadData != "null" && payloadData != ""){
    //         goToChatFromNotification(payloadData);
    //       }*/
    //     } catch (e) {
    //       print("onLaunch: $e");
    //     }

    //     // _navigateToItemDetail(message);
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     try {
    //       String data = json.encode(message['data']);
    //       print('message $message');

    //       var payloadMap = json.decode(data) as Map;
    //       print('payloadMap $payloadMap');
    //       if (payloadMap != null) {
    //         goToChatFromLocalNotification(payloadMap);
    //       }
    //     } catch (e) {
    //       print("onResume: $e");
    //     }
    //     //_navigateToItemDetail(message);
    //   },
    // );

    // if (Platform.isIOS) {
    //   _requestPermissions();
    // }
  }

  void _requestPermissions() {
    // _firebaseMessaging.requestNotificationPermissions(
    //     const IosNotificationSettings(
    //         sound: true, badge: true, alert: true, provisional: true));
    // _firebaseMessaging.onIosSettingsRegistered
    //     .listen((IosNotificationSettings settings) {
    //   print("Settings registered: $settings");
    // });

    /* flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        .requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>()
        .requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );*/
  }

  showNotification(Map<String, dynamic> message) async {
    final title = message['notification']['title'] ?? '';
    final body = message['notification']['body'] ?? '';
    //final image = message['notification']['image'] ?? '';
    final payloadData = message['data'] ?? '';
    //String senderId = message['data']['senderId'] ?? '0';
    //int notificationId = int.parse(senderId);

    var android = new AndroidNotificationDetails('id', 'channel ', 'description',
        priority: Priority.high, importance: Importance.max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(0, title, body, platform,
        payload: payloadData.toString());
  }

  Future<void> _showBigPictureNotification(Map<String, dynamic> message) async {
    final title = message['notification']['title'] ?? '';
    final body = message['notification']['body'] ?? '';
    final image = message['data']['image'] ?? '';
    //String senderId = message['data']['senderId'] ?? '0';
    //int notificationId = int.parse(senderId);
    //final roomId = message['data']['chatRoomId'] ?? '0';
    //final payloadData = message['data'] ?? '';
    String payloadData = json.encode(message['data']);

    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicturePath),
        largeIcon: FilePathAndroidBitmap(largeIconPath),
        contentTitle: title,
        htmlFormatContentTitle: true,
        summaryText: body,
        htmlFormatSummaryText: true);
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'big text channel id', 'big text channel name', 'big text channel description',
        styleInformation: bigPictureStyleInformation);

    var iOSChannelSpecifics = IOSNotificationDetails();
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, title, body, platformChannelSpecifics,
        payload: payloadData);
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  cameras = await availableCameras();
  setNotification();
// Disable persistence on web platforms
  //await FirebaseAuth.instance.setPersistence(Persistence.NONE);

  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  FirebaseCrashlytics.instance.sendUnsentReports();

  runZonedGuarded(() {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyApp(),
      ),
    );
  }, FirebaseCrashlytics.instance.recordError);

//   runZonedGuarded(() {
//     runApp(MyApp());
//   }, FirebaseCrashlytics.instance.recordError);
  configLoading();
}

setNotification() async {
  final NotificationAppLaunchDetails notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload = notificationAppLaunchDetails.payload;
    print("notificationClick");
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (int id, String title, String body, String payload) async {
        didReceiveLocalNotificationSubject
            .add(ReceivedNotification(id: id, title: title, body: body, payload: payload));
      });
  const MacOSInitializationSettings initializationSettingsMacOS = MacOSInitializationSettings(
      requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false);
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    selectedNotificationPayload = payload;
    selectNotificationSubject.add(payload);
  });
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.blue
    ..backgroundColor = Colors.blue
    ..indicatorColor = Colors.blue
    ..textColor = Colors.blue
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true;
}
