import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import 'unimp_sdk_plugin_platform_interface.dart';

/// An implementation of [UnimpSdkPluginPlatform] that uses method channels.
class MethodChannelUnimpSdkPlugin extends UnimpSdkPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('unimp_sdk_plugin');

  void registerDefaultCall(){
    methodChannel.setMethodCallHandler((call) => call.arguments);
  }
  @override
  void registerCallHandler(Future<dynamic> Function(MethodCall call)? handler){
    methodChannel.setMethodCallHandler(handler);
  }

  final _dio = Dio();
  final _fileExt = '.wgt';
  final logger = Logger();

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
      {Map<String, dynamic>? extraData, int? version}) async {
    String path = await _localPath;
    bool isLink = appid.startsWith("http");
    String realAppid = isLink
        ? Uri.parse(appid).pathSegments.last.replaceFirst(_fileExt, '')
        : appid;
    bool exist = await isExistsUniMP(realAppid);
    String wgtPath = "$path/$realAppid$_fileExt";
    logger.i("[$realAppid]: exist => $exist, path: $wgtPath");

    if (!exist && !isLink) {
      throw UnsupportedError("$realAppid not found");
    }
    var fetch = false;
    if (!exist) {
      fetch = true;
    }
    if (!fetch && version != null) {
      bool upd =  await updateCheck(realAppid, version) ?? true;
      fetch = upd && isLink;
    }
    if(fetch) {
      logger.i("[$realAppid]: link => $appid, version => $version");
      await release(realAppid, appid, wgtPath);
    }

    Map<Object?, Object?>? r = await methodChannel
        .invokeMethod(
            "openUniMP", {"appid": realAppid, "extraData": extraData});
    logger.i("result: $r");
    return r?['ok'] as bool;
  }

  Future<bool?> updateCheck(String appid,int version){
    return  methodChannel
        .invokeMethod("updateCheck", {"appid": appid, version: version});
  }

  Future<void> release(
      String appid, String url, String path) async {
    await _dio.download(url, path);
    await methodChannel.invokeMethod(
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
