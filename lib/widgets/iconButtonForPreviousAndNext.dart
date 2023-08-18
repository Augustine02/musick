import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
class IconButtonForPreviousAndSkip extends StatelessWidget {

  final AudioPlayer? player;
  void Function()? onTap;
  Widget? child;

  IconButtonForPreviousAndSkip ({required this.player, this.onTap, this.child});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: InkWell(
          onTap: onTap,
          //     (){
          //   if(_player.hasPrevious){
          //     _player.seekToPrevious();
          //   }
          // },
          child: child
          // Container(
          //   padding: const EdgeInsets.all(10.0),
          //   decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          //   child: const Icon(Icons.skip_previous, color: Colors.black,),
          // ),
        ));
  }
}