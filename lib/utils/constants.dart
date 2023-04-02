import 'dart:ui';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:solstice/utils/size_utils.dart';

class Constants {
  //algolia
  static const String appId = "6JEP1L3I8Z";
  static const String ApiKey = "e70a2feee080c6308f0c2364440ce3d3";
  static const String postIndex = "Posts";
  static const String stitchIndex = "Stitches";
  static const String routineIndex = "Routines";
  static const String userIndex = "Users";
  static const String forumsIndex = "Forums";
  static const String groupsIndex = "Groups";

  static const String userImages = "userImages";
  static const String finish = "Finish";

  //images path
  static const String assetsPath = "assets/images/";
  static const String crossIcon = assetsPath + "cross_icon.svg";
  static const String redCrossIcon = assetsPath + "red_cross_icon.svg";
  static const String checkIcon = assetsPath + "check_icon.svg";
  static const String rightArrow = assetsPath + "next_arrow.svg";
  static String publicIcon = assetsPath + "globe.png";
  static String privateIcon = assetsPath + "lock_icon.png";
  static String captureIcon = assetsPath + "capture_icon.svg";
  static String galleryAddIcon = assetsPath + "gallery_add.svg";
  static String playIcon = assetsPath + "play_icon.svg";
  static String iconCross = assetsPath + "icon_cross.svg";
  static String searchIcon = assetsPath + "search_icon.svg";
  static String addIcon = assetsPath + "add_icon.svg";
  static String eyeIcon = assetsPath + "eye_icon.svg";
  static String shareIcon = assetsPath + "share_icon.svg";
  static String saveIcon = assetsPath + "download_icon.svg";
  static String downArrow = assetsPath + "down_arrow.svg";
  static String upArrow = assetsPath + "up_arrow.svg";
  static String tempImage = assetsPath + "temp_image.png";
  static String playBlueIcon = assetsPath + "play_blue_icon.svg";
  static String pauseIcon = assetsPath + "pause_icon.png";
  static String imageIcon = assetsPath + "Image.png";
  static String videoIcon = assetsPath + "video.png";
  static String rightArrowIcon = assetsPath + "right_arrow.svg";
  static String staticCardImage = assetsPath + "static_card_image.png";
  static String icDownload = assetsPath + "ic_download.png";
  static String addCircleIcon = assetsPath + "add_circle.png";
  static String circleCheckIcon = assetsPath + "circle_check.png";
  static String anonymoustUserImage =
      "https://console.firebase.google.com/project/solstice-d447d/storage/solstice-d447d.appspot.com/files/depositphotos_199564354-stock-illustration-creative-vector-illustration-default-avatar.jpeg";
  static String import = assetsPath + "import.png";
  static String drag = assetsPath + "drag.png";
  static String forward = assetsPath + "forward.png";
  static String previous = assetsPath + "previous.png";
  static String pause = assetsPath + "pause.png";
  static String play = assetsPath + "play.png";
  static String expandIcon = assetsPath + "expand_icon.png";
  static String collapseIcon = assetsPath + "collapse_icon.png";
  static String menu = assetsPath + "menu.png";
  static String menu_card = assetsPath + "menu_card.png";
  static String numbers = assetsPath + "numbers.png";
  static String demoPic = assetsPath + "demo_pic.png";
  static String cardVideo = assetsPath + "card_video.png";
  static String greenTick = assetsPath + "green_tick.png";
  static String groupIcon = assetsPath + "group_icon.png";
  static String solsFeedIcon = assetsPath + "sols_feed.png";
  static String uncheckIcon = assetsPath + "uncheck_icon.png";
  static String bodyImage = assetsPath + "body_image.png";
  static String menuIcon = assetsPath + "menu_icon.png";
  static String bodyPartsIcon = assetsPath + "body_parts.png";
  static String editIcon = assetsPath + "edit_icon.png";
  static String selectedSectionImage = assetsPath + "selected.png";
  static String unselectedSectionImage = assetsPath + "unselected.png";
  static String backGround = assetsPath + "background.png";
  static String solsticeImage = assetsPath + "solsticeImage.png";
  static String welcomeBG = assetsPath + "welcomebg.png";
  static String uncheckBox = assetsPath + "uncheck_box.png";
  static String welcomeBgNew = assetsPath + "sp.png";
  static String welcomeBgFile = assetsPath + "welcome_bg.png";
  static String reSharedIcon = assetsPath + "re_shared.png";
  static String chatIcon = assetsPath + "chat.png";
  static String youtubeIcon = assetsPath + "youtube.png";
  static String twitterIcon = assetsPath + "twitter.png";
  static String instagramIcon = assetsPath + "instagram.png";
  static String tiktokIcon = assetsPath + "tiktok.png";

  // Firebase add card keys
  static const String sectionColl = "Sections";
  static const String goalsColl = "Goals";
  static const String bodyPartsColl = "BodyParts";
  static const String movementTypeColl = "MovementType";
  static const String sportActivitiesColl = "SportsActivities";
  static const String equipmentColl = "Equipments";
  static const String cardImagesFolder = "cardImages";
  static const String cardVideosFolder = "cardVideos";
  static const String nutritionColl = "MovementNutrition";
  static const String stitchImagesFolder = "stitchImages";
  static const String routineImagesFolder = "routineImages";
  static const String stitchCollection = "Stitches";
  static const String routineCollection = "Routines";
  static const String forumsCollection = "Forums";
  static const String cardTitles = "CardTitles";
  static const String cardDescriptions = "CardDescriptions";
  static const String subCategory = "Sub Category";
  static const String category = "Category";
  static const String tools = "Tools";
  static const String importK = "Import";
  static const String addExerciseTitleHint = "Add Exercise Title...";
  static const String chooseDescription = "Choose Description";
  static const String chooseTitle = "Choose Title";
  static const String trainingCategories = "TrainingCategories";
  static const String trainingSubCategories = "TrainingSubCategory";
  static const String importWorkout = "Import Workout";
  static const String routineFeedCollection = "RoutineFeed";
  static const String numberK = "Numbers";
  static const String profileInComplete =
      "Your profile is incomplete! Solstice relies on your profile’s information to tailor specific content for you.";
  static const String completeProfile = "Complete My Profile";

  // Filter post
  static const String goal = "Goal";
  static const String bodyParts = "Body Parts";
  static const String movementType = "Movement type";
  static const String sportActivity = "Sport/Activity";
  static const String equipmentPI = "Equipment/Products/ingredients";
  static const String link = "Corresponding Website";
  static const String movementOrNutrition = "Movement or nutrition";
  static const String sendFilter = "Send";
  static const String people = "People";
  static const String applyFilter = "Apply Filter";
  static const String selectBodyParts = "Select Body Parts";
  static const String submit = "Submit";

  // Filter Group
  static const String specify = "Specify";
  static const String interestGoals = "Interest/goals";
  static const String admins = "Admins";
  static const String location = "Location";
  static const String healthWellness = "Health/wellness";
  static const String websiteLink = "Website Link";
  static const String sponsorsPartners = "Sponsors/Partners";
  static const String teamMembers = "Team Members";
  static const String achievementsCertifications = "Achievements/Certifications";

  //About You
  static const String share = "Share";
  static const String occupation = "Occupation(s)";
  static const String activeInjuries = "Active Injuries";
  static const String previousInjuries = "Previous Injuries";
  static const String coachesInstructors = "Coaches/Instructors";
  static const String skipForNow = "skipForNow";

