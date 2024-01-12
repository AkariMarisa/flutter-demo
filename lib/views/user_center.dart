import 'package:flutter/material.dart';
import 'package:flutter_demo/utils/toast.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserCenterPage extends StatelessWidget {
  const UserCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Column(
        children: [
          _UserCard(),
          _ListMenu(),
        ],
      ),
    );
  }
}

class _GradientAvatar extends StatelessWidget {
  const _GradientAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      decoration: const BoxDecoration(
        gradient: SweepGradient(
          colors: [
            Color.fromRGBO(15, 15, 215, 1),
            Color.fromRGBO(9, 230, 116, 1),
            Color.fromRGBO(205, 0, 255, 1),
            Color.fromRGBO(0, 212, 255, 1),
            Color.fromRGBO(15, 15, 215, 1),
          ],
          stops: [0, 0.2, 0.5, 0.9, 1],
        ),
        shape: BoxShape.circle,
      ),
      child: const CircleAvatar(
        foregroundImage: AssetImage('images/boy.png'),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      elevation: 10,
      color: Colors.blueAccent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _GradientAvatar(),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '你好, AdminAdminAdminAdmin',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  Text(
                    '上次登陆时间: 2024-01-10',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListMenu extends StatelessWidget {
  const _ListMenu();

  void _showLogoutDialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('提示'),
            content: const Text('确定要退出登陆吗？'),
            actions: [
              TextButton(
                  onPressed: () async => await _doLogout(context),
                  child: const Text('确定')),
              TextButton(
                  onPressed: () => context.pop(), child: const Text('取消')),
            ],
          );
        });
  }

  Future<void> _doLogout(BuildContext context) async {
    final router = GoRouter.of(context);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userInfo');

    router.pop();
    router.replace('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            offset: Offset(4, 4),
            color: Color.fromRGBO(0, 0, 0, 0.15),
            blurRadius: 10,
            spreadRadius: 0,
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => showToast('个人信息'),
                  icon: const Icon(Icons.person),
                  label: const Text('个人信息'),
                  style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => showToast('修改密码'),
                  icon: const Icon(Icons.edit),
                  label: const Text('修改密码'),
                  style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => showToast('关于'),
                  icon: const Icon(Icons.info),
                  label: const Text('关于'),
                  style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('退出登陆'),
                  style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
