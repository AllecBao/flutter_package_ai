import 'request.dart';

class Api{

  static voiceToTextToSkip(data) async {
   return await RequestService().fetchData('file', '/app-common/voice/voiceToTextToSkip', {}, data);
  }
}