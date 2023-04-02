
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class SharedPref  {



  static SharedPreferences prefs;

  SharedPref1(){
    loadPrefs();
  }


  //set data into shared preferences like this
  static Future<void> saveBooleanInPrefs(String key , bool value) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

//get value from shared preferences
  static  getBooleanFromPrefs(String key) {
    return  prefs.getBool(key) ?? false;
  }

  static Future<bool> getBool(String key) async{
    prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  static Future<void> saveStringInPrefs(String key , String value) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

//get value from shared preferences
 /* static getStringFromPrefs(String key) {
    return  prefs.getString(key) ?? "";
  }*/

  static getProfileData(String key) {
    return prefs.getString(key) ?? "";
  }
  static Future<String> getStringFromPrefs(String key) async{
    prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "";
  }


  static Future<int> saveIntInPrefs(String key , int value) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }

//get value from shared preferences
  static getIntFromPrefs(String key) async {
     prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 0;
  }

  static loadPrefs() async{
    prefs = await SharedPreferences.getInstance();
  }

  static remove(String key) async {
    prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  static Future clear() async{
    prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }


  static Future removeKeys() async{
    prefs = await SharedPreferences.getInstance();
    //prefs.remove(Constants.EMAIL);
   // prefs.remove(Constants.FIRST_NAME);

  }

  static Future<String> getLoginStatus(String key) async{
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    return _prefs.getString(key) ?? "0";
  }

  static Future<bool> setLoginStatus(String key, String value) async{
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    return _prefs.setString(key, value);
  }

  static Future<bool> saveList(String key, String data) async {
    prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, data);
  }

  static Future<String> getList(String key) async{
    return prefs.getString(key) ?? "";
  }


}