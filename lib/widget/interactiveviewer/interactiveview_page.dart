import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:interactiveviewer_gallery/hero_dialog_route.dart';
import 'package:interactiveviewer_gallery/interactiveviewer_gallery.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:video_player/video_player.dart';

class DemoSourceEntity {
  int id;
  String url;
  String previewUrl;
  String type;

  DemoSourceEntity(this.id, this.type, this.url, {this.previewUrl});
}

class InteractiveviewDemoPage extends StatefulWidget {

  @override
  _InteractiveviewDemoPageState createState() =>
      _InteractiveviewDemoPageState();
}

class _InteractiveviewDemoPageState extends State<InteractiveviewDemoPage> {
  List<DemoSourceEntity> sourceList = [
    DemoSourceEntity(1, 'image', 'http://file.jinxianyun.com/inter_05.jpg'),
    DemoSourceEntity(2, 'image', 'http://file.jinxianyun.com/inter_02.jpg'),
    DemoSourceEntity(3, 'image', 'http://file.jinxianyun.com/inter_03.gif'),
    DemoSourceEntity(4, 'video', 'http://file.jinxianyun.com/inter_04.mp4',
        previewUrl: 'http://file.jinxianyun.com/inter_04_pre.png'),
    DemoSourceEntity(5, 'video',
        'http://file.jinxianyun.com/6438BF272694486859D5DE899DD2D823.mp4',
        previewUrl: 'http://file.jinxianyun.com/102.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('InteractiveviewerGallery Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Wrap(
          children: sourceList.map((source) => _buildItem(source)).toList(),
        ),
      ),
    );
  }

  Widget _buildItem(DemoSourceEntity source) {
    return Hero(
      tag: source.id,
      placeholderBuilder: (BuildContext context, Size heroSize, Widget child) {
        // keep building the image since the images can be visible in the
        // background of the image gallery
        return child;
      },
      child: GestureDetector(
        onTap: () => _openGallery(source),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: source.type == 'video' ? source.previewUrl : source.url,
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            ),
            source.type == 'video'
                ? Icon(
              Icons.play_arrow,
              color: Colors.white,
            )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  void _openGallery(DemoSourceEntity source) {
    Navigator.of(context).push(
      HeroDialogRoute<void>(
        // DisplayGesture is just debug, please remove it when use
        builder: (BuildContext context) =>
           InteractiveviewerGallery<DemoSourceEntity>(
            sources: sourceList,
            initIndex: sourceList.indexOf(source),
            itemBuilder: itemBuilder,
          ),

      ),
    );
  }

  Widget itemBuilder(BuildContext context, int index, bool isFocus) {
    DemoSourceEntity sourceEntity = sourceList[index];
    if (sourceEntity.type == 'video') {
      // return DemoVideoItem(
      //   sourceEntity,
      //   isFocus: isFocus,
      // );
    } else {
      return DemoImageItem(sourceEntity);
    }
  }
}

class DemoImageItem extends StatefulWidget {
  final DemoSourceEntity source;

  DemoImageItem(this.source);

  @override
  _DemoImageItemState createState() => _DemoImageItemState();
}

class _DemoImageItemState extends State<DemoImageItem> {
  @override
  void initState() {
    super.initState();
    print('initState: ${widget.source.id}');
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose: ${widget.source.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
        ),
        Align(
          alignment: Alignment.center,
          child: Hero(
            tag: widget.source.id,
            child: CachedNetworkImage(
              imageUrl: widget.source.url,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}

