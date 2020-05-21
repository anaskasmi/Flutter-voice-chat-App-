import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_project_name/models/voice_message.dart';
import 'package:my_project_name/providers/driver_providers/fire_base__voice_messages_provider.dart';
import 'package:my_project_name/providers/driver_providers/mto_auth_provider.dart';
import 'package:my_project_name/utilities/user_interface_utilities/screen_size.dart';

import 'package:my_project_name/utilities/time_utilities/time_utils.dart';
import 'package:provider/provider.dart';
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
  final _scrollController = ScrollController();
  String myId = "0";
  bool isAllowedToUseChat;

  //first method called when the widget is built
  @override
  void didChangeDependencies() {
    SizeConfig().init(context);
    Provider.of<DriverMTOAuthProvider>(context).currentDriver.then((driver) {
      myId = driver.badgeId;
    });
    Provider.of<DriverMTOAuthProvider>(context)
        .isAllowedToUseChat()
        .then((answer) {
      setState(() {
        isAllowedToUseChat = answer;
      });
    });

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        title: Text("Chilliwack Taxi Radio"),
      ),
      body: buildScreen(context),
    );
  }

  Widget buildScreen(context) {
    if (isAllowedToUseChat == null)
      return Center(
        child: CircularProgressIndicator(),
      );
    else if (isAllowedToUseChat == false)
      return buildNotAllowedScreen();
    else
      return buildChatScreen(context);
  }

  Widget buildNotAllowedScreen() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal * 10,
            vertical: SizeConfig.blockSizeVertical * 20),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.error,
              color: Colors.deepOrange,
              size: SizeConfig.blockSizeHorizontal * 25,
            ),
            SizedBox(
              height: SizeConfig.blockSizeVertical * 1,
            ),
            Text(
              "Sorry !",
              style: TextStyle(
                  color: Colors.black45,
                  fontSize: SizeConfig.blockSizeHorizontal * 10),
            ),
            Text(
              "You are not allowed to use this functionally, contact your company for more info.",
              style: TextStyle(
                color: Colors.black45,
                fontSize: SizeConfig.blockSizeHorizontal * 4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChatScreen(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: new StreamBuilder(
              stream: Provider.of<FireBaseVoiceMessagesProvider>(context)
                  .voiceMessages,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return buildListView(snapshot);
                }
              }),
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
    );
  }

  Widget buildListView(AsyncSnapshot snapshot) {
    var documents = snapshot.data.documents;
    if (documents.length == 0) {
      return Center(
        child: Text('No Messages available !'),
      );
    }
    Timer(
        Duration(milliseconds: 1000),
            () => _scrollController
            .jumpTo(_scrollController.position.minScrollExtent));

    return ListView.builder(
        reverse: true,
        controller: _scrollController,
        padding: EdgeInsets.only(
          top: SizeConfig.safeBlockVertical * 2,
          bottom: SizeConfig.safeBlockVertical * 4,
        ),
        itemCount: documents.length,
        itemBuilder: (context, index) {
          var voiceMessages = documents.map((DocumentSnapshot document) {
            var fields = document.data;

            return VoiceMessage(
              id: document.documentID,
              ownerId: fields['owner_id'],
              durationInSec: int.parse(fields['duration_in_sec']),
              ownerFullName: fields['owner_full_name'],
              pictureUrl: fields['picture_url'],
              url: fields['file_path'],
              createdAt: fields['created_at'].toDate().millisecondsSinceEpoch,
            );
          }).toList();

          VoiceMessage vm = voiceMessages[index];
          return (isItMyVoiceMessage(vm.ownerId))
              ? MyConversationItem(
            id: vm.id,
            imageUrl: vm.pictureUrl,
            name: vm.ownerFullName,
            time: TimeUtils.getPassedTimeFromMilliSeconds(vm.createdAt),
            audioUrl: vm.url,
            duration: vm.durationInSec,
          )
              : ConversationItem(
            id: vm.id,
            imageUrl: vm.pictureUrl,
            name: vm.ownerFullName,
            time: TimeUtils.getPassedTimeFromMilliSeconds(vm.createdAt),
            audioUrl: vm.url,
            duration: vm.durationInSec,
          );
        });
  }
}
