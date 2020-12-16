import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';

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
    player.setDataSource(widget.url, autoPlay: true);
  }

  @override
  void dispose() {
    super.dispose();
    player.release();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FijkView(
            player: player,
            color: AppColor.bgBlack,
            fit: FijkFit.cover,
            fsFit: FijkFit.cover,
            cover: AssetImage("images/test.png"),
          ),
          //拦截一下播放器的默认手势操作
          GestureDetector(
            onTap: () {},
            child: Container(
              color: AppColor.transparent,
            ),
          ),
          Positioned(
            top: 8 + ScreenUtil.instance.statusBarHeight,
            left: 16,
            child: Container(
              height: 36,
              width: 180,
              decoration: BoxDecoration(
                color: AppColor.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 4, right: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          NetworkImage("https://i1.hdslb.com/bfs/face/b73ff4cb30851e970d9c5413b94b73b1df3c09b3.jpg"),
                      radius: 14,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("洪荒少女What the fuck",
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: TextStyle(color: AppColor.white.withOpacity(0.85), fontSize: 10)),
                        Text("在线人数1234.5万",
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: TextStyle(color: AppColor.white.withOpacity(0.65), fontSize: 9)),
                      ],
                    )),
                    SizedBox(
                      width: 8,
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: 18,
                      width: 42,
                      decoration: BoxDecoration(color: AppColor.mainRed, borderRadius: BorderRadius.circular(9)),
                      child: Text("下一步", style: TextStyle(color: AppColor.white, fontSize: 10)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
              right: 16,
              bottom: 8,
              child: RaisedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("X"),
              ))
        ],
      ),
    );
  }
}
