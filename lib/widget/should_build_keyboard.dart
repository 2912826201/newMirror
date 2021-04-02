import 'dart:async';

import 'package:flutter/widgets.dart';

typedef XCShouldBuildFunction<T> = bool Function(
    T oldSubstance, T newSubstance);

class XCShouldBuild<T> extends StatefulWidget {
  final T substance; // substance
  final XCShouldBuildFunction<T> shouldBuildFunction;
  final WidgetBuilder builder;
  XCShouldBuild(
      {this.substance, this.shouldBuildFunction, @required this.builder})
      : assert(() {
    if (builder == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('error in XCShouldBuild: builder must exist')
      ]);
    }
    return true;
  }());
  @override
  _XCShouldBuildState createState() => _XCShouldBuildState<T>();
}

class _XCShouldBuildState<T> extends State<XCShouldBuild> {
  Widget oldWidget;
  T oldSubstance;

  bool _isInit = true;

  @override
  Widget build(BuildContext context) {
    final newSubstance = widget.substance;

    if (_isInit ||
        (widget.shouldBuildFunction == null
            ? true
            : widget.shouldBuildFunction(oldSubstance, newSubstance))) {
      _isInit = false;
      oldSubstance = newSubstance;
      oldWidget = widget.builder(context);
    }
    return oldWidget;
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint("_XCShouldBuildState dispose");
  }
}
/// ## Sumarry

/// - this is a way of resolving the issue of rebuilding stateful widget when a navigator is pushing or popping

/// - associated issue：https://github.com/flutter/flutter/issues/11655?tdsourcetag=s_pcqq_aiomsg

///  ## Usage

/// 1. import XCShouldBuild.dart and XCState.dart

/// 2. make all classes of State inherit from [XCState]，do not inherit from [State]

/// 3. override [XCState.shouldBuild]，do not override [State.build]

/// 4. use [XCState.reload] to reload，do not use [State.setState] to reload
abstract class XCState<T> extends State with WidgetsBindingObserver{
  bool _isShouldBuild = false;
  double oldKeyboardHeight=0;
  Timer _timerBottomHeight;
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
    _timerBottomHeight = Timer.periodic(Duration(milliseconds: 1), (timer) {
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
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    bool willUseSubstance = useSubstance();

    return XCShouldBuild<T>(
        substance: willUseSubstance ? substance() : null,
        shouldBuildFunction: (oldSubstance, newSubstance) {
          bool willReload;
          if (_isShouldBuild) {
            willReload = true;
          } else {
            if (willUseSubstance) {
              willReload = oldSubstance != newSubstance;
            } else {
              willReload = false;
            }
          }
          return willReload;
        },
        builder: (BuildContext context) {
          _isShouldBuild = false;
          return shouldBuild(context);
        });
  }

  Widget shouldBuild(BuildContext context);

  bool useSubstance() => false;

  T substance() => null;

  void reload([VoidCallback fn]) {
    if (!mounted) return;
    setState(() {
      _isShouldBuild = true;
      if (fn != null) {
        fn();
      }
    });
  }

  void startCanvasPage(bool isOpen);

  void endCanvasPage();


  @override
  void dispose() {
    super.dispose();
    if (_timerBottomHeight != null) {
      _timerBottomHeight.cancel();
      _timerBottomHeight = null;
    }
    debugPrint("XCState dispose");
  }

}
