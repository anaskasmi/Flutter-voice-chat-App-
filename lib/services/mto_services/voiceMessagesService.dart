import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:my_project_name/models/driver.dart';
import 'package:my_project_name/providers/driver_providers/mto_auth_provider.dart';
import 'package:my_project_name/services/fire_base_services/mto_api_service.dart';
import 'package:provider/provider.dart';

class VoiceMessagesService {
  Future<http.StreamedResponse> storeVoiceMessages(
      String filePath, String duration) async {
    //get owner info
    Driver currentDriver = await DriverMTOAuthProvider().currentDriver;
    DocumentReference documentReference =
        await FireBaseMtoApiService('voice_messages').addDocument({
      'created_at': Timestamp.now(),
      'duration_in_sec': duration,
      'file_path': null,
      'owner_full_name': currentDriver.firstName + " " + currentDriver.lastName,
      'owner_id': currentDriver.badgeId,
      'picture_url': currentDriver.pictureUrl,
    });
    //upload voicemessage to fire store
    StorageReference storageReference = FirebaseStorage.instance.ref().child(
        '/voice_messages/' +
            currentDriver.badgeId +
            "_" +
            DateTime.now().millisecondsSinceEpoch.toString());
    StorageUploadTask uploadTask = storageReference.putFile(
      File(filePath),
      StorageMetadata(
        contentType: 'audio/m4a',
        customMetadata: <String, String>{'file': 'audio'},
      ),
    );
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      //upload document
      FireBaseMtoApiService('voice_messages')
          .updateDocumentByReference(documentReference, {
        'file_path': fileURL,
      });
    });
  }
}
