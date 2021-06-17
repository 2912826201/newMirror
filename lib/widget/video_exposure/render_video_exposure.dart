import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:mirror/widget/video_exposure/video_exposure.dart';
import 'package:mirror/widget/video_exposure/video_exposure_layer.dart';

class RenderVideoExposure extends RenderProxyBox {
  /// Constructor.
  RenderVideoExposure({RenderBox child, @required this.key, VideoExposureCallback onExposure})
      : assert(key != null),
        _onExposure = onExposure,
        super(child);
  final Key key;
  VideoExposureCallback _onExposure;

  /// See [RenderObject.alwaysNeedsCompositing].
  @override
  bool get alwaysNeedsCompositing => (_onExposure != null);

  /// See [VisibilityDetector.onVisibilityChanged].
  VideoExposureCallback get onExposure => _onExposure;

  set onExposure(VideoExposureCallback value) {
    _onExposure = value;
    markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  /// See [RenderObject.paint].
  @override
  void paint(PaintingContext context, Offset offset) {
    var visibilityDetectorLayer = VideoExposureLayer(
      key: key,
      widgetSize: semanticBounds.size,
      paintOffset: offset,
      onExposureChanged: _onExposure,
    );
    final layer = visibilityDetectorLayer;
    context.pushLayer(layer, super.paint, offset);
  }
}

