
import 'package:flutter/widgets.dart';

import 'ptt_ai_package_platform_interface.dart';
export 'common.dart';
class PttAiPackage {
  Future<String?> getPlatformVersion() {
    return PttAiPackagePlatform.instance.getPlatformVersion();
  }
}
