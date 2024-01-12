import 'dart:developer';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/camera.dart';
import 'package:uri_to_file/uri_to_file.dart';

/// TODO 1. 支持选择视频，播放视频
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<StatefulWidget> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _imageFile;
  final XTypeGroup types =
      const XTypeGroup(label: 'images', extensions: ['jpg', 'png']);

  Future<void> _chooseImage() async {
    final file = await openFile(acceptedTypeGroups: [types]);
    if (file != null) {
      log('图片路径: ${file.path}  图片名称: ${file.name}');
      final tempFile = await toFile(file.path);
      setState(() {
        _imageFile = tempFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('拍照'),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: _imageFile == null
                  ? Container(color: Colors.red)
                  : Image.file(_imageFile!),
            ),
            const Spacer(),
            Wrap(
              spacing: 10,
              children: [
                FilledButton(
                  onPressed: () {
                    takePhoto(
                      context,
                      onPhotoTaken: (String value) =>
                          setState(() => _imageFile = File(value)),
                    );
                  },
                  child: const Text('调起拍照'),
                ),
                FilledButton(
                    onPressed: () async => await _chooseImage(),
                    child: const Text('选择图片')),
                FilledButton(onPressed: () => {}, child: const Text('拍摄视频')),
              ],
            ),
            const Spacer(
              flex: 3,
            ),
          ],
        ),
      ),
    );
  }
}
