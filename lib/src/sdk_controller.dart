part of sdk;

/// Main entry point for the Situm Flutter SDK. Use [SitumSdk] to start
/// positioning, calculate routes and fetch resources.
///
/// ```dart
/// var situmSdk = SitumSdk();
/// // Set up your credentials:
/// situmSdk.init();
/// situmSdk.setApiKey(situmUser, situmApiKey);
/// // Set up location listeners:
/// situmSdk.onLocationUpdate((location) {
///   ...
/// });
/// situmSdk.onLocationStatus((status) {
///   ...
/// });
/// situmSdk.onLocationError((error) {
///   ...
/// });
/// ```
class SitumSdk {
  late final MethodChannel methodChannel;
  Function(MethodCall call)? internalMethodCallDelegate;

  OnLocationUpdateCallback? _onLocationUpdateCallback;
  OnLocationStatusCallback? _onLocationStatusCallback;
  OnLocationErrorCallback? _onLocationErrorCallback;

  OnEnteredGeofencesCallback? _onEnteredGeofencesCallback;
  OnExitedGeofencesCallback? _onExitedGeofencesCallback;

  OnNavigationStartCallback? _onNavigationStartCallback;
  OnNavigationDestinationReachedCallback? _onNavigationDestReachedCallback;
  OnNavigationCancellationCallback? _onNavigationCancellationCallback;
  OnNavigationProgressCallback? _onNavigationProgressCallback;
  OnNavigationOutOfRouteCallback? _onNavigationOORCallback;

  OnDirectionsRequestedCallback? _onDirectionsRequestedCallback;

  final _LocationStatusAdapter _statusAdapter = _LocationStatusAdapter();

  static final SitumSdk _controller = SitumSdk._internal();

  final _LocationErrorAdapter _errorAdapter = _LocationErrorAdapter();

  /// Main entry point for the Situm Flutter SDK. Use [SitumSdk] to start
  /// positioning, calculate routes and fetch resources.
  factory SitumSdk() {
    // Factory: ensure only one controller exists.
    return _controller;
  }

  SitumSdk._internal() {
    _initializeMethodChannel();
  }

  _initializeMethodChannel() {
    methodChannel = const MethodChannel(situmSdkChannelId);
    methodChannel.setMethodCallHandler(_methodCallHandler);
  }

  // Calls

  /// Initializes and authenticates [SitumSdk].
  ///
  /// This method must be called before invoking any other methods. The use of parameters in this method is
  /// deprecated, instead call it without them followed by setApiKey to authenticate yourself.
  /// * [situmUser] (deprecated) email associated with your account.
  /// * [situmApiKey] (deprecated) is the API key associated with your account.
  /// You can find this key at https://dashboard.situm.com/accounts/profile.
  ///
  /// **Note**: If you call this method without providing any parameters,
  /// it will only initialize the SDK. In this case, ensure to call [setApiKey] afterwards.
  Future<void> init([String? situmUser, String? situmApiKey]) async {
    if (situmApiKey == null) {
      await methodChannel.invokeMethod<String>('initSdk');
    } else {
      await methodChannel.invokeMethod<String>(
        'init',
        <String, dynamic>{
          'situmUser': "---@situm.com",
          // Underlying sdk expects to have a non empty, non null and valid email. But is not used anymore.
          'situmApiKey': situmApiKey,
        },
      );
    }
  }

  /// Sets the API's base URL to retrieve the data. **Make sure you follow the next steps**:
  ///
  /// * For this method to work correctly, you should call methods in the following order:
  ///     1. [init]
  ///     2. [setDashboardURL]
  ///     3. [setApiKey]
  ///
  /// Failing to follow this order might result in unexpected behavior.
  ///
  /// * Also make sure you have declared the same value for the
  /// [MapViewConfiguration.apiDomain] parameter if using our [MapView] widget.
  ///
  /// Failing to implement this parameter might result in unexpected behavior.
  ///
  /// [url] should include only the protocol and the domain (e.g., "https://dashboard.situm.com").
  /// Do not include paths or query parameters.
  Future<void> setDashboardURL(String? url) async {
    if (url == null) {
      url = "https://dashboard.situm.com";
    } else {
      if (!url.startsWith(RegExp(r'https://'))) {
        url = "https://$url";
      }
      if (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
      }
    }

    await methodChannel.invokeMethod(
      "setDashboardURL",
      <String, dynamic>{
        'url': url,
      },
    );
  }

  /// Authenticate yourself into our SDK to start positioning, navigating
  /// and using further functionalities of our SDK.
  ///
  /// * [situmApiKey] is the API key associated with your account.
  /// You can find this key at https://dashboard.situm.com/accounts/profile.
  ///
  /// **Note**: This method should only be used if you have called [init] without the optional parameters
  Future<void> setApiKey(String situmApiKey) async {
    await methodChannel.invokeMethod(
      "setApiKey",
      <String, dynamic>{
        'situmUser': "---@situm.com",
        // Underlying sdk expects to have a non empty, non null email. But is not used anymore.
        'situmApiKey': situmApiKey,
      },
    );
  }

  /// Sets the SDK [ConfigurationOptions].
  Future<void> setConfiguration(ConfigurationOptions options) async {
    await methodChannel.invokeMethod(
      "setConfiguration",
      <String, dynamic>{
        'useRemoteConfig': options.useRemoteConfig,
      },
    );
  }

  /// Starts positioning. Use [onLocationUpdate], [onLocationStatus] and
  /// [onLocationError] callbacks to receive location updates, status changes and
  /// positioning errors.
  Future<void> requestLocationUpdates(LocationRequest locationRequest) async {
    await methodChannel.invokeMethod(
        'requestLocationUpdates', locationRequest.toMap());
  }

  /// Get notified about location updates. See [requestLocationUpdates].
  Future<void> onLocationUpdate(OnLocationUpdateCallback callback) async {
    _onLocationUpdateCallback = callback;
  }

  /// Get notified about positioning status changes. See
  /// [requestLocationUpdates].
  Future<void> onLocationStatus(OnLocationStatusCallback callback) async {
    _onLocationStatusCallback = callback;
  }

  /// Get notified about positioning errors. See [requestLocationUpdates].
  Future<void> onLocationError(OnLocationErrorCallback callback) async {
    _onLocationErrorCallback = callback;
  }

  /// Requests directions between two [Point]s using the given
  /// [DirectionsRequest].
  Future<SitumRoute> requestDirections(
      DirectionsRequest directionsRequest) async {
    Map response = await methodChannel.invokeMethod(
        'requestDirections', directionsRequest.toMap());
    _onDirectionsRequestedCallback?.call(directionsRequest);
    return createRoute(response);
  }

  /// Requests navigation between two [Point]s, using the given
  /// [DirectionsRequest] and [NavigationRequest].
  Future<SitumRoute> requestNavigation(DirectionsRequest directionsRequest,
      NavigationRequest navigationRequest) async {
    Map response = await methodChannel.invokeMethod('requestNavigation', {
      // For convenience on the native side, set the buildingId here:
      "buildingIdentifier": directionsRequest.buildingIdentifier,
      // Set directions/navigation options:
      "directionsRequest": directionsRequest.toMap(),
      "navigationRequest": navigationRequest.toMap(),
    });
    return createRoute(response);
  }

  /// Stops navigation if running.
  Future<void> stopNavigation() async {
    await methodChannel.invokeMethod("stopNavigation", {});
  }

  /// Sets a callback that will be notified when the navigation starts.
  ///
  /// See [requestNavigation].
  Future<void> onNavigationStart(OnNavigationStartCallback callback) async {
    _onNavigationStartCallback = callback;
  }

  /// Sets a callback that will be notified when the destination is reached.
  /// This will happen when the user is close to the destination by less than
  /// the distanceToGoalThreshold of [NavigationRequest].
  ///
  /// See [requestNavigation].
  Future<void> onNavigationDestinationReached(
      OnNavigationDestinationReachedCallback callback) async {
    _onNavigationDestReachedCallback = callback;
  }

  /// Sets a callback that will be notified when the navigation is cancelled.
  /// This may happen due to user interaction or a call to [stopNavigation].
  Future<void> onNavigationCancellation(
      OnNavigationCancellationCallback callback) async {
    _onNavigationCancellationCallback = callback;
  }

  /// Sets a callback that will be notified on every navigation progress.
  ///
  /// See [requestNavigation].
  Future<void> onNavigationProgress(
      OnNavigationProgressCallback callback) async {
    _onNavigationProgressCallback = callback;
  }

