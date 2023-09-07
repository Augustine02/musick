import 'package:flutter/material.dart';
import 'package:musick/widgets/music_list_tile.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:musick/models/duration.dart';
import 'package:rxdart/rxdart.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:musick/widgets/iconButtonForPreviousAndNext.dart';

final pageBucket = PageStorageBucket();


class MusicList extends StatefulWidget {
  @override
  State<MusicList> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
    var _audioQuery;
    bool isAudioQueryAvailable = false;

    final AudioPlayer _player = AudioPlayer();
    ScrollController? _scrollController;
  @override
  void initState() {
    checkPermission(Permission.storage,context);
    _scrollController = ScrollController();
    super.initState();
    // requestStoragePermission();
    // update the current playing song index listener
    _player.currentIndexStream.listen((index){
      if(index != null){
        print(index);
        _updateCurrentPlayingSongDetails(index);
      }
    });
    }


  @override
  void dispose(){
    _player.dispose();
    _searchController.dispose();
    super.dispose();
  }
  Future <void> checkPermission(Permission permission,BuildContext context)async{
    final status = await permission.request();

    if(status.isGranted){
      _audioQuery = OnAudioQuery();
      setState(() => isAudioQueryAvailable = true );
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permission is granted')));

    }else{
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permission is not granted')));
    }
  }

  String currentTitle = '';
  QueryArtworkWidget? currentCover;
  QueryArtworkWidget? currentCoverForMusicPlayerPage;
  String? currentSinger = '';
  double currentSlider = 0;
  //for the music player
  List<SongModel> songs = [];
  String currentSongTitle = '';
  int currentIndex = 0;
  bool isPlayerViewVisible = false;
  bool isbuttonTapped = false;

  //define a method to set the player view visibility
  void _changePlayerViewVisibility(){
    setState(() {
      isPlayerViewVisible = !isPlayerViewVisible;
    });
  }
  void checkIfButtonIsTapped(){
    setState(() {
      isbuttonTapped = !isbuttonTapped;
    });
  }
  //uses uri from _updateCurrentPlayingSongDetails method
  // and obtains the source or path for playing the music
  ConcatenatingAudioSource createPlaylist(List<SongModel>songs){
    List<AudioSource> sources = [];
    for (var song in defaultSongItems!){
      sources.add(AudioSource.uri(Uri.parse(song.uri!)));
    }
    return ConcatenatingAudioSource(children: sources);
  }
  //responsible for all the details of the song
  void _updateCurrentPlayingSongDetails(int index){
    setState(() {
      if (defaultSongItems!.isEmpty){print ('Songs are empty');}
      if(defaultSongItems!.isNotEmpty){
        print('Songs are not empty');
        print(index);
        currentSongTitle = defaultSongItems![index].title;
        currentTitle = defaultSongItems![index].displayNameWOExt;
        currentSinger = defaultSongItems![index].artist;
        currentCover =  QueryArtworkWidget(
            quality: 100,
          id: defaultSongItems![index].id,
          type: ArtworkType.AUDIO,
          artworkBorder: BorderRadius.circular(200.0),
            nullArtworkWidget: CircleAvatar(
              child: Icon(Icons.music_note,size: 40,),
              backgroundColor: Colors.grey,
            )
        );
       currentCoverForMusicPlayerPage = QueryArtworkWidget(
            quality: 100,
            // artworkQuality: FilterQuality.high,
            id: defaultSongItems![index].id,
            type: ArtworkType.AUDIO,
            artworkBorder: BorderRadius.circular(200.0),
            nullArtworkWidget: CircleAvatar(
              child: Icon(Icons.music_note, size: 150,),
              backgroundColor: Colors.grey,
            )
        );
        currentIndex = index;
        print(songs);
      }
    });
  }

  //duration state stream
  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, Duration?, DurationState>(
        _player.positionStream, _player.durationStream, (position, duration)=>DurationState(
        position: position, total: duration??Duration.zero
      )
      );
  //searching the music list
  bool searching = false;
  List <SongModel> filteredSongs = [];

