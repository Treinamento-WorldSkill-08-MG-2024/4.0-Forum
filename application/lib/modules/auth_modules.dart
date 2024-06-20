import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

part './user_module.dart';

class UserModelFields {
  static const token = "auth-token";
}

class AuthHandler {
  static const _kBaseURL = "http://10.0.2.2:1323/auth";

  Future<Object> login(String email, String password) async {
    final response = await http.Client().post(
      Uri.parse("$_kBaseURL/login"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': email, 'password': password}),
    );

    final bodyData = jsonDecode(response.body) as Map<String, dynamic>;
    assert(bodyData.containsKey("message"),
        "Login response does not contain message key");

    final data = bodyData['message'];
    if (response.statusCode != 200) {
      if (kDebugMode) {
        print(data);
      }

      throw Exception(data);
    }

    assert(data.containsKey("token"), "Login response does not contain token key");
    assert(data.containsKey("user"), "Login response does not contain user key");
    final token = data["token"] as String;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(UserModelFields.token, data['token']);

    return Object.fromJson(data['user'], token: token);
  }

  Future<Object?> isAuthenticated(String token) async {
    final response = await http.Client().post(
      Uri.parse(_kBaseURL),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    
    if (response.statusCode != 202) {
      if (kDebugMode) {
        print(data);
      }

      // throw Exception("Falha ao autenticar usuário");
      return null;
    }

    return Object.fromJson(data);
  }

  Future<bool> register(Object userData) async {
    final response = await http.Client().post(
      Uri.parse("$_kBaseURL/register"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception("Falha ao registrar usuário");
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data.containsKey('message') && data['message'] != null;
  }
}
