import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:logger/logger.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:my_project_name/services/mto_services/databaseService.dart';
import 'package:my_project_name/services/mto_services/voiceMessagesService.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vibration/vibration.dart';

class AudioRecordProvider with ChangeNotifier {
  final dbService = DatabaseService.instance;
  final assetsAudioPlayer = AssetsAudioPlayer();
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  String finalPath;
  String voiceMessageSendingStatus;

  Duration get duration {
    return this._current.duration;
  }

  Future<void> startRecording() async {
    // assetsAudioPlayer.open(
    //   Audio("assets/audios/start_recording.mp3"),
    // );
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 100);
    } else {
      Logger().e("no permessions for vibrationg");
    }

    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        String customPath = '/MyTaxOffice_audios_';
        io.Directory appDocDirectory;
        if (io.Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }
        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString();
        _recorder =
            FlutterAudioRecorder(customPath, audioFormat: AudioFormat.AAC);
        await _recorder.initialized;
        _current = await _recorder.current(channel: 0);
        _currentStatus = _current.status;
      } else {
        //todo : manage to ask permissions
        Logger().wtf("Permessions must be granted to this app");
      }
    } catch (e) {
      Logger().e("error raised while init recording :" + e);
    }
    try {
      await _recorder.start();
      var recording = await _recorder.current(channel: 0);
      _current = recording;

      const tick = const Duration(milliseconds: 50);
      new Timer.periodic(tick, (Timer t) async {
        if (_currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }

        var current = await _recorder.current(channel: 0);
        _current = current;
        _currentStatus = _current.status;
        // notifyListeners();
      });
    } catch (e) {
      print("error raised in start recording :" + e);
    }
  }

  Future<void> sendRecord() async {
    assetsAudioPlayer.open(
      Audio("assets/audios/send_record.mp3"),
    );
    await stopRecord();
    voiceMessageSendingStatus = "loading";
    notifyListeners();
    await VoiceMessagesService()
        .storeVoiceMessages(this.finalPath, this.duration.inSeconds.toString())
        .then((response) {
      if (response.statusCode == 200) {
        voiceMessageSendingStatus = "sent";
      } else {
        voiceMessageSendingStatus = "failed";
      }
      voiceMessageSendingStatus = null;
      notifyListeners();

      print('uploaded');
    });
  }

  Future<void> stopRecord() async {
    try {
      var result = await this._recorder.stop();
      print("Stop recording path: ${result.path}");
      finalPath = result.path;
      print("Stop recording duration : ${result.duration}");
    } catch (e) {
      Logger().wtf("couldnt save the record please try again");
    }
    assetsAudioPlayer.open(
      Audio("assets/audios/cancel_recording.mp3"),
    );
  }
}
