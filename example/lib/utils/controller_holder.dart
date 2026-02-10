import 'dart:async';

import 'package:situm_flutter/wayfinding.dart';

class MapViewControllerHolder {
  static final MapViewControllerHolder _instance =
      MapViewControllerHolder._internal();

  factory MapViewControllerHolder() => _instance;

  MapViewControllerHolder._internal();

  final Completer<MapViewController> _completer = Completer<MapViewController>();

  /// Use this method to call MapViewController methods.
  Future<MapViewController> ensureMapViewController() {
    // Reuse the same future.
    return _completer.future;
  }

  /// Call this from your MapView.onLoad callback.
  void setController(MapViewController controller) {
    if (!(_completer.isCompleted)) {
      _completer.complete(controller);
    }
  }
}
