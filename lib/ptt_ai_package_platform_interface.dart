import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:ptt_ai_package/ptt_ai_package.dart';

import 'ptt_ai_package_method_channel.dart';

abstract class PttAiPackagePlatform extends PlatformInterface {
  /// Constructs a PttAiPackagePlatform.
  PttAiPackagePlatform() : super(token: _token);

  static final Object _token = Object();

  static PttAiPackagePlatform _instance = MethodChannelPttAiPackage();

  /// The default instance of [PttAiPackagePlatform] to use.
  ///
  /// Defaults to [MethodChannelPttAiPackage].
  static PttAiPackagePlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PttAiPackagePlatform] when
  /// they register themselves.
  static set instance(PttAiPackagePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

}
