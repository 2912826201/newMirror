



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class dynamicPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
   return MaterialApp(
     home: Builder(builder: (context){
       var width = MediaQuery.of(context).size.width;
       var height = MediaQuery.of(context).size.height;
       return Scaffold(
         body:Column(
           children: [
           ],
         ),
       );
     }),
   );
  }

}

