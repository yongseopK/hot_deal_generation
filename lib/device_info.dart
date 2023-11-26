import 'dart:io';

import 'package:device_info/device_info.dart';

Future<Map<String, dynamic>> _getDeviceInfo() async {
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> deviceData = <String, dynamic>{};

  try {
    if (Platform.isAndroid) {
      deviceData = _readAndroidDeviceInfo(await deviceInfoPlugin.androidInfo);
    } else if (Platform.isIOS) {
      deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
    }
  } catch (e) {
    deviceData = {"Error": "Failed to get platform version."};
  }
  return deviceData;
}

Map<String, dynamic> _readAndroidDeviceInfo(AndroidDeviceInfo info) {
  var release = info.version.release;
  var sdkInt = info.version.sdkInt;
  var manufacturer = info.manufacturer;
  var model = info.model;

  return {
    "OS 버전": "Android $release (SDK $sdkInt)",
    "\n기기": "$manufacturer $model\n"
  };
}

Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo info) {
  var systemName = info.systemName;
  var version = info.systemVersion;
  var machine = info.utsname.machine;

  return {"OS 버전": "$systemName $version", "\n기기": '$machine\n'};
}

Future<String> getEmailBody() async {
  Map<String, dynamic> deviceInfo = await _getDeviceInfo();

  String body = "";

  body += "===================\n";
  body += "아래의 내용을 함께 보내주시면 큰 도움이 됩니다.\n";

  deviceInfo.forEach((key, value) {
    body += "$key : $value";
  });

  body += "\n===================\n";

  return body;
}
