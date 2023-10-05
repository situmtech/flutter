part of wayfinding;

/// Controller for [MapView]. This class exposes methods and callbacks.
class MapViewController {
  OnPoiSelectedCallback? _onPoiSelectedCallback;
  OnPoiDeselectedCallback? _onPoiDeselectedCallback;
  OnDirectionsRequestInterceptor? _onDirectionsRequestInterceptor;
  OnNavigationRequestInterceptor? _onNavigationRequestInterceptor;

  late Function(MapViewConfiguration) _widgetUpdater;
  late MapViewCallback _widgetLoadCallback;
  late PlatformWebViewController _webViewController;

  Location? _currentLocation;

  MapViewController({
    String? situmUser,
    required String situmApiKey,
  }) {
    var situmSdk = SitumSdk();
    // Be sure to initialize, configure and authenticate in our SDK
    // so it can be used in callbacks, etc.
    situmSdk.init();
    situmSdk.setApiKey(situmApiKey);
    situmSdk.setConfiguration(ConfigurationOptions(useRemoteConfig: true));
    // Subscribe to native SDK messages so the location updates can be directly
    // forwarded to the map viewer.
    situmSdk.internalSetMethodCallDelegate(_methodCallHandler);
  }

  /// Tells the [MapView] where the user is located at.
  void setCurrentLocation(Location location) {
    _sendMessage(WV_MESSAGE_LOCATION, location.toMap());
  }

  /// Notifies [MapView] about the new location status received from the SDK.
  void _setCurrentLocationStatus(Location location, String status) {
    Map<String, dynamic> locationMap = location.toMap();
    locationMap["status"] = '"$status"';
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

  /// Selects the given POI in the map.
  void selectPoi(String identifier) async {
    _sendMessage(WV_MESSAGE_CARTOGRAPHY_SELECT_POI, {"identifier": identifier});
  }

  /// Starts navigating to the given POI. You can optionally choose the desired
  /// [AccessibilityMode] used to calculate the route.
  void navigateToPoi(
    String identifier, {
    AccessibilityMode? accessibilityMode,
  }) async {
    dynamic message = {"navigationTo": identifier};
    if (accessibilityMode != null) {
      message["type"] = "'${accessibilityMode.name}'";
    }
    _sendMessage(WV_MESSAGE_NAVIGATION_START, message);
  }

  /// Starts navigating to the given coordinates, at the given floor. You can
  /// optionally choose the desired [AccessibilityMode] used to calculate the
  /// route. You can also set the name of the destination to be displayed on the
  /// [MapView].
  void navigateToPoint(
    double lat,
    double lng,
    String floorIdentifier, {
    String? navigationName,
    AccessibilityMode? accessibilityMode,
  }) async {
    dynamic message = {
      "lat": lat,
      "lng": lng,
      "floorIdentifier": floorIdentifier
    };
    if (accessibilityMode != null) {
      message["type"] = accessibilityMode.name;
    }
    if (navigationName != null) {
      message["navigationName"] = navigationName;
    }
    _sendMessage(WV_MESSAGE_NAVIGATION_START, jsonEncode(message));
  }

  /// Cancels the current navigation, if any.
  void cancelNavigation() async {
    _sendMessage(WV_MESSAGE_NAVIGATION_CANCEL, {});
  }

  /// Sets the UI language based on the given ISO 639-1 code. Checkout the
  /// [Situm docs](https://situm.com/docs/query-params/) to see the list of
  /// supported languages.
  void setLanguage(String lang) async {
    _sendMessage(WV_MESSAGE_UI_SET_LANGUAGE, "'$lang'");
  }

  /// Tells the map to keep the camera centered on the user position.
  void followUser() async {
    _sendMessage(WV_MESSAGE_CAMERA_FOLLOW_USER, {"value": true});
  }

  /// Stops following the user (see [followUser]).
  void unfollowUser() async {
    _sendMessage(WV_MESSAGE_CAMERA_FOLLOW_USER, {"value": false});
  }

  /// Animate the map's [Camera].
  void setCamera(Camera camera) async {
    _sendMessage(WV_MESSAGE_CAMERA_SET, camera.toMap());
  }

  /// Select new floor by its level
  void selectLevel(int level) async {
    _sendMessage(WV_MESSAGE_CARTOGRAPHY_SELECT_LEVEL, {"level": level});
  }

  // WYF internal utils:

  void _notifyMapIsReady() {
    _widgetLoadCallback(this);
  }

  void _setRoute(
      DirectionsMessage directionsMessage, SitumRoute situmRoute) async {
    situmRoute.rawContent["identifier"] = directionsMessage.identifier;
    situmRoute.rawContent["originIdentifier"] =
        directionsMessage.originIdentifier;
    situmRoute.rawContent["destinationIdentifier"] =
        directionsMessage.destinationIdentifier;
    // The map-viewer waits for an accessibility mode in the "type" attribute
    // of the payload. This is due to internal state management.
    situmRoute.rawContent["type"] = directionsMessage.accessibilityMode?.name ??
        AccessibilityMode.CHOOSE_SHORTEST;
    _sendMessage(
        WV_MESSAGE_DIRECTIONS_UPDATE, jsonEncode(situmRoute.rawContent));
  }

  void _setRouteError(dynamic code, {String? routeIdentifier}) {
    _sendMessage(
        WV_MESSAGE_DIRECTIONS_UPDATE,
        jsonEncode({
          "error": code,
          "identifier": routeIdentifier,
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

  void _setNavigationDestinationReached() {
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

  /// Get notified when a POI is selected.
  void onPoiSelected(OnPoiSelectedCallback callback) {
    _onPoiSelectedCallback = callback;
  }

  /// Get notified when the selected POI is deselected.
  void onPoiDeselected(OnPoiDeselectedCallback callback) {
    _onPoiDeselectedCallback = callback;
  }

  // Directions & Navigation Interceptors:

  void _interceptDirectionsRequest(DirectionsRequest directionsRequest) {
    _onDirectionsRequestInterceptor?.call(directionsRequest);
  }

  void _interceptNavigationRequest(NavigationRequest navigationRequest) {
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
      // Navigation callbacks are used by both WYF and the integrator. If WYF
      // uses them, they will be overwritten. To avoid that problem, we listen
      // for native calls here.
      case 'onNavigationDestinationReached':
        _setNavigationDestinationReached();
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
    _currentLocation = createLocation(arguments);
    setCurrentLocation(_currentLocation!);
  }

  void _onStatusChanged(arguments) {
    String newStatus = arguments["statusName"];
    if (_currentLocation != null &&
        (newStatus == "STOPPED" || newStatus == "USER_NOT_IN_BUILDING")) {
      _setCurrentLocationStatus(_currentLocation!, newStatus);
    }
  }

  void _onError(arguments) {
    // TODO: send errors to map viewer?
  }
}
