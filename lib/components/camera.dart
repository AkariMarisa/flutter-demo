import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/utils/toast.dart';
import 'package:go_router/go_router.dart';

takePhoto(BuildContext context, {required ValueChanged<String> onPhotoTaken}) {
  // TODO 考虑这里直接跳页，不用全屏Dialog了。
  showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black,
      useSafeArea: false,
      builder: (BuildContext context) {
        return _CameraWidget(onPhotoTaken: onPhotoTaken);
      });
}

/// TODO 1. 支持闪光灯开关
/// TODO 2. 支持缩放
/// TODO 3. 支持录制视频
/// TODO 4. 支持预览视频
/// TODO 5. 优化界面，添加拍照音效
class _CameraWidget extends StatefulWidget {
  final ValueChanged<String> onPhotoTaken;

  const _CameraWidget({required this.onPhotoTaken, super.key});

  @override
  State<StatefulWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<_CameraWidget>
    with WidgetsBindingObserver {
  late CameraDescription _camera;
  late CameraController _cameraController;
  bool _isInitialized = false;
  String _imagePath = '';

  /// 获取摄像头
  Future<void> _getCamera() async {
    log('######开始获取设备摄像头######');
    WidgetsFlutterBinding.ensureInitialized();

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      showToast('无法获取设备摄像头，请确认摄像头是否存在。');
      return;
    }

    _camera = cameras.first;

    // 配置相机成像质量，质量越高，调用相机越慢
    _initCameraController();
  }

  /// 初始化相机控制器
  void _initCameraController() {
    _cameraController = CameraController(_camera, ResolutionPreset.max);

    _cameraController.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
    });
  }

  /// 拍照
  Future<void> _takePicture() async {
    // TODO 纯SB的Bug，暂时只能这样解决，详见 https://github.com/flutter/flutter/issues/97501
    await _cameraController.setExposureMode(ExposureMode.locked);
    final image = await _cameraController.takePicture();
    await _cameraController.setFlashMode(FlashMode.off);
    log('图片位置: ${image.path}');
    setState(() {
      _imagePath = image.path;
    });
  }

  @override
  void initState() {
    super.initState();
    _getCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO 维护应用生命周期中相机的生命
    if (state == AppLifecycleState.inactive) {
      // 销毁相机
      _cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // 重新创建相机
      _initCameraController();
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: (_imagePath.isEmpty ? _cameraView() : _pictureView()),
          ),
          Positioned(
            top: 5,
            left: 5,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(
                Icons.close,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 拍照界面
  List<Widget> _cameraView() {
    return [
      Expanded(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CameraPreview(_cameraController),
        ),
      ),
      FilledButton(
        onPressed: () => _takePicture(),
        child: const Text('拍照'),
      )
    ];
  }

  /// 图片预览界面
  List<Widget> _pictureView() {
    return [
      Expanded(
        child: Image(
          image: FileImage(File(_imagePath)),
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              debugPrint('image loading null');
              return child;
            }
            debugPrint('image loading...');
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton(
            onPressed: () {
              widget.onPhotoTaken(_imagePath);
              context.pop();
            },
            child: const Text('确认'),
          ),
          FilledButton(
            onPressed: () {
              setState(() => _imagePath = '');
            },
            child: const Text('重拍'),
          ),
        ],
      )
    ];
  }
}
