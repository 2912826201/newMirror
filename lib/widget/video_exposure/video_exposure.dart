import 'dart:async';
import 'dart:async' show Timer;
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:mirror/widget/sliding_element_exposure/exposure_detector.dart';
import 'package:mirror/widget/sliding_element_exposure/exposure_detector_controller.dart';

class VideoExposure extends SingleChildRenderObjectWidget {
  VideoExposure({
    @required Key key,
    @required Widget child,
    this.onExposure,
  })  : assert(key != null),
        assert(child != null),
        super(key: key, child: child);

  /// 回调触发曝光函数
  final ExposureCallback onExposure;

  @override
  RenderVideoExposure createRenderObject(BuildContext context) {
    return RenderVideoExposure(
      key: key,
      onExposure: onExposure,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderVideoExposure renderObject) {
    assert(renderObject.key == key);
    renderObject.onExposure = onExposure;
  }
}

typedef ExposureCallback = void Function(VisibilityInfo info);

class RenderVideoExposure extends RenderProxyBox {
  /// Constructor.
  RenderVideoExposure({RenderBox child, @required this.key, ExposureCallback onExposure})
      : assert(key != null),
        _onExposure = onExposure,
        super(child);
  final Key key;
  ExposureCallback _onExposure;

  /// See [RenderObject.alwaysNeedsCompositing].
  @override
  bool get alwaysNeedsCompositing => (_onExposure != null);

  /// See [VisibilityDetector.onVisibilityChanged].
  ExposureCallback get onExposure => _onExposure;

  set onExposure(ExposureCallback value) {
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

/// exposure_detector_layer
/// Created by sl on 2021/3/13.
Iterable<Layer> _getLayerChain(Layer start) {
  final List<Layer> layerChain = <Layer>[];
  for (Layer layer = start; layer != null; layer = layer.parent) {
    layerChain.add(layer);
  }
  return layerChain.reversed;
}

Matrix4 _accumulateTransforms(Iterable<Layer> layerChain) {
  assert(layerChain != null);

  final Matrix4 transform = Matrix4.identity();
  if (layerChain.isNotEmpty) {
    Layer parent = layerChain.first;
    for (final Layer child in layerChain.skip(1)) {
      (parent as ContainerLayer).applyTransform(child, transform);
      parent = child;
    }
  }
  return transform;
}

Rect _localRectToGlobal(Layer layer, Rect localRect) {
  final Iterable<Layer> layerChain = _getLayerChain(layer);

  assert(layerChain.isNotEmpty);
  assert(layerChain.first is TransformLayer);
  final Matrix4 transform = _accumulateTransforms(layerChain.skip(1));
  return MatrixUtils.transformRect(transform, localRect);
}

class VideoExposureTimeLayer {
  final int time;
  VideoExposureLayer layer;

  VideoExposureTimeLayer(this.time, this.layer);
}

class VideoExposureLayer extends ContainerLayer {
  VideoExposureLayer(
      {@required this.key,
      @required this.widgetSize,
      @required this.paintOffset,
      this.onExposureChanged})
      : assert(key != null),
        assert(paintOffset != null),
        assert(widgetSize != null),
        assert(onExposureChanged != null),
        _layerOffset = Offset.zero;
  static Timer _timer;

  static final _updated = <Key, VideoExposureLayer>{};

  final Key key;
  final Size widgetSize;

  Offset _layerOffset;

  final Offset paintOffset;

  final ExposureCallback onExposureChanged;

  static final _exposureTime = <Key, VideoExposureTimeLayer>{};

  bool filter = false;

  static void setScheduleUpdate() {
    final bool isFirstUpdate = _updated.isEmpty;

    final updateInterval = ExposureDetectorController.instance.updateInterval;
    if (updateInterval == Duration.zero) {
      if (isFirstUpdate) {
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          _processCallbacks();
        });
      }
    } else if (_timer == null) {
      _timer = Timer(updateInterval, _handleTimer);
    } else {
      assert(_timer.isActive);
    }
  }

