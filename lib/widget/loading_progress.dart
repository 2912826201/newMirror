import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogLoadingController extends ChangeNotifier {
  bool isShow = true;

  dismissDialog() {
    isShow = false;
    notifyListeners();
  }
}

class LoadingProgress extends StatefulWidget {
  final Widget progress;
  final Color bgColor;
  final DialogLoadingController controller;

  const LoadingProgress({Key key, this.progress, this.bgColor, @required this.controller}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoadingProgressState();
  }
}

class LoadingProgressState extends State<LoadingProgress> {
  @override
  void initState() {
    super.initState();
    //对controller进行监听
    widget.controller.addListener(() {
      if (widget.controller.isShow) {
        //todo
      } else {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Navigator.of(context).pop();
        });
      }
    });
  }

  @override
  void dispose() {
    widget.controller.isShow = false;
    widget.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      color: widget.bgColor ?? Color.fromRGBO(34, 34, 34, 0.3),
      width: size.width,
      height: size.height,
      alignment: Alignment.center,
      child: widget.progress ?? CircularProgressIndicator(),
    );
  }
}
