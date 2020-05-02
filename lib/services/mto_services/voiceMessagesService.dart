import 'package:http/http.dart' as http;
import 'package:my_project_name/services/mto_services/mto_api_service.dart';

class VoiceMessagesService extends MTOApiService {
  Future<http.Response> getNewVoiceMessages(int lastId) async {
    return await httpGet('driver/voiceMessages/newVoiceMessages/$lastId');
  }

  Future<http.Response> getAllVoiceMessages() async {
    return await httpGet('driver/voiceMessages/templates');
  }

  Future<http.StreamedResponse> storeVoiceMessages(
      String filePath, String duration) async {
    return await httpPostWithFile(
        'driver/voiceMessage', filePath, 'voice_message', duration);
  }
}
