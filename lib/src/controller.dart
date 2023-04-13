part of situm_flutter_wayfinding;

class SitumFlutterWYF {
  // TODO: handle states.
  bool situmMapLoaded = false;
  bool onDisposeCalled = false;

  OnPoiSelectedCallback? _onPoiSelectedCallback;
  OnPoiDeselectedCallback? _onPoiDeselectedCallback;
  OnDirectionsRequestInterceptor? _onDirectionsRequestInterceptor;
  OnNavigationRequestedCallback? _onNavigationRequestedCallback;
  OnNavigationErrorCallback? _onNavigationErrorCallback;
  OnNavigationFinishedCallback? _onNavigationFinishedCallback;
  OnNavigationStartedCallback? _onNavigationStartedCallback;

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
  void _sendMessage(String channel, Map payload) {
    // Do not quote payload keys!
    var message = "{type: '$channel', payload: $payload}";
    webViewController.runJavaScript("""
      window.postMessage($message)
    """);
  }

  // Actions:
  void selectPoi(String id, String buildingId) async {

  }

  void navigateToPoi(String id, String buildingId) async {

  }

  void setRoute(SitumRoute situmRoute) async {

  }

  // Callbacks:
  void onPoiSelected(OnPoiSelectedCallback callback) {
    _onPoiSelectedCallback = callback;
  }

  void onPoiDeselected(OnPoiDeselectedCallback callback) {
    _onPoiDeselectedCallback = callback;
  }

  void _onDirectionsRequested(DirectionsRequest directionsRequest) {
    _onDirectionsRequestInterceptor?.call(directionsRequest);
  }

  void onDirectionsRequestInterceptor(OnDirectionsRequestInterceptor callback) {
    _onDirectionsRequestInterceptor = callback;
  }

  void onNavigationRequested(OnNavigationRequestedCallback callback) {
    _onNavigationRequestedCallback = callback;
  }

  void onNavigationError(OnNavigationErrorCallback callback) {
    _onNavigationErrorCallback = callback;
  }

  void onNavigationFinished(OnNavigationFinishedCallback callback) {
    _onNavigationFinishedCallback = callback;
  }

  void onNavigationStarted(OnNavigationStartedCallback callback) {
    _onNavigationStartedCallback = callback;
  }
}
