import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptt_ai_package/ptt_ai_package_method_channel.dart';

void main() {
  MethodChannelPttAiPackage platform = MethodChannelPttAiPackage();
  const MethodChannel channel = MethodChannel('ptt_ai_package');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
