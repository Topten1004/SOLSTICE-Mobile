import 'package:http/http.dart' as http;
import 'dart:convert' show json, jsonEncode;


class ResponseInterFace{
  void  onSuccess(Object data,int code){}
  void onFailure(int code,String message){}
}


class ApiCall {

  ResponseInterFace responseInterFace;
  ApiCall(this.responseInterFace);

   // ignore: missing_return
   Future<http.Response> hitGetApi(Uri url,String token,int code) async {
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 1) {
          responseInterFace.onSuccess(data,code);
        } else {
          responseInterFace.onFailure(code,data['message']);
        }
      } else {
        throw Exception('Failed to load post');
      }
    } catch (e) {
    }
  }


 // ignore: missing_return
 Future<http.Response> hitPostApi(Uri url,Object body,String token,code) async {
  try {
    final response = await http.post(url,body:body);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['status'] == 1) {
        responseInterFace.onSuccess(data,code);
      } else {
        responseInterFace.onFailure(code,data['message']);
      }
    } else {
      throw Exception('Failed to load post');
    }
  } catch (e) {
  }
   }

  static Future<void> sendPushMessage(String receiverFBToken, String payload) async {
    if (receiverFBToken == null || receiverFBToken == "") {
      return;
    }


    try {
      final response = await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            "X-Requested-With": "XMLHttpRequest",
            "Content-Type": "application/json",
            "Authorization":
            "key=AAAAyvtc5r0:APA91bH50voGDGMlayEbcBOKC4AWBmKUjjlr-N4Nt1drYhVYFkt9U6zhgGv3c4ABsC9iQtuCgmOdXqSTIU633Ysaux3M9x1kP5UbFNv9tkrE2U0YT9wlRZI3g3Z8rdz6-ctIUJi8wEAv",


          }, body: payload);


      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON
      } else {
        // If that response was not OK, throw an error.
        throw Exception('Failed to load post');
      }
    } catch (e) {
      print(e);
    }

  }







  // static Future<http.Response> fetchGeneralData(ApiInterface callBack) async {
  //
  //   //showLoadingDialog();
  //   try {
  //     final response = await http.get(UrlConstant.generalUrl);
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     print("Api Error >>> $e");
  //     // callBack.onFailure("משהו השתבש" + "  1");//Some thing went wrong
  //
  //   }
  // }
  //
  // static Future<dynamic> callRegistrationApi(
  //     String firstName, String lastName, String email, String password,
  //     String phoneNo, String profile, String referralCode,
  //     String oneSignalID,String appVersion,String deviceType,
  //     ApiInterface callBack) async {
  //
  //
  //   try {
  //     var postUri = Uri.parse(UrlConstant.register);
  //     var request = await http.MultipartRequest('POST', postUri);
  //
  //     request.fields['email'] = email;
  //     request.fields['password'] = password;
  //     request.fields['first_name'] = firstName;
  //     request.fields['last_name'] = lastName;
  //     request.fields['phone'] = phoneNo;
  //     request.fields['referred_code'] = referralCode;
  //     request.fields['one_signal_id'] = oneSignalID;
  //     request.fields['app_version'] = appVersion;
  //     request.fields['device_type'] = deviceType;
  //
  //     if(profile != ""){
  //       var multipartFile =
  //       await http.MultipartFile.fromPath('profile', profile);
  //       request.files.add(multipartFile);
  //     }
  //
  //
  //     print((email +
  //         " " +
  //         password +
  //         " " +
  //
  //         firstName +
  //         " " +
  //         lastName +
  //         " " +
  //         phoneNo ));
  //     var streamedResponse = await request.send();
  //     /* streamedResponse.stream.transform(utf8.decoder).listen((value) {
  //     print("Response ===> $value");
  //
  //   });*/
  //     final response = await http.Response.fromStream(streamedResponse);
  //     final int statusCode = response.statusCode;
  //     if (statusCode < 200 || statusCode > 400 || json == null) {
  //
  //       callBack.onFailure("Failed to upload");
  //       print(statusCode);
  //
  //       throw new Exception("Error while fetching data");
  //     } else {
  //       var data = json.decode(response.body);
  //       print(data);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  2");//Some thing went wrong
  //
  //   }
  // }
  //
  // static Future<http.Response> callVerifyEmail(String email, String code,
  //     ApiInterface callBack) async {
  //
  //   try {
  //     final response = await http.post(UrlConstant.verifyEmail, headers: {
  //       "X-Requested-With": "XMLHttpRequest"
  //     }, body: {
  //       'email': email,
  //       'code': code,
  //     });
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         //print("data"+ data['data']);
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  3");//Some thing went wrong
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<http.Response> callResendCodeVerifyEmail(String email,
  //     ApiInterface callBack) async {
  //
  //   try {
  //     final response = await http.post(UrlConstant.resendCodeVerifyEmail, headers: {
  //       "X-Requested-With": "XMLHttpRequest"
  //     }, body: {
  //       'email': email,
  //     });
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  4");//Some thing went wrong
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<http.Response> callForgotPassword(String email,
  //     ApiInterface callBack) async {
  //
  //   try {
  //     final response = await http.post(UrlConstant.forgotPassword, headers: {
  //       "X-Requested-With": "XMLHttpRequest"
  //     }, body: {
  //       'email': email,
  //     });
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     print("Api Error >>> $e");
  //     // callBack.onFailure("משהו השתבש"+ "  5");//Some thing went wrong
  //   }
  // }
  //
  //
  // static Future<http.Response> callLoginApi(String email, String password,
  //     String oneSignalID,String appVersion,String deviceType,
  //     ApiInterface callBack) async {
  //   try {
  //     final response = await http.post(UrlConstant.loginUrl, headers: {
  //       "X-Requested-With": "XMLHttpRequest"
  //     }, body: {
  //       'email': email,
  //       'password': password,
  //       'one_signal_id': oneSignalID,
  //       'app_version': appVersion,
  //       'device_type': deviceType,
  //     });
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //
  //         callBack.onSuccess(data);
  //       } else {
  //
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  6");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<http.Response> callReferralApi(String code,  ApiInterface callBack) async {
  //   try {
  //     final response = await http.post(UrlConstant.referralCheckUrl, headers: {
  //       "X-Requested-With": "XMLHttpRequest"
  //     }, body: {
  //       'referral_code': code,
  //     });
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //
  //         callBack.onSuccess(data);
  //       } else {
  //
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  7");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<http.Response> callProfileSetupApi(String currentHeight, String currentHeightUnit,
  //     String currentWeight,String currentWeightUnit,String targetWeight, String targetWeightUnit,
  //     String token, ApiInterface callBack) async {
  //   try {
  //     final response = await http.post(UrlConstant.profileSetup, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //
  //     }, body: {
  //       'current_height': currentHeight,
  //       'current_height_unit': currentHeightUnit,
  //       'current_weight': currentWeight,
  //       'current_weight_unit': currentWeightUnit,
  //       'target_weight': targetWeight,
  //       'target_weight_unit': targetWeightUnit,
  //     });
  //
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  8");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<http.Response> callProfileSetupNewApi(String type,ItemSendRegisterationModel jsonData,
  //     String token, ApiInterface callBack) async {
  //   print(type+" "+jsonData.getDataWithType(type).toString());
  //
  //   try {
  //     final response = await http.post(UrlConstant.profileSetup, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //     }, body: jsonData.getDataWithType(type));
  //
  //     print("token profileSetup> "+token );
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  9");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<http.Response> callUpdateProfileDietitianSideApi(String type,ItemSendRegisterationModel jsonData,
  //     String token, ApiInterface callBack) async {
  //   print(type+" "+jsonData.getDataWithType(type).toString());
  //
  //   try {
  //     final response = await http.post(UrlConstant.updateUserProfileDietitianSide, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //     }, body: jsonData.getDataWithType(type));
  //
  //     print("token profileSetup> "+token );
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  10");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<http.Response> callAddCreditCard(String cardNumber, String cardExpMonth,
  //     String cardExpYear,String cardCvv,String identificationNumber,
  //     String token, ApiInterface callBack) async {
  //   try {
  //     final response = await http.post(UrlConstant.addCreditCard, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //
  //     }, body: {
  //       'card_number': cardNumber,
  //       'card_exp_month': cardExpMonth,
  //       'card_exp_year': cardExpYear,
  //       'card_cvv': cardCvv,
  //       'identification_number': identificationNumber,
  //     });
  //
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  11");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<dynamic> callCreateGroupApi(
  //     String name,
  //     String level,
  //     String startDate,
  //     String endDate,
  //     String weightingDay,
  //     String image,
  //     String token,
  //     String groupId,
  //     String status,
  //     ApiInterface callBack) async {
  //
  //   print("group status $status");
  //
  //   var hitUrl = UrlConstant.createGroup;
  //   if(groupId != ""){
  //     hitUrl = UrlConstant.updateGroup+groupId;
  //   }
  //
  //   try {
  //     var postUri = Uri.parse(hitUrl);
  //     var request = await http.MultipartRequest('POST', postUri);
  //     Map<String, String> headers = { "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"};
  //     request.headers.addAll(headers);
  //
  //     request.fields['name'] = name;
  //     request.fields['level'] = level;
  //     request.fields['start_date'] = startDate;
  //     request.fields['end_date'] = endDate;
  //     request.fields['weighting_day'] = weightingDay;
  //     request.fields['status'] = status;
  //
  //     if(image != ""){
  //       var multipartFile =
  //       await http.MultipartFile.fromPath('image', image);
  //       request.files.add(multipartFile);
  //     }
  //     var streamedResponse = await request.send();
  //     /* streamedResponse.stream.transform(utf8.decoder).listen((value) {
  //     print("Response ===> $value");
  //
  //   });*/
  //     final response = await http.Response.fromStream(streamedResponse);
  //     final int statusCode = response.statusCode;
  //     if (statusCode < 200 || statusCode > 400 || json == null) {
  //
  //       callBack.onFailure("Failed to upload");
  //       print(statusCode);
  //
  //       throw new Exception("Error while fetching data");
  //     } else {
  //       var data = json.decode(response.body);
  //       print(data);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  12");//Some thing went wrong
  //     print("Api Error >>> $e");
  //
  //   }
  // }
  //
  // static Future<http.Response> getGroupsListingApi(
  //     String searchedString,String groupStatus,String token, ApiInterface callBack) async {
  //
  //   var uri = UrlConstant.groupListing+"/?status="+groupStatus;
  //   if(searchedString != ""){
  //     uri = UrlConstant.groupListing+"/?status="+groupStatus+"&keyword="+searchedString;
  //   }
  //
  //   try {
  //     print("Url>>>>> $uri   token $token ");
  //
  //
  //     var postUri = Uri.parse(uri);
  //
  //     final response = await http.get(postUri, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //     });
  //
  //     print(token);
  //     if (response.statusCode == 200) {
  //       Map data = json.decode(response.body);
  //       print(data);
  //
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       print(response.statusCode);
  //       callBack.onFailure("something went wrong");
  //
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  13");//Some thing went wrong
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<dynamic> callGetGroupDetailsApi(
  //     String groupId,
  //     String token,
  //     ApiInterface callBack) async {
  //
  //   try {
  //     final response = await http.post(UrlConstant.getGroupDetail, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //
  //     }, body: {
  //       'group_id': groupId,
  //     });
  //
  //     print("token profileSetup> $token  group_id>> $groupId" );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  14");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<dynamic> callGetFoodListApi(
  //     String token,
  //     String userId,
  //     String selectedDate,
  //     ApiInterface callBack) async {
  //
  //   var uri = UrlConstant.getFoodList+"/?date="+selectedDate;
  //   if(userId != ""){
  //     uri = UrlConstant.getFoodList+"/?user_id="+userId+"/?date="+selectedDate;
  //   }
  //   try {
  //     print(token);
  //
  //     var postUri = Uri.parse(uri);
  //     final response = await http.get(postUri, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //     });
  //
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  15");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<dynamic> callGetWaterListApi(
  //     String token,
  //     String userId,
  //     String selectedDate,
  //     ApiInterface callBack) async {
  //
  //   var uri = UrlConstant.getWaterList+"/?date="+selectedDate;
  //   if(userId != ""){
  //     uri = UrlConstant.getWaterList+"/?user_id="+userId+"/?date="+selectedDate;
  //   }
  //   try {
  //     print(token);
  //
  //     var postUri = Uri.parse(uri);
  //     final response = await http.get(postUri, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //     });
  //
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  16");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<dynamic> callGetTrainingListApi(
  //     String token,
  //     String userId,
  //     String selectedDate,
  //
  //     ApiInterface callBack) async {
  //
  //   var uri = UrlConstant.getTrainingList+"/?date="+selectedDate;
  //   if(userId != ""){
  //     uri = UrlConstant.getTrainingList+"/?user_id="+userId+"/?date="+selectedDate;
  //   }
  //   try {
  //     print(token);
  //
  //     var postUri = Uri.parse(uri);
  //     final response = await http.get(postUri, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //     });
  //
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  17");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<dynamic> callGetFeelingListApi(
  //     String token,
  //     String userId,
  //     ApiInterface callBack) async {
  //
  //   var uri = UrlConstant.getFeelingList;
  //   if(userId != ""){
  //     uri = UrlConstant.getFeelingList+"/?user_id="+userId;
  //   }
  //   try {
  //     print(token);
  //
  //     var postUri = Uri.parse(uri);
  //     final response = await http.get(postUri, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //     });
  //
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  18");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<http.Response> callFoodSelectedDataApi(
  //     SendSelectedItemTempModel jsonData, String token,String callType, ApiInterface callBack) async {
  //
  //   var uri = UrlConstant.addFoodSelectedLog;
  //   if(callType == "update"){
  //     uri = UrlConstant.updateFoodSelectedLog;
  //   }
  //
  //   try {
  //     print(json.encode(jsonData));
  //     final response = await http.post(uri, headers: {
  //       "Content-Type": "application/json",
  //       "Authorization": "Bearer $token"
  //     }, body: json.encode(jsonData));
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       print(data);
  //
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       print(response.statusCode);
  //       //callBack.onFailure("something went wrong");
  //
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<dynamic> callGetLogByDateApi(
  //     String selectedDate,
  //     String userId,
  //     String token,
  //     ApiInterface callBack) async {
  //
  //   try {
  //     final response = await http.post(UrlConstant.getLogByDate, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //
  //     }, body: {
  //       'date': selectedDate,
  //       'user_id': userId,
  //     });
  //
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  20");//Some thing went wrong
  //
  //     print("Api Error 1>>> $e");
  //   }
  // }
  //
  // static Future<http.Response> callAddWeightApi(
  //     String currentWeight,String currentWeightUnit,
  //     String selectedDate, String token,weightId,ApiInterface callBack) async {
  //   try {
  //     final response = await http.post(UrlConstant.addWeight, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //
  //     }, body: {
  //       'date': selectedDate,
  //       'weight': currentWeight,
  //       'weight_unit': currentWeightUnit,
  //       'weight_id': weightId,
  //     });
  //
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  21");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<dynamic> callGetWeightProgress(
  //     String userId,
  //     String token,
  //     ApiInterface callBack) async {
  //
  //   var uri = UrlConstant.getWeightProgress;
  //   if(userId != ""){
  //     uri = UrlConstant.getWeightProgress+"/?user_id="+userId;
  //   }
  //   try {
  //     print(token);
  //
  //     var postUri = Uri.parse(uri);
  //     final response = await http.get(postUri, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //     });
  //
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  22");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<dynamic> callUpdateProfileApi(
  //     String firstName,
  //     String lastName,
  //     String email,
  //     String password,
  //     String phoneNo,
  //     String profile,
  //     String groupDiaryLog,
  //     String token,
  //     ApiInterface callBack) async {
  //
  //
  //   try {
  //     var postUri = Uri.parse(UrlConstant.editProfile);
  //     var request = await http.MultipartRequest('POST', postUri);
  //
  //     Map<String, String> headers = { "Accept": "application/json",
  //       "Authorization": "Bearer $token"};
  //     request.headers.addAll(headers);
  //
  //     request.fields['email'] = email;
  //     request.fields['first_name'] = firstName;
  //     request.fields['last_name'] = lastName;
  //     request.fields['phone'] = phoneNo;
  //
  //     if(password != ""){
  //       request.fields['password'] = password;
  //     }
  //     if(groupDiaryLog != ""){
  //       request.fields['group_diary_log'] = groupDiaryLog;
  //     }
  //
  //
  //     if(profile != ""){
  //       var multipartFile =
  //       await http.MultipartFile.fromPath('profile', profile);
  //       request.files.add(multipartFile);
  //     }
  //
  //
  //     print((email +
  //         " " +
  //         password +
  //         " " +
  //
  //         firstName +
  //         " " +
  //         lastName +
  //         " " +
  //         phoneNo ));
  //     var streamedResponse = await request.send();
  //     /* streamedResponse.stream.transform(utf8.decoder).listen((value) {
  //     print("Response ===> $value");
  //
  //   });*/
  //     final response = await http.Response.fromStream(streamedResponse);
  //     final int statusCode = response.statusCode;
  //     if (statusCode < 200 || statusCode > 400 || json == null) {
  //
  //       callBack.onFailure("Failed to upload");
  //       print(statusCode);
  //
  //       throw new Exception("Error while fetching data");
  //     } else {
  //       var data = json.decode(response.body);
  //       print(data);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data['data']);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  23");//Some
  //     print("Api Error >>> $e");// thing went wrong
  //
  //   }
  // }
  //
  //
  // static Future<dynamic> callGetRecipeDetailApi(
  //     String recipeId,
  //     String token,
  //     ApiInterface callBack) async {
  //
  //
  //   var uri = UrlConstant.getRecipeDetail;
  //   if(recipeId != ""){
  //     uri = UrlConstant.getRecipeDetail+"/?id="+recipeId;
  //   }
  //   try {
  //     print(uri);
  //     var postUri = Uri.parse(uri);
  //     print("token profileSetup> "+token );
  //
  //
  //     final response = await http.get(postUri, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //     });
  //
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     //callBack.onFailure("37   "+"משהו השתבש");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<dynamic> callSignOutApi(
  //     String token,
  //     ApiInterface callBack) async {
  //
  //   try {
  //     final response = await http.get(UrlConstant.signOut, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //     });
  //
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  24");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<dynamic> callGetUserProfileApi(
  //     String token,
  //     ApiInterface callBack) async {
  //
  //   try {
  //     final response = await http.get(UrlConstant.viewProfile, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //     });
  //
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  25");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<dynamic> callGetUserProfileDietitianSideApi(
  //     String token,
  //     String userId,
  //     ApiInterface callBack) async {
  //
  //   try {
  //     final response = await http.post(UrlConstant.viewUserProfileDietitianSide, headers: {
  //       "Accept": "application/json",
  //       "Authorization": "Bearer $token"
  //     }, body: {
  //       'user_id': userId,
  //     });
  //
  //     if (response.statusCode == 200) {
  //       Map data = json.decode(response.body);
  //       print(data);
  //
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       print(response.statusCode);
  //       callBack.onFailure("something went wrong");
  //
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  26");//Some thing went wrong
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<http.Response> callUpdateUserSetting(
  //     String totalStars,
  //     String redStars,
  //     String yellowStars,
  //     String targetWeight,
  //     String targetWeightUnit,
  //     String trainingPoints,
  //     String drinkingCups,
  //     String selectedWeightDay,
  //     String selectedDiaryLog,
  //     String token,
  //     ApiInterface callBack) async {
  //   try {
  //     print("total Stars $totalStars red stars $redStars yellow $yellowStars tWeight $targetWeight weightUnit $targetWeightUnit");
  //     final response = await http.post(UrlConstant.updateUserSettings, headers: {
  //       "Accept": "application/json",
  //       "Authorization": "Bearer $token"
  //     }, body: {
  //       'total_stars': totalStars,
  //       'red_stars': redStars,
  //       'yellow_stars': yellowStars,
  //       'target_weight': targetWeight,
  //       'target_weight_unit': targetWeightUnit,
  //       'training_points': trainingPoints,
  //       'water_cups': drinkingCups,
  //       "weighting_day":selectedWeightDay,
  //       "group_diary_log":selectedDiaryLog,
  //
  //     });
  //
  //     if (response.statusCode == 200) {
  //       Map data = json.decode(response.body);
  //       print(data);
  //
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       print(response.statusCode);
  //       callBack.onFailure("something went wrong");
  //
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  27");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<http.Response> callUpdateUserSettingDietitianSide(
  //     String totalStars,
  //     String redStars,
  //     String yellowStars,
  //     String trainingPoints,
  //     String drinkingCups,
  //     String selectedWeightDay,
  //     String userId,
  //     String token,
  //     ApiInterface callBack) async {
  //   try {
  //     print("total Stars $totalStars red stars $redStars yellow $yellowStars");
  //     final response = await http.post(UrlConstant.updateUserSettingsDietitianSide, headers: {
  //       "Accept": "application/json",
  //       "Authorization": "Bearer $token"
  //     }, body: {
  //       'total_stars': totalStars,
  //       'red_stars': redStars,
  //       'yellow_stars': yellowStars,
  //       'training_points': trainingPoints,
  //       'water_cups': drinkingCups,
  //       "weighting_day":selectedWeightDay,
  //       "user_id":userId,
  //     });
  //
  //     if (response.statusCode == 200) {
  //       Map data = json.decode(response.body);
  //       print(data);
  //
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       print(response.statusCode);
  //       callBack.onFailure("something went wrong");
  //
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  28");//Some thing went wrong
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  //
  // static Future<http.Response> callChangeGroupStatus(
  //     String statusType,
  //     String groupId,
  //     String token,
  //     ApiInterface callBack) async {
  //   try {
  //     final response = await http.post(UrlConstant.changeGroupStatus, headers: {
  //       "Accept": "application/json",
  //       "Authorization": "Bearer $token"
  //     }, body: {
  //       'status': statusType,
  //       'group_id': groupId,
  //     });
  //
  //     if (response.statusCode == 200) {
  //       Map data = json.decode(response.body);
  //       print(data);
  //
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data['message']);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       print(response.statusCode);
  //       callBack.onFailure("something went wrong");
  //
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     print("Api Error >>> $e");
  //     // callBack.onFailure("משהו השתבש"+ "  29");//Some thing went wrong
  //   }
  // }
  //
  // static Future<http.Response> callUserMoveToGroup(
  //     String userId,
  //     String groupId,
  //     String token,
  //     ApiInterface callBack) async {
  //   try {
  //     final response = await http.post(UrlConstant.moveToGroup, headers: {
  //       "Accept": "application/json",
  //       "Authorization": "Bearer $token"
  //     }, body: {
  //       'user_id': userId,
  //       'group_id': groupId,
  //     });
  //
  //     if (response.statusCode == 200) {
  //       Map data = json.decode(response.body);
  //       print(data);
  //
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data['message']);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       print(response.statusCode);
  //       callBack.onFailure("something went wrong");
  //
  //       // If th4 gat response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     print("Api Error >>> $e");
  //     // callBack.onFailure("משהו השתבש"+ "  30");//Some thing went wrong
  //
  //   }
  // }
  //
  // static Future<dynamic> callCancelSubscriptionApi(
  //     String token,
  //     ApiInterface callBack) async {
  //
  //   try {
  //     final response = await http.get(UrlConstant.cancelSubscription, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //     });
  //
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  31");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<dynamic> callGetPaymentHistoryApi(
  //     String token,
  //     ApiInterface callBack) async {
  //
  //   try {
  //     final response = await http.get(UrlConstant.myPaymentsHistory, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //     });
  //
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  32");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<http.Response> callUpdateMeasurementDietitianSideApi(String currentHeight, String currentHeightUnit,
  //     String currentWeight,String currentWeightUnit,String targetWeight, String targetWeightUnit,String userId,
  //     String token, ApiInterface callBack) async {
  //   try {
  //     final response = await http.post(UrlConstant.updateUserMeasurementDietitianSide, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //
  //     }, body: {
  //       'current_height': currentHeight,
  //       'current_height_unit': currentHeightUnit,
  //       'current_weight': currentWeight,
  //       'current_weight_unit': currentWeightUnit,
  //       'target_weight': targetWeight,
  //       'target_weight_unit': targetWeightUnit,
  //       'user_id': userId,
  //     });
  //
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  33");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<http.Response> callDeleteLogApi(String logID, String uniqueID,
  //     String token, ApiInterface callBack) async {
  //   try {
  //     final response = await http.post(UrlConstant.deleteLogApi, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //
  //     }, body: {
  //       'log_id': logID,
  //       'unique_id': uniqueID,
  //     });
  //
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  34");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  // static Future<http.Response> callDeleteWeightApi(String weightID,
  //     String token, ApiInterface callBack) async {
  //   try {
  //     final response = await http.post(UrlConstant.deleteWeightApi, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //
  //     }, body: {
  //       'weight_id': weightID,
  //     });
  //
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  35");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<dynamic> callGetCitiesApi(
  //     ApiInterface callBack) async {
  //
  //   try {
  //     final response = await http.get(UrlConstant.getCities, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //     });
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  36");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  //
  // static Future<dynamic> callGetRecipeFilterList(
  //     String token,
  //     ApiInterface callBack) async {
  //   try {
  //     print(token);
  //
  //     final response = await http.get(UrlConstant.getRecipeFilters, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //     });
  //
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  37");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<dynamic> callGetRecipeUserList(
  //     String token,
  //     String filteredRecipeSettings,
  //     ApiInterface callBack) async {
  //
  //
  //   var uri = UrlConstant.getRecipeUser;
  //   if(filteredRecipeSettings != ""){
  //     uri = UrlConstant.getRecipeUser+"/?name="+filteredRecipeSettings;
  //   }
  //   try {
  //     print(uri);
  //     var postUri = Uri.parse(uri);
  //     print("token profileSetup> "+token );
  //
  //
  //     final response = await http.get(postUri, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //     });
  //
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     //callBack.onFailure("31   "+"משהו השתבש");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  //
  // static Future<http.Response> callUpdateOneSignalOnServerApi(String oneSingleId,
  //     String currentTimeZone,String appVersion,String deviceType,String token,ApiInterface callBack) async {
  //   try {
  //     final response = await http.post(UrlConstant.updateOneSignal, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //
  //     }, body: {
  //       'one_single_id': oneSingleId,
  //       'time_zone': currentTimeZone,
  //       'app_version': appVersion,
  //       'device_type': deviceType,
  //     });
  //
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  39");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<http.Response> callAddUpdateMyWaterApi(
  //     String itemType,
  //     String itemName,
  //     String itemText,
  //     String noOfWaterCups,
  //     String itemId,
  //     String token,
  //     ApiInterface callBack) async {
  //
  //   try {
  //     final response = await http.post(UrlConstant.addUpdateMyWater, headers: {
  //       "Accept": "application/json",
  //       "Authorization": "Bearer $token"
  //     }, body: {
  //       'item_type': itemType,
  //       'name': itemName,
  //       'text': itemText,
  //       'no_of_water_cups': noOfWaterCups,
  //       'id': itemId,
  //     });
  //
  //     if (response.statusCode == 200) {
  //       Map data = json.decode(response.body);
  //       print(data);
  //
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data['data']);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       print(response.statusCode);
  //       callBack.onFailure("something went wrong");
  //
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  40");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<http.Response> callDeleteMyWaterApi(String logID,
  //     String token, ApiInterface callBack) async {
  //   try {
  //     final response = await http.post(UrlConstant.deleteMyWaterItem, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //
  //     }, body: {
  //       'id': logID,
  //     });
  //
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  41");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<http.Response> callAddUpdateMyFeelingApi(
  //     String itemType,
  //     String itemName,
  //     String userType,
  //     String itemId,
  //     String token,
  //     ApiInterface callBack) async {
  //
  //   try {
  //     final response = await http.post(UrlConstant.addUpdateMyFeeling, headers: {
  //       "Accept": "application/json",
  //       "Authorization": "Bearer $token"
  //     }, body: {
  //       'item_type': itemType,
  //       'name': itemName,
  //       'user_type': userType,
  //       'id': itemId,
  //     });
  //
  //     if (response.statusCode == 200) {
  //       Map data = json.decode(response.body);
  //       print(data);
  //
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data['data']);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       print(response.statusCode);
  //       callBack.onFailure("something went wrong");
  //
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     print("Api Error >>> $e");
  //     // callBack.onFailure("משהו השתבש"+ "  42");//Some thing went wrong
  //
  //   }
  // }
  //
  // static Future<http.Response> callDeleteMyFeelingApi(String logID,
  //     String token, ApiInterface callBack) async {
  //   try {
  //     final response = await http.post(UrlConstant.deleteMyFeelingItem, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //
  //     }, body: {
  //       'id': logID,
  //     });
  //
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+"  43");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<http.Response> callAddUpdateMyTrainingApi(
  //     String itemType,
  //     String itemName,
  //     String itemText,
  //     String trainingPoints,
  //     String itemId,
  //     String token,
  //     ApiInterface callBack) async {
  //
  //   try {
  //     final response = await http.post(UrlConstant.addUpdateMyTraining, headers: {
  //       "Accept": "application/json",
  //       "Authorization": "Bearer $token"
  //     }, body: {
  //       'item_type': itemType,
  //       'name': itemName,
  //       'text': itemText,
  //       'training_points': trainingPoints,
  //       'id': itemId,
  //     });
  //
  //     if (response.statusCode == 200) {
  //       Map data = json.decode(response.body);
  //       print(data);
  //
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data['data']);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       print(response.statusCode);
  //       callBack.onFailure("something went wrong");
  //
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     print("Api Error >>> $e");
  //     // callBack.onFailure("משהו השתבש"+ "  44");//Some thing went wrong
  //
  //   }
  // }
  //
  // static Future<http.Response> callDeleteMyTrainingApi(String logID,
  //     String token, ApiInterface callBack) async {
  //   try {
  //     final response = await http.post(UrlConstant.deleteMyTrainingItem, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //     }, body: {
  //       'id': logID,
  //     });
  //
  //     print("token profileSetup> "+token );
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+ "  45");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<http.Response> callAddUpdateMyFoodApi(
  //     String itemType,
  //     String itemName,
  //     String itemText,
  //     String itemTextUnit,
  //     String redAmount,
  //     String yellowAmount,
  //     String itemId,
  //     String token,
  //     ApiInterface callBack) async {
  //
  //   try {
  //     final response = await http.post(UrlConstant.addUpdateMyFood, headers: {
  //       "Accept": "application/json",
  //       "Authorization": "Bearer $token"
  //     }, body: {
  //       'name': itemName,
  //       'text': itemText,
  //       'text_unit': itemTextUnit,
  //       'item_type': itemType,
  //       'red_amount': redAmount,
  //       'yellow_amount': yellowAmount,
  //       'id': itemId,
  //     });
  //
  //     if (response.statusCode == 200) {
  //       Map data = json.decode(response.body);
  //       print(data);
  //
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data['data']);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       print(response.statusCode);
  //       callBack.onFailure("something went wrong");
  //
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     print("Api Error >>> $e");
  //     // callBack.onFailure("משהו השתבש"+ "  46");//Some thing went wrong
  //
  //   }
  // }
  //
  // static Future<http.Response> callDeleteMyFoodApi(String logID,
  //     String token, ApiInterface callBack) async {
  //   try {
  //     final response = await http.post(UrlConstant.deleteMyFoodItem, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //     }, body: {
  //       'id': logID,
  //     });
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     // callBack.onFailure("משהו השתבש"+"   47");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<dynamic> callGet10DaysDataApi(
  //     String selectedDate,
  //     String userId,
  //     String token,
  //     ApiInterface callBack) async {
  //
  //   try {
  //     final response = await http.post(UrlConstant.getLogsTill10Days, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //
  //     }, body: {
  //       'date': selectedDate,
  //       'user_id': userId,
  //     });
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     //callBack.onFailure("54   "+"משהו השתבש");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<http.Response> callUpdateLogsCount(
  //     SendSelectedItemTempModel jsonData, String token, ApiInterface callBack) async {
  //
  //   var uri = UrlConstant.updateLogsCountApi;
  //
  //
  //   try {
  //     print(json.encode(jsonData.getUpdateLogsCountData()));
  //     final response = await http.post(uri, headers: {
  //       "Accept": "application/json",
  //       "Authorization": "Bearer $token"
  //     }, body: jsonData.getUpdateLogsCountData());
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       print(data);
  //
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       print(response.statusCode);
  //       //callBack.onFailure("something went wrong");
  //
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     print("Api Error >>> $e");
  //   }
  // }
  //
  // static Future<dynamic> callGetUserDetailFromNotification(
  //     String userId,
  //     String token,
  //     ApiInterface callBack) async {
  //   try {
  //     final response = await http.post(UrlConstant.getUserDetailFromNotification, headers: {
  //       "X-Requested-With": "XMLHttpRequest",
  //       "Authorization": "Bearer $token"
  //     }, body: {
  //       'user_id': userId,
  //     });
  //     print("token profileSetup> "+token );
  //
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       if (data['status'] == 1) {
  //         callBack.onSuccess(data);
  //       } else {
  //         callBack.onFailure(data['message']);
  //       }
  //
  //       // If server returns an OK response, parse the JSON
  //     } else {
  //       // If that response was not OK, throw an error.
  //       throw Exception('Failed to load post');
  //     }
  //   } catch (e) {
  //     //callBack.onFailure("54   "+"משהו השתבש");//Some thing went wrong
  //
  //     print("Api Error >>> $e");
  //   }
  // }

}
