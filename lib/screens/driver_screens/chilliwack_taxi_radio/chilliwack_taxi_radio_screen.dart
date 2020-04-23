import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_project_name/providers/driver_providers/mto_auth_provider.dart';
import 'package:my_project_name/providers/driver_providers/voiceMessagesProvider.dart';
import 'package:my_project_name/utilities/user_interface_utilities/screen_size.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import 'local_widgets/conversation_item.dart';
import 'local_widgets/myConversationItem.dart';
import 'local_widgets/record_button.dart';

class ChilliwackTaxiRadioScreen extends StatefulWidget {
  static final routeName = 'chilliwack_taxi_radio_screen';
  @override
  _ChilliwackTaxiRadioScreenState createState() =>
      _ChilliwackTaxiRadioScreenState();
}

class _ChilliwackTaxiRadioScreenState extends State<ChilliwackTaxiRadioScreen> {
  final logger = Logger();

  final size = SizeConfig();
  final _scrollController = ScrollController();
  Timer longPoolingTimer;
  Timer checkNewMessagesTimer;
  bool scrollDownNextBuild = false;

  bool newNotification = false;
  bool isLoading;
  String myId = '0';
  List<Map<String, dynamic>> currenVoiceMessages =
      new List<Map<String, dynamic>>();

  //first method called when the widget is built
  @override
  void didChangeDependencies() {
    Logger().e('didChangeDependencies updated..');
    if (currenVoiceMessages.isEmpty) {
      Logger().e('currenVoiceMessages isEmpty..');

      Provider.of<VoiceMessagesProvider>(context)
          .currentVoiceMessages
          .then((result) {
        this.currenVoiceMessages = result;
        isLoading = true;

        Provider.of<DriverMTOAuthProvider>(context)
            .currentDriver
            .then((result) {
          isLoading = false;

          this.myId = result?.badgeId;
        });
        _sortVoiceMessages();
        isLoading = false;
        startLongPooling();
        Logger().e('setting the state after calling startLongPooling..');

        Timer(Duration(milliseconds: 1000), () {
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      });
    } else {
      Logger().e('currenVoiceMessages is NOT Empty..');

      Provider.of<VoiceMessagesProvider>(context).init().then((_) {
        Provider.of<VoiceMessagesProvider>(context)
            .currentVoiceMessages
            .then((result) {
          if (currenVoiceMessages.length != result.length) {
            Logger().e('currenVoiceMessages.length != result.length..');

            currenVoiceMessages.clear();
            currenVoiceMessages = result;
            _sortVoiceMessages();
            startLongPooling();

            // setState(() {});
            Timer(Duration(milliseconds: 1000), () {
              if (_scrollController.hasClients) {
                _scrollController
                    .jumpTo(_scrollController.position.maxScrollExtent);
              }
            });
          }
        });
      });
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    Logger().w('dispose..');

    if (longPoolingTimer != null && longPoolingTimer.isActive) {
      longPoolingTimer.cancel();
    }
    super.dispose();
    if (checkNewMessagesTimer != null && checkNewMessagesTimer.isActive) {
      checkNewMessagesTimer.cancel();
    }
    logger.close();
  }

  void startLongPooling() {
    Logger().w('function =>  startLongPooling..');

    if (longPoolingTimer == null ||
        (longPoolingTimer != null && !longPoolingTimer.isActive)) {
      Logger().e('------creating longPoolingTimer------');

      this.longPoolingTimer =
          Timer.periodic(Duration(seconds: 15), (timer) async {
        await Provider.of<VoiceMessagesProvider>(context).longPoolingCheck();
      });
    }
    startCheckNewMessages();
  }

  void startCheckNewMessages() {
    Logger().w('function => startCheckNewMessages..');

    if (checkNewMessagesTimer == null ||
        (checkNewMessagesTimer != null && !checkNewMessagesTimer.isActive)) {
      Logger().e('------creating checkNewMessagesTimer------');

      this.checkNewMessagesTimer =
          Timer.periodic(Duration(seconds: 2), (timer) async {
        var result =
            Provider.of<VoiceMessagesProvider>(context).latestNewVoiceMessages;
        if (result.isNotEmpty) {
          print('!!!!!!! new messages found !!!!!!!');
          _sortVoiceMessages();
          this.currenVoiceMessages.addAll(result);
          if (result.length > 1 || !isItMyVoiceMessage(result[0]['ownerId'])) {
            Provider.of<VoiceMessagesProvider>(context).playNotificationSound();
          }
          Provider.of<VoiceMessagesProvider>(context)
              .clearLatestNewVoiceMessages();
          scrollDownNextBuild = true;
          Logger().w('CheckNewMessages.. => setState');

          setState(() {});
        }
      });
    }
  }

  //sort voice messages by id
  void _sortVoiceMessages({bool reversed: true}) {
    currenVoiceMessages.sort((a, b) {
      if (a['id'] < b['id']) {
        return 1;
      }
      if (a['id'] > b['id']) {
        return -1;
      }
      return 0;
    });

    if (reversed) {
      currenVoiceMessages = currenVoiceMessages.reversed.toList();
    }
  }

  //clear the database and cleare the memory from all voice messages
  //fetch all records
  Future<void> hotRestart() async {
    this.currenVoiceMessages.clear();
    await Provider.of<VoiceMessagesProvider>(context).recreateTable();
    await Provider.of<VoiceMessagesProvider>(context).getAllVoiceMessages();
    Provider.of<VoiceMessagesProvider>(context)
        .currentVoiceMessages
        .then((result) {
      // this.currenVoiceMessages.addAll(result);
      Provider.of<DriverMTOAuthProvider>(context).currentDriver.then((result) {
        this.myId = result?.badgeId;
      });
      _sortVoiceMessages();
      // setState(() {});
      Timer(Duration(milliseconds: 1000), () {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });
  }

  //to transform milliseconds since epoch into readable data
  String getTimeFromDate(int secondsNumber) {
    var now = DateTime.now();
    var format = DateFormat('HH:mm a');
    var date = DateTime.fromMillisecondsSinceEpoch(secondsNumber);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' DAY AGO';
      } else {
        time = diff.inDays.toString() + ' DAYS AGO';
      }
    } else {
      if (diff.inDays == 7) {
        time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
      } else {
        time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
      }
    }
    return time;
  }

  bool isItMyVoiceMessage(String id) {
    if (int.parse(myId) == int.parse(id)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    size.init(context);
    if (scrollDownNextBuild) {
      Timer(Duration(milliseconds: 1000), () {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
      scrollDownNextBuild = false;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        title: Text("Let's Talk"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: hotRestart),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: isLoading == true
                ? Center(child: CircularProgressIndicator())
                : buildListView(),
          ),
          Container(
            height: SizeConfig.safeBlockVertical * 18,
            child: Container(
              child: RecordButton(),
              padding: EdgeInsets.only(
                top: SizeConfig.safeBlockVertical * 4,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildListView() {
    return currenVoiceMessages.isEmpty
        ? Center(child: Text('No Messages Available'))
        : ListView.builder(
            itemCount: currenVoiceMessages.length,
            // reverse: true,
            controller: _scrollController,
            padding: EdgeInsets.only(
              top: SizeConfig.safeBlockVertical * 2,
              bottom: SizeConfig.safeBlockVertical * 4,
            ),
            itemBuilder: (BuildContext ctxt, int index) {
              return (isItMyVoiceMessage(currenVoiceMessages[index]['ownerId']))
                  ? MyConversationItem(
                      imageUrl: currenVoiceMessages[index]['pictureUrl'],
                      id: currenVoiceMessages[index]['id'],
                      name: currenVoiceMessages[index]['ownerFullName'],
                      time: getTimeFromDate(
                          currenVoiceMessages[index]['createdAt']),
                      audioUrl: currenVoiceMessages[index]['url'],
                      duration: currenVoiceMessages[index]['durationInSec'],
                    )
                  : ConversationItem(
                      imageUrl: currenVoiceMessages[index]['pictureUrl'],
                      id: currenVoiceMessages[index]['id'],
                      name: currenVoiceMessages[index]['ownerFullName'],
                      time: getTimeFromDate(
                          currenVoiceMessages[index]['createdAt']),
                      audioUrl: currenVoiceMessages[index]['url'],
                      duration: currenVoiceMessages[index]['durationInSec'],
                    );
            });
  }
}
