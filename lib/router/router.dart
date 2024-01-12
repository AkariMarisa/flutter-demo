import 'package:flutter/material.dart';
import 'package:flutter_demo/utils/auth.dart';
import 'package:flutter_demo/views/bluetooth.dart';
import 'package:flutter_demo/views/camera.dart';
import 'package:go_router/go_router.dart';

import '../views/counter.dart';
import '../views/login.dart';
import '../views/my_home_page.dart';

/// 路由管理
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const TabPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/counter', builder: (context, state) => const CounterPage()),
    GoRoute(
      path: '/camera',
      builder: (context, state) => const CameraPage(),
    ),
    GoRoute(
      path: '/bluetooth',
      builder: (context, state) => const BluetoothPage(),
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) async {
    if (!await hasToken()) {
      return '/login';
    } else {
      return null;
    }
  },
);
