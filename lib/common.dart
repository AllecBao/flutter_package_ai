// import 'pages.dart';
import 'package:flutter/material.dart';

import 'views/home_view.dart';

/// 返回数据格式：{'errorMsg': '麦克风权限未打开','errorType':'1'}
/// errorType：0接口错误信息，1授权错误
/// {"isNativePage": 是否是web地址, "url": 路由地址}
/// isDebug：
/// scaleWidth: 实际尺寸与UI设计的比例
Future<dynamic> showMainView(
  context, {
  int? time,
  bool isDebug = false,
  double scaleWidth = 1,
}) async {
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
          time: time,
          isDebug: isDebug,
          scaleWidth: scaleWidth,
        );
      });
}
