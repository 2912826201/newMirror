import 'package:flutter/material.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      //通过统一方法处理页面跳转路由
      onGenerateRoute: (RouteSettings settings) => AppRouter.dispatchRoute(settings),
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
                AppRouter.goToTestPage(context);
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
