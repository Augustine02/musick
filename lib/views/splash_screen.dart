import 'package:flutter/material.dart';
import 'dart:async';
import 'package:musick/views/music_list.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void>checkPermission(Permission permission,BuildContext context)async{
    final status = await permission.request();

    if(status.isGranted){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permission is granted')));

    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permission is not granted')));
    }
  }
  Timer? _timer;

  // For the timer, to know the number of period the splash screen would be active
  _startDelay(){
    _timer = Timer(const Duration(seconds: 5), decideNavigation);
  }

  //To decide the next page to move after the splashscreen
  decideNavigation(){
    Navigator.of(context).
    push(MaterialPageRoute(builder: (context)=> MusicList()));
  }
  @override
  void initState() {
    checkPermission(Permission.storage,context);
    _startDelay();
    super.initState();
  }

  @override
  void dispose(){
    _timer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Text('musick', style:
      TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.indigo
      ),
      )),
    );
  }
}

