import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 直播详情页
class LiveDetailPage extends StatefulWidget {
  @override
  createState() => new LiveDetailPageState();
}

class LiveDetailPageState extends State<LiveDetailPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: null,
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    return Text("直播详情页");
  }
}
