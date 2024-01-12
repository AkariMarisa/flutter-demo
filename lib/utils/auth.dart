import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../dto/user.dart';

Future<bool> hasToken() async {
  // 判断当前用户是否已经登陆
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userJson = prefs.getString('userInfo') ?? '{}';
  User user = User.fromJson(jsonDecode(userJson));

  return user.token != null && user.token!.isNotEmpty;
}