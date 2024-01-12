import 'package:flutter/material.dart';

/// 文本输入框
/// TODO 应该可以转换成Stateless的控件
class InputText extends StatefulWidget {
  final String label;
  final double width;
  final InputDecoration? decoration;
  final Function? listenValueChange;
  final bool isPassword;
  final int maxLines;
  final String? text;

  const InputText(
      {required this.label,
      this.width = 100,
      this.decoration,
      this.isPassword = false,
      this.maxLines = 1,
      this.text,
      this.listenValueChange,
      super.key});

  @override
  State<StatefulWidget> createState() => _InputTextState();
}

/// 密码输入框
class InputPassword extends InputText {
  const InputPassword(
      {required super.label,
      super.width,
      super.decoration,
      super.isPassword = true,
      super.listenValueChange,
      super.key});
}

class _InputTextState extends State<InputText> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    if (widget.listenValueChange != null) {
      _controller.addListener(() {
        final String value = _controller.text;
        widget.listenValueChange!(value);
      });
    }

    if (widget.text != null) {
      _controller.text = widget.text!;
    }

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration deco = widget.decoration == null
        ? InputDecoration(label: Text(widget.label))
        : widget.decoration!.copyWith(label: Text(widget.label));
    return SizedBox(
      width: widget.width,
      child: TextField(
        maxLines: widget.maxLines,
        controller: _controller,
        decoration: deco,
        obscureText: widget.isPassword,
      ),
    );
  }
}
