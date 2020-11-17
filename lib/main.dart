import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'api/user_api.dart';
import 'config/application.dart';
import 'data/notifier/user_notifier.dart';
import 'route/router.dart';

void main() {
  _initApp().then((value) => runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UserNotifier()),
          ],
          child: MyApp(),
        ),
      ));
}

//初始化APP
Future _initApp() async {
  //TODO 初始化融云IM 无法在runApp之前执行 需要进一步研究
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  MyAppState() {
    final router = FluroRouter();
    AppRouter.configureRouter(router);
    Application.router = router;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Flutter Demo',
      theme: ThemeData(
        // primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      //通过统一方法处理页面跳转路由
      onGenerateRoute: Application.router.generator,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _result = "";

  // void _incrementCounter() {
  //   requestUserSearch("十五", 10, false).then((result) {
  //     setState(() {
  //       _counter++;
  //       _result = result;
  //     });
  //   });
  // }

  void _incrementCounter() async {
    _result = await requestUserSearch("十五", 10, false);
    if (_result == null) {
      _result = "请求失败";
    }
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text("跳转到测试页"),
              textColor: Colors.orangeAccent,
              onPressed: () {
                // AppRouter.goToTestPage(context);
              },
            ),
            FlatButton(
              child: Text("跳转到融云测试页"),
              textColor: Colors.orangeAccent,
              onPressed: () {
                // AppRouter.goToRCTestPage(context);
              },
            ),
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              _result,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
