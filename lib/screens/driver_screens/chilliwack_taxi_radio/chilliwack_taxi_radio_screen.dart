import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_project_name/models/voice_message.dart';
import 'package:my_project_name/providers/driver_providers/mto_auth_provider.dart';
import 'package:my_project_name/utilities/user_interface_utilities/screen_size.dart';

import 'package:my_project_name/utilities/time_utilities/time_utils.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'local_widgets/conversation_item.dart';
import 'local_widgets/myConversationItem.dart';

class ChilliwackTaxiRadioScreen extends StatefulWidget {
  static final routeName = 'chilliwack_taxi_radio_screen';
  @override
  _ChilliwackTaxiRadioScreenState createState() =>
      _ChilliwackTaxiRadioScreenState();
}

class _ChilliwackTaxiRadioScreenState extends State<ChilliwackTaxiRadioScreen> {
  final _scrollController = ScrollController();
  String myId = "0";

  //first method called when the widget is built
  @override
  void didChangeDependencies() {
    SizeConfig().init(context);
    Provider.of<DriverMTOAuthProvider>(context).currentDriver.then((driver) {
      myId = driver.badgeId;
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
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        title: Text("Let's Talk"),
      ),
      body: new StreamBuilder(
          stream: Firestore.instance.collection("voice_messages").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              return buildListView(snapshot);
            }
          }),
    );
  }

  Widget buildListView(AsyncSnapshot snapshot) {
    var documents = snapshot.data.documents;
    return ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(
          top: SizeConfig.safeBlockVertical * 2,
          bottom: SizeConfig.safeBlockVertical * 4,
        ),
        itemCount: documents.length,
        itemBuilder: (context, index) {
          var voiceMessages = documents.map((document) {
            var fields = document.data;
            return VoiceMessage(
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
                  imageUrl: vm.pictureUrl,
                  name: vm.ownerFullName,
                  time: TimeUtils.getPassedTimeFromMilliSeconds(vm.createdAt),
                  audioUrl: vm.url,
                  duration: vm.durationInSec,
                )
              : ConversationItem(
                  imageUrl: vm.pictureUrl,
                  name: vm.ownerFullName,
                  time: TimeUtils.getPassedTimeFromMilliSeconds(vm.createdAt),
                  audioUrl: vm.url,
                  duration: vm.durationInSec,
                );
        });
  }
}
