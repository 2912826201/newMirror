import 'dart:async';

// Project imports:
import 'package:better_player/better_player.dart';
import 'package:better_player/src/core/better_player_with_controls.dart';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class BetterPlayer extends StatefulWidget {
  const BetterPlayer({Key key, @required this.controller})
      : assert(controller != null, 'You must provide a better player controller'),
        super(key: key);

  factory BetterPlayer.network(
    String url, {
    BetterPlayerConfiguration betterPlayerConfiguration,
  }) =>
      BetterPlayer(
        controller: BetterPlayerController(
          betterPlayerConfiguration ?? const BetterPlayerConfiguration(),
          betterPlayerDataSource: BetterPlayerDataSource(BetterPlayerDataSourceType.network, url),
        ),
      );

  factory BetterPlayer.file(
    String url, {
    BetterPlayerConfiguration betterPlayerConfiguration,
  }) =>
      BetterPlayer(
        controller: BetterPlayerController(
          betterPlayerConfiguration ?? const BetterPlayerConfiguration(),
          betterPlayerDataSource: BetterPlayerDataSource(BetterPlayerDataSourceType.file, url),
        ),
      );

  final BetterPlayerController controller;

  @override
  _BetterPlayerState createState() {
    return _BetterPlayerState();
  }
}

class _BetterPlayerState extends State<BetterPlayer> with WidgetsBindingObserver {
  BetterPlayerConfiguration get _betterPlayerConfiguration => widget.controller.betterPlayerConfiguration;

  ///Flag which determines if widget has initialized
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, () {
      _setup();
    });
  }

  @override
  void didChangeDependencies() {
    if (!_initialized) {
      _initialized = true;
    }
    super.didChangeDependencies();
  }

  Future<void> _setup() async {
    var locale = const Locale("en", "US");
    if (mounted) {
      final contextLocale = Localizations.localeOf(context);
      if (contextLocale != null) {
        locale = contextLocale;
      }
    }
    widget.controller.setupTranslations(locale);
  }

  @override
  void dispose() {
    ///If somehow BetterPlayer widget has been disposed from widget tree and
    ///full screen is on, then full screen route must be pop and return to normal
    ///state.
    widget.controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BetterPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
  }


  @override
  Widget build(BuildContext context) {
    return BetterPlayerControllerProvider(
      controller: widget.controller,
      child: _buildPlayer(),
    );
  }

  Widget _buildPlayer() {
    return BetterPlayerWithControls(
      controller: widget.controller,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    widget.controller.setAppLifecycleState(state);
  }
}

///Page route builder used in fullscreen mode.
typedef BetterPlayerRoutePageBuilder = Widget Function(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, BetterPlayerControllerProvider controllerProvider);
