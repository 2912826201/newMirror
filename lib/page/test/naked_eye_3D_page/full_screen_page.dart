import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';

import 'interactionl_widget.dart';

class FullScreenPage extends StatefulWidget {
  const FullScreenPage({Key key}) : super(key: key);

  @override
  _FullScreenPageState createState() => _FullScreenPageState();
}

class _FullScreenPageState extends State<FullScreenPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InteractionalWidget(
        maxAngleX: 30,
        maxAngleY: 80,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        middleScale: 1,
        foregroundScale: 1.1,
        backgroundScale: 1.1,
        backgroundWidget: backgroundWidget(),
        middleWidget: middleWidget(),
        foregroundWidget: foregroundWidget(),
      ),
    );
  }

  Widget backgroundWidget() {
    return Container(
      child: getImage('back.png'),
    );
  }

  Widget foregroundWidget() {
    return Container(
      child: getImage('fore.png'),
    );
  }

  Widget middleWidget() {
    return Center(child: Text('裸眼3D效果',style: TextStyle(fontSize: 24,color: AppColor.white),));
  }

  Image getImage(String s) {
    return Image.asset(
      "images/$s",
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      fit: BoxFit.cover,
      scale: 3.0,
    );
  }
}