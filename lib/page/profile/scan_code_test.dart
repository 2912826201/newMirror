// /*
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_qr_reader/flutter_qr_reader.dart';
//
// void main(){
//   runApp(ScanCodeTest());
// }
// class ScanCodeTest extends StatefulWidget{
//
//   @override
//   State<StatefulWidget> createState() {
//       return ScanCodeTestState();
//   }
//
// }
//
// class ScanCodeTestState extends State<ScanCodeTest>{
//   QrReaderViewController _controller;
//   String data;
//   @override
//   Widget build(BuildContext context) {
//         return MaterialApp(
//           home: Builder(builder: (context){
//             double width = MediaQuery.of(context).size.width;
//             double height = MediaQuery.of(context).size.height;
//             return Scaffold(
//               appBar: AppBar(title: Text("扫码测试"),centerTitle: true,),
//             body: Container(
//               width: width,
//               height: height,
//               child: Column(children: [
//                 data!=null?Text(data):Text("无数据"),
//                 AspectRatio(
//                   ///拿到相机的aspectRatio
//                   aspectRatio: _controller.value.aspectRatio,
//                   child: QrReaderView(
//                     callback: (controller){
//                       _controller = controller;
//                       _controller.startCamera(onScan);
//                     },
//                   ),
//                 ),
//
//
//               ],)
//             ),
//           );},)
//         );
//   }
//   void onScan(String v, List<Offset> offsets) {
//     print([v, offsets]);
//     setState(() {
//       data = v;
//     });
//     _controller.stopCamera();
//   }
//
// }*/