  /// Sets a callback that will be notified when the current user gets out
  /// of the current route.
  ///
  /// See [requestNavigation].
  Future<void> onNavigationOutOfRoute(
      OnNavigationOutOfRouteCallback callback) async {
    _onNavigationOORCallback = callback;
  }

  /// Get notified when the user requests a route to any destination.
  void onDirectionsRequested(OnDirectionsRequestedCallback callback) {
    _onDirectionsRequestedCallback = callback;
  }

  Future<void> clearCache() async {
    await methodChannel.invokeMethod('clearCache');
  }

  /// Stops positioning.
  Future<void> removeUpdates() async {
    await methodChannel.invokeMethod('removeUpdates');
  }

  /// Downloads all the buildings for the current user.
  Future<List<Building>> fetchBuildings() async {
    List response = await methodChannel.invokeMethod("fetchBuildings");
    return createList<Building>(response, createBuilding);
  }

  /// Downloads all the building data for the selected building. This info
  /// includes [Floor]s, indoor and outdoor [Poi]s, events and paths. It also
  /// download floor maps and [PoiCategory] icons to local storage.
  Future<BuildingInfo> fetchBuildingInfo(String buildingIdentifier) async {
    Map response = await methodChannel.invokeMethod(
        "fetchBuildingInfo", {"buildingIdentifier": buildingIdentifier});
    return createBuildingInfo(response);
  }

  /// Downloads all the necessary information to start positioning. This includes
  /// [Building], [BuildingInfo] and the building's model. Downloaded
  /// information will be saved in cache.
  Future<String> prefetchPositioningInfo(
    List<String> buildingIdentifiers, {
    PrefetchOptions? options,
  }) async {
    Map<String, dynamic> optionsMap = {};
    if (options != null) {
      optionsMap = {
        "preloadImages": options.preloadImages,
      };
    }
    return await methodChannel.invokeMethod("prefetchPositioningInfo", {
      "buildingIdentifiers": buildingIdentifiers,
      "optionsMap": optionsMap,
    });
  }

  /// Returns the complete list of indoor POIs of the given building.
  Future<List<Poi>> fetchPoisFromBuilding(String buildingIdentifier) async {
    List response = await methodChannel.invokeMethod("fetchPoisFromBuilding", {
      "buildingIdentifier": buildingIdentifier,
    });
    return createList<Poi>(response, createPoi);
  }

  /// Returns the given indoor POI for the given building.
  Future<Poi?> fetchPoiFromBuilding(
      String buildingIdentifier, String poiIdentifier) async {
      var response = await methodChannel.invokeMethod("fetchPoiFromBuilding", {
        "buildingIdentifier": buildingIdentifier,
        "poiIdentifier": poiIdentifier
      });
      return createPoi(response);
  }

  Future<List<PoiCategory>> fetchPoiCategories() async {
    List response = await methodChannel.invokeMethod("fetchCategories");
    return createList<PoiCategory>(response, createCategory);
  }

  Future<String> getDeviceId() async {
    String response = await methodChannel.invokeMethod("getDeviceId");
    return response;
  }

  Future<List<String>> getCPUVendors() async {
    List response = await methodChannel.invokeMethod("getCPUVendors");
    return response.cast<String>();
  }

  Future<List<String>> getCPUModels() async {
    List response = await methodChannel.invokeMethod("getCPUModels");
    return response.cast<String>();
  }

  /// Get notified when the user enters a [Geofence]. Call this method before
  /// the positioning is started.
  Future<void> onEnterGeofences(OnEnteredGeofencesCallback callback) async {
    _onEnteredGeofencesCallback = callback;
    // Install the native listener only when it was explicitly required as it
    // supposes a computational costs.
    await methodChannel.invokeMethod('geofenceCallbacksRequested');
  }

  /// Get notified when the user exits a [Geofence]. Call this method before the
  /// positioning is started.
  Future<void> onExitGeofences(OnExitedGeofencesCallback callback) async {
    _onExitedGeofencesCallback = callback;
    // Install the native listener only when it was explicitly required as it
    // supposes a computational costs.
    await methodChannel.invokeMethod('geofenceCallbacksRequested');
  }

  /// Set a native [MethodCall] delegate.
  /// Do not use this method as it is intended for internal use by the map
  /// viewer module.
  void internalSetMethodCallDelegate(Function(MethodCall call) delegate) {
    internalMethodCallDelegate = delegate;
  }

  // Callbacks:

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'onLocationChanged':
        // Reset last status stored in case it was USER_NOT_IN_BUILDING
        // and a new location is received.
        _statusAdapter.resetUserNotInBuilding();

        _onLocationChanged(call.arguments);
        break;
      case 'onStatusChanged':
        if (call.arguments["statusName"] == "BLE_SENSOR_DISABLED_BY_USER") {
          // Send Android BLE_SENSOR_DISABLED_BY_USER as nonCritical error
          // to the _onLocationErrorCallback.
          // NOTE: MapViewController will keep receiving a the status, not the processed error
          _sendBleDisabledStatusAsError();
        } else {
          String? processedStatus =
              _statusAdapter.handleStatus(call.arguments["statusName"]);
          // statusName will be null when some native status should be ignored,
          // so do not forward this call in these cases.
          if (processedStatus == null) return;

          call.arguments["statusName"] = processedStatus;
          _onStatusChanged(call.arguments);
        }
        break;
      case 'onError':
        // TODO: We are currently processing only positioning errors,
        // in some future we might need to differentiate between
        // navigation errors, communication errors, ...
        Error proccessedError = _errorAdapter.handleError(call.arguments);
        // Modify the method call arguments with the processed error
        // before sending it to the _onLocationErrorCallback and the MapViewController.
        call.arguments["code"] = proccessedError.code;
        call.arguments["type"] = proccessedError.type;
        _onError(proccessedError);
        break;
      case 'onEnteredGeofences':
        _onEnterGeofences(call.arguments);
        break;
      case 'onExitedGeofences':
        _onExitGeofences(call.arguments);
        break;
      case 'onNavigationDestinationReached':
        _onNavigationDestinationReached();
        break;
      case 'onNavigationStart':
        _onNavigationStart(call.arguments);
        break;
      case 'onNavigationCancellation':
        _onNavigationCancellation();
        break;
      case 'onNavigationProgress':
        _onNavigationProgress(call.arguments);
        break;
      case 'onUserOutsideRoute':
        _onNavigationOutOfRoute();
        break;
      default:
        debugPrint('Method ${call.method} not found!');
    }
    // Forward call to internal delegate (send locations and status to MapViewController).
    internalMethodCallDelegate?.call(call);
  }

  // LOCATION UPDATES:

  void _onLocationChanged(arguments) {
    // Send location to the _onLocationUpdateCallback.
    _onLocationUpdateCallback?.call(createLocation(arguments));
  }

  void _onStatusChanged(arguments) {
    // Send the processed location status to the _onLocationStatusCallback.
    _onLocationStatusCallback?.call(arguments["statusName"]);
  }

  void _onError(Error proccessedError) {
    _onLocationErrorCallback?.call(proccessedError);
  }

  void _sendBleDisabledStatusAsError() {
    _onLocationErrorCallback?.call(Error.bleDisabledError());
  }

  // GEOFENCES:

  void _onEnterGeofences(arguments) {
    List<Geofence> geofencesList =
        createList<Geofence>(arguments, createGeofence);
    if (geofencesList.isNotEmpty) {
      _onEnteredGeofencesCallback
          ?.call(OnEnteredGeofenceResult(geofences: geofencesList));
    }
  }

  void _onExitGeofences(arguments) {
    List<Geofence> geofencesList =
        createList<Geofence>(arguments, createGeofence);
    if (geofencesList.isNotEmpty) {
      _onExitedGeofencesCallback
          ?.call(OnExitedGeofenceResult(geofences: geofencesList));
    }
  }

  // NAVIGATION UPDATES:

  void _onNavigationStart(arguments) {
    _onNavigationStartCallback?.call(SitumRoute(rawContent: arguments));
  }

  void _onNavigationProgress(arguments) {
    _onNavigationProgressCallback?.call(RouteProgress(rawContent: arguments));
  }

  void _onNavigationDestinationReached() {
    _onNavigationDestReachedCallback?.call();
  }

  void _onNavigationCancellation() {
    _onNavigationCancellationCallback?.call();
  }

  void _onNavigationOutOfRoute() {
    _onNavigationOORCallback?.call();
  }
}
