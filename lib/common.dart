import 'package:flutter/material.dart';
import 'package:ptt_ai_package/common/config.dart';

import 'views/home_view.dart';

/// 返回数据格式：{'errorMsg': '麦克风权限未打开','errorType':'1'}
/// errorType：0接口错误信息，1授权错误
/// {"isNativePage": 是否是web地址, "url": 路由地址}
/// isDebug：
/// scaleWidth: 实际尺寸与UI设计的比例
/// type: 0:录音；1:播报语音
/// openVolume: 是否打开声音
Future<dynamic> showMainView(
  context, {
  required int type, //0:录音；1:播报语音
  int? time,
  bool isDebug = false,
  double scaleWidth = 1,
  bool? openVolume,
  List<String>? audioTextArray, //如果有值，则自动播放内容语音
  String? promptText, //弹框提示词
  String? imageBg, //背景图
}) async {
  debug = isDebug;
  return await showModalBottomSheet(
      context: context,
      routeSettings: const RouteSettings(name: '/ptt/aiDialog'),
      barrierColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: (Radius.circular(10)), topRight: (Radius.circular(10)))),
      builder: (BuildContext context) {
        return HomeView(
          type: type,
          time: time,
          isDebug: isDebug,
          scaleWidth: scaleWidth,
          openVolume: openVolume,
          audioTextArray: audioTextArray,
          promptText: promptText,
          imageBg: imageBg,
        );
      });
}
