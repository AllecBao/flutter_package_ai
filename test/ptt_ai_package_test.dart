import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptt_ai_package/ptt_ai_package.dart';
import 'package:ptt_ai_package/ptt_ai_package_platform_interface.dart';
import 'package:ptt_ai_package/ptt_ai_package_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPttAiPackagePlatform
    with MockPlatformInterfaceMixin
    implements PttAiPackagePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future showAiBottomSheet(BuildContext context) {
    // TODO: implement showAiBottomSheet
    throw UnimplementedError();
  }
}

void main() {
  final PttAiPackagePlatform initialPlatform = PttAiPackagePlatform.instance;

  test('$MethodChannelPttAiPackage is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPttAiPackage>());
  });

  test('getPlatformVersion', () async {
    PttAiPackage pttAiPackagePlugin = PttAiPackage();
    MockPttAiPackagePlatform fakePlatform = MockPttAiPackagePlatform();
    PttAiPackagePlatform.instance = fakePlatform;
  
    expect(await pttAiPackagePlugin.getPlatformVersion(), '42');
  });
}
