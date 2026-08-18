import 'package:shared_preferences/shared_preferences.dart';
class SettingsService {
  static const darkMode='dark_mode', categoryOrder='category_order', isPro='is_pro', unitOrderPrefix='unit_order_';
  SettingsService(this.prefs); final SharedPreferences prefs;
  static Future<SettingsService> create() async => SettingsService(await SharedPreferences.getInstance());
  String getString(String key,[String fallback=''])=>prefs.getString(key)??fallback;
  bool getBool(String key,[bool fallback=false])=>prefs.getBool(key)??fallback;
  Future<void> putString(String key,String value)=>prefs.setString(key,value);
  Future<void> putBool(String key,bool value)=>prefs.setBool(key,value);
}
