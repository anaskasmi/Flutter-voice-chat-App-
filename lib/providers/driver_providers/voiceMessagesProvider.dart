import 'dart:async';
import 'dart:convert';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:my_project_name/models/voice_message.dart';
import 'package:my_project_name/services/mto_services/databaseService.dart';
import 'package:my_project_name/services/mto_services/voiceMessagesService.dart';
import 'package:vibration/vibration.dart';

class VoiceMessagesProvider with ChangeNotifier {
  final audioPlayer = AudioPlayer();
  final dbService = DatabaseService.instance;
  final VoiceMessagesService _voiceMessagesService = VoiceMessagesService();
  List<Map<String, dynamic>> _currentVoiceMessages =
      new List<Map<String, dynamic>>();
  List<Map<String, dynamic>> _latestNewVoiceMessages =
      new List<Map<String, dynamic>>();
  bool isPlaying = false;
  bool alreadyFetchedAudios;
  int currentMessageId;
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

  Future<void> playAudio(String audioUrl, int id) async {
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

  Future<void> longPoolingCheck() async {
    List<Map<String, dynamic>> lastRow = await dbService.queryLastAddedRow();
    if (lastRow.isEmpty) {
      await getAllVoiceMessages();
    } else {
      await this.getNewVoiceMessages(lastRow);
    }
  }

  List<Map<String, dynamic>> get latestNewVoiceMessages {
    return _latestNewVoiceMessages;
  }

  void clearLatestNewVoiceMessages() {
    _latestNewVoiceMessages.clear();
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

  Future<void> init() async {
    List<Map<String, dynamic>> lastRow = await dbService.queryLastAddedRow();
    if (lastRow == null || lastRow.isEmpty) //no records in the table
    {
      await this.getAllVoiceMessages();
    } else {
      await this.getNewVoiceMessages(lastRow);
    }
  }

  Future<List<Map<String, dynamic>>> get currentVoiceMessages async {
    int numberOfRows = await dbService.queryRowCount();
    if (this._currentVoiceMessages.isEmpty ||
        numberOfRows != this._currentVoiceMessages.length) {
      var rows = await dbService.queryAllRows();
      rows.forEach((element) {
        this._currentVoiceMessages.add(element);
      });
    }
    return this._currentVoiceMessages;
  }

  Future<void> getNewVoiceMessages(List<Map<String, dynamic>> lastRow) async {
    VoiceMessage lastVoiceMessage = VoiceMessage.fromMap(lastRow[0]);
    var response =
        await _voiceMessagesService.getNewVoiceMessages(lastVoiceMessage.id);
    var data = json.decode(response.body);
    if ((response.statusCode == 200 && data['data'] != null) ||
        (!data.containsKey("error") && data['data'] != null)) {
      data = data['data'];
      List<VoiceMessage> fetchedVoiceMessages = new List<VoiceMessage>();
      data.forEach((element) {
        fetchedVoiceMessages.add(createNewVoiceMessageObject(element));
      });
      if (fetchedVoiceMessages.isNotEmpty) {
        await this.insertMessages(fetchedVoiceMessages);
        print("getNewVoiceMessages : new messages found! notifying..");
      }
    } else if (response.statusCode >= 400) {
      Logger().e(data['error']);
    }
  }

  Future<void> getAllVoiceMessages() async {
    print('am in get all voice messages');
    this._currentVoiceMessages?.clear();
    var response = await _voiceMessagesService.getAllVoiceMessages();
    var data = json.decode(response.body);
    if (response.statusCode == 200 || !data.containsKey("error")) {
      data = data['data'];
      List<VoiceMessage> fetchedVoiceMessages = new List<VoiceMessage>();
      data.forEach((element) {
        fetchedVoiceMessages.add(createNewVoiceMessageObject(element));
      });
      if (fetchedVoiceMessages.isNotEmpty) {
        await this.insertMessages(fetchedVoiceMessages);
        print('lll');
        print("getAllVoiceMessages - new messages found! notifying..");
      }
      this.alreadyFetchedAudios = true;
    } else if (response.statusCode >= 400) {
      Logger().e(data['error']);
    }
  }

  VoiceMessage createNewVoiceMessageObject(element) {
    return VoiceMessage(
      id: element['id'],
      durationInSec: int.tryParse(element['duration_in_sec']),
      ownerId: element['owner_id'],
      ownerFullName: element['owner_full_name'],
      url: "https://mytaxioffice.com/" + element['file_path'],
      createdAt: DateTime.parse(element['created_at']).millisecondsSinceEpoch,
      pictureUrl: element['picture_url'],
    );
  }

  Future<bool> insertMessages(List<VoiceMessage> allVoiceMessages) async {
    allVoiceMessages.forEach((element) async {
      var row = element.toMap();
      try {
        if (await dbService.insert(row) != 0) {
          this._currentVoiceMessages.add(row);
          this._latestNewVoiceMessages.add(row);

          print("inserted");
        }
      } catch (e) {
        print(" inserting exception");
      }
    });
    return true;
  }

  Future<bool> recreateTable() async {
    await dbService.deleteTable();
    await dbService.createTable();
    return true;
  }
}
