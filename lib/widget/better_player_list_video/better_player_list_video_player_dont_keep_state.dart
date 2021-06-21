import 'dart:math';

import 'package:better_player/better_player.dart';
import 'package:better_player/src/configuration/better_player_configuration.dart';
import 'package:better_player/src/configuration/better_player_data_source.dart';
import 'package:better_player/src/core/better_player_utils.dart';
import 'package:better_player/src/list/better_player_list_video_player_controller.dart';
import 'package:flutter/material.dart';

///Special version of Better Player which is used to play video in list view.
class BetterPlayerListVideoPlayerDontKeep extends StatefulWidget {
  ///Video to show
  final BetterPlayerDataSource dataSource;

  ///Video player configuration
  final BetterPlayerConfiguration configuration;

  ///Fraction of the screen height that will trigger play/pause. For example
  ///if playFraction is 0.6 video will be played if 60% of player height is
  ///visible.
  final double playFraction;

  ///Flag to determine if video should be auto played
  final bool autoPlay;

  ///Flag to determine if video should be auto paused
  final bool autoPause;



  final int index;

  final int modelId;


  const BetterPlayerListVideoPlayerDontKeep(
    this.dataSource, {
    this.configuration = const BetterPlayerConfiguration(),
    this.playFraction = 0.6,
    this.autoPlay = true,
    this.autoPause = true,
    // this.betterPlayerListVideoPlayerController,
    this.index,
    this.modelId,
    Key key,
  })  : assert(dataSource != null, "Data source can't be null"),
        assert(configuration != null, "Configuration can't be null"),
        assert(playFraction != null && playFraction >= 0.0 && playFraction <= 1.0,
            "Play fraction can't be null and must be between 0.0 and 1.0"),
        assert(autoPlay != null, "Auto play can't be null"),
        assert(autoPause != null, "Auto pause can't be null"),
        super(key: key);

  @override
  _BetterPlayerListVideoPlayerDontKeepState createState() => _BetterPlayerListVideoPlayerDontKeepState();
}

class _BetterPlayerListVideoPlayerDontKeepState extends State<BetterPlayerListVideoPlayerDontKeep> {
  BetterPlayerController _betterPlayerController;
  bool _isDisposing = false;
  bool isScroll = false;
  double visibleDouble = 0.0;
  BetterPlayerListVideoPlayerController betterPlayerListVideoPlayerController;
  @override
  void initState() {
    super.initState();
    _betterPlayerController = BetterPlayerController(
      widget.configuration.copyWith(
        playerVisibilityChangedBehavior: onVisibilityChanged,
        eventListener: onEventListener,
      ),
      betterPlayerDataSource: widget.dataSource,
      betterPlayerPlaylistConfiguration: const BetterPlayerPlaylistConfiguration(),
    );

    if (betterPlayerListVideoPlayerController != null) {
      betterPlayerListVideoPlayerController.setBetterPlayerController(_betterPlayerController);
    }
    print("初始化的播放器控制器::::${_betterPlayerController.hashCode}");
  }


  setScroll(bool isScroll){
    this.isScroll=isScroll;
    print("setScroll---${isScroll}");
    if(!isScroll){
      if (visibleDouble >= widget.playFraction) {
        if (widget.autoPlay && _betterPlayerController.isVideoInitialized() &&
            !_betterPlayerController.isPlaying() && !_isDisposing) {
          _betterPlayerController.play();
        }
      }
    }
  }

  @override
  void dispose() {
    print("视频测试dispose");
    _betterPlayerController.removeEventsListener(widget.configuration.eventListener);
    print("销毁的播放器控制器::::${_betterPlayerController.hashCode}");
    // 不能在此销毁在better_player文件内有销毁流程，在此销毁会引发notifyListeners的报错
    // _betterPlayerController.dispose();
    _isDisposing = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return AspectRatio(
      aspectRatio: _betterPlayerController.getAspectRatio() ?? BetterPlayerUtils.calculateAspectRatio(context),
      child: BetterPlayer(
        key: Key("${_getUniqueKey()}_player"),
        controller: _betterPlayerController,
      ),
    );
  }

  void onEventListener(BetterPlayerEvent event) {
    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.initialized:
        print("visibleDouble:::::$visibleDouble");
        _betterPlayerController?.setVolume(0);
        if (widget.index == 0 && visibleDouble != 0.0) {
          onVisibilityChanged(visibleDouble);
        }
        break;
      default:
        break;
    }
  }

  void onVisibilityChanged(double visibleFraction) async {
    final bool isPlaying = _betterPlayerController.isPlaying();
    final bool initialized = _betterPlayerController.isVideoInitialized();
    print("视频曝光的比例是：：：：：：$visibleFraction 当前要显示的比例是：：：${widget.playFraction}");
    print("widget.autoPlay::::${widget.autoPlay}");
    print("initialized::::$initialized");
    print("!isPlaying ::::::${!isPlaying}");
    print("!_isDisposing::::${!_isDisposing}");
    print("widget.index:::${widget.index}");
    print("isScroll:::${isScroll}");
    if (visibleFraction >= widget.playFraction) {
      betterPlayerListVideoPlayerController = BetterPlayerListVideoPlayerController();
      betterPlayerListVideoPlayerController.setBetterPlayerController(_betterPlayerController);
      visibleDouble = visibleFraction;
      if (widget.index != null && widget.index == 0) {
        visibleDouble = visibleFraction;
      }
      // } else {
      if (widget.autoPlay && initialized && !isPlaying && !_isDisposing) {
        if(isScroll){
          return;
        }
        _betterPlayerController.play();
      }
      // }
    } else {
      if (widget.autoPause && initialized && isPlaying && !_isDisposing) {
        _betterPlayerController.pause();
      }
    }
  }

  String _getUniqueKey() => widget.dataSource.hashCode.toString();

// @override
// bool get wantKeepAlive => true;
}
