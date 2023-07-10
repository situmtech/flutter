part of wayfinding;

/// Controller for [MapView]. This class exposes methods and callbacks.
class MapViewController {
  OnPoiSelectedCallback? _onPoiSelectedCallback;
  OnDirectionsRequestInterceptor? _onDirectionsRequestInterceptor;
  OnNavigationRequestInterceptor? _onNavigationRequestInterceptor;

  final Function(MapViewConfiguration) _widgetUpdater;
  final PlatformWebViewController _webViewController;

  MapViewController({
    required String situmUser,
    required String situmApiKey,
    required dynamic Function(MapViewConfiguration) widgetUpdater,
    required PlatformWebViewController webViewController,
  })  : _webViewController = webViewController,
        _widgetUpdater = widgetUpdater {
    var situmSdk = SitumSdk();
    // Be sure to initialize the SitumSdk so it can be used in callbacks, etc.
    situmSdk.init(situmUser, situmApiKey);
    // Subscribe to native SDK messages so the location updates can be directly
    // forwarded to the map viewer.
    situmSdk.internalSetMethodCallDelegate(_methodCallHandler);
  }

  /// Tells the SitumMap where the user is located at.
  void setCurrentLocation(Location location) {
    _sendMessage(WV_MESSAGE_LOCATION, location.toMap());
  }

  void onMapViewerMessage(String type, Map<String, dynamic> payload) {
    MessageHandler(type).handleMessage(this, payload);
  }

  // Private utils:
  void _sendMessage(String type, dynamic payload) {
    // Do not quote payload keys!
    var message = "{type: '$type', payload: $payload}";
    _webViewController.runJavaScript("""
      window.postMessage($message)
    """);
  }

  // Actions:

  void _reloadWithConfiguration(MapViewConfiguration configuration) async {
    // TODO - feature: reload with a new configuration.
    _widgetUpdater(configuration);
  }

  void _selectPoi(String id, String buildingId) async {
    // TODO - make public.
  }

  void _navigateToPoi(String id, String buildingId) async {
    // TODO - make public.
  }

  // WYF internal utils:

  void _setRoute(
    String originIdentifier,
    String destinationIdentifier,
    String? routeType,
    SitumRoute situmRoute,
  ) async {
    situmRoute.rawContent["originIdentifier"] = originIdentifier;
    situmRoute.rawContent["destinationIdentifier"] = destinationIdentifier;
    // The map-viewer waits for an accessibility mode in the "type" attribute
    // of the payload. This is due to internal state management.
    situmRoute.rawContent["type"] =
        routeType ?? AccessibilityMode.CHOOSE_SHORTEST;
    _sendMessage(
        WV_MESSAGE_DIRECTIONS_UPDATE, jsonEncode(situmRoute.rawContent));
  }

  void _setRouteError(dynamic code) {
    _sendMessage(
        WV_MESSAGE_DIRECTIONS_UPDATE,
        jsonEncode({
          "error": code,
        }));
  }

  void _setNavigationRoute(
    String originIdentifier,
    String destinationIdentifier,
    SitumRoute situmRoute,
  ) async {
    situmRoute.rawContent["originIdentifier"] = originIdentifier;
    situmRoute.rawContent["destinationIdentifier"] = destinationIdentifier;
    _sendMessage(
        WV_MESSAGE_NAVIGATION_START, jsonEncode(situmRoute.rawContent));
  }

  void _setNavigationOutOfRoute() {
    _sendMessage(
        WV_MESSAGE_NAVIGATION_UPDATE,
        jsonEncode({
          "type": "OUT_OF_ROUTE",
        }));
  }

  void _setNavigationFinished() {
    _sendMessage(
        WV_MESSAGE_NAVIGATION_UPDATE,
        jsonEncode({
          "type": "DESTINATION_REACHED",
        }));
  }

  void _setNavigationProgress(RouteProgress progress) {
    progress.rawContent["type"] = "PROGRESS";
    _sendMessage(WV_MESSAGE_NAVIGATION_UPDATE, jsonEncode(progress.rawContent));
  }

  // Callbacks:
  void onPoiSelected(OnPoiSelectedCallback callback) {
    _onPoiSelectedCallback = callback;
  }

  // Directions & Navigation Interceptors:

  void _onDirectionsRequested(DirectionsRequest directionsRequest) {
    _onDirectionsRequestInterceptor?.call(directionsRequest);
  }

  void _onNavigationRequested(NavigationRequest navigationRequest) {
    _onNavigationRequestInterceptor?.call(navigationRequest);
  }

  void onDirectionsRequestInterceptor(OnDirectionsRequestInterceptor callback) {
    _onDirectionsRequestInterceptor = callback;
  }

  void onNavigationRequestInterceptor(OnNavigationRequestInterceptor callback) {
    _onNavigationRequestInterceptor = callback;
  }

  // Native SDK callbacks:
  // This component needs to listen the native SDK callbacks so it can send
  // location (and status/errors) to the map-viewer automatically.

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'onLocationChanged':
        _onLocationChanged(call.arguments);
        break;
      case 'onStatusChanged':
        _onStatusChanged(call.arguments);
        break;
      case 'onError':
        _onError(call.arguments);
        break;
    }
  }

  void _onLocationChanged(arguments) {
    // Send location to the map-viewer.
    setCurrentLocation(createLocation(arguments));
  }

  void _onStatusChanged(arguments) {
    // currentLocationStatus = arguments['statusName'];
    // TODO: send status to map viewer.
  }

  void _onError(arguments) {
    // TODO: send errors to map viewer?
  }
}
