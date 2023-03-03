part of situm_flutter_sdk;

class SitumFlutterSDK {
  late final MethodChannel methodChannel;

  LocationListener? locationListener;
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
      LocationListener listener, Map<String, dynamic> locationRequest) async {
    if (!identical(locationListener, listener)) {
      locationListener = listener;
      await methodChannel.invokeMethod(
          'requestLocationUpdates', locationRequest);
    }
  }

  Future<void> clearCache() async {
    await methodChannel.invokeMethod('clearCache');
  }

  Future<void> removeUpdates() async {
    await methodChannel.invokeMethod('removeUpdates');
  }

  Future<List<Building>> fetchBuildings() async {
    List response = await methodChannel.invokeMethod("fetchBuildings");
    return createBuildings(response);
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
    return createPois(response);
  }

  Future<List<PoiCategory>> fetchPoiCategories() async {
    List response = await methodChannel.invokeMethod("fetchCategories");
    return createCategories(response);
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
        print('Method ${call.method} not found!');
    }
  }

  void _onLocationChanged(arguments) {
    locationListener?.onLocationChanged(OnLocationChangedResult(
      buildingId: arguments['buildingId'],
    ));
  }

  void _onStatusChanged(arguments) {
    locationListener?.onStatusChanged(arguments['status']);
  }

  void _onError(arguments) {
    locationListener?.onError(Error(
      code: arguments['code'],
      message: arguments['message'],
    ));
  }

  void _onEnterGeofences(arguments) {
    List<Geofence> geofencesList = createGeofences(arguments);
    if (geofencesList.isNotEmpty) {
      onEnteredGeofencesCallback
          ?.call(OnEnteredGeofenceResult(geofences: geofencesList));
    }
  }

  void _onExitGeofences(arguments) {
    List<Geofence> geofencesList = createGeofences(arguments);
    if (geofencesList.isNotEmpty) {
      onExitedGeofencesCallback
          ?.call(OnExitedGeofenceResult(geofences: geofencesList));
    }
  }
}
