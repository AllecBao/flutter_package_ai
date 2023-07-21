import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 创建文件获取路径
Future<String?> createFileGetPath({
  required String fileName,
  bool tempFile = false,
  String? dirName,
}) async {
  try {
    final appDocDir = (await getAppDirectory(isTemp: tempFile)).path;
    var context = p.Context(style: p.Style.platform);
    String filePath = appDocDir;
    if (dirName != null) {
      filePath = context.join(appDocDir, dirName);
      if (!await Directory(filePath).exists()) {
        await Directory(filePath).create();
      }
    }
    filePath = context.join(filePath, fileName);
    return filePath;
  } catch (e) {
    
  }
  return null;
}

/// 获取app目录
Future<Directory> getAppDirectory({isTemp = false}) async {
  Directory? appDocDir;
  if (Platform.isAndroid) {
    if (isTemp) {
      List<Directory>? dirList = await getExternalCacheDirectories();
      if (dirList != null && dirList.isNotEmpty) {
        appDocDir = dirList[0];
      } else {
        appDocDir ??= await getTemporaryDirectory();
      }
    } else {
      appDocDir = await getExternalStorageDirectory();
      appDocDir ??= await getTemporaryDirectory();
    }
  } else {
    if (isTemp) {
      appDocDir = await getTemporaryDirectory();
    } else {
      appDocDir = await getApplicationDocumentsDirectory();
    }
  }
  return appDocDir;
}