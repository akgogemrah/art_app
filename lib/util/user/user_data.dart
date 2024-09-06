import 'package:shared_preferences/shared_preferences.dart';

class UserProfileInfoData{

  Future<void> storeToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> storeFname(String fname) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fname', fname);
  }
  Future<void> storeMail(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
  }







  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getFname() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('fname');
  }


  Future<String?> getMail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }
}