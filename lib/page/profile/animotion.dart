


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
void main(){
  runApp(AnimotionTest());
}
class AnimotionTest extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
   return _AnimotionTestState();
  }

}

class _AnimotionTestState extends State<AnimotionTest>{
  var _top = 30.0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:Builder(builder: (context){
        double width = MediaQuery.of(context).size.width;
        double height = MediaQuery.of(context).size.height;
        return Scaffold(
          body:Container(
            child: Row(
              children:[
                ListView.builder(
                  itemBuilder:(context,index){

                  })
              ],
            ),
          )
        );
      },)
    );
  }

Widget _Item(String url){

}

}