part of situm_flutter_sdk;

class SitumFlutterSDK {
  late final MethodChannel methodChannel;

  OnLocationChangeCallback? onLocationChangeCallback;
  OnStatusChangeCallback? onStatusChangeCallback;
  OnErrorCallback? onErrorCallback;

  OnEnteredGeofencesCallback? onEnteredGeofencesCallback;
  OnExitedGeofencesCallback? onExitedGeofencesCallback;

  SitumFlutterSDK() {
    methodChannel = const MethodChannel(CHANNEL_SDK_ID);
    methodChannel.setMethodCallHandler(_methodCallHandler);
    // Stablish callback
  }

  // Calls

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

  Future<void> requestLocationUpdates(
      LocationRequest locationRequest) async {
    await methodChannel.invokeMethod('requestLocationUpdates', locationRequest.toJson());
  }

  Future<void> onLocationChange(OnLocationChangeCallback callback) async {
    onLocationChangeCallback = callback;
  }

  Future<void> onStatusChange(OnStatusChangeCallback callback) async {
    onStatusChangeCallback = callback;
  }

  Future<void> onError(OnErrorCallback callback) async {
    onErrorCallback = callback;
  }

  Future<void> clearCache() async {
    await methodChannel.invokeMethod('clearCache');
  }

  Future<void> removeUpdates() async {
    await methodChannel.invokeMethod('removeUpdates');
  }

  Future<List<Building>> fetchBuildings() async {
    List response = await methodChannel.invokeMethod("fetchBuildings");
    return createList<Building>(response, createBuilding);
  }

  Future<BuildingInfo> fetchBuildingInfo(String buildingId) async {
    Map response = await methodChannel
        .invokeMethod("fetchBuildingInfo", {"buildingId": buildingId});
    return createBuildingInfo(response);
  }

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
    return buildingPois.cast<Poi?>().firstWhere((poi) => poi?.id == poiId, orElse: () => null);
  }

  Future<List<PoiCategory>> fetchPoiCategories() async {
    List response = await methodChannel.invokeMethod("fetchCategories");
    return createList<PoiCategory>(response, createCategory);
  }

  Future<void> onEnterGeofences(OnEnteredGeofencesCallback callback) async {
    onEnteredGeofencesCallback = callback;
    // Install the native listener only when it was explicitly required as it
    // supposes a computational costs.
    await methodChannel.invokeMethod('geofenceCallbacksRequested');
  }

  Future<void> onExitGeofences(OnExitedGeofencesCallback callback) async {
    onExitedGeofencesCallback = callback;
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
      default:
        debugPrint('Method ${call.method} not found!');
    }
  }

  void _onLocationChanged(arguments) {
    onLocationChangeCallback?.call(Location.fromArguments(arguments));
  }

  void _onStatusChanged(arguments) {
    onStatusChangeCallback?.call(arguments['status']);
  }

  void _onError(arguments) {
    onErrorCallback?.call(Error(
      code: "${arguments['code']}", // Ensure code is a string!
      message: arguments['message'],
    ));
  }

  void _onEnterGeofences(arguments) {
    List<Geofence> geofencesList =
        createList<Geofence>(arguments, createGeofence);
    if (geofencesList.isNotEmpty) {
      onEnteredGeofencesCallback
          ?.call(OnEnteredGeofenceResult(geofences: geofencesList));
    }
  }

  void _onExitGeofences(arguments) {
    List<Geofence> geofencesList =
        createList<Geofence>(arguments, createGeofence);
    if (geofencesList.isNotEmpty) {
      onExitedGeofencesCallback
          ?.call(OnExitedGeofenceResult(geofences: geofencesList));
    }
  }
}
