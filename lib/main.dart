import 'package:flutter/material.dart';
import 'package:musick/models/song_state.dart';
import 'package:musick/views/music_list.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SongState>(
        create: (_) => SongState(),
      child: MaterialApp(
        title: 'Musick',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: MusicList()
      ),
    );
  }
}




