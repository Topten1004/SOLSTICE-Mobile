class UrlConstant{

  static const String BaseUrlImg = "http://bwg.tunavpn.com:8080/";
  static const String BaseUrl = "http://bwg.tunavpn.com:8080/";
  static const String uploadInit= BaseUrl+"auth/1/hoclogin/u";
  static const String uploadHocFile= BaseUrl+"auth/1/hoc-file-upload";

  static const String ApiBaseUrl='http://ec2-18-222-29-111.us-east-2.compute.amazonaws.com/solstice/public/api/';

  static Uri sendOtp= Uri.parse(ApiBaseUrl+"sendOtp");
  static int sendOtpCode=1;

  static Uri register= Uri.parse(ApiBaseUrl+"register");
  static int registerCode=2;

  static Uri login= Uri.parse(ApiBaseUrl+"login");
  static int loginCode=3;

  static Uri addBucket= Uri.parse(ApiBaseUrl+"addBucket");
  static int addBucketCode=4;

}