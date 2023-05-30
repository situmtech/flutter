part of situm_flutter_wayfinding;

class SitumFlutterWYF {
  // TODO: handle states.
  bool situmMapLoaded = false;
  bool onDisposeCalled = false;

  OnPoiSelectedCallback? _onPoiSelectedCallback;
  OnDirectionsOptionsInterceptor? _onDirectionsOptionsInterceptor;
  OnNavigationOptionsInterceptor? _onNavigationOptionsInterceptor;

  final SitumMapView widget;
  final WebViewController webViewController;

  SitumFlutterWYF({
    required this.widget,
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
    String originIdentifier,
    String destinationIdentifier,
    SitumRoute situmRoute,
  ) async {
    situmRoute.rawContent["originIdentifier"] = originIdentifier;
    situmRoute.rawContent["destinationIdentifier"] = destinationIdentifier;
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
          "type": "out_of_route",
        }));
  }

  void _setNavigationFinished() {
    _sendMessage(
        WV_MESSAGE_NAVIGATION_UPDATE,
        jsonEncode({
          "type": "destination_reached",
        }));
  }

  void _setNavigationProgress(RouteProgress progress) {
    progress.rawContent["type"] = "progress";
    _sendMessage(
        WV_MESSAGE_NAVIGATION_UPDATE, jsonEncode(progress.rawContent));
  }

  // TODO: This method is a workaround to obtain a POI without knowing the
  //  buildingId. Otherwise we would search among all the POIs of all the
  //  buildings, which would significantly impact performance.
  Future<Poi?> _fetchPoiFromCurrentBuilding(String poiId) async {
    var sdk = SitumFlutterSDK();
    return await sdk.fetchPoiFromBuilding(widget.buildingIdentifier, poiId);
  }

  // Callbacks:
  void onPoiSelected(OnPoiSelectedCallback callback) {
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
