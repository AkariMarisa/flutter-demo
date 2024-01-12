import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_demo/utils/common.dart';
import 'package:flutter_demo/utils/toast.dart';
import 'package:go_router/go_router.dart';

import '../components/form.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<StatefulWidget> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  bool _canUseBluetooth = false;
  StreamSubscription? _bluetoothListener;
  bool _isAdapterOn = false;
  bool _isScanning = false;
  List<ScanResult> _bluetoothDevices = <ScanResult>[];
  BluetoothDevice? _connectedDevice;
  StreamSubscription? _notifyListener;
  String _responseText = '';
  String _writeData = '';

  @override
  void initState() {
    super.initState();

    FlutterBluePlus.isSupported.then((isSupported) {
      if (!isSupported) {
        showToast('该设备不支持蓝牙操作');
      } else {
        setState(() => _canUseBluetooth = true);
        _initBluetoothListener();
      }
    });
  }

  @override
  void dispose() {
    _bluetoothListener?.cancel();
    super.dispose();
  }

  /// 初始化蓝牙监听器，监听蓝牙适配器状态
  void _initBluetoothListener() {
    // 清理之前的监听器
    if (_bluetoothListener != null) {
      _bluetoothListener!.cancel();
    }

    _bluetoothListener =
        FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      log('蓝牙适配器状态: $state');
      if (state == BluetoothAdapterState.on) {
        setState(() => _isAdapterOn = true);
      } else {
        // TODO 包含除适配器开启的其他状态，包括关闭状态
      }
    });
  }

  /// 手动开启蓝牙适配器
  void _startBluetoothAdapter() {
    // iOS只能用户控制蓝牙开关，所以只有Android下才能代码控制
    if (Platform.isAndroid) {
      FlutterBluePlus.turnOn();
    }
  }

  /// 扫描附近蓝牙设备
  Future<void> _scanDevices() async {
    /*
      TODO 这里扫描应该只是扫描一次，如果需要持续扫描附近的设备，需要缩短扫描持续时间，
       并通过计时器或其他方式反复开启扫描
    */

    // listen to scan results
    // Note: `onScanResults` only returns live scan results, i.e. during scanning
    // Use: `scanResults` if you want live scan results *or* the previous results
    StreamSubscription subscription = FlutterBluePlus.onScanResults.listen(
      (results) async {
        if (results.isNotEmpty) {
          _bluetoothDevices.clear();
          setState(() => _bluetoothDevices = results);
        }
      },
      onError: (e) => log(e),
    );

    // cleanup: cancel subscription when scanning stops
    FlutterBluePlus.cancelWhenScanComplete(subscription);

    // Start scanning w/ timeout
    // optional: use `stopScan()` to stop the scan at anytime
    await FlutterBluePlus.startScan(timeout: const Duration(minutes: 1));

    setState(() => _isScanning = true);

    // wait for scanning to stop
    FlutterBluePlus.isScanning
        .where((val) => val == false)
        .first
        .then((value) => setState(() => _isScanning = false));
  }

  /// 停止蓝牙扫描
  Future<void> _stopScanning() async {
    await FlutterBluePlus.stopScan();

    setState(() => _isScanning = false);
  }

  /// 连接蓝牙设备
  Future<void> _connectDevice(BluetoothDevice device) async {
    // 关闭之前设备的连接
    await _connectedDevice?.disconnect();

    /*
      TODO 可能需要监听蓝牙设备断开事件，要么更新界面可以让用户重新连接，
        要么需要自动重连
     */
    // listen for disconnection
    // var subscription =
    //     device.connectionState.listen((BluetoothConnectionState state) async {
    //   if (state == BluetoothConnectionState.disconnected) {
    //     // 1. typically, start a periodic timer that tries to
    //     //    reconnect, or just call connect() again right now
    //     // 2. you must always re-discover services after disconnection!
    //     print(
    //         "${device.disconnectReason?.code} ${device.disconnectReason?.description}");
    //   }
    // });

    showToast('尝试连接到设备${device.advName}');
    // Connect to the device
    await device.connect();
    showToast('连接成功');

    setState(() => _connectedDevice = device);
  }

  /// 断开蓝牙设备连接
  Future<void> _disconnectDevice(BluetoothDevice device) async {
    showToast('正在断开连接');
    await device.disconnect();
    showToast('断开成功');
  }

  /// 发现蓝牙设备的Service
  Future<List<BluetoothService>> _discoverServices(
      BluetoothDevice device) async {
    return await device.discoverServices();
  }

  /// 显示设备Service的对话框
  void _showServiceDialog(BluetoothDevice device) {
    // 显示Loading
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.white,
          ));
        });

    _discoverServices(device).then((services) {
      context.pop();

      if (services.isEmpty) {
        showToast('当前设备无Service，或Service获取失败。');
        return;
      }

      showDialog(
        useSafeArea: true,
        barrierDismissible: false,
        context: context,
        builder: (_) => _buildServiceDialog(device, services),
      );
    });
  }

  /// 显示读取指令对话框
  void _showReadDialog(BluetoothCharacteristic characteristic) {
    showDialog(
      useSafeArea: true,
      context: context,
      builder: (BuildContext context) => _buildReadDialog(characteristic),
    );
  }

  Future<void> _read(BluetoothCharacteristic characteristic) async {
    List<int> response = await characteristic.read();
    log(response.toString());
    setState(() => _responseText = intListToHexString(response));
  }

  /// 显示写入指令对话框
  void _showWriteDialog(BluetoothCharacteristic characteristic,
      {bool ignoreResponse = true}) {
    _writeData = '';
    showDialog(
      useSafeArea: true,
      context: context,
      builder: (BuildContext context) =>
          _buildWriteDialog(characteristic, ignoreResponse),
    );
  }

  Future<void> _write(
      BluetoothCharacteristic characteristic, bool ignoreResponse) async {
    if (_writeData.isEmpty) return;

    await characteristic.write(hexStringToIntList(_writeData),
        withoutResponse: ignoreResponse);
  }

  /// 显示推送数据对话框
  void _showNotifyDialog(
      BluetoothDevice device, BluetoothCharacteristic characteristic) {
    showDialog(
      useSafeArea: true,
      context: context,
      builder: (BuildContext context) =>
          _buildNotifyDialog(device, characteristic),
    ).then((value) {
      characteristic.setNotifyValue(false);
    });
  }

  Future<void> _notify(
      BluetoothDevice device, BluetoothCharacteristic characteristic) async {
    // 先把之前的监听器删除掉
    if (_notifyListener != null) _notifyListener!.cancel();

    _notifyListener = characteristic.onValueReceived.listen((value) {
      // onValueReceived is updated:
      //   - anytime read() is called
      //   - anytime a notification arrives (if subscribed)
      log('收到订阅的消息了 ${value.toString()}');
      // FIXME 需要解决无法通过修改state重绘InputText的问题
      setState(() => _responseText = intListToHexString(value));
    });

    // cleanup: cancel subscription when disconnected
    device.cancelWhenDisconnected(_notifyListener!);

    // subscribe
    // Note: If a characteristic supports both **notifications** and **indications**,
    // it will default to **notifications**. This matches how CoreBluetooth works on iOS.
    await characteristic.setNotifyValue(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('蓝牙Low Energy'),
      ),
      body: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            children: [
              FilledButton(
                onPressed: !_canUseBluetooth
                    ? null
                    : (_isAdapterOn ? null : () => _startBluetoothAdapter()),
                child: Text(!_canUseBluetooth
                    ? '蓝牙不可用'
                    : _isAdapterOn
                        ? '已开启蓝牙'
                        : '开启蓝牙'),
              ),
              FilledButton(
                style: _isScanning
                    ? ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.redAccent),
                      )
                    : null,
                onPressed: () {
                  if (!_canUseBluetooth || !_isAdapterOn) return;
                  _isScanning ? _stopScanning() : _scanDevices();
                },
                child: _isScanning ? const Text('停止扫描') : const Text('开始扫描'),
              ),
            ],
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '*蓝牙扫描时，如果一直没有扫描到新设备，将不会清理原先扫描到的结果列表',
                style: TextStyle(
                    fontSize: 8,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                '*参见https://pub.dev/packages/flutter_blue_plus',
                style: TextStyle(
                    fontSize: 8,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: _buildDeviceList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 构造蓝牙设备列表
  List<Widget> _buildDeviceList() {
    List<Widget> list = <Widget>[];
    if (_bluetoothDevices.isNotEmpty) {
      for (var result in _bluetoothDevices) {
        log('设备ID: ${result.device.remoteId} 设备名称: ${result.advertisementData.advName} '
            'RSSI: ${result.rssi} MTU: ${result.device.mtuNow}');
        list.add(
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '设备名 ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(result.advertisementData.advName),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            '设备ID ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(result.device.remoteId.toString()),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'RSSI ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(result.rssi.toString()),
                  ],
                ),
                SizedBox(
                  width: 24,
                  child: PopupMenuButton(
                    surfaceTintColor: Colors.white,
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        child: const Text('连接'),
                        onTap: () async {
                          await _connectDevice(result.device);
                          _showServiceDialog(result.device);
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }
    }
    return list;
  }

  /// 构建Service弹窗
  Widget _buildServiceDialog(
      BluetoothDevice device, List<BluetoothService> service) {
    List<Widget> rows = [];

    for (var service in service) {
      List<Widget> characteristics = [];

      for (var characteristic in service.characteristics) {
        characteristics.add(ExpansionTile(
          title: Text('UUID ${characteristic.uuid}'),
          children: () {
            List<Widget> l = [];
            if (characteristic.properties.broadcast) {
              l.add(const ListTile(title: Text('Broadcast true')));
            }

            if (characteristic.properties.read) {
              l.add(ListTile(
                title: const Text('Read true'),
                trailing: IconButton(
                  onPressed: () => _showReadDialog(characteristic),
                  icon: const Icon(Icons.outbox),
                ),
              ));
            }

            if (characteristic.properties.write) {
              l.add(ListTile(
                title: const Text('Write true'),
                trailing: IconButton(
                  onPressed: () =>
                      _showWriteDialog(characteristic, ignoreResponse: false),
                  icon: const Icon(Icons.read_more),
                ),
              ));
            }

            if (characteristic.properties.writeWithoutResponse) {
              l.add(ListTile(
                title: const Text('Write without response true'),
                trailing: IconButton(
                  onPressed: () => _showWriteDialog(characteristic),
                  icon: const Icon(Icons.read_more),
                ),
              ));
            }

            if (characteristic.properties.notify) {
              l.add(ListTile(
                title: const Text('Notify true'),
                trailing: IconButton(
                  onPressed: () => _showNotifyDialog(device, characteristic),
                  icon: const Icon(Icons.notification_add),
                ),
              ));
            }

            if (characteristic.properties.indicate) {
              l.add(ListTile(
                title: const Text('Indicate true'),
                trailing: IconButton(
                  onPressed: () => _showNotifyDialog(device, characteristic),
                  icon: const Icon(Icons.notification_add),
                ),
              ));
            }

            if (characteristic.properties.authenticatedSignedWrites) {
              l.add(const ListTile(
                  title: Text('Authenticated signed writes true')));
            }

            if (characteristic.properties.extendedProperties) {
              l.add(const ListTile(title: Text('Extended properties true')));
            }

            if (characteristic.properties.notifyEncryptionRequired) {
              l.add(const ListTile(
                  title: Text('Notify encryption required true')));
            }

            if (characteristic.properties.indicateEncryptionRequired) {
              l.add(const ListTile(
                  title: Text('Indicate encryption required true')));
            }

            return l;
          }(),
        ));
      }

      rows.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Service UUID ${service.uuid.toString()}'),
          Text('Is primary? ${service.isPrimary}'),
          ExpansionTile(
            title: const Text('Characteristics'),
            subtitle: Text('总计${service.characteristics.length}个'),
            children: characteristics,
          ),
        ],
      ));
    }

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Card(
        color: Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    _disconnectDevice(device);
                    context.pop();
                  },
                  child: const Text('关闭并断开连接'),
                )
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  Column(
                    children: rows,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildReadDialog(BluetoothCharacteristic characteristic) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 200, horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InputText(
                      label: '响应数据', text: _responseText, maxLines: 10),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => _read(characteristic),
                    child: const Text('发送读取指令'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWriteDialog(
      BluetoothCharacteristic characteristic, bool ignoreResponse) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InputText(
                    label: '请求数据',
                    maxLines: 10,
                    listenValueChange: (value) => _writeData = value,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: InputText(
                      label: '响应数据', text: _responseText, maxLines: 10),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => _write(characteristic, ignoreResponse),
                    child: const Text('发送数据'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNotifyDialog(
      BluetoothDevice device, BluetoothCharacteristic characteristic) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 200, horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InputText(
                      label: '响应数据', text: _responseText, maxLines: 10),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => _notify(device, characteristic),
                    child: const Text('启用监听'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
