import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:musick/views/music_list.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class PermissionHandler extends StatefulWidget {

  @override
  State<PermissionHandler> createState() => _PermissionHandlerState();
}

class _PermissionHandlerState extends State<PermissionHandler> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    permissionServicesCall();
  }

   permissionServicesCall() async{
   var request = await Permission.storage.request();
    if (request.isGranted) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MusicList()));
    }else {
      Alert(
        style: AlertStyle(
          backgroundColor: Colors.white
        ),
          context: context,
          title: "Permission Required",
          desc: "Cannot proceed without permission",
        buttons: [
          DialogButton(
            color: Colors.indigo,
            child: Text('Open App Settings',
            style: TextStyle(color: Colors.white,fontSize: 15),
              textAlign: TextAlign.center,
            ),
            onPressed: () => openAppSettings(),
          ),
          DialogButton(
            color: Colors.indigo,
              child: Text('ok',
                  style: TextStyle(color: Colors.white,fontSize: 20)
              ),
              onPressed: () => Navigator.pop(context),)
        ]
      ).show();
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
