import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';

/// live_room_page
/// Created by yangjiayi on 2020/12/12.

class LiveRoomPage extends StatefulWidget {
  final String url = "rtmp://58.200.131.2:1935/livetv/cctv13";
  @override
  _LiveRoomState createState() => _LiveRoomState();
}

class _LiveRoomState extends State<LiveRoomPage> {
  final FijkPlayer player = FijkPlayer();

  @override
  void initState() {
    super.initState();
    player.setDataSource(
        widget.url,
        autoPlay: true);
  }

  @override
  void dispose() {
    super.dispose();
    player.release();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("直播间测试"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: FijkView(player: player),
      ),
    );
  }
}
