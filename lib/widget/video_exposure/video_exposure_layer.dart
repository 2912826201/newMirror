import 'dart:async' show Timer;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:mirror/widget/video_exposure/video_exposure.dart';
import 'package:mirror/widget/video_exposure/video_exposure_detector_controller.dart';

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
      {@required this.key, @required this.widgetSize, @required this.paintOffset, this.onExposureChanged})
      : assert(key != null),
        assert(paintOffset != null),
        assert(widgetSize != null),
        assert(onExposureChanged != null),
        _layerOffset = Offset.zero;
  static Timer _timer;

  static final _updated = <Key, VideoExposureLayer>{};

  static final _lastVisibility = <Key, VideoVisibilityInfo>{};

  static Map<Key, Rect> get widgetBounds => _lastBounds;
  static final _lastBounds = <Key, Rect>{};

  Offset widgetOffset;
  final Key key;
  final Size widgetSize;

  Offset _layerOffset;

  final Offset paintOffset;

  final VideoExposureCallback onExposureChanged;

  bool filter = false;

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

  /// Schedules a timer to invoke the visibility callbacks.  The timer is used
  /// to throttle and coalesce updates.
  void _scheduleUpdate() {
    final isFirstUpdate = _updated.isEmpty;
    _updated[key] = this;

    final updateInterval = VideoExposureDetectorController.instance.updateInterval;
    if (updateInterval == Duration.zero) {
      // Even with [Duration.zero], we still want to defer callbacks to the end
      // of the frame so that they're processed from a consistent state.  This
      // also ensures that they don't mutate the widget tree while we're in the
      // middle of a frame.
      if (isFirstUpdate) {
        // We're about to render a frame, so a post-frame callback is guaranteed
        // to fire and will give us the better immediacy than `scheduleTask<T>`.
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          _processCallbacks();
        });
      }
    } else if (_timer == null) {
      // We use a normal [Timer] instead of a [RestartableTimer] so that changes
      // to the update duration will be picked up automatically.
      _timer = Timer(updateInterval, _handleTimer);
    } else {
      assert(_timer.isActive);
    }
  }

  /// [Timer] callback.  Defers visibility callbacks to execute after the next
  /// frame.
  static void _handleTimer() {
    _timer = null;

    // Ensure that work is done between frames so that calculations are
    // performed from a consistent state.  We use `scheduleTask<T>` here instead
    // of `addPostFrameCallback` or `scheduleFrameCallback` so that work will
    // be done even if a new frame isn't scheduled and without unnecessarily
    // scheduling a new frame.
    SchedulerBinding.instance.scheduleTask<void>(_processCallbacks, Priority.touch);
  }

  /// See [VisibilityDetectorController.notifyNow].
  static void notifyNow() {
    _timer?.cancel();
    _timer = null;
    _processCallbacks();
  }

  /// Removes entries corresponding to the specified [Key] from our internal
  /// caches.
  static void forget(Key key) {
    _updated.remove(key);
    _lastVisibility.remove(key);
    _lastBounds.remove(key);

    if (_updated.isEmpty) {
      _timer?.cancel();
      _timer = null;
    }
  }

  /// Executes visibility callbacks for all updated [VisibilityDetectorLayer]
  /// instances.
  static void _processCallbacks() {
    for (final layer in _updated.values) {
      if (!layer.attached) {
        layer._fireCallback(VideoVisibilityInfo(key: layer.key, size: _lastVisibility[layer.key]?.size));
        continue;
      }

      final widgetBounds = layer._computeWidgetBounds();
      _lastBounds[layer.key] = widgetBounds;

      final info =
          VideoVisibilityInfo.fromRects(key: layer.key, widgetBounds: widgetBounds, clipRect: layer._computeClipRect());
      layer._fireCallback(info);
    }
    // _updated.clear();
  }

  /// Invokes the visibility callback if [VisibilityInfo] hasn't meaningfully
  /// changed since the last time we invoked it.
  void _fireCallback(VideoVisibilityInfo info) {
    assert(info != null);

    final oldInfo = _lastVisibility[key];
    final visible = !info.visibleBounds.isEmpty;

    if (oldInfo == null) {
      if (!visible) {
        return;
      }
    } else if (info.matchesVisibility(oldInfo)) {
      return;
    }

    if (visible) {
      _lastVisibility[key] = info;
    } else {
      // Track only visible items so that the maps don't grow unbounded.
      _lastVisibility.remove(key);
      _lastBounds.remove(key);
    }

    onExposureChanged(info);
  }

  /// See [Layer.addToScene].
  @override
  void addToScene(ui.SceneBuilder builder, [Offset layerOffset = Offset.zero]) {
    _layerOffset = layerOffset;
    _scheduleUpdate();
    super.addToScene(builder, layerOffset);
  }

  /// See [AbstractNode.attach].
  @override
  void attach(Object owner) {
    super.attach(owner);
    _scheduleUpdate();
  }

  /// See [AbstractNode.detach].
  @override
  void detach() {
    super.detach();

    // The Layer might no longer be visible.  We'll figure out whether it gets
    // re-attached later.
    _scheduleUpdate();
  }

  /// See [Diagnosticable.debugFillProperties].
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(DiagnosticsProperty<Key>('key', key))
      ..add(DiagnosticsProperty<Rect>('widgetRect', _computeWidgetBounds()))
      ..add(DiagnosticsProperty<Rect>('clipRect', _computeClipRect()));
  }
}
