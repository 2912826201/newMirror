import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
/**
 * description
 *
 * @date 2020/11/30
 * @author:TaoSi
 */


class ToastShow {
  static show({ @required String msg, @required context,int gravity = 0,int duration=1} ){
    Toast.show(
        msg, //必填
        context, //必填
        duration: duration,
        gravity: gravity,

        // .BOTTOM,
        backgroundRadius: 16);//规范圆角16
  }
}



class Toast {
  static final int LENGTH_SHORT = 1;
  static final int LENGTH_LONG = 2;
  static final int BOTTOM = 0;
  static final int CENTER = 1;
  static final int TOP = 2;

  static void show(String msg, BuildContext context,
      {int duration = 1,
        int gravity = 0,
        Color backgroundColor = AppColor.toastBgGrey,
        Color textColor = AppColor.white,
        double backgroundRadius = 20,
        Border border}) {
    ToastView.dismiss();
    ToastView.createView(
        msg, context, duration, gravity, backgroundColor, textColor, backgroundRadius, border);
  }
}

class ToastView {
  static final ToastView _singleton = new ToastView._internal();

  factory ToastView() {
    return _singleton;
  }

  ToastView._internal();

  static OverlayState overlayState;
  static OverlayEntry _overlayEntry;
  static bool _isVisible = false;

  static void createView(String msg, BuildContext context, int duration, int gravity,
      Color background, Color textColor, double backgroundRadius, Border border) async {
    if(context==null){
      return;
    }
    overlayState = Overlay.of(context);

    Paint paint = Paint();
    paint.strokeCap = StrokeCap.square;
    paint.color = background;

    _overlayEntry = new OverlayEntry(
      builder: (BuildContext context) => ToastWidget(
          widget: Container(
            width: MediaQuery.of(context).size.width,
            child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(backgroundRadius),
                    border: border,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child:
                  Text(msg, softWrap: true, style: TextStyle(fontSize: 15, color: textColor)),
                )),
          ),
          gravity: gravity),
    );
    _isVisible = true;
    if(overlayState==null){
      dismiss();
    }else {
      overlayState.insert(_overlayEntry);
      await new Future.delayed(Duration(seconds: duration == null ? Toast.LENGTH_SHORT : duration));
      dismiss();
    }
  }

  static dismiss() async {
    if (!_isVisible) {
      return;
    }
    _isVisible = false;
    _overlayEntry?.remove();
  }
}

class ToastWidget extends StatelessWidget {
  ToastWidget({
    Key key,
    @required this.widget,
    @required this.gravity,
  }) : super(key: key);

  final Widget widget;
  final int gravity;

  @override
  Widget build(BuildContext context) {
    return new Positioned(
        top: gravity == 2 ? 50 : null,
        bottom: gravity == 0 ? 50 : null,
        child: Material(
          color: Colors.transparent,
          child: widget,
        ));
  }
}
