import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';

class NowPlaying extends StatefulWidget {
  const NowPlaying(
      {Key? key, required this.songModel, required this.audioPlayer})
      : super(key: key);
  final SongModel songModel;
  final AudioPlayer audioPlayer;
  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  Duration _duration = Duration();
  Duration _position = Duration();
  bool _isPlaying = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playSong();

    widget.audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d!;
      });
    });
    widget.audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });
  }

  playSong() {
    try {
      widget.audioPlayer.setAudioSource(AudioSource.uri(
        Uri.parse(widget.songModel.uri!),
        tag: MediaItem(
          // Specify a unique ID for each media item:
          id: "${widget.songModel.id}",
          // Metadata to display in the notification:
          album: "${widget.songModel.album}",
          title: widget.songModel.displayNameWOExt,
          artUri: Uri.parse('https://example.com/albumart.jpg'),
        ),
      ));
      widget.audioPlayer.play();
      _isPlaying = true;
    } on Exception {
      log("cannot play the song");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios)),
            const SizedBox(
              height: 60,
            ),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    //this is not goo because rebuild every time
                    radius: 100.0,
                    child: QueryArtworkWidget(
                        id: widget.songModel.id,
                        type: ArtworkType.AUDIO,
                        nullArtworkWidget: const Icon(
                          Icons.music_note,
                          color: Colors.blue,
                        )),
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                  Text(
                    widget.songModel.displayNameWOExt,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.songModel.artist.toString() == "<unknown>"
                        ? "<unknown Artist>"
                        : widget.songModel.artist.toString(),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(_position.toString().split(".")[0]),
                      Expanded(
                          child: Slider(
                              min: Duration(microseconds: 0)
                                  .inSeconds
                                  .toDouble(),
                              value: _position.inSeconds.toDouble(),
                              max: _duration.inSeconds.toDouble(),
                              onChanged: (value) {
                                setState(() {
                                  sliderChange(value.toInt());
                                  value = value;
                                });
                              })),
                      Text(_duration.toString().split(".")[0]),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.skip_previous,
                            size: 40,
                          )),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              if (_isPlaying == true) {
                                widget.audioPlayer.pause();
                              } else {
                                widget.audioPlayer.play();
                              }
                              _isPlaying = !_isPlaying;
                            });
                          },
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 40,
                          )),
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.skip_next,
                            size: 40,
                          )),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      )),
    );
  }

  void sliderChange(int seconds) {
    Duration duration = Duration(seconds: seconds);
    widget.audioPlayer.seek(duration);
  }
}
