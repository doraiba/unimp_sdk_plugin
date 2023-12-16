import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'unimp_sdk_plugin_platform_interface.dart';

/// An implementation of [UnimpSdkPluginPlatform] that uses method channels.
class MethodChannelUnimpSdkPlugin extends UnimpSdkPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('unimp_sdk_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
