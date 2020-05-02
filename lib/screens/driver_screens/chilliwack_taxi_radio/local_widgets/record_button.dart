import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:my_project_name/providers/driver_providers/audioRecorderProvider.dart';
import 'package:my_project_name/screens/driver_screens/chilliwack_taxi_radio/local_widgets/roundedButton.dart';
import 'package:my_project_name/utilities/user_interface_utilities/screen_size.dart';
import 'package:provider/provider.dart';

class RecordButton extends StatefulWidget {
  @override
  _RecordButtonState createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  final double largeButtonSize = 60;

  final double largeIconSize = 30;

  final double smallButtonSize = 40;

  final double smallIconSize = 20;

  bool isRecording = false;
  final size = SizeConfig();
  String duration = "00:00";
  Tween<double> _scaleTween = Tween<double>(begin: 0, end: 1);
  Tween<double> _scaleTweenSendButton = Tween<double>(begin: 0, end: 0);

  @override
  Widget build(BuildContext context) {
    size.init(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        buildSendButton(),
        buildRecordButton(),
        buildDeleteButton(),
      ],
    );
  }

  Widget buildDeleteButton() {
    if (isRecording) {
      return GestureDetector(
        child: TweenAnimationBuilder(
          curve: Curves.easeInOutBack,
          tween: _scaleTween,
          duration: Duration(milliseconds: 700),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding:
                        EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
                    child: RoundedButton(
                      buttonColor: Colors.redAccent,
                      buttonSize: smallButtonSize,
                      iconColor: Colors.white,
                      iconSize: smallIconSize,
                      icon: Icons.restore_from_trash,
                    ),
                  ),
                  Text("Cancel",
                      style: TextStyle(color: Colors.redAccent, fontSize: 10)),
                ],
              ),
            );
          },
        ),
        onTap: () {
          Provider.of<AudioRecordProvider>(context).stopRecord().then((_) {});

          if (isRecording) {
            setState(() {
              _scaleTween = Tween<double>(begin: 1.4, end: 1);
              _scaleTweenSendButton = Tween<double>(begin: 0, end: 1);
              this.isRecording = false;
            });
          }
        },
      );
    } else {
      return Container();
    }
  }

  GestureDetector buildRecordButton() {
    return GestureDetector(
      child: TweenAnimationBuilder(
        curve: Curves.easeInExpo,
        tween: _scaleTween,
        duration: Duration(milliseconds: 200),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Column(
              children: <Widget>[
                buildRecordStatus(),
                RoundedButton(
                  buttonColor: isRecording ? Colors.grey : Colors.redAccent,
                  buttonSize: largeButtonSize,
                  iconColor: Colors.white,
                  iconSize: largeIconSize,
                  icon:
                      isRecording ? Icons.settings_voice : Icons.keyboard_voice,
                ),
              ],
            ),
          );
        },
      ),
      onTap: () {
        if (!isRecording) {
          Provider.of<AudioRecordProvider>(context)
              .startRecording()
              .then((_) {});
          setState(() {
            this.isRecording = true;
            _scaleTween = Tween<double>(begin: 1, end: 1.4);
          });
        }
      },
    );
  }

  Widget buildRecordStatus() {
    if (isRecording) {
      const tick = const Duration(milliseconds: 50);
      new Timer.periodic(tick, (Timer t) async {
        if (!isRecording) {
          t.cancel();
        }
        setState(() {
          Duration d = Provider.of<AudioRecordProvider>(context).duration;
          duration = d.inMinutes.toString().padLeft(2, '0') +
              ":" +
              d.inSeconds.toString().padLeft(2, '0');
          print("duration :" + duration);
        });
      });
      return Text(duration,
          style: TextStyle(color: Colors.black54, fontSize: 10));
    } else {
      return Container();
    }
  }

  Widget buildSendButton() {
    if (isRecording) {
      return GestureDetector(
          child: TweenAnimationBuilder(
            curve: Curves.easeInOutBack,
            tween: _scaleTween,
            duration: Duration(milliseconds: 700),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          top: SizeConfig.blockSizeVertical * 2),
                      child: RoundedButton(
                        buttonColor: Colors.cyan,
                        buttonSize: smallButtonSize,
                        iconColor: Colors.white,
                        iconSize: smallIconSize,
                        icon: Icons.send,
                      ),
                    ),
                    Text("Send",
                        style: TextStyle(color: Colors.cyan, fontSize: 10)),
                  ],
                ),
              );
            },
          ),
          onTap: () {
            BotToast.showText(text: "Sending... ");

            Provider.of<AudioRecordProvider>(context).sendRecord().then((_) {});
            if (isRecording) {
              setState(() {
                _scaleTween = Tween<double>(begin: 1.4, end: 1);
                _scaleTweenSendButton = Tween<double>(begin: 0, end: 1);
                this.isRecording = false;
              });
            }
          });
    } else {
      return Container();
    }
  }
}
