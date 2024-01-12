import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_demo/components/form.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dto/user.dart';
import '../utils/toast.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: OverflowBox(
            maxHeight: 420,
            child: Column(
              children: [
                Text(
                  '欢迎使用\nXXXX平台',
                  style: TextStyle(
                    fontSize: 36,
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                _LoginForm()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  String? _username, _password;
  bool _isLogon = false;

  Future<bool> _doLogin() async {
    if (_username?.isEmpty ?? true) {
      showToast('用户名不能为空');
      return false;
    }

    if (_password?.isEmpty ?? true) {
      showToast('密码不能为空');
      return false;
    }

    setState(() {
      _isLogon = true;
    });

    await Future.delayed(const Duration(seconds: 3), () {});

    setState(() {
      _isLogon = false;
    });

    showToast('登陆成功');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(User(1, 'admin', '111111'));
    await prefs.setString('userInfo', userJson);

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InputText(
                label: '用户名',
                width: 200,
                listenValueChange: (value) => {_username = value},
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InputPassword(
                label: '密码',
                width: 200,
                listenValueChange: (value) => {_password = value},
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 40, bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _isLogon
                      ? null
                      : () async {
                          final router = GoRouter.of(context);
                          bool isLogon = await _doLogin();
                          if (isLogon) router.go('/');
                        },
                  icon: _isLogon
                      ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.chevron_right_sharp),
                  label: Text(_isLogon ? '登陆中' : '登陆'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
