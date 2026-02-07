import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static Future set(String name, String value) async {
    final SharedPreferences instance = await SharedPreferences.getInstance();
    return instance.setString(name, value);
  }
  static Future setBool(String name, bool value) async {

    final SharedPreferences instance = await SharedPreferences.getInstance();
    return instance.setBool(name, value);
  }

  static Future get(String name) async {
    final SharedPreferences instance = await SharedPreferences.getInstance();
    return instance.getString(name);
  }

  static Future getBool(String name) async {
    final SharedPreferences instance = await SharedPreferences.getInstance();
    return instance.getBool(name);
  }

  static Future clear(String name) async {
    final SharedPreferences instance = await SharedPreferences.getInstance();
    return instance.remove(name);
  }



  static Future setList(List<String> value,String name) async {
    final SharedPreferences instance = await SharedPreferences.getInstance();
    return instance.setStringList(name, value);
  }

  static Future getList(String name) async {
    final SharedPreferences instance = await SharedPreferences.getInstance();
    return instance.getStringList(name);
  }

  static Future clearList(String name) async {
    final SharedPreferences instance = await SharedPreferences.getInstance();
    return instance.remove(name);
  }


}
