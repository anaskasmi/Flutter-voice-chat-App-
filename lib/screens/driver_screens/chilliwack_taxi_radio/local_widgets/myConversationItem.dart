import 'dart:async';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:my_project_name/providers/driver_providers/voiceMessagesProvider.dart';
import 'package:my_project_name/utilities/user_interface_utilities/screen_size.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyConversationItem extends StatefulWidget {
  final imageUrl;
  final name;
  final id;
  final time;
  final audioUrl;
  final duration;

  const MyConversationItem({
    this.id,
    this.name,
    this.imageUrl,
    this.time,
    this.audioUrl,
    this.duration,
    Key key,
  }) : super(key: key);

  @override
  _MyConversationItemState createState() => _MyConversationItemState();
}

class _MyConversationItemState extends State<MyConversationItem> {
  bool amPlaying = false;
  bool amLookingPlayable = false;
  Stopwatch stopwatch = new Stopwatch();
  Timer playingTimer;
  final tick = Duration(seconds: 1);
  void didChangeDependencies() {
    print(
        '#########didChangeDependencies_MyConversationItemState#############');
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
            makeAudioLookPlayable();
          });
        } else {
          setState(() {
            amPlaying = false;
            makeAudioLookUnplayable();
          });
        }
      }
    });

    super.didChangeDependencies();
  }

  makeAudioLookUnplayable() {
    print('#########  makeAudioLookUnplayable  #############');
    if (playingTimer != null ||
        (playingTimer != null && playingTimer.isActive)) {
      this.playingTimer.cancel();
      stopwatch.reset();
    }
    amLookingPlayable = false;
  }

  makeAudioLookPlayable() {
    if (!amLookingPlayable) {
      print('#########  makeAudioLookPlayable  #############');

      amLookingPlayable = true;
      stopwatch.start();
      playingTimer = new Timer.periodic(tick, (Timer t) {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double initialWidth = SizeConfig.safeBlockHorizontal * 59;
    double currentWidth() {
      int duration = this.widget.duration;
      int currentSecond = stopwatch.elapsed.inSeconds;
      print("############ now : " + currentSecond.toString() + "############");
      if (currentSecond >= duration) {
        makeAudioLookUnplayable();
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
          trailing: buildImage(),
          title: Stack(
            children: <Widget>[
              Container(
                height: SizeConfig.safeBlockHorizontal * 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    colors: [Colors.blueGrey[800], Colors.blueGrey],
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
                            iconSize: SizeConfig.safeBlockHorizontal * 2,
                            onPressed: () {},
                            icon: CircularProgressIndicator(
                              strokeWidth: 2.0,
                            ),

                            // Icon(Icons.av_timer),
                            color: Colors.white,
                          );
                        } else if (amPlaying) {
                          return IconButton(
                            iconSize: SizeConfig.safeBlockHorizontal * 7,
                            onPressed: () async {
                              await provider.pauseAudio(this.widget.id);
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
              Container(
                height: SizeConfig.safeBlockHorizontal * 12,
                margin: EdgeInsets.only(left: 55),
                //margin will be replaced by the position of the audio reader
                // color: Colors.white,
                width: currentWidth(),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    // topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    // bottomRight: Radius.circular(20),
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
