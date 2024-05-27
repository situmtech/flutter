part of wayfinding;

/// Controller for [MapView]. This class exposes methods and callbacks.
class MapViewController {
  late final MethodChannel methodChannel;
  OnPoiSelectedCallback? _onPoiSelectedCallback;
  OnPoiDeselectedCallback? _onPoiDeselectedCallback;
  OnSpeakAloudTextCallback? _onSpeakAloudTextCallback;
  OnDirectionsRequestInterceptor? _onDirectionsRequestInterceptor;
  OnNavigationRequestInterceptor? _onNavigationRequestInterceptor;
  OnExternalLinkClickedCallback? _onExternalLinkClickedCallback;

  late Function(MapViewConfiguration) _widgetUpdater;
  late MapViewCallback _widgetLoadCallback;
  late PlatformWebViewController _webViewController;

  // Internal callback that will receive every MapView message. This callback
  // has been introduced to enable communication between MapView and the new AR
  // module, serving as a direct and extensible mode that avoids the
  // intermediation of this plugin.
  Function(String, dynamic payload)? _internalMessageDelegate;

  List<String> mapViewerStatusesFilter = [
    'STARTING',
    'USER_NOT_IN_BUILDING',
    'BLE_DISABLED',
    'STOPPED',
  ];

  MapViewController({
    String? situmUser,
    required String situmApiKey,
  }) {
    // Open SDK channel to call native (private) methods if necessary.
    // WARNING: don't set the method call handler here as it will overwrite the
    // one provided by the SDK controller.
    methodChannel = const MethodChannel(situmSdkChannelId);
    var situmSdk = SitumSdk();
    // Be sure to initialize, configure and authenticate in our SDK
    // so it can be used in callbacks, etc.
    situmSdk.init();
    situmSdk.setApiKey(situmApiKey);
    situmSdk.setConfiguration(ConfigurationOptions(useRemoteConfig: true));
    // Subscribe to native SDK messages so the location updates can be directly
    // forwarded to the map viewer.
    situmSdk.internalSetMethodCallMapDelegate(_methodCallHandler);
  }

  /// Tells the [MapView] where the user is located at.
  void setCurrentLocation(Location location) {
    _sendMessage(WV_MESSAGE_LOCATION, location.toMap());
  }

  /// Notifies [MapView] about the new location status received from the SDK.
  void _setCurrentLocationStatus(String status) {
    Map<String, dynamic> statusMap = {};
    statusMap["status"] = '"$status"';
    _sendMessage(WV_MESSAGE_LOCATION_STATUS, statusMap);
  }

  void onMapViewerMessage(String type, Map<String, dynamic> payload) {
    MessageHandler(type).handleMessage(this, payload);
    _internalMessageDelegate?.call(type, payload);
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

  /// Selects the given POI category in the map.
  ///
  /// This method is deprecated. You can instead use [search] to filter POIs by category.
  @Deprecated("Use instead MapViewController.search()")
  void selectPoiCategory(String identifier) async {
    _sendMessage(
        WV_MESSAGE_CARTOGRAPHY_SELECT_POI_CATEGORY, {"identifier": identifier});
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

  /// Performs a search with the given [SearchFilter].
  ///
  /// This action will have the same effect
  /// as the user searching in the searchbar.
  void search(SearchFilter searchFilter) async {
    _sendMessage(
        WV_MESSAGE_UI_SET_SEARCH_FILTER, jsonEncode(searchFilter.toMap()));
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
  ///
  /// * **NOTE**: Calling this method repeatedly within a short period of time might result in unexpected behaviours with the camera animations,
  /// so make sure you leave at least 1000 ms between subsequent calls to this method.
  void setCamera(Camera camera) async {
    _sendMessage(WV_MESSAGE_CAMERA_SET, jsonEncode(camera.toMap()));
  }

  /// Select a floor of the current building by its [Floor.identifier].
  ///
  /// **NOTE**: introducing an invalid identifier may result in unexpected behaviours.
  void selectFloor(int identifier) async {
    _sendMessage(
        WV_MESSAGE_CARTOGRAPHY_SELECT_FLOOR, {"identifier": identifier});
  }

  /// Communicates the state of the AR module to the [MapView].
  void updateAugmentedRealityStatus(ARStatus status) async {
    _sendMessage(
        WV_MESSAGE_AR_UPDATE_STATUS, jsonEncode({"type": status.name}));
  }

  /// Process two lists: included & excluded tags and asynchronously sends directions.set_options message.
  ///
  /// Example:
  /// ```dart
  ///
  /// List<String> includedTags = ['user1', 'user5'];
  /// List<String> excludedTags = [];
  ///
  /// setDirectionsOptions(MapViewDirectionsOptions(includedTags: includedTags, excludedTags: excludedTags));
  /// 
  /// ```

  void setDirectionsOptions(MapViewDirectionsOptions directionOptions) async {
    dynamic message = {
      "includedTags": directionOptions.includedTags,
      "excludedTags": directionOptions.excludedTags,
    };

    _sendMessage(WV_MESSAGE_DIRECTIONS_SET_OPTIONS, jsonEncode(message));
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

  /// Get notified when the viewer wants to read aloud some text.
  void onSpeakAloudText(OnSpeakAloudTextCallback callback) {
    _onSpeakAloudTextCallback = callback;
  }

  /// Callback invoked when the user clicks on a link in the MapView that leads
  /// to a website different from the MapView's domain.
  /// If this callback is not set, the link will be opened in the system's
  /// default browser by default.
  void onExternalLinkClicked(OnExternalLinkClickedCallback callback) {
    _onExternalLinkClickedCallback = callback;
  }

  /// Set a callback that will receive internal messages from the [MapView].
  /// Do not use this method as it is intended for internal use.
  void internalARMessageDelegate(
      Function(String type, dynamic payload) callback) {
    _internalMessageDelegate = callback;
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

  // External links navigation:

  void _onExternalLinkClicked(String url) {
    if (_onExternalLinkClickedCallback != null) {
      _onExternalLinkClickedCallback!
          .call(OnExternalLinkClickedResult(url: url));
    } else {
      // Invoke native method directly:
      methodChannel.invokeMethod('openUrlInDefaultBrowser', {"url": url});
    }
  }

  // Native SDK callbacks:
  // This component needs to listen the native SDK callbacks so it can send
  // location (and status/errors) to the map-viewer automatically.

  Future<void> _methodCallHandler(InternalCall call) async {
    switch (call.type) {
      case InternalCallType.location:
        _onLocationChanged(call.get());
        break;
      case InternalCallType.locationStatus:
        _onStatusChanged(call.get());
        break;
      case InternalCallType.locationError:
        _onError(call.get());
        break;
      // Navigation callbacks are used by both WYF and the integrator. If WYF
      // uses them, they will be overwritten. To avoid that problem, we listen
      // for native calls here.
      case InternalCallType.navigationDestinationReached:
        _setNavigationDestinationReached();
        break;
      case InternalCallType.navigationProgress:
        _setNavigationProgress(call.get());
        break;
      case InternalCallType.navigationOutOfRoute:
        _setNavigationOutOfRoute();
        break;
    }
  }

  void _onLocationChanged(Location location) {
    // Send location to the map-viewer.
    setCurrentLocation(location);
  }

  void _onStatusChanged(String status) {
    if (mapViewerStatusesFilter.contains(status)) {
      _setCurrentLocationStatus(status);
    }
  }

  void _onError(Error error) {
    // Right now the MapView will show a generic error.
    _setCurrentLocationStatus(error.code);
  }
}
