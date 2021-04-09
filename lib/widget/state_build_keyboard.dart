import 'dart:async';

import 'package:flutter/widgets.dart';

abstract class StateKeyboard<T extends StatefulWidget> extends State<T> with WidgetsBindingObserver{
  double oldKeyboardHeight=0;
  Timer timerBottomHeight;
  int _timerBottomHeightCount=0;
  bool pageHeightStopCanvas=true;

  @override
  void initState() {
    super.initState();
    print("initState-初始化");
    _initTime();
  }


  //计时
  _initTime() {
    timerBottomHeight = Timer.periodic(Duration(milliseconds: 1), (timer) {
      if(this.context!=null&&this.mounted) {
        if (oldKeyboardHeight == MediaQuery.of(this.context).viewInsets.bottom) {
          _timerBottomHeightCount++;
          if(_timerBottomHeightCount>200){
            _timerBottomHeightCount=0;
            if(!pageHeightStopCanvas) {
              pageHeightStopCanvas = true;
              endCanvasPage();
              print("oldKeyboardHeight:$oldKeyboardHeight,${MediaQuery.of(this.context).viewInsets.bottom}");
            }
          }
        }else{
          if(pageHeightStopCanvas) {
            startCanvasPage(oldKeyboardHeight<MediaQuery.of(this.context).viewInsets.bottom);
            print("oldKeyboardHeight:$oldKeyboardHeight,${MediaQuery.of(this.context).viewInsets.bottom}");
            pageHeightStopCanvas = false;
          }
        }
        oldKeyboardHeight=MediaQuery.of(this.context).viewInsets.bottom;
        if(MediaQuery.of(this.context).viewInsets.bottom>0){
          keyBoardHeightThanZero();
        }
      }
    });
  }


  void startCanvasPage(bool isOpen);

  void endCanvasPage();


  @override
  void dispose() {
    super.dispose();
    if (timerBottomHeight != null) {
      timerBottomHeight.cancel();
      timerBottomHeight = null;
    }
    debugPrint("XCState dispose");
  }

  void keyBoardHeightThanZero();
}
