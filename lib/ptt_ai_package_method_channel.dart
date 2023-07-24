import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ptt_ai_package_platform_interface.dart';

/// An implementation of [PttAiPackagePlatform] that uses method channels.
class MethodChannelPttAiPackage extends PttAiPackagePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ptt_ai_package');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
