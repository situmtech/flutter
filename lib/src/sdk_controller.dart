part of situm_flutter_sdk;

class SitumFlutterSDK {
  late final MethodChannel methodChannel;

  OnLocationChangeCallback? _onLocationChangeCallback;
  OnStatusChangeCallback? _onStatusChangeCallback;
  OnErrorCallback? _onErrorCallback;

  OnEnteredGeofencesCallback? _onEnteredGeofencesCallback;
  OnExitedGeofencesCallback? _onExitedGeofencesCallback;

  OnNavigationFinishedCallback? _onNavigationFinishedCallback;
  OnNavigationProgressCallback? _onNavigationProgressCallback;
  OnNavigationOutOfRouteCallback? _onNavigationOORCallback;

  static final SitumFlutterSDK _controller = SitumFlutterSDK._internal();

  factory SitumFlutterSDK() {
    // Factory: ensure only one controller exists.
    return _controller;
  }

  SitumFlutterSDK._internal() {
    _initializeMethodChannel();
  }

  _initializeMethodChannel() {
    methodChannel = const MethodChannel(CHANNEL_SDK_ID);
    methodChannel.setMethodCallHandler(_methodCallHandler);
  }

  // Calls

  /// Initialize SDK. You have to call this function prior any call to other
  /// method.
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

  /// Start positioning. Use [onLocationChange], [onStatusChange] and
  /// [onError] callbacks to receive location updates, status changes and
  /// positioning errors.
  Future<void> requestLocationUpdates(LocationRequest locationRequest) async {
    await methodChannel.invokeMethod(
        'requestLocationUpdates', locationRequest.toMap());
  }

  /// Get notified about location updates. See [requestLocationUpdates].
  Future<void> onLocationChange(OnLocationChangeCallback callback) async {
    _onLocationChangeCallback = callback;
  }

  /// Get notified about positioning status changes. See
  /// [requestLocationUpdates].
  Future<void> onStatusChange(OnStatusChangeCallback callback) async {
    _onStatusChangeCallback = callback;
  }

  /// Get notified about positioning errors. See [requestLocationUpdates].
  Future<void> onError(OnErrorCallback callback) async {
    _onErrorCallback = callback;
  }

  /// Request directions between two [Point]s, using the given
  /// [DirectionsOptions].
  Future<SitumRoute> requestDirections(
      DirectionsOptions directionsOptions) async {
    Map response = await methodChannel.invokeMethod(
        'requestDirections', directionsOptions.toMap());
    return createRoute(response);
  }

  /// Request navigation between two [Point]s, using the given
  /// [DirectionsOptions] and [NavigationRequest].
  Future<SitumRoute> requestNavigation(DirectionsOptions directionsOptions,
      NavigationOptions navigationOptions) async {
    Map response = await methodChannel.invokeMethod('requestNavigation', {
      // For convenience on the native side, set the buildingId here:
      "buildingId": directionsOptions.buildingId,
      // Set directions/navigation options:
      "directionsOptions": directionsOptions.toMap(),
      "navigationOptions": navigationOptions.toMap()
    });
    return createRoute(response);
  }

  /// Stop navigation if running.
  Future<void> stopNavigation() async {
    await methodChannel.invokeMethod("stopNavigation", {});
  }

  /// Set a callback that will be notified when the navigation finishes.
  /// This will happen when the user is close to the destination of the current
  /// route by less than the distanceToGoalThreshold of [NavigationOptions].
  /// See [requestNavigation].
  Future<void> onNavigationFinished(
      OnNavigationFinishedCallback callback) async {
    _onNavigationFinishedCallback = callback;
  }

  /// Set a callback that will be notified on every navigation progress.
  /// See [requestNavigation].
  Future<void> onNavigationProgress(
      OnNavigationProgressCallback callback) async {
    _onNavigationProgressCallback = callback;
  }

  /// Set a callback that will be notified when the current the user gets out
  /// of the current route.
  /// See [requestNavigation].
  Future<void> onNavigationOutOfRoute(
      OnNavigationOutOfRouteCallback callback) async {
    _onNavigationOORCallback = callback;
  }

  Future<void> clearCache() async {
    await methodChannel.invokeMethod('clearCache');
  }

  /// Stop positioning.
  Future<void> removeUpdates() async {
    await methodChannel.invokeMethod('removeUpdates');
  }

  /// Download all the buildings for the current user.
  Future<List<Building>> fetchBuildings() async {
    List response = await methodChannel.invokeMethod("fetchBuildings");
    return createList<Building>(response, createBuilding);
  }

  /// Download all the building data for the selected building. This info
  /// includes [Floor]s, indoor and outdoor [Poi]s, events and paths. It also
  /// download floor maps and [PoiCategory] icons to local storage.
  Future<BuildingInfo> fetchBuildingInfo(String buildingId) async {
    Map response = await methodChannel
        .invokeMethod("fetchBuildingInfo", {"buildingId": buildingId});
    return createBuildingInfo(response);
  }

  /// Download all the necessary information to start positioning. This includes
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

  Future<List<Poi>> fetchPoisFromBuilding(String buildingId) async {
    List response = await methodChannel.invokeMethod("fetchPoisFromBuilding", {
      "buildingId": buildingId,
    });
    return createList<Poi>(response, createPoi);
  }

  Future<Poi?> fetchPoiFromBuilding(String buildingId, String poiId) async {
    List<Poi> buildingPois = await fetchPoisFromBuilding(buildingId);
    return buildingPois
        .cast<Poi?>()
        .firstWhere((poi) => poi?.id == poiId, orElse: () => null);
  }

  Future<List<PoiCategory>> fetchPoiCategories() async {
    List response = await methodChannel.invokeMethod("fetchCategories");
    return createList<PoiCategory>(response, createCategory);
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
      case 'navigation.finished':
        _onNavigationFinished();
        break;
      case 'navigation.progress':
        _onNavigationProgress(call.arguments);
        break;
      case 'navigation.oor':
        _onNavigationOutOfRoute();
        break;
      default:
        debugPrint('Method ${call.method} not found!');
    }
  }

  // LOCATION UPDATES:

  void _onLocationChanged(arguments) {
    _onLocationChangeCallback?.call(createLocation(arguments));
  }

  void _onStatusChanged(arguments) {
    _onStatusChangeCallback?.call(arguments['statusName']);
  }

  void _onError(arguments) {
    _onErrorCallback?.call(Error(
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
