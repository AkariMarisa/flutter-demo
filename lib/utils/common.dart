String intListToHexString(List<int> list) {
  String s = '';

  for (int i in list) {
    s += '${i.toRadixString(16)} ';
  }

  return '0x${s.toUpperCase()}';
}

List<int> hexStringToIntList(String hex) {
  // 去掉前缀0x
  if (hex.startsWith('0x')) hex = hex.replaceFirst('0x', '');

  // 如果数据不是成对的，则前补0
  if (hex.length % 2 != 0) hex = '0$hex';

  List<int> l = [];

  int size = hex.length ~/ 2;

  for (int i = 0; i < size ; i ++) {
    l.add(int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16));
  }

  return l;
}