  static const String LOGINSTATUS = "is_logged_in";
  static const String getStarted = "Get Started!";
  static const String welcomeBack = "Welcome\nBack!";
  static const String letsGetStarted = "Let's Get\nStarted!";
  static const String donotHaveAnAccount = "Don’t have an account?";
  static const String alreadyHaveAccount = "Already have account?";
  static const String didnotReceiveCode = "Didn't receive the code?";
  static const String show = "Show";
  static const String hide = "Hide";
  static const String enterValidUserNameError = "Enter valid username";
  static const String login = "Log In";
  static const String signup = "Sign Up";
  static const String username = "Username";
  static const String otp_verification = "OTP Verification";
  static const String password = "Password";
  static const String email = "Email";
  static const String enterUserNameError = "Enter username";
  static const String enterEmailError = "Enter email";
  static const String enterValidEmailError = "Enter valid email";
  static const String enterPasswordError = "Enter password";
  static const String enterValidPasswordError = "Enter valid password";
  static const String otpVerification = "OTP\nVerification!";
  static const String verifiedOtp = "Verify OTP";
  static const String cancel = "Cancel";
  static const String doneText = "Done";
  static const String forgotPassword = "Forgot Password?";
  static const String phoneVerification = "Phone Verification";
  static const String phoneNumber = "Phone Number";
  static const String enterPhoneError = "Enter phone number";
  static const String enterValidPhoneError = "Enter valid phone";
  static const String sendCode = "Send Code";
  static const String resend = "Resend";
  static const String feed = "Feeds";
  static const String buckets = "Buckets";
  static const String stitch = "Stitch";
  static const String group = "Group";
  static const String forum = "Forum";
  static const String update = "Update";
  static const String recent = "Recent";
  static const String trending = "Trending";
  static const String save = "Save";
  static const String saved = "Saved";
  static const String postJourney = "New Post";
  static const String createGroup = "Create Group";
  static const String createPost = "Create Post";
  static const String createStitch = "Create Stitch";
  static const String createRoutine = "Create Routine";
  static const String createForum = "Create Forum";
  static const String uploadPhoto = "Upload Photo";
  static const String title = "Title";
  static const String describeYourJourney = "Description";
  static const String locationOptional = "Location (optional)";
  static const String selectLocation = "Select Location";
  static const String continueTxt = "Continue";
  static const String enterTitleError = "Enter title";
  static const String enterNameError = "Enter name";
  static const String enterDescriptionError = "Enter description";
  static const String nameMust4Characters = "Name must have minimum 4 characters";
  static const String titleMust4Characters = "Title must have minimum 4 characters";
  static const String gTitleMust4Characters = "Title must have minimum 4 characters";
  static const String gDesMust4Characters = "Description must have minimum 4 characters";
  static const String enterJourneyError = "Enter your description";
  static const String enterGroupDescription = "Enter group description";
  static const String journeyMust4Characters = "Description must have minimum 4 characters";
  static const String minimum4Character = "Enter atleast 4 characters";
  static const String addACard = "Add a Card";
  static const String addCard = "Add Card";
  static const String cardID = "Card ID";
  static const String cardName = "Card Name";
  static const String enterCardIDError = "Enter Card ID";
  static const String enterCardNameError = "Enter card name";
  static const String addMoreCards = "Add more cards";
  static const String seeDetailCards = " See Detail Cards";
  static const String hideDetailCards = "Hide Detail Cards";
  static const String addAComment = "add a comment";
  static const String comments = "Comments";
  static const String comment = "Comment";
  static const String likes = "Likes";
  static const String like = "Like";
  static const String profileSettings = "Profile Settings";
  static const String profile = "Profile";
  static const String changeUserName = "Change Username";
  static const String changeEmail = "Change Email";
  static const String changePassword = "Change Password";
  static const String helpCenter = "Help Center";
  static const String privacyPolicy = "Privacy Policy";
  static const String privacyType = "Privacy Type";
  static const String customerCare = "Customer Care";
  static const String logOut = "Log Out";
  static const String appVersion = "App Version";
  static const String imageFileError = "Please select image";
  static const String enterCommentError = "Enter comment";
  static const String updateForum = "Update Forum";
  static const String updatePost = "Update Post";
  static const String deletePost = "Delete Post";
  static const String deleteForum = "Delete Forum";

  static const String updateGroup = "Update Group";
  static const String deleteGroup = "Delete Group";
  static const String deleteStitch = "Delete Stitch";
  static const String deleteRoutine = "Delete Routine";
  static const String deleteCard = "Delete Card";
  static const String delete = "Delete";
  static const String joinGroup = "Join Group";
  static const String leaveGroup = "Leave Group";
  static const String filterPost = "Filter Post";
  static const String deleteForumConfirmDes =
      "Are you sure you want to delete this forum permanently?";

  static const String deletePostConfirmDes =
      "Are you sure you want to delete this post permanently?";

  static const String deleteStitchConfirmDes =
      "Are you sure you want to delete this stitch permanently?";

  static const String deleteRoutineConfirmDes =
      "Are you sure you want to delete this routine permanently?";

  static const String deleteCardConfirmDes =
      "Are you sure you want to delete this card permanently?";

  static const String deleteGroupConfirmDes =
      "Are you sure you want to delete this group permanently?";
  static const String leaveGroupConfirmDes =
      "Are you sure you want to leave this group permanently?";

  // fonts
  static const String boldFont = "epilogue_bold";
  static const String semiBoldFont = "epilogue_semibold";
  static const String mediumFont = "epilogue_medium";
  static const String regularFont = "epilogue_regular";
  static const String lightFont = "epilogue_light";
  static const String openSauceFont = "open_saucesans_regular";
  static const String fontSfPro = "SFProText";
  static const String fontInter = "Inter";

  //Posts
  static const String posts = "Posts";
  static const String cardsColl = "Cards";
  static const String feedsColl = "Feeds";
  static const String settingsCollec = "GeneralSettings";

