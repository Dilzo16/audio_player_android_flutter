import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';

class NowPlaying extends StatefulWidget {
  NowPlaying(
      {Key? key,
      required this.index,
      required this.audioPlayer,
      required this.item})
      : super(key: key);
  int index;
  final AudioPlayer audioPlayer;
  final AsyncSnapshot<List<SongModel>> item;

  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  Duration _duration = Duration();
  Duration _position = Duration();
  bool _isPlaying = false;
  late SongModel songModel;

  setSong() {
    songModel = widget.item.data![widget.index];
    playSong();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setSong();

    widget.audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d!;
      });
    });
    widget.audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
        print("dur-$_duration ");
        print("position-$_position");
        if (_position >= _duration) {
          playNext();
        }
      });
    });
  }

  playNext() {
    widget.index++;
    setSong();
  }

  playPrevious() {
    widget.index--;
    setSong();
  }

  playSong() {
    _isPlaying = false;
    try {
      print(songModel);
      widget.audioPlayer.setAudioSource(AudioSource.uri(
        Uri.parse(songModel.uri!),
        tag: MediaItem(
          // Specify a unique ID for each media item:
          id: "${songModel.id}",
          // Metadata to display in the notification:
          album: "${songModel.album}",
          title: songModel.displayNameWOExt,
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
        color: Colors.cyan,
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
                  const CircleAvatar(
                    //this is not goo because rebuild every time
                    radius: 100.0,
                    // child: QueryArtworkWidget(
                    //     id: songModel.id,
                    //     type: ArtworkType.AUDIO,
                    //     nullArtworkWidget: const Icon(
                    //       Icons.music_note,
                    //       color: Colors.blue,
                    //     )),
                    child: Icon(
                      Icons.music_note,
                      color: Colors.indigo,
                      size: 180,
                    ),
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                  Text(
                    songModel.displayNameWOExt,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    songModel.artist.toString() == "<unknown>"
                        ? "<unknown Artist>"
                        : songModel.artist.toString(),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(
                    height: 60,
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
                          onPressed: () {
                            playPrevious();
                          },
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
                          onPressed: () {
                            playNext();
                          },
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
