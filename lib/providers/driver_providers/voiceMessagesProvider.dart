import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:my_project_name/services/mto_services/databaseService.dart';
import 'package:vibration/vibration.dart';

class VoiceMessagesProvider with ChangeNotifier {
  final audioPlayer = AudioPlayer();
  final dbService = DatabaseService.instance;
  bool isPlaying = false;
  bool alreadyFetchedAudios;
  String currentMessageId;
  bool isLoading = false;
  bool playSoundNotification = true;
  bool get getIsPlaying {
    return this.isPlaying;
  }

  void setIsPlaying(bool newVal) {
    this.isPlaying = newVal;
    notifyListeners();
    print("setIsPlaying notifyListeners");
  }

  AudioPlayerState get getState {
    audioPlayer.onPlayerStateChanged.listen((s) {
      print("getState notifyListeners");
      notifyListeners();

      return s;
    });
    return this.audioPlayer.state;
  }

  Future<void> playAudio(String audioUrl, String id) async {
    this.isLoading = true;
    this.currentMessageId = id;
    notifyListeners();
    print("playAudio notify listeners");

    audioPlayer.stop().then((_) {
      audioPlayer.play(audioUrl).then((_) {
        this.isLoading = false;
        notifyListeners();
        print("playAudio notify listeners2");
      });
    });

    audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.STOPPED) {
        notifyListeners();
        print("onPlayerStateChanged notify listeners");
      }
    });
  }

  int get getCurrentSecond {
    return audioPlayer.duration.inSeconds;
  }

  Future<void> pauseAudio(int id) async {
    this.isLoading = true;
    this.currentMessageId = null;

    notifyListeners();
    print("pauseAudio notify listeners");

    audioPlayer.pause().then((_) {
      setIsPlaying(false);
      this.isLoading = false;
      notifyListeners();
      print("pauseAudio notify listeners 2");
    });
  }

  Future<void> stopAudio() async {
    this.isLoading = true;
    notifyListeners();
    print("stopAudio notify listeners 1");

    audioPlayer.stop().then((_) {
      setIsPlaying(false);
      this.isLoading = false;
      notifyListeners();
      print("stopAudio notify listeners 2");
    });
  }

  Future<void> playNotificationSound() async {
    final assetsAudioPlayer = AssetsAudioPlayer();
    if (playSoundNotification == true) {
      assetsAudioPlayer.open(
        Audio("assets/audios/send_record.mp3"),
      );
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 100);
      } else {
        Logger().e("no permessions for vibrationg");
      }
      playSoundNotification = false;
    }
    Timer(Duration(seconds: 5), () {
      playSoundNotification = true;
    });
  }
}
