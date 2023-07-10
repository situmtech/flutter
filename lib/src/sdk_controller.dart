part of sdk;

/// Main entry point for the Situm Flutter SDK. Use [SitumSdk] to start
/// positioning, calculate routes and fetch resources.
///
/// ```dart
/// var situmSdk = SitumSdk();
/// // Set up your credentials:
/// situmSdk.init(situmUser, situmApiKey);
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

  OnNavigationFinishedCallback? _onNavigationFinishedCallback;
  OnNavigationProgressCallback? _onNavigationProgressCallback;
  OnNavigationOutOfRouteCallback? _onNavigationOORCallback;

  static final SitumSdk _controller = SitumSdk._internal();

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
    methodChannel = const MethodChannel(_CHANNEL_SDK_ID);
    methodChannel.setMethodCallHandler(_methodCallHandler);
  }

  // Calls

  /// Initializes [SitumSdk]. You have to call this function prior any call to
  /// other method.
  Future<void> init(String situmUser, String situmApiKey) async {
    await methodChannel.invokeMethod<String>(
      'init',
      <String, dynamic>{
        'situmUser': situmUser,
        'situmApiKey': situmApiKey,
      },
    );
  }

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

  /// Sets a callback that will be notified when the navigation finishes.
  /// This will happen when the user is close to the destination of the current
  /// route by less than the distanceToGoalThreshold of [NavigationRequest].
  ///
  /// See [requestNavigation].
  Future<void> onNavigationFinished(
      OnNavigationFinishedCallback callback) async {
    _onNavigationFinishedCallback = callback;
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

  Future<List<Poi>> fetchPoisFromBuilding(String buildingIdentifier) async {
    List response = await methodChannel.invokeMethod("fetchPoisFromBuilding", {
      "buildingIdentifier": buildingIdentifier,
    });
    return createList<Poi>(response, createPoi);
  }

  Future<Poi?> fetchPoiFromBuilding(
      String buildingIdentifier, String poiIdentifier) async {
    List<Poi> buildingPois = await fetchPoisFromBuilding(buildingIdentifier);
    return buildingPois.cast<Poi?>().firstWhere(
        (poi) => poi?.identifier == poiIdentifier,
        orElse: () => null);
  }

  Future<List<PoiCategory>> fetchPoiCategories() async {
    List response = await methodChannel.invokeMethod("fetchCategories");
    return createList<PoiCategory>(response, createCategory);
  }

  Future<String> getDeviceId() async {
    String response = await methodChannel.invokeMethod("getDeviceId");
    return response;
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
        _onLocationChanged(call.arguments);
        break;
      case 'onStatusChanged':
        _onStatusChanged(call.arguments);
        break;
      case 'onError':
        _onError(call.arguments);
        break;
      case 'onEnteredGeofences':
        _onEnterGeofences(call.arguments);
        break;
      case 'onExitedGeofences':
        _onExitGeofences(call.arguments);
        break;
      case 'onNavigationFinished':
        _onNavigationFinished();
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
    // Forward call to internal delegate (send locations to MapView).
    internalMethodCallDelegate?.call(call);
  }

  // LOCATION UPDATES:

  void _onLocationChanged(arguments) {
    _onLocationUpdateCallback?.call(createLocation(arguments));
  }

  void _onStatusChanged(arguments) {
    _onLocationStatusCallback?.call(arguments['statusName']);
  }

  void _onError(arguments) {
    _onLocationErrorCallback?.call(Error(
      code: "${arguments['code']}", // Ensure code is a string!
      message: arguments['message'],
    ));
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

  void _onNavigationFinished() {
    _onNavigationFinishedCallback?.call();
  }

  void _onNavigationProgress(arguments) {
    _onNavigationProgressCallback?.call(RouteProgress(rawContent: arguments));
  }

  void _onNavigationOutOfRoute() {
    _onNavigationOORCallback?.call();
  }
}
