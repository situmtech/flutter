part of situm_flutter_wayfinding;

class SitumFlutterWYF {
  // TODO: handle states.
  bool situmMapLoaded = false;
  bool onDisposeCalled = false;

  OnPoiSelectedCallback? _onPoiSelectedCallback;
  OnDirectionsOptionsInterceptor? _onDirectionsOptionsInterceptor;
  OnNavigationOptionsInterceptor? _onNavigationOptionsInterceptor;

  final WebViewController webViewController;

  SitumFlutterWYF({
    required this.webViewController,
  });

  /// Tell the SitumMap where the user is located at.
  void setCurrentLocation(Location location) {
    _sendMessage(WV_MESSAGE_LOCATION, location.toMap());
  }

  void onMapViewerMessage(String type, Map<String, dynamic> payload) {
    MessageHandler(type).handleMessage(this, payload);
  }

  // Lifecycle utils:
  void onWidgetDisposed() {
    onDisposeCalled = true;
  }

  // Private utils:
  void _sendMessage(String type, dynamic payload) {
    // Do not quote payload keys!
    var message = "{type: '$type', payload: $payload}";
    webViewController.runJavaScript("""
      window.postMessage($message)
    """);
  }

  // Actions:
  void selectPoi(String id, String buildingId) async {
    // TODO.
  }

  void navigateToPoi(String id, String buildingId) async {
    // TODO.
  }

  // WYF internal utils:

  void _setRoute(
    String originId,
    String destinationId,
    SitumRoute situmRoute,
  ) async {
    situmRoute.rawContent["originId"] = originId;
    situmRoute.rawContent["destinationId"] = destinationId;
    _sendMessage("directions.updated", jsonEncode(situmRoute.rawContent));
  }

  void _setNavigationRoute(
    String originId,
    String destinationId,
    SitumRoute situmRoute,
  ) async {
    situmRoute.rawContent["originId"] = originId;
    situmRoute.rawContent["destinationId"] = destinationId;
    _sendMessage("navigation.started", jsonEncode(situmRoute.rawContent));
    debugPrint("navigation.started has been sent");
  }

  void _setNavigationOutOfRoute() {
    _sendMessage("navigation.updated", {
      "type": "out_of_route",
    });
  }

  void _setNavigationFinished() {
    _sendMessage("navigation.updated", {
      "type": "destination_reached",
    });
  }

  void _setNavigationProgress(RouteProgress progress) {
    _sendMessage("navigation.updated", jsonEncode(progress.rawContent));
  }

  // Callbacks:
  void onPoiSelected(OnPoiSelectedCallback callback) {
    // TODO: waiting for missing data from map-viewer.
    _onPoiSelectedCallback = callback;
  }

  // Directions & Navigation Interceptors:

  void _onDirectionsRequested(DirectionsOptions directionsOptions) {
    _onDirectionsOptionsInterceptor?.call(directionsOptions);
  }

  void _onNavigationRequested(NavigationOptions navigationOptions) {
    _onNavigationOptionsInterceptor?.call(navigationOptions);
  }

  void onDirectionsOptionsInterceptor(OnDirectionsOptionsInterceptor callback) {
    _onDirectionsOptionsInterceptor = callback;
  }

  void onNavigationOptionsInterceptor(OnNavigationOptionsInterceptor callback) {
    _onNavigationOptionsInterceptor = callback;
  }
}
