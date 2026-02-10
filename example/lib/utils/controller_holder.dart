import 'dart:async';

import 'package:situm_flutter/wayfinding.dart';

/// Singleton holder for a [MapViewController] from a Situm MapView.
///
/// Use this to safely await the controller until the MapView has finished loading.
/// This helps orchestrate actions that require the controller, like selecting POIs,
/// navigating, or other map operations.
///
/// Typical usage:
/// ```dart
/// // 1️⃣ In your MapView widget:
/// MapView(
///   onLoad: (controller) {
///     MapViewControllerHolder().setController(controller);
///   },
/// );
///
/// // 2️⃣ In another part of your code, await the controller:
/// final controller = await MapViewControllerHolder().ensureMapViewController();
/// controller.navigateToPoi(poi);
///
/// // 3️⃣ When the MapView is disposed:
/// MapViewControllerHolder().reset();
/// ```
///
/// Notes:
/// - This holder currently supports **a single MapView** at a time. Multiple simultaneous MapViews
///   require a more advanced implementation with separate IDs.
/// - Always call [setController] from `onLoad` and [reset] from your `dispose` method.
/// - Calling [ensureMapViewController] before `onLoad` will await until the controller is available.
class MapViewControllerHolder {
  static final MapViewControllerHolder _instance =
      MapViewControllerHolder._internal();

  factory MapViewControllerHolder() => _instance;

  MapViewControllerHolder._internal();

  Completer<MapViewController>? _completer;

  /// Use this method to call MapViewController methods.
  Future<MapViewController> ensureMapViewController() {
    _completer ??= Completer<MapViewController>();
    return _completer!.future;
  }

  /// Call this from your MapView.onLoad callback.
  void setController(MapViewController controller) {
    _completer ??= Completer<MapViewController>();
    if (!_completer!.isCompleted) {
      _completer!.complete(controller);
    }
  }

  /// Call this from your dispose() method.
  void reset() {
    _completer = null;
  }
}
