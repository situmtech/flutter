part of wayfinding;

/// Controller for [MapView]. This class exposes methods and callbacks.
class MapViewController {
  OnPoiSelectedCallback? _onPoiSelectedCallback;
  OnDirectionsRequestInterceptor? _onDirectionsRequestInterceptor;
  OnNavigationRequestInterceptor? _onNavigationRequestInterceptor;

  final Function(MapViewConfiguration) _widgetUpdater;
  final PlatformWebViewController _webViewController;

  Location? _currentLocation;
  LocationStatus _currentLocationStatus = LocationStatus.STOPPED;

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
  void setCurrentLocation(dynamic locationMap) {
    _sendMessage(WV_MESSAGE_LOCATION, locationMap);
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
      // Navigation finished/progress/OOR callbacks are used by both WYF and
      // the integrator. If WYF uses them, they will be overwritten. To avoid
      // that problem, we listen for native calls here.
      case 'onNavigationFinished':
        _setNavigationFinished();
        break;
      case 'onNavigationProgress':
        _setNavigationProgress(RouteProgress(rawContent: call.arguments));
        break;
      case 'onUserOutsideRoute':
        _setNavigationOutOfRoute();
        break;
    }
  }

  void _onLocationChanged(arguments) {
    // Send location to the map-viewer.
    if (_currentLocationStatus == LocationStatus.USER_NOT_IN_BUILDING) {
      _currentLocationStatus = LocationStatus.CALCULATING;
    }

    _currentLocation = createLocation(arguments);
    dynamic locationMap = _currentLocation!.toMap();
    locationMap["status"] = '"${_currentLocationStatus.name}"';
    
    setCurrentLocation(locationMap);
  }

  void _onStatusChanged(arguments) {
    switch(arguments["statusName"]) {
      case "STARTING":
        _currentLocationStatus = LocationStatus.STARTING;
        break;
      case "USER_NOT_IN_BUILDING":
      // Send the last location with USER_NOT_IN_BUILDING state so map-viewer paints the grey-dot
      // TODO: make map-viewer react to only location status, and decouple location from its status.
        _currentLocationStatus = LocationStatus.USER_NOT_IN_BUILDING;
        if (_currentLocation != null) {
          dynamic locationMap = _currentLocation?.toMap();
          locationMap["status"] = '"${arguments["statusName"]}"';
          setCurrentLocation(locationMap);
        }
        break;
      case "STOPPED":
        _currentLocationStatus = LocationStatus.STOPPED;
        break;
      default:
        _currentLocationStatus = LocationStatus.CALCULATING;
        break;
    }
  }

  void _onError(arguments) {
    // TODO: send errors to map viewer?
  }
}
