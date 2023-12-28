import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:unimp_sdk_plugin/unimp_sdk_plugin.dart';
import 'package:unimp_sdk_plugin/unimp_sdk_plugin_platform_interface.dart';
import 'package:unimp_sdk_plugin/unimp_sdk_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockUnimpSdkPluginPlatform
    with MockPlatformInterfaceMixin
    implements UnimpSdkPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> isExistsUniMP(String appid) {
    // TODO: implement isExistsUniMP
    throw UnimplementedError();
  }

  @override
  Future<bool?> closeAll() {
    // TODO: implement closeAll
    throw UnimplementedError();
  }

  @override
  Future<bool> openUniMP(String appid, {Map<String, dynamic>? extraData, int? version}) {
    // TODO: implement openUniMP
    throw UnimplementedError();
  }


}

void main() {
  final UnimpSdkPluginPlatform initialPlatform = UnimpSdkPluginPlatform.instance;

  test('$MethodChannelUnimpSdkPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelUnimpSdkPlugin>());
  });

  test('getPlatformVersion', () async {
    UnimpSdkPlugin unimpSdkPlugin = UnimpSdkPlugin();
    MockUnimpSdkPluginPlatform fakePlatform = MockUnimpSdkPluginPlatform();
    UnimpSdkPluginPlatform.instance = fakePlatform;

    expect(await unimpSdkPlugin.getPlatformVersion(), '42');
  });
}
