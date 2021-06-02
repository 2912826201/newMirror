import 'package:flutter/cupertino.dart';

class SizeTransitionView extends StatefulWidget {
  SizeTransitionView({this.id,this.child,this.animationMap});
  Widget child;
  Map<int, AnimationController> animationMap;
  int id;

  @override
  SizeTransitionViewState createState() => SizeTransitionViewState();

}
class SizeTransitionViewState extends State<SizeTransitionView> {
  @override
  Widget build(BuildContext context) {
    return SizeTransition(
        sizeFactor: Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: widget.animationMap[widget.id],
      curve: Curves.fastOutSlowIn,
    )),
    axis: Axis.vertical,
    axisAlignment: 1.0,
    child: widget.child
    );
  }
}