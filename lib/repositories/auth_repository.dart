import 'package:shared_preferences/shared_preferences.dart';
import 'package:avighn_medicare/utils/app_constants.dart';

class AuthRepository {
  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (username == AppConstants.adminUsername && password == AppConstants.adminPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.sessionKey, AppConstants.sessionValue);
      return true;
    }
    return false;
  }
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.sessionKey);
  }
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.sessionKey) == AppConstants.sessionValue;
  }
}