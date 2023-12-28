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
      {Map<String, dynamic>? configuration, int? version}) async {
    String path = await _localPath;
    bool isLink = appid.startsWith("http");
    String realAppid = isLink
        ? Uri.parse(appid).pathSegments.last.replaceFirst(_fileExt, '')
        : appid;
    bool exist = await isExistsUniMP(realAppid);
    debugPrint("app -- $realAppid, exist: $exist");
    String wgtPath = "$path/$realAppid$_fileExt";

    if (!exist) {
      await release(realAppid, appid, wgtPath);
    }
    if (version != null) {
      bool needUpdate = await methodChannel
          .invokeMethod("updateCheck", {"appid": realAppid, version: version});
      if (needUpdate) {
        await release(realAppid, appid, wgtPath);
      }
    }

    Map<String, dynamic>? r = await methodChannel
        .invokeMethod<Map<String, dynamic>>(
            "openUniMP", {"appid": realAppid, "extraData": configuration});
    return r?['ok'] ?? false;
  }

  Future<Map<String, dynamic>?> release(
      String appid, String url, String path) async {
    await _dio.download(url, path);
    return methodChannel.invokeMethod<Map<String, dynamic>>(
        "releaseWgtWithAppid", {"appid": appid, "wgtPath": path});
  }

  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();

    return "${directory.path}/apps";
  }

  Future<String> getAppBasePath() async {
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

    Directory appDirectory = Directory(runningPath);
    if (appDirectory.existsSync()) {
      List<FileSystemEntity> appHome = appDirectory.listSync();
      for (var element in appHome) {
        element.deleteSync(recursive: true);
      }
    }
  }
}
