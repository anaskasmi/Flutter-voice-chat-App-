import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:my_project_name/providers/driver_providers/mto_auth_provider.dart';
import 'package:my_project_name/utilities/user_interface_utilities/screen_size.dart';
import 'package:audioplayers/audioplayers.dart' as AudioPlayers;

class FireBaseVoiceMessagesProvider with ChangeNotifier {
  String myBadgeId = "";
  final audioPlayer = new AudioPlayer();
  final audioPlayers = AudioPlayers.AudioPlayer();

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
          audioPlayers.play(change.document.data['file_path']);
//          try {
//              assetsAudioPlayer.open(
//                Audio.network(change.document.data['file_path']),
////                Audio.network("https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_2MG.mp3"),
//              );
//          } catch (t) {
//            Logger().e('couldnt play audio');
//          }
        }
      });
    });
    return stream;
  }
}
