import 'dart:ffi';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'unimp_sdk_plugin_platform_interface.dart';

/// An implementation of [UnimpSdkPluginPlatform] that uses method channels.
class MethodChannelUnimpSdkPlugin extends UnimpSdkPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('unimp_sdk_plugin');

  final _dio = Dio();
  final _fileExt = '.wgt';

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> isExistsUniMP(String appid) async {
    return await methodChannel.invokeMethod("isExistsUniMP", appid);
  }

  @override
  Future<bool?> closeAll() async {
    return await methodChannel.invokeMethod('closeAll');
  }

  @override
  Future<bool> openUniMP(String appid,
      {Map<String, dynamic>? configuration}) async {
    String path = await _localPath;
    bool isLink = appid.startsWith("http");
    String realAppid = isLink ? Uri.parse(appid).pathSegments.last.replaceFirst(_fileExt, ''): appid;
    bool exist = await isExistsUniMP(realAppid);
    print("app -- $realAppid, exist: $exist");
    if(!exist){
      // 获取文件并释放
      String wgtPath = "$path/$realAppid$_fileExt";
      print("url: $appid, location: $wgtPath");
      await _dio.download(appid, wgtPath);
      print("load ok");
      dynamic installed = await methodChannel.invokeMethod<dynamic>("releaseWgtWithAppid", {"appid": realAppid, "wgtPath": wgtPath});
      print("$realAppid installed: $installed");
    }
    dynamic test = await methodChannel.invokeMethod("openUniMP", {"appid": realAppid, "configuration": configuration});
    print("cccc $test");
    return Future(() => false);
  }

  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();

    return "${directory.path}/apps";
  }
  Future<String> getAppBasePath() async{
    // 安卓获取运行目录
    return await methodChannel.invokeMethod("getAppBasePath");
  }

  /// 清除本地所有小程序资源
  Future<void> clearAllAppRuntimeDictionary() async {
    await closeAll();

    //获取小程序的运行目录
    String? runningPath;
    if (Platform.isAndroid) {
      runningPath = await getAppBasePath();
    } else {
      runningPath = "${(await getLibraryDirectory()).path}/Pandora/apps/";
    }

    if (runningPath == null) {
      return;
    }

    Directory appDirectory = Directory(runningPath);
    if (appDirectory.existsSync()) {
      List<FileSystemEntity> appHome = appDirectory.listSync();
      for (var element in appHome) {
        element.deleteSync(recursive: true);
      }
    }
  }
}
