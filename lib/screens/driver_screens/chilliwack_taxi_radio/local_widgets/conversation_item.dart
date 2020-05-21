import 'dart:async';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:my_project_name/providers/driver_providers/voiceMessagesProvider.dart';
import 'package:my_project_name/utilities/user_interface_utilities/screen_size.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ConversationItem extends StatefulWidget {
  final imageUrl;
  final String name;
  final id;
  final time;
  final audioUrl;
  final duration;
  const ConversationItem({
    this.id,
    this.name,
    this.imageUrl,
    this.time,
    this.audioUrl,
    this.duration,
    Key key,
  }) : super(key: key);

  @override
  _ConversationItemState createState() => _ConversationItemState();
}

class _ConversationItemState extends State<ConversationItem> {
  bool amPlaying = false;
  bool updatingState = false;
  Timer barReaderTimer;
  Stopwatch stopwatch = new Stopwatch();
  void didChangeDependencies() {
    setState(() {
      amPlaying = false;
    });
    Provider.of<VoiceMessagesProvider>(context)
        .audioPlayer
        .onPlayerStateChanged
        .listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        if (Provider.of<VoiceMessagesProvider>(context).currentMessageId ==
            this.widget.id) {
          setState(() {
            amPlaying = true;
            updatingState = true;
            updateStateEverySeconde();
            stopwatch.start();
          });
        } else {
          setState(() {
            amPlaying = false;
            clearUpdateStateTimer();
          });
        }
      }
    });

    super.didChangeDependencies();
  }

  void clearUpdateStateTimer() {
    if (barReaderTimer != null ||
        (barReaderTimer != null && barReaderTimer.isActive)) {
      barReaderTimer.cancel();
      updatingState = false;
      stopwatch.reset();
    }
  }

  void updateStateEverySeconde() {
    if (updatingState == true) {
      if (barReaderTimer == null ||
          (barReaderTimer != null && !barReaderTimer.isActive)) {
        barReaderTimer = new Timer.periodic(Duration(seconds: 1), (Timer t) {
          if (!mounted) return;
          setState(() {});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // SizeConfig().init(context);
    double currentWidth() {
      double initialWidth = SizeConfig.safeBlockHorizontal * 59;
      int duration = this.widget.duration;
      int currentSecond = stopwatch.elapsed.inSeconds;
      print("############ now : " + currentSecond.toString() + "############");
      if (currentSecond >= duration) {
        clearUpdateStateTimer();
        return initialWidth;
      }

      if (amPlaying) {
        return (initialWidth / duration) * currentSecond;
      } else {
        return initialWidth;
      }
    }

    String getDuration() {
      Duration duration;
      if (amPlaying) {
        duration = Duration(
            seconds: this.widget.duration - stopwatch.elapsed.inSeconds);
      } else {
        duration = Duration(seconds: this.widget.duration);
      }
      return duration.inMinutes.toString().padLeft(2, '0') +
          ":" +
          duration.inSeconds.toString().padLeft(2, '0');
    }

    buildImage() {
      return CachedNetworkImage(
        imageUrl: this.widget.imageUrl,
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

    return Column(
      children: <Widget>[
        ListTile(
          leading: buildImage(),
          title: Stack(
            children: <Widget>[
              Container(
                height: SizeConfig.safeBlockHorizontal * 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    colors: [Colors.lightBlue[800], Colors.lightBlueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.safeBlockHorizontal * 1),
                      child: Consumer<VoiceMessagesProvider>(
                          builder: (ctx, provider, _) {
                        if (((provider.isLoading) && amPlaying) ||
                            this.widget.audioUrl == "") {
                          return IconButton(
                            iconSize: SizeConfig.safeBlockHorizontal * 7,
                            onPressed: () {},
                            icon: Icon(Icons.av_timer),
                            color: Colors.white,
                          );
                        } else if (amPlaying) {
                          return IconButton(
                            iconSize: SizeConfig.safeBlockHorizontal * 7,
                            onPressed: () async {
                              await provider.pauseAudio(this.widget.id);
                              clearUpdateStateTimer();
                            },
                            icon: Icon(Icons.pause),
                            color: Colors.white,
                          );
                        } else {
                          return IconButton(
                            iconSize: SizeConfig.safeBlockHorizontal * 7,
                            onPressed: () async {
                              await provider.playAudio(
                                  this.widget.audioUrl, this.widget.id);
                            },
                            icon: Icon(Icons.play_arrow),
                            color: Colors.white,
                          );
                        }
                      }),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          right: SizeConfig.safeBlockHorizontal * 5),
                      child: Text(
                        getDuration(),
                        style: TextStyle(
                            fontSize: SizeConfig.safeBlockHorizontal * 4,
                            color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
              //barReader
              Container(
                height: SizeConfig.safeBlockHorizontal * 12,
                margin: EdgeInsets.only(left: 55),
                //margin will be replaced by the position of the audio reader
                // color: Colors.white,
                width: currentWidth(),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    // topLeft: Radius.circular(20),
                    topRight: Radius.circular(3),
                    bottomRight: Radius.circular(3),
                  ),
                  gradient: LinearGradient(
                    colors: [Colors.white30, Colors.white30],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.centerLeft,
              ),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                this.widget.name.toUpperCase(),
                style: TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.w700),
              ),
              Text(
                this.widget.time,
                style: TextStyle(fontSize: 13, color: Colors.black38),
              ),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }
}
