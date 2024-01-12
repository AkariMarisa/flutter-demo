import 'package:flutter/material.dart';
import 'package:flutter_demo/router/router.dart';
import 'package:oktoast/oktoast.dart';

/// 程序主入口
void main() {
  // 通过调用runApp运行一个组件
  runApp(const MyApp());
}

/// 应用根组件
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    );

    return OKToast(
      child: MaterialApp.router(
        routerConfig: router,
        title: '这是一个flutter应用demo',
        theme: theme,
      ),
    );
  }
}
