part of situm_flutter_wayfinding;

class SitumFlutterWYF {
  // TODO: handle states.
  bool situmMapLoaded = false;
  bool onDisposeCalled = false;

  OnPoiSelectedCallback? onPoiSelectedCallback;
  OnPoiDeselectedCallback? onPoiDeselectedCallback;
  OnNavigationRequestedCallback? onNavigationRequestedCallback;
  OnNavigationErrorCallback? onNavigationErrorCallback;
  OnNavigationFinishedCallback? onNavigationFinishedCallback;
  OnNavigationStartedCallback? onNavigationStartedCallback;

  final WebViewController webViewController;

  SitumFlutterWYF({
    required this.webViewController,
  });

  void setCurrentLocation(Location location) {
    _sendMessage(WV_CHANNEL_LOCATION, location.toMapViewer());
  }

  void onMapViewerMessage(String type, Map<String, dynamic> payload) {
    MessageHandler(type).handleMessage(this, payload);
  }

  // Lifecycle utils:
  void onWidgetDisposed() {
    onDisposeCalled = true;
  }

  // Private utils:
  void _sendMessage(String channel, String payload) {
    var message = "{type: '$channel', payload: $payload}";
    webViewController.runJavaScript("""
      window.postMessage($message)
    """);
  }

  void onPoiSelected(OnPoiSelectedCallback callback) {
    onPoiSelectedCallback = callback;
  }

  void onPoiDeselected(OnPoiDeselectedCallback callback) {
    onPoiDeselectedCallback = callback;
  }

  void onNavigationRequested(OnNavigationRequestedCallback callback) {
    onNavigationRequestedCallback = callback;
  }

  void onNavigationError(OnNavigationErrorCallback callback) {
    onNavigationErrorCallback = callback;
  }

  void onNavigationFinished(OnNavigationFinishedCallback callback) {
    onNavigationFinishedCallback = callback;
  }

  void onNavigationStarted(OnNavigationStartedCallback callback) {
    onNavigationStartedCallback = callback;
  }
}
