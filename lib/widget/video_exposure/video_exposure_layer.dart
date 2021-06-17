 import 'dart:async' show Timer;
 import 'dart:ui' as ui;
 import 'package:flutter/foundation.dart';
 import 'package:flutter/rendering.dart';
 import 'package:flutter/scheduler.dart';
import 'package:mirror/widget/video_exposure/video_exposure.dart';
import 'package:mirror/widget/video_exposure/video_exposure_detector_controller.dart';
import 'package:mirror/widget/video_exposure/video_exposure_time_layer.dart';
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

  final VideoExposureCallback onExposureChanged;

  static final _exposureTime = <Key, VideoExposureTimeLayer>{};

  bool filter = false;

  static void setScheduleUpdate() {
    final bool isFirstUpdate = _updated.isEmpty;

    final updateInterval = VideoExposureDetectorController.instance.updateInterval;
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

    final updateInterval = VideoExposureDetectorController.instance.updateInterval;
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
      VideoVisibilityInfo.fromRects(key: layer.key, widgetBounds: widgetBounds, clipRect: layer._computeClipRect());

      if (_exposureTime[layer.key] != null && _exposureTime[layer.key].time > 0) {
        if (nowTime - _exposureTime[layer.key].time > 1) {
          print("最内层计算：：：：：info${info.visibleFraction}");
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

  static void notifyNow() {
    _timer?.cancel();
    _timer = null;
    _processCallbacks();
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