  final _searchController = TextEditingController();
  Widget searchField(){
    return Container(
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: (value){
          filter(value);
          setState(() {});
        },
        cursorColor: Colors.white24,
        style: const TextStyle(
          color: Colors.white24),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Search music',
          hintStyle: TextStyle(
            color: Colors.white30,
          )
        ),
        ),
      );
  }

  void filter(String query){
    if(songs.isNotEmpty){
      filteredSongs.clear();
      for(SongModel song in songs){
        if(song.displayNameWOExt.toLowerCase().contains(query.toLowerCase())){
          filteredSongs.add(song);
        }
      }
    }
  }
  List? defaultSongItems;


  @override
  Widget build(BuildContext context) {
    if(isPlayerViewVisible){
      return Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50.0, right: 20.0, left: 20.0),
            decoration: BoxDecoration(color: Colors.black),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        child: InkWell(
                          onTap: _changePlayerViewVisibility,
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            // decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                            child: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 40),
                          )
                        )),
                    Expanded(
                        child: Text(
                          currentSongTitle,
                          style: const TextStyle(color: Colors.white70,
                          fontWeight: FontWeight.bold,
                            fontSize: 18
                          ), textAlign: TextAlign.start,
                        ),
                    flex: 5
                    )
                  ]
                ),
                Container(
                  width: 300,
                  height: 300,
                  decoration:const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  margin: const EdgeInsets.only(top: 30, bottom: 50),
                  child:
                  currentCoverForMusicPlayerPage
                ),

                Column(
                  children: [
                    //slider bar container
                    Container(
                      padding: EdgeInsets.zero,
                      margin: const EdgeInsets.only(bottom: 4.0),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
                      child: StreamBuilder<DurationState>(
                        stream:_durationStateStream,
                        builder: (context,snapshot){
                          final durationState = snapshot.data;
                          final progress = durationState?.position ?? Duration.zero;
                          final total = durationState?.total ?? Duration.zero;
                          return ProgressBar(
                              progress: progress,
                              total: total,
                              barHeight: 5.0,
                              baseBarColor: Colors.grey,
                              progressBarColor: Colors.white,
                              // Color(0xEE9E9E9E),
                              thumbColor: Colors.white,
                              thumbRadius: 8.0,
                              timeLabelTextStyle: const TextStyle(
                                fontSize: 0
                              ),
                            onSeek: (duration){
                                _player.seek(duration);
                            },
                          );
                        },
                      ),
                    ),
                    //position, progress and label text
                    StreamBuilder<DurationState>(
                        stream: _durationStateStream,
                        builder: (context, snapshot){
                          final durationState = snapshot.data;
                          final progress = durationState?.position?? Duration.zero;
                          final total = durationState?.total ?? Duration.zero;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Text(
                                  progress.toString().split(".")[0],
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15
                                  )
                                )
                              ),
                              Text(
                                  total.toString().split(".")[0],
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15
                                  )
                              ),
                            ],
                          );
                        }
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      height:250,
                      width:MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withOpacity(0.2),
                      ),
                      // color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      //play, play/pause & seek next control buttons
                      Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            //skip to previous
                            IconButtonForPreviousAndSkip(
                                player: _player,
                              onTap: () {
                                  if(_player.hasPrevious){
                                _player.seekToPrevious();}},
                            child: Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                child: const Icon(Icons.skip_previous, color: Colors.black,),
                              ),
                            ),
                            //play pause
                            Expanded(
                                child: InkWell(
                                  onTap: (){
                                    if(_player.playing){
                                      _player.pause();
                                    }else{
                                      if(_player.currentIndex != null){
                                        _player.play();
                                      }
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(20.0),
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                    child: StreamBuilder<bool>(
                                      stream: _player.playingStream,
                                      builder: (context, snapshot){
                                        bool? playingState = snapshot.data;
                                        if(playingState != null && playingState){
                                          return const Icon(Icons.pause, size: 30, color: Colors.black);
                                        }
                                        return const Icon(Icons.play_arrow, size: 30, color: Colors.black);
                                      },
                                  ),
                                  ),
                                )),

                            //skip to next
                            IconButtonForPreviousAndSkip(
                                player: _player,
                                onTap: (){
                                  if(_player.hasNext){
                                    _player.seekToNext();
                                  }
                                },
                              child: Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                child: const Icon(Icons.skip_next, color: Colors.black,),
                              ),
                            )

                          ],
                        ),
                      ),
                      //go to playlist, shuffle, repeat all and repeat one control buttons
                      Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            //go to playlist
                            Expanded(
                                child: InkWell(
                                  onTap: (){
                                    _changePlayerViewVisibility();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                    child: const Icon(Icons.task_alt,color: Colors.black,),
                                  ),
                                )),
                            //shuffle playlist
                            Expanded(
                                child: InkWell(
                                  onTap: (){
                                    _player.setShuffleModeEnabled(true);
                                    //toast to be put here
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 30.0, left: 30.0),
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                    child: const Icon(Icons.shuffle,color: Colors.black,),
                                  ),
                                )),
                            //repeat mode
                            Expanded(
                                child: InkWell(
                                  onTap: (){
                                    _player.loopMode == LoopMode.one ? _player.setLoopMode(LoopMode.all):
                                    _player.setLoopMode(LoopMode.one);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                    child: StreamBuilder<LoopMode>(
                                        stream: _player.loopModeStream,
                                        builder: (context, snapshot){
                                          final loopMode = snapshot.data;
                                          if(LoopMode.one == loopMode){
                                            return const Icon(Icons.repeat_one, color: Colors.black);
                                          }
                                          return const Icon(Icons.repeat, color: Colors.black);
                                        }),
                                  ),
                                )),
                          ],
                        ),
                      )
            ]
                      ),
                    )
                  ],
                )
              ]
            ),
          )
        ),
      );
    }
    if (_audioQuery == null && isAudioQueryAvailable == false){
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: Text('Musick',
            style: TextStyle(color: Colors.indigo, fontSize: 60, fontWeight: FontWeight.w800),)),
        );
    }else{
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: searching ? searchField() : const Text("My Playlist",
          style: TextStyle(color: Colors.white),
          ),
          actions: [
            //search btn
            IconButton(
            onPressed: (){
              if (searching){
                FocusScope.of(context).requestFocus(FocusNode());
                _searchController.text = '';
                filteredSongs.clear();
              }
              searching = !searching;
              setState(() {});
            },
            icon: Icon(searching ? Icons.close : Icons.search, color: Colors.white70,))

          ],
          elevation: 0,
        ),

        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<SongModel>>(
                future: _audioQuery.querySongs(
                  sortType: null,
                  orderType: OrderType.ASC_OR_SMALLER,
                  uriType: UriType.EXTERNAL,
                  ignoreCase: true
                ),

                  builder: (context, item) {
                    // foundSongs = item.data!;
                    // if(item.connectionState == ConnectionState.waiting){
                    //   return const Center(
                    //     child: CircularProgressIndicator(
                    //       color: Colors.indigo,
                    //     ));
                    // }

                    if (item.hasError){
                      return const Center(
                        child: Text('No Songs'),);
                    }
                    else if(item.data == null){
                      return Container();

                      }
                    else{
                      songs.clear();
                      songs = item.data!;
                      defaultSongItems = [];
                      // defaultSongItems.add('default play btns');
                      defaultSongItems!.addAll(searching && _searchController.text.isNotEmpty ? filteredSongs : songs);
                      return Column(
                      children: [
                        PageStorage(
                          bucket: pageBucket,
                          child: Expanded(
                            child: ScrollbarTheme(
                              data: ScrollbarThemeData(
                                trackColor: MaterialStatePropertyAll(Colors.black),
                                trackBorderColor: MaterialStatePropertyAll(Colors.black),
                              ),
                              child: Scrollbar(
                                interactive: true,
                                trackVisibility: true,
                                radius: Radius.circular(12),
                                controller: _scrollController,
                                thumbVisibility: true,
                                thickness: 5,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  key: PageStorageKey<String>('pageOne'), //giving key to ListView.builder
                                  itemBuilder: (context, index) =>
                                          MusicListTile(
                                                title: defaultSongItems![index].displayNameWOExt,
                                                singer: defaultSongItems![index].artist,
                                                cover: QueryArtworkWidget(
                                                      id: defaultSongItems![index].id,
                                                      type: ArtworkType.AUDIO,
                                                      nullArtworkWidget: CircleAvatar(
                                                        child: Icon(Icons.music_note),
                                                        backgroundColor: Colors.grey,
                                                      ),),
                                            onTap: () async{
                                              // setState(() {
                                              //   currentTitle = item.data![index].displayNameWOExt;
                                              //   currentSinger= item.data![index].artist;
                                              //   currentCover = QueryArtworkWidget(
                                              //       id: item.data![index].id,
                                              //       type: ArtworkType.AUDIO,
                                              //       nullArtworkWidget: CircleAvatar(
                                              //         child: Icon(Icons.music_note),
                                              //         backgroundColor: Colors.grey,
                                              //       ));
                                              // });
                                              _changePlayerViewVisibility();
                                              // String? uri = item.data![index].uri;
                                              // await _player.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
                                              await _player.setAudioSource(
                                                createPlaylist(item.data!),
                                                initialIndex: index
                                              );
                                              await _player.play();
                                            },

                                            ),
                                        itemCount: defaultSongItems!.length,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                        );
                        }
                    }

                ),
              ),
              // Music detail box
              Column(
                children: [
                  GestureDetector(
                    onTap: _changePlayerViewVisibility,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Expanded(
                        child: Container(
                            height: 90,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(30))
                            ),
                            child: Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              RawMaterialButton(
                                                elevation: 0.0,
                                                child: currentCover,
                                                onPressed: () => (),
                                                fillColor: Color(0xFF4E4C5E),
                                                shape: CircleBorder(),
                                                constraints: BoxConstraints.tightFor(
                                                  width: 56.0,
                                                  height: 56.0,
                                                ) ,
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 12.0),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // Expanded(
                                                      //   child: Marquee(
                                                      //     text: currentTitle,
                                                      //     style:TextStyle(
                                                      //         color: Colors.white,
                                                      //         fontSize: 16,
                                                      //         fontWeight: FontWeight.bold
                                                      //     ),
                                                      //     scrollAxis: Axis.horizontal,
                                                      //     crossAxisAlignment: CrossAxisAlignment.center,
                                                      //     showFadingOnlyWhenScrolling: true,
                                                      //     startAfter: Duration(seconds: 5),
                                                      //     pauseAfterRound: Duration(seconds: 2),
                                                      //     fadingEdgeEndFraction: 0.3,
                                                      //     blankSpace: 20.0,
                                                      //     velocity: 50.0,
                                                      //     startPadding: 10.0,
                                                      //     accelerationDuration: Duration(seconds: 1),
                                                      //     accelerationCurve: Curves.linear,
                                                      //     decelerationDuration: Duration(seconds: 1),
                                                      //     decelerationCurve: Curves.easeOut,
                                                      //   ),
                                                      // ),
                                                      Text(currentTitle,
                                                        style:TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold
                                                        ),textAlign: TextAlign.left,
                                                        overflow: TextOverflow.ellipsis,),
                                                      Text(currentSinger.toString(),
                                                        style:TextStyle(
                                                          color: Colors.white54,
                                                        ),
                                                        textAlign: TextAlign.left,
                                                      ),

                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              IconButtonForPreviousAndSkip(
                                                player: _player,
                                                onTap: () {
                                                  if(_player.hasPrevious){
                                                    _player.seekToPrevious();}},
                                                child: const Icon(Icons.skip_previous, color: Colors.white, size: 30),
                                              ),
                                              Expanded(
                                                  child: InkWell(
                                                    onTap: (){
                                                      if(_player.playing){
                                                        _player.pause();
                                                      }else{
                                                        if(_player.currentIndex != null){
                                                          _player.play();
                                                        }
                                                      }
                                                    },
                                                    child: StreamBuilder<bool>(
                                                      stream: _player.playingStream,
                                                      builder: (context, snapshot){
                                                        bool? playingState = snapshot.data;
                                                        if(playingState != null && playingState){
                                                          return const Icon(Icons.pause, size: 30, color: Colors.white);
                                                        }
                                                        return const Icon(Icons.play_arrow, size: 30, color: Colors.white);
                                                      },
                                                    ),
                                                  )),
                                              IconButtonForPreviousAndSkip(
                                                player: _player,
                                                onTap: (){
                                                  if(_player.hasNext){
                                                    _player.seekToNext();
                                                  }
                                                },
                                                child: const Icon(Icons.skip_next_outlined, color: Colors.white, size: 30,),
                                              )
                                              // Icon(Icons.pause, color: Colors.white, size: 30,),
                                              // Icon(Icons.skip_next_outlined, color: Colors.white, size: 30,),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  //   crossAxisAlignment: CrossAxisAlignment.center,
                                  //   children: [
                                  //     Text(
                                  //       Duration(seconds: currentSlider.toInt()).
                                  //       toString().
                                  //       split('.')[0].
                                  //       substring(2),
                                  //       style: TextStyle(color: Colors.white),
                                  //     ),
                                  //     Text(
                                  //       Duration(seconds: currentSlider.toInt()).
                                  //       toString().
                                  //       split('.')[0].
                                  //       substring(2),
                                  //       style: TextStyle(color: Colors.white),
                                  //     )
                                  //   ],
                                  // )
                                ]
                              ),
                            )
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ) ,
      );

  }}


}



