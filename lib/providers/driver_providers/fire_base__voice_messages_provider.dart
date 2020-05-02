import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:my_project_name/models/voice_message.dart';
import 'package:my_project_name/services/fire_base_services/mto_api_service.dart';
import 'package:logger/logger.dart';

class FireBaseVoiceMessagesProvider with ChangeNotifier {
  List<VoiceMessage> _voiceMessagesFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((document) {
      var fields = document.data;
      return VoiceMessage(
        ownerId: fields['owner_id'] ?? '',
        durationInSec: fields['duration_in_sec'] ?? '',
        ownerFullName: fields['owner_full_name'] ?? '',
        pictureUrl: fields['picture_url'] ?? '',
        url: fields['file_path'] ?? '',
        createdAt: fields['created_at'] ?? '',
      );
    }).toList();
  }

  Stream<List<VoiceMessage>> get voiceMessages {
    FireBaseMtoApiService service = FireBaseMtoApiService("voice_messages");
    Stream<List<VoiceMessage>> l =
        service.streamDataCollection().map(_voiceMessagesFromSnapshot);
    return l;
  }
}
