import 'dart:convert';
import 'dart:io';

import 'package:application/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

part './user_module.dart';

class UserModelFields {
  static const token = "auth-token";
}

class AuthHandler {
  static const _kBaseURL = "http://10.0.2.2:1323/auth";

  Future<bool> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    final response = await http.Client().post(
      Uri.parse("$_kBaseURL/login"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': email, 'password': password}),
    );

    final bodyData = jsonDecode(response.body) as Map<String, dynamic>;
    assert(bodyData.containsKey("message"));

    final data = bodyData['message'];
    if (response.statusCode != HttpStatus.ok) {
      if (kDebugMode) {
        print(data);
      }

      throw Exception(data);
    }

    assert(
        data.containsKey("token"), "Login response does not contain token key");
    assert(
        data.containsKey("user"), "Login response does not contain user key");
    final token = data["token"] as String;

    if (!context.mounted) {
      return false;
    }

    await Provider.of<AuthProvider>(context, listen: false)
        .authenticateUser(incomingToken: token);
    return true;
  }

  Future<UserModel?> isAuthenticated(String token) async {
    final response = await http.Client().post(
      Uri.parse(_kBaseURL),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == HttpStatus.unauthorized) {
      return null;
    }

    if (response.statusCode != HttpStatus.ok) {
      if (kDebugMode) {
        print(data);
      }

      throw Exception("Falha ao autenticar usuário");
    }

    assert((data as Map<String, dynamic>).containsKey("message"));
    return UserModel.fromJson(data["message"]);
  }

  Future<bool> register(UserModel userData) async {
    final response = await http.Client().post(
      Uri.parse("$_kBaseURL/register"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData.toJson()),
    );

    if (response.statusCode != HttpStatus.created) {
      throw Exception("Falha ao registrar usuário");
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data.containsKey('message') && data['message'] != null;
  }
}
