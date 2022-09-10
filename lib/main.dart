import 'dart:developer';

import 'package:audio_player_android_flutter/screens/NowPlaying.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Music player test",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: AllSongs(),
    );
  }
}

class AllSongs extends StatefulWidget {
  const AllSongs({Key? key}) : super(key: key);

  @override
  State<AllSongs> createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  final _audioQuery = new OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermission();
  }

  playSong(String? uri) {
    try {
      _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
      _audioPlayer.play();
    } on Exception {
      log("Error parsing song");
    }
  }

  void requestPermission() {
    Permission.storage.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Music player"),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            )
          ],
        ),
        body: FutureBuilder<List<SongModel>>(
          future: _audioQuery.querySongs(
              sortType: null,
              orderType: OrderType.ASC_OR_SMALLER,
              uriType: UriType.EXTERNAL,
              ignoreCase: true),
          builder: ((context, item) {
            if (item.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (item.data!.isEmpty) {
              return const Center(
                child: Text("No songs found"),
              );
            }
            return ListView.builder(
              itemBuilder: (context, index) => ListTile(
                leading: QueryArtworkWidget(
                  id: item.data![index].id,
                  type: ArtworkType.AUDIO,
                  nullArtworkWidget: const Icon(
                    Icons.music_note,
                    color: Colors.blue,
                  ),
                ),
                title: Text(item.data![index].displayNameWOExt),
                subtitle: Text(item.data![index].artist.toString()),
                trailing: const Icon(Icons.more_horiz),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => NowPlaying(
                                songModel: item.data![index],
                                audioPlayer: _audioPlayer,
                              ))));
                },
              ),
              itemCount: item.data!.length,
            );
          }),
        ));
  }
}
