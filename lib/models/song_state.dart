import'package:flutter/material.dart';
import 'dart:collection';
import 'package:musick/widgets/music_list_tile.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SongState extends ChangeNotifier{
  String currentTitle = '';
  QueryArtworkWidget? currentCover;
  String? currentSinger = '';

  dynamic updateTile (List? musickList, int index){
    return musickList![index];
  }

}