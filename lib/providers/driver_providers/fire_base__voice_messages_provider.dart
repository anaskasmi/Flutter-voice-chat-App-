import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:my_project_name/models/driver.dart';
import 'package:my_project_name/models/voice_message.dart';
import 'package:my_project_name/providers/driver_providers/mto_auth_provider.dart';
import 'package:my_project_name/providers/driver_providers/voiceMessagesProvider.dart';
import 'package:my_project_name/screens/driver_screens/chilliwack_taxi_radio/local_widgets/conversation_item.dart';
import 'package:my_project_name/screens/driver_screens/chilliwack_taxi_radio/local_widgets/myConversationItem.dart';
import 'package:my_project_name/utilities/time_utilities/time_utils.dart';
import 'package:my_project_name/utilities/user_interface_utilities/screen_size.dart';

class FireBaseVoiceMessagesProvider with ChangeNotifier {
  String myBadgeId = "";

  buildImage(imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        height: SizeConfig.safeBlockVertical * 8,
        width: SizeConfig.safeBlockVertical * 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
        alignment: Alignment.center,
      ),
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }

  Stream<QuerySnapshot> get voiceMessages {
    DriverMTOAuthProvider().currentDriver.then((result) {
      myBadgeId = result.badgeId;
    });
    final assetsAudioPlayer = AssetsAudioPlayer();

    Stream<QuerySnapshot> stream = Firestore.instance
        .collection("voice_messages")
        .orderBy('created_at', descending: true)
        .limit(10)
        .snapshots();
    stream.listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((change) {
        if (change.type == DocumentChangeType.modified &&
            change.document.data['owner_id'] != myBadgeId) {
          AssetsAudioPlayer().open(
            Audio("assets/audios/send_record.mp3"),
          );

          BotToast.showSimpleNotification(
            title: change.document.data['owner_full_name'].toUpperCase(),
            subTitle: "Playing voice message..",
            duration: Duration(
                seconds:
                    int.parse(change.document.data['duration_in_sec']) + 5),
            hideCloseButton: true,
          );
//           VoiceMessagesProvider().playAudio(
//              change.document.data['file_path'], change.document.documentID);

          try {
              assetsAudioPlayer.open(
              Audio.network(change.document.data['file_path'],metas: Metas(
                title:  "Country",
                artist: "Florent Champigny",
                album: "CountryAlbum",
                image: MetasImage.asset("assets/images/country.jpg"), //can be MetasImage.network
              ),),
            );
          } catch (t) {
            Logger().e('couldnt play audio');
          }
        }
      });
    });
    return stream;
  }
}
