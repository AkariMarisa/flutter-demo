import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart' as oktoast;

void showToast(String msg) {
  oktoast.showToast(msg,
      position: oktoast.ToastPosition.bottom,
      radius: 32,
      textPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20));
}
