import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
class MusicListTile extends StatelessWidget {
  String? title;
  String? singer;
  QueryArtworkWidget? cover;
  void Function()? onTap;
  MusicListTile({this.title, this.singer, this.cover, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(
            top: 10.0, left: 12.0, right: 16.0),
        padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
        decoration: BoxDecoration(
          color: Colors.indigo,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: ListTile(
          leading: cover,
          title: Text(title.toString()),
          subtitle: Text(singer.toString()),
          trailing: Icon(Icons.more_vert),
          onTap: onTap,
        ));
  }
}

// Widget MusicListTile ({String? title, String? singer, QueryArtworkWidget? cover, void Function()? onTap}){
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//           margin: EdgeInsets.only(
//           top: 10.0, left: 12.0, right: 16.0),
//       padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
//       decoration: BoxDecoration(
//       color: Colors.indigo,
//       borderRadius: BorderRadius.circular(20.0),
//       ),
//         child: ListTile(
//         leading: cover,
//         title: Text(title.toString()),
//         subtitle: Text(singer.toString()),
//         trailing: Icon(Icons.more_vert),
//       )),
//     );
//
// }
