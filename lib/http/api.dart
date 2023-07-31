import 'package:dio/dio.dart';

import 'request.dart';

class Api{

  static voiceToTextToSkip(data,{CancelToken? cancelToken}) async {

   return await RequestService().fetchData('file', '/app-common/voice/voiceToTextToSkip', {}, data,cancelToken: cancelToken);
  }
}