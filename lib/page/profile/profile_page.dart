import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/route/router.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("我的页");
    return Center(
      child: FlatButton(child: Text("我的页"),
      onPressed: (){
      AppRouter.navigatorToLogin(context);
      },),
    );
  }
}