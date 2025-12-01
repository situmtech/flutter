import 'dart:async';

import 'package:situm_flutter/wayfinding.dart';

class MapViewControllerHolder {
  static final MapViewControllerHolder _instance =
      MapViewControllerHolder._internal();

  factory MapViewControllerHolder() => _instance;

  MapViewControllerHolder._internal();

  Completer<MapViewController>? _completer;

  /// Use this method to call MapViewController methods.
  Future<MapViewController> ensureMapViewController() {
    // If a controller is already loading or available, reuse the same future.
    if (_completer != null) {
      return _completer!.future;
    }
    // Otherwise create a new Completer and wait for whoever will complete it.
    _completer = Completer<MapViewController>();
    return _completer!.future;
  }

  /// Call this from your MapView.onLoad callback.
  void setController(MapViewController controller) {
    if (!(_completer?.isCompleted ?? true)) {
      _completer!.complete(controller);
    }
  }
}
