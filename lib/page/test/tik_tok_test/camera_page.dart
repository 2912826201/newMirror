import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  final Function onPop;
  CameraPage({ Key key,this.onPop}): super(key: key);
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  Widget build(BuildContext context) {
    Widget rightButtons = Column(
      children: <Widget>[
        _CameraIconButton(
          icon: Icons.repeat,
          title: '翻转',
        ),
        _CameraIconButton(
          icon: Icons.tonality,
          title: '速度',
        ),
        _CameraIconButton(
          icon: Icons.texture,
          title: '滤镜',
        ),
        _CameraIconButton(
          icon: Icons.sentiment_satisfied,
          title: '美化',
        ),
        _CameraIconButton(
          icon: Icons.timer,
          title: '计时关',
        ),
      ],
    );
    rightButtons = Opacity(
      opacity: 0.8,
      child: Container(
        padding: EdgeInsets.only(right: 20, top: 12),
        alignment: Alignment.topRight,
        child: Container(
          child: rightButtons,
        ),
      ),
    );
    Widget selectMusic = Container(
      padding: EdgeInsets.only(left: 20, top: 20),
      alignment: Alignment.topCenter,
      child: DefaultTextStyle(
        style: TextStyle(
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.15),
              offset: Offset(0, 1),
              blurRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconToText(
              Icons.music_note,
            ),
            Text(
              '选择音乐',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                inherit: true,
              ),
            ),
            Container(width: 32, height: 12),
          ],
        ),
      ),
    );

    var closeButton = Tapped(
      child: Container(
        padding: EdgeInsets.only(left: 20, top: 20),
        alignment: Alignment.topLeft,
        child: Container(
          child: Icon(Icons.clear),
        ),
      ),
      onTap: widget.onPop,
    );

    var cameraButton = Container(
      padding: EdgeInsets.only(bottom: 12),
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 80,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _SidePhotoButton(title: '道具'),
            Expanded(
              child: Center(
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      style: BorderStyle.solid,
                      color: Colors.white.withOpacity(0.4),
                      width: 6,
                    ),
                  ),
                ),
              ),
            ),
            _SidePhotoButton(title: '上传'),
          ],
        ),
      ),
    );
    var body = Stack(
      fit: StackFit.expand,
      children: <Widget>[
        cameraButton,
        closeButton,
        selectMusic,
        rightButtons,
      ],
    );

    return Scaffold(
      // backgroundColor: Color(0xFFf5f5f4),
      body: SafeArea(
        child: body,
      ),
    );
  }
}

class _SidePhotoButton extends StatelessWidget {
  final String title;
  const _SidePhotoButton({
    Key key,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 20),
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              style: BorderStyle.solid,
              color: Colors.white.withOpacity(0.4),
              width: 2,
            ),
          ),
        ),
        Container(height: 2),
        Text(
          title,
          style:TextStyle(
            color: const Color.fromRGBO(0xff, 0xff, 0xff, .66),
            fontWeight: FontWeight.normal,
            fontSize: 12,
            inherit: true,
          ),
        )
      ],
    );
  }
}

class _CameraIconButton extends StatelessWidget {
  final IconData icon;
  final String title;
  const _CameraIconButton({
    Key key,
    this.icon,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: DefaultTextStyle(
        style: TextStyle(shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.15),
            offset: Offset(0, 1),
            blurRadius: 1,
          ),
        ]),
        child: Column(
          children: <Widget>[
            IconToText(
              icon,
            ),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
                inherit: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 把IconData转换为文字，使其可以使用文字样式
class IconToText extends StatelessWidget {
  final IconData icon;
  final TextStyle style;
  final double size;
  final Color color;

  const IconToText(
      this.icon, {
        Key key,
        this.style,
        this.size,
        this.color,
      }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Text(
      String.fromCharCode(icon.codePoint),
      style: style ??
          TextStyle(
            fontFamily: 'MaterialIcons',
            fontSize: size ?? 30,
            inherit: true,
            color: color,
          ),
    );
  }
}


class Tapped extends StatefulWidget {
  Tapped({this.child, this.onTap, this.onLongTap});
  final Widget child;
  final Function onTap;
  final Function onLongTap;

  @override
  _TappedState createState() => _TappedState();
}

class _TappedState extends State<Tapped> with TickerProviderStateMixin {
  bool _isChangeAlpha = false;

  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    _controller = AnimationController(value: 1, vsync: this);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _animation.addListener(() {
      this.setState(() {});
    });
    super.initState();
  }

  bool _tapDown = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Duration duration = const Duration(milliseconds: 50);
    Duration showDuration = const Duration(milliseconds: 660);

    return GestureDetector(
      onTap: () async {
        await Future.delayed(Duration(milliseconds: 100));
        widget.onTap?.call();
      },
      onLongPress: widget.onLongTap == null
          ? null
          : () async {
        await Future.delayed(Duration(milliseconds: 100));
        widget.onLongTap();
      },
      onTapDown: (detail) async {
        _tapDown = true;
        _isChangeAlpha = true;
        await _controller.animateTo(0.4, duration: duration);
        if (!_tapDown) {
          await _controller.animateTo(1, duration: showDuration);
        }
        _tapDown = false;
        _isChangeAlpha = false;
      },
      onTapUp: (detail) async {
        _tapDown = false;
        if (_isChangeAlpha == true) {
          return;
        }
        await _controller.animateTo(1, duration: showDuration);
        _isChangeAlpha = false;
      },
      onTapCancel: () async {
        _tapDown = false;
        _controller.value = 1;
        _isChangeAlpha = false;
      },
      child: Opacity(
        opacity: _animation.value,
        child: widget.child,
      ),
    );
  }
}
