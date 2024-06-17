import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final String name;
  final String email;
  final String password;

  String? authToken;

  UserModel(this.name, this.email, this.password, {this.authToken});
  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return switch (json) {
      {
        'name': String name,
        'email': String email,
        'password': String password,
      } =>
        UserModel(name, email, password, authToken: token),
      _ => throw const FormatException("Fail to convert json to user model")
    };
  }
}

class UserModelFields {
  static const token = "auth-token";
}

class AuthHandler {
  static const _kBaseURL = "http://10.0.2.2:1323";

  Future<UserModel> login(String email, String password) async {
    final response = await http.Client().post(
      Uri.parse("$_kBaseURL/auth/login"),
      body: jsonEncode({'name': email, 'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception("Falha ao fazer login");
    }

    final prefs = await SharedPreferences.getInstance();

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    assert(data.containsKey("token"), "Login response does not contain token key");
    assert(data.containsKey("user"), "Login response does not contain user key");

    final token = data["token"] as String;
    await prefs.setString(UserModelFields.token, data['user']);

    return UserModel.fromJson(data, token: token);
  }

  Future<bool> isAuthenticated() async {
    final response = await http.Client().post(Uri.parse('$_kBaseURL/auth'));
    if (response.statusCode != 200) {
      throw Exception("Falha ao autentiar usuário");
    }

    final _ = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception("Not Implements");
  }

  Future<bool> register() async {
    final response =
        await http.Client().get(Uri.parse("$_kBaseURL/auth/register"));
    if (response.statusCode != 201) {
      throw Exception("Falha ao registrar usuário");
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data.containsKey('message') && data['message'] != null;
  }
}