  static const String addRecipient = "Add Recipient";
  static const String verify = "Verify";
  static const String yourEmail = "Your Email";
  static const String message = "Message";
  static const String files = "Files";
  static const String selectFiles = "Select Files";
  static const String uploadNewFile = "Upload New Files";
  static const String send = "Send";
  static const String download = "Download";
  static const String close = "Close";
  static const String recipients = "Recipients";
  static const String camera = "Camera";
  static const String videos = "Videos";
  static const String photos = "Photos";
  static const String docs = "Documents";
  static const String folders = "Folders";
  static const String record = "Record";
  static const String uploadSuccessfully = "Upload Successfully!";
  static const String yourDownloadStarted = "Your Download Started.";
  static const String copyLink = "Copy Link";
  static const String settings = "Settings";
  static const String sent = "Sent";
  static const String received = "Received";
  static const String skipLogin = "Skip Login";
  static const String noInternet = "Please check your internet connection!";
  static const String unauthorized = "Unauthorized";
  static const String requestTimeout = "Request expired";
  static const String badRequest = "Bad Request";
  static const String noDataFound = "No data found!";
  static const String noCommentFound = "No comment found!";

  static const String deleteForumConfirmTitle = "Delete Forum";

  static const String USER_ID = "user_id";

  static const String USER_NAME = "user_name";
  static const String PROFILE_COMEPLETE = "profile_complete";
  static const String LAST_NAME = "last_name";
  static const String PHONE_NO = "phone_no";
  static const String COUNTRY_CODE = "country_code";

  static const String IS_REGISTER_SCREEN_DONE = "is_register_screen_done";
  static const String TOKEN = "token";
  static const String LOGIN_RESPONSE = "login_response";
  static const String IS_PROFILE_SETUP = "profile_setup_response";
  static const String PROFILE_IMAGE = "profile_image";
  static const String EMAIL = "email";

  static const String Front = "Front";
  static const String Back = "Back";

  static const String UsersFB = "Users";
  static const String userIdFB = "userId";
  static const String userNameFB = "userName";
  static const String userImageFB = "userImage";
  static const String userEmailFB = "userEmail";

  static const String ForumsFB = "Forums";
  static const String ForumsLikesFB = "ForumsLikes";
  static const String ForumsCommentsFB = "ForumsComments";
  static const String PostCommentsFB = "PostComments";
  static const String ForumsCommentsLikesFB = "ForumsCommentsLikes";
  static const String PostLikesFB = "PostLikes";
  static const String phoneFB = "phone";
  static const String countryCodeFB = "countryCode";
  static const String groupsFB = "Groups";
  static const String FollowersFB = "Followers";
  static const String ChatsFB = "Chats";
  static const String FollowingsFB = "Followings";

  static const String InterestsColl = "Interests";
  static const String OccupationColl = "Occupation";
  static const String ActiveInjuriesColl = "ActiveInjuries";
  static const String PreviousInjuriesColl = "PreviousInjuries";
  static const String CertificationsColl = "Certifications";
  static const String CoachesColl = "Coaches";

  // Card Titles
  static const String addTitle = "Add Title";
  static const String library = "Library";
  static const String recents = "Recents";
  static const String public = "Public";
  static const String private = "Private";
  static const String createCard = "Create Card";
  static const String chooseCardType = "Choose card type";
  static const String addDetails = "Add details";
  static const String addDescription = "Add Description";
  static const String next = "Next";
  static const String viewTitle = "Title";
  static const String viewDesc = "Description";
  static const String recentPosts = "RecentPosts";
  static const String editSegment = "Edit Segment";
  static const String chooseSegment = "Choose a 30s segment";
  static const String addNumbers = "Add Numbers";
  static const String numberOfSets = "Number of Sets";
  static const String addSet = "Add Set";
  // static const String cardDescriptions = "CardDescriptions";
  static const String addTagsToCard = "Add tags to card";
  static const String publishCard = "Publish Card";
  static const String discard = "Discard";
  static const String videoLength = "Video can be max 30s long";

  static const String gallery = "Gallery";
  static const String trimVideo = "Trim Video";
  static const String chooseThumbnail = "Choose a Thumbnail";
  static const String adjustDragHandles = "Adjust drag handles to trim";
  static const String selectThumb = "Select thumbnail";
  static const String addVideoInstr = "Video longer than 30s will have to\nbe segmented.";
  static const String addVideo = "Add Video";
  static const String showParts = "Show Parts";
  static const String hideParts = "Hide Parts";
  static const String card = "CARD";
  static const String routine = "ROUTINE";
  static const String cardImages = "CardImagesStorage";
  static const String cardVideos = "CardVideos";

  static const String giveRoutineName = "Give your routine a name";
  static const String addTagsToRoutine = "Add tags to routine";
  static const String chooseCards = "Choose Cards";
  static const String suggested = "Suggested";
  static const String explainWorkout = "Explain the workout...";
  static const String addToSection = "Add to Section";
  static const String createSection = "Create New Section";
  static String importKeyword = "Import";
  static String card_ = "Card";
  static String shareRoutine = "Share Routine to";
  static String chooseGroup = "Choose Groups";

  static const String googleMapApiKey = "AIzaSyDKfzUhxvQz6v6Meo34CYtav4M2X-Wmx6I";

  // onboarding Strings

  static String solstice = "SOLSTICE";
  static String embraceTextLine = "Embrace Movement Like Never Before";
  static String welcomeDesc =
      "The Solstice platform empowers users to connect,teach, inspire, and grow stronger together. Join our community for free.";

//   static const String googleMapApiKey =
//       "AIzaSyCgqe3NTYPtITpgHJblkRhzyGL86UzgYbo";

  // void warningToast(String message) {
  //   Fluttertoast.showToast(
  //       msg: message,
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: AppColors.waringColor,
  //       textColor: Colors.white,
  //       fontSize: 16.0);
  // }

  // void toast(String message) {
  //   Fluttertoast.showToast(
  //       msg: message,
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: Colors.black,
  //       textColor: Colors.white,
  //       fontSize: 16.0);
  // }

  void errorToast(BuildContext context, String message) {
    Flushbar(
      messageText: Text(
        message,
        style: TextStyle(fontSize: 16.0, color: Colors.white, fontFamily: "epilogue_medium"),
      ),
      backgroundColor: Colors.red[600],
      flushbarStyle: FlushbarStyle.FLOATING,
      duration: Duration(seconds: 3),
      boxShadows: [
        BoxShadow(
          color: Colors.red[800],
          offset: Offset(0.0, 2.0),
          blurRadius: 3.0,
        )
      ],
    )..show(context);
  }

  void successToast(BuildContext context, String message) {
    Flushbar(
      messageText: Text(
        message,
        style: TextStyle(fontSize: 16.0, color: Colors.white, fontFamily: "epilogue_medium"),
      ),
      backgroundColor: Colors.green,
      flushbarStyle: FlushbarStyle.FLOATING,
      duration: Duration(seconds: 3),
      boxShadows: [
        BoxShadow(
          color: Colors.greenAccent,
          offset: Offset(0.0, 2.0),
          blurRadius: 3.0,
        )
      ],
    )..show(context);
  }

  static String getChatRoomId(String senderId, String receiverId) {
    if (senderId.compareTo(receiverId) > 0) {
      return "${senderId}_$receiverId";
    } else {
      return "${receiverId}_$senderId";
    }
  }

  static showSnackBarWithMessage(
      String message, GlobalKey<ScaffoldState> scaffoldKey, BuildContext context, Color color) {
    scaffoldKey.currentState.removeCurrentSnackBar();
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  // void successToast(String message) {
  //   Fluttertoast.showToast(
  //       msg: message,
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: Colors.green,
  //       textColor: Colors.white,
  //       fontSize: 16.0);
  // }

  setUserDefaultCircularImage() {
    return Container(
      width: Dimens.imageSize25(),
      height: Dimens.imageSize25(),
      child: SvgPicture.asset(
        'assets/images/ic_male_placeholder.svg',
        width: Dimens.imageSize25(),
        height: Dimens.imageSize25(),
        fit: BoxFit.fill,
      ),
      /*decoration: BoxDecoration(
        color: AppColors.viewLineColor,
        borderRadius:
        BorderRadius.all(Radius.circular(50.0)),
        border: Border.all(
          color: AppColors.yellowColor,
          width: 1.0,
        ),
      ),*/
    );
  }

  static String getTime(String timeStampValue) {
    int timestamp = 0;
    if (timeStampValue != null && timeStampValue != "null" && timeStampValue != "") {
      timestamp = int.parse(timeStampValue);
    }
    var time = '';
    var now = DateTime.now();
    var format = DateFormat('HH:mm');
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp /* * 1000*/);
    var diff = now.difference(date);

    if (diff.inDays >= 1) {
      time = '${diff.inDays}d';
    } else {
      time = format.format(date);
    }
    return time;
  }

  static String changeToFormatedNumber(String text) {
    int number = text != null && text != "" && text != "null" ? int.parse(text) : 0;
    var _formattedNumber = NumberFormat.compactCurrency(
      decimalDigits: 0,
      symbol: '', // if you want to add currency symbol then pass that in this else leave it empty.
    ).format(number);

    _formattedNumber = _formattedNumber.replaceAll(".0", "");
    return _formattedNumber;
  }
}

class AppColors {
  static Map<int, Color> defaultAppColor = {
    50: Color(0x33C3994B),
    100: Color(0x99C3994B),
    200: Color(0xB3C3994B),
    300: Color(0xCCC3994B),
    400: Color(0xE6C3994B),
    500: Color(0xFFC3994B),
  };

  static Map<int, Color> whiteColor = {
    50: Color(0x33FFFFFF),
    100: Color(0x99FFFFFF),
    200: Color(0xB3FFFFFF),
    300: Color(0xCCFFFFFF),
    400: Color(0xE6FFFFFF),
    500: Color(0xFFFFFFFF),
  };

  static Map<int, Color> appGreyColor = {
    50: Color(0x332B2B2B),
    100: Color(0x992B2B2B),
    200: Color(0xB32B2B2B),
    300: Color(0xCC2B2B2B),
    400: Color(0xE62B2B2B),
    500: Color(0xFF2B2B2B),
    700: Color(0x662B2B2B),
  };

  static Color splashOpacityColor = Color(0xFF11161D);
  static Color titleTextColor = Color(0xFF11161D);
  static Color lightSkyBlue = Color(0xFFEBF1FF);
  static Color darkRedColor = Color(0XFFF12653);
  static Color hintColor = Color(0XFFBDCCDD);
  static Color liteColorTxt = Color(0XFF8A94A6);

  static Color mediumGrey = Color(0xFFC4C4C4);
  static Color primaryColor = Color(0xFF1A58E7);
  static Color viewLineColor = Color(0xFFEBEBEB);
  static Color accentColor = Color(0xFF727272);
  static Color lightGreyColor = Color(0xFFB1B1B1);
  static Color yellowColor = Color(0xFFFCC121);
  static Color shadowColor = Color(0xFFD9DADB);
  static Color waringColor = Color(0xFFFFCC00);
  static Color searchBoxColor = Color(0xFFF8F9FA);
  static Color greenColor = Color(0xFF20C997);
  static Color receiverMsgColor = Color(0XFFE9ECEF);
  static Color cardColor = Color(0XFF319AD4);
  static Color cardTextColor = Color(0XFF215DE3);
  static Color blueColor = Color(0XFF338BEF);
  static Color textColor = Color(0XFFC0D1DD);
  static Color segmentAppBarColor = Color(0XFF338BEF);
  static Color darkTextColor = Color(0XFF283646);
  static Color lightBlue = Color(0XFFF2F6FB);
  static Color liteTextColor = Color(0XFF969393);
  static Color greyTextColor = Color(0XFF738497);
  static Color orangeColor = Color(0XFFE4730B);
  static Color greyBG = Color(0XFFE5E5E5);
  static Color viewColor = Color(0XFFEDEEF0);
  static Color bordergrey = Color(0XFFEAEAEA);
  static Color liteIconColor = Color(0XFFADB7C2);
  static Color downloadBgColor = Color(0XFFE6F7FC);
  static Color redColorNew = Color(0XFFEF333E);
  static Color lineColor = Color(0XFFE4E7EC);
  static Color hintTextColor = Color(0XFFB9BAC8);
  static Color viewColorGrey = Color(0XFFDCDEEE);

  static Color redColor = Color(0xFFDF252C);
  static Color viewsBg = Color(0xFFE6F6FA);
  static Color lineColor1 = Color(0xFFF5F2F2);
  static Color onboardingDarkTextColor = Color(0xFF2E2E2E);

  static Map<int, Color> blackColor = {
    50: Color(0x33000000),
    100: Color(0x99000000),
    200: Color(0xB3000000),
    300: Color(0xCC000000),
    400: Color(0xE6000000),
    500: Color(0xFF000000),
  };
}

String globalUserId = "";
String globalUserName = "";
String globaUserProfileImage = "";
String globalUserFBToken = "";
String defaultPostImage = "";
String globalCurrentChatRoomId = "";
String twitterImage = "";
String instagramImage = "";
String youtubeImage = "";
String tikTokImage = "";

int profileCompleteStatus = 0;

int globalUserUnSeenChats = 0;
