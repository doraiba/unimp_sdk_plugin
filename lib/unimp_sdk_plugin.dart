// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'unimp_sdk_plugin_platform_interface.dart';

class UnimpSdkPlugin {
  Future<String?> getPlatformVersion() {
    return UnimpSdkPluginPlatform.instance.getPlatformVersion();
  }

  Future<bool> isExistsUniMP(String appid) {
    return UnimpSdkPluginPlatform.instance.isExistsUniMP(appid);
  }

  Future<bool> openUniMP(String appid, {Map<String, dynamic>? extraData, int? version}) {
    return UnimpSdkPluginPlatform.instance
        .openUniMP(appid, extraData: extraData, version: version);
  }

  Future<bool?> closeAll() {
    return UnimpSdkPluginPlatform.instance.closeAll();
  }
}
