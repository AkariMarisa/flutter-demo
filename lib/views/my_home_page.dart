import 'package:flutter/material.dart';
import 'package:flutter_demo/utils/toast.dart';
import 'package:flutter_demo/views/user_center.dart';
import 'package:go_router/go_router.dart';

class TabPage extends StatelessWidget {
  const TabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                width: 1,
                color: Color.fromRGBO(227, 227, 227, 1.0),
              ),
            ),
          ),
          child: const TabBar(
            indicator: BoxDecoration(),
            labelColor: Colors.blue,
            tabs: [
              Tab(
                text: '首页',
                icon: Icon(Icons.home),
                iconMargin: EdgeInsets.zero,
                height: 60,
              ),
              Tab(
                text: '我的',
                icon: Icon(Icons.person_sharp),
                iconMargin: EdgeInsets.zero,
                height: 60,
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MyHomePage(title: '我的首页'),
            UserCenterPage(),
          ],
        ),
      ),
    );
  }
}

/// 首页组件
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        // centerTitle: true,
        elevation: 10,
        shadowColor: Colors.black,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          PopupMenuButton(
              iconColor: Colors.white,
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    onTap: () => showToast('我是一个子菜单'),
                    child: const Text('子菜单1'),
                  ),
                ];
              })
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shrinkWrap: true,
        children: [
          FilledButton(
            onPressed: () => context.push('/counter'),
            child: const Text('计数器'),
          ),
          FilledButton(
            onPressed: () => context.push('/camera'),
            child: const Text('拍照'),
          ),
          FilledButton(
            onPressed: () => context.push('/bluetooth'),
            child: const Text('蓝牙LE设备'),
          ),
        ],
      ),
    );
  }
}
