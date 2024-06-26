import 'package:application/modules/auth_modules.dart';
import 'package:application/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  UserModel? currentUser;

  Future authenticateUser({String? incomingToken}) async {
    final prefs = await SharedPreferences.getInstance();

    final token = incomingToken ?? prefs.getString(UserModelFields.token);
    if (token == null) {
      currentUser = null;
      notifyListeners();

      return;
    }

    currentUser = await AuthHandler().isAuthenticated(token);
    notifyListeners();
  }

  void redirectIfNotAuthenticated(BuildContext context) {
    if (currentUser == null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ));
    }
  }
}
