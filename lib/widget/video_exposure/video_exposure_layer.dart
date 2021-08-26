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
    print(isFirstUpdate);
    // print(_updated);
    final updateInterval =VideoExposureDetectorController.instance.updateInterval ;
    print("0000000");
    if (updateInterval == Duration.zero) {
      print("111111111");
    // 即使使用 [Duration.zero]，我们仍然希望将回调推迟到最后
    // 帧，以便从一致的状态处理它们。 这个
    // 还确保当我们在
    // 帧的中间。
      if (isFirstUpdate) {
        print("2222222222");
        // 我们将要渲染一个帧，所以保证了帧后回调
        // 触发并将给我们比 `scheduleTask<T>` 更好的即时性。
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          _processCallbacks();
        });
      }
    } else if (_timer == null) {
      // We use a normal [Timer] instead of a [RestartableTimer] so that changes
      // to the update duration will be picked up automatically.
      /// 创建一个新的计时器。
      ///
      /// 在给定的 [duration] 之后调用 [callback] 函数。
      ///
        print("333333333");
      _timer = Timer(updateInterval, _handleTimer);
    } else {
      // 返回计时器是否仍处于活动状态。
      ///
      /// 如果回调尚未执行，则非周期性计时器处于活动状态，
      /// 并且计时器还没有被取消。
      ///
      /// 如果它没有被取消，一个周期性的计时器是活动的。
       print("444444444");
      assert(_timer.isActive);
    }
  }

  /// [Timer] callback.  Defers visibility callbacks to execute after the next
  /// frame.
  static void _handleTimer() {
    _timer = null;

    // 确保工作在帧之间完成，以便计算
    // 从一致状态执行。 我们在这里使用 `scheduleTask<T>` 代替
    // 的`addPostFrameCallback` 或`scheduleFrameCallback` 以便工作
    // 即使没有安排新的帧也没有不必要地完成
    // 调度一个新的帧。
    SchedulerBinding.instance.scheduleTask<void>(_processCallbacks, Priority.animation); /// idle当没有动画运行时，在所有其他任务之后运行的任务。 touch即使在用户与设备交互时也要运行的任务。animation 即使在动画运行时也要运行的任务。
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
      //  此节点是否位于根附加到某物的树中。
      //    ///
      //    /// 这在调用 [attach] 期间变为 true。
      //    ///
      //    /// 在调用 [detach] 期间这会变为 false。
      print("第一层");
      if (!layer.attached) {
        print("第二层");
        layer._fireCallback(VideoVisibilityInfo(key: layer.key, size: _lastVisibility[layer.key]?.size));
        continue;
      }

      final widgetBounds = layer._computeWidgetBounds();
      _lastBounds[layer.key] = widgetBounds;
      print("第三层");
      final info =
          VideoVisibilityInfo.fromRects(key: layer.key, widgetBounds: widgetBounds, clipRect: layer._computeClipRect());
      layer._fireCallback(info);
    }
    // _updated.clear();
  }

  static void a () {
    for (final layer in _updated.values) {
      //  此节点是否位于根附加到某物的树中。
      //    ///
      //    /// 这在调用 [attach] 期间变为 true。
      //    ///
      //    /// 在调用 [detach] 期间这会变为 false。
      print("第一层");
      if (!layer.attached) {
        print("第二层");
        layer._fireCallback(VideoVisibilityInfo(key: layer.key, size: _lastVisibility[layer.key]?.size));
        continue;
      }

      final widgetBounds = layer._computeWidgetBounds();
      _lastBounds[layer.key] = widgetBounds;
      print("第三层");
      final info =
      VideoVisibilityInfo.fromRects(key: layer.key, widgetBounds: widgetBounds, clipRect: layer._computeClipRect());
      if(  info != null) {
        layer._b(info);
      }
    }
  }
  void _b (VideoVisibilityInfo info) {
    onExposureChanged(info);
  }
  /// Invokes the visibility callback if [VisibilityInfo] hasn't meaningfully
  /// changed since the last time we invoked it.
  void _fireCallback(VideoVisibilityInfo info) {
    assert(info != null);
    print("第四层");
    final oldInfo = _lastVisibility[key];
    final visible = !info.visibleBounds.isEmpty;

    if (oldInfo == null) {
      print("第五层");
      if (!visible) {
        print("第六层");
        return;
      }
    } else if (info.matchesVisibility(oldInfo)) {
      print("第七层");
      return;
    }

    if (visible) {
      print("第8层");
      _lastVisibility[key] = info;
    } else {
      // Track only visible items so that the maps don't grow unbounded.
      _lastVisibility.remove(key);
      _lastBounds.remove(key);
      print("第9层");
    }
     print("曝光回调了::::::");
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
