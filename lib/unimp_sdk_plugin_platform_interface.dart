import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'unimp_sdk_plugin_method_channel.dart';

abstract class UnimpSdkPluginPlatform extends PlatformInterface {
  /// Constructs a UnimpSdkPluginPlatform.
  UnimpSdkPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static UnimpSdkPluginPlatform _instance = MethodChannelUnimpSdkPlugin();

  /// The default instance of [UnimpSdkPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelUnimpSdkPlugin].
  static UnimpSdkPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UnimpSdkPluginPlatform] when
  /// they register themselves.
  static set instance(UnimpSdkPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