  void _scheduleUpdate() {
    final bool isFirstUpdate = _updated.isEmpty;
    _updated[key] = this;

    final updateInterval = ExposureDetectorController.instance.updateInterval;
    if (updateInterval == Duration.zero) {
      if (isFirstUpdate) {
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          _processCallbacks();
        });
      }
    } else if (_timer == null) {
      _timer = Timer(updateInterval, _handleTimer);
    } else {
      assert(_timer.isActive);
    }
  }

  static void _handleTimer() {
    _timer = null;
    _exposureTime.forEach((key, exposureLayer) {
      if (_updated[key] == null) {
        _updated[key] = exposureLayer.layer;
      }
    });

    /// 确保在两次绘制中计算完
    SchedulerBinding.instance.scheduleTask<void>(_processCallbacks, Priority.touch);
  }

  /// 计算组件的矩形
  Rect _computeWidgetBounds() {
    final Rect r = _localRectToGlobal(this, Offset.zero & widgetSize);
    return r.shift(paintOffset + _layerOffset);
  }

  /// 计算两个两个矩形相交
  Rect _computeClipRect() {
    assert(RendererBinding.instance?.renderView != null);
    Rect clipRect = Offset.zero & RendererBinding.instance.renderView.size;

    ContainerLayer parentLayer = parent;
    while (parentLayer != null) {
      Rect curClipRect;
      if (parentLayer is ClipRectLayer) {
        curClipRect = parentLayer.clipRect;
      } else if (parentLayer is ClipRRectLayer) {
        curClipRect = parentLayer.clipRRect.outerRect;
      } else if (parentLayer is ClipPathLayer) {
        curClipRect = parentLayer.clipPath.getBounds();
      }

      if (curClipRect != null) {
        curClipRect = _localRectToGlobal(parentLayer, curClipRect);
        clipRect = clipRect.intersect(curClipRect);
      }

      parentLayer = parentLayer.parent;
    }

    return clipRect;
  }

  /// instances.
  static void _processCallbacks() {
    int nowTime = new DateTime.now().millisecondsSinceEpoch;
    List<Key> toReserveList = [];

    for (final VideoExposureLayer layer in _updated.values) {
      if (!layer.attached) {
        continue;
      }

      final widgetBounds = layer._computeWidgetBounds();
      final info =
          VisibilityInfo.fromRects(key: layer.key, widgetBounds: widgetBounds, clipRect: layer._computeClipRect());

      if (_exposureTime[layer.key] != null && _exposureTime[layer.key].time > 0) {
        if (nowTime - _exposureTime[layer.key].time > 0) {
          layer.onExposureChanged(info);
        } else {
          setScheduleUpdate();
          toReserveList.add(layer.key);
          _exposureTime[layer.key].layer = layer;
        }
      } else {
        _exposureTime[layer.key] = VideoExposureTimeLayer(nowTime, layer);
        toReserveList.add(layer.key);
        setScheduleUpdate();
      }
      _exposureTime.removeWhere((key, _) => !toReserveList.contains(key));
    }

    _updated.clear();
  }

  static void forget(Key key) {
    if (_updated[key] != null) {
      _updated[key].filter = true;
      _updated.remove(key);
    }

    if (_updated.isEmpty) {
      _timer?.cancel();
      _timer = null;
    }
  }

  /// See [Layer.addToScene].
  @override
  void addToScene(ui.SceneBuilder builder, [Offset layerOffset = Offset.zero]) {
    if (!filter) {
      _layerOffset = layerOffset;
      _scheduleUpdate();
    }
    super.addToScene(builder, layerOffset);
  }

  /// See [AbstractNode.attach].
  @override
  void attach(Object owner) {
    super.attach(owner);
    if (!filter) {
      _scheduleUpdate();
    }
  }

  /// See [AbstractNode.detach].
  @override
  void detach() {
    super.detach();

    // The Layer might no longer be visible.  We'll figure out whether it gets
    // re-attached later.
    if (!filter) {
      _scheduleUpdate();
    }
  }
}
