import 'package:dio/dio.dart';

import 'request.dart';

class Api{

  //语音处理
  static voiceToTextToSkip(data,{CancelToken? cancelToken}) async {

   return await RequestService().fetchData('file', '/app-common/voice/voiceToTextToSkip', {}, data,cancelToken: cancelToken);
  }

  //文字转语音
  static textToVoice(data,{CancelToken? cancelToken}) async {

    return await RequestService().fetchData('post', '/app-common/voice/textToVoice', {}, data,cancelToken: cancelToken);
  }
}