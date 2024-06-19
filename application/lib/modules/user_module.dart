part of './auth_modules.dart';

class UserModel {
  final int? id;
  final String name;
  final String email;
  final String? password;

  String? authToken;

  UserModel(this.id, this.name, this.email, this.password, {this.authToken});
  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return switch (json) {
      {
        'id': int id,
        'name': String name,
        'email': String email,
        'password': String password,
      } =>
        UserModel(id, name, email, password, authToken: token),
      _ => throw const FormatException("Fail to convert json to user model")
    };
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'password': password};
  }
}

class UserHandler {
  static const _kBaseURL = "http://10.0.2.2:1323/user";

  Future<UserModel> getUserData(int id) async {
    final response = await http.Client().get(
      Uri.parse("$_kBaseURL/$id"),
      headers: {'Content-Type': 'application/json'},
    );

    final bodyData = jsonDecode(response.body) as Map<String, dynamic>;
    assert(bodyData.containsKey("message"), "Login response does not contain message key");

    final data = bodyData['message'];
    if (response.statusCode != 200) {
      if (kDebugMode) {
        print(data);
      }

      throw Exception(data);
    }

    return UserModel.fromJson(data);
  }
}
