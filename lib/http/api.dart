import 'package:dio/dio.dart';

import '../model/audio_url_model.dart';
import 'request.dart';

class Api {
  /// 语音处理
  static voiceToTextToSkip(data, {CancelToken? cancelToken}) async {
    return await RequestService().fetchData(
      method: 'file',
      path: '/app-common/voice/voiceToTextToSkip',
      params: {},
      data: data,
      cancelToken: cancelToken,
    );
  }

  /// 文字转语音
  static Future<List<AudioUrlModel>?> textListToVoice({
    required List<AudioUrlModel> audioPathList,
    CancelToken? cancelToken,
  }) async {
    final dataList = audioPathList.map((e) {
      return {
        'alpha': 1.15,
        'gen_exp_name': 'zt',
        'text': e.path,
        'upload_oss': true
      };
    }).toList();
    final res = await RequestService().fetchDataList(
      method: 'post',
      path: '/app-common/voice/textToVoice',
      dataList: dataList,
      cancelToken: cancelToken,
    );
    if (res != null) {
      final resultList = <AudioUrlModel>[];
      for (var element in audioPathList) {
        resultList.add(AudioUrlModel(index: element.index, path: null));
      }
      for (var i = 0; i < res.length; i++) {
        final response = res[i].data;
        if (response["code"] == '10000') {
          var result = response["res"];
          if (result != null) {
            var index = resultList[i].index;
            resultList.setAll(i, [AudioUrlModel(index: index, path: result)]);
          }
        }
      }
      return resultList;
    }
    return null;
  }
}
