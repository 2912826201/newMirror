import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:permission_handler/permission_handler.dart';

/// agora_test_page
/// Created by yangjiayi on 2020/11/30.

class AgoraTestPage extends StatefulWidget {
  AgoraTestPage(this.token, this.channel, this.uid, {Key key}) : super(key: key);

  String token;
  String channel;
  int uid;

  @override
  _AgoraTestState createState() => _AgoraTestState();
}

class _AgoraTestState extends State<AgoraTestPage> {
  bool _joined = false;
  int _remoteUid = null;
  bool _switch = false;
  var engine;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await [Permission.camera, Permission.microphone, Permission.storage].request();

    engine = await RtcEngine.create("48e51da9c1b64e359db0c94c1bf17176");
    engine.setEventHandler(RtcEngineEventHandler(joinChannelSuccess: (String channel, int uid, int elapsed) {
      print('joinChannelSuccess ${channel} ${uid}');
      setState(() {
        _joined = true;
      });
    }, userJoined: (int uid, int elapsed) {
      print('userJoined ${uid}');
      setState(() {
        _remoteUid = uid;
      });
    }, userOffline: (int uid, UserOfflineReason reason) {
      print('userOffline ${uid}');
      setState(() {
        _remoteUid = null;
      });
    }));
    await engine.enableVideo();
    await engine.joinChannel(widget.token, widget.channel, null, widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: 'Plugin example app',
      ),
      body: Stack(
        children: [
          Center(
            child: _switch ? _renderRemoteVideo() : _renderLocalPreview(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 100,
              height: 100,
              color: Colors.blue,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _switch = !_switch;
                  });
                },
                child: Center(
                  child: _switch ? _renderLocalPreview() : _renderRemoteVideo(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderLocalPreview() {
    if (_joined) {
      return RtcLocalView.SurfaceView();
    } else {
      return Text(
        'Please join channel first',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _renderRemoteVideo() {
    if (_remoteUid != null) {
      return RtcRemoteView.SurfaceView(uid: _remoteUid);
    } else {
      return Text(
        'Please wait remote user join',
        textAlign: TextAlign.center,
      );
    }
  }
}
