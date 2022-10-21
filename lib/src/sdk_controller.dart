part of situm_flutter_sdk;

class SitumFlutterSDK {
  late final MethodChannel methodChannel;
  late final MethodChannel wayfindingMethodChannel;
  LocationListener? locationListener;
  OnEnteredGeofencesCallback? onEnteredGeofencesCallback;
  OnExitedGeofencesCallback? onExitedGeofencesCallback;

  SitumFlutterSDK() {
    methodChannel = const MethodChannel(CHANNEL_SDK_ID);
    methodChannel.setMethodCallHandler(_methodCallHandler);

    wayfindingMethodChannel = const MethodChannel('situm.com/flutter_wayfinding');
    // Stablish callback

  }

  // Calls

  Future<void> init(String situmUser, String situmApiKey) async {
    await methodChannel.invokeMethod<String>('init',
        <String, dynamic>{'situmUser': situmUser, 'situmApiKey': situmApiKey});
  }

  Future<void> selectPoi(String identifier) async {
    await wayfindingMethodChannel.invokeMethod('selectPoi', {
      "identifier" : identifier,
    });
  }

  Future<void> requestLocationUpdates(
      LocationListener listener, Map<String, dynamic> locationRequest) async {
    locationListener = listener;
    await methodChannel.invokeMethod('requestLocationUpdates', locationRequest);
  }

  Future<void> removeUpdates() async {
    locationListener = null;
    await methodChannel.invokeMethod('removeUpdates');
  }

  Future<String> prefetchPositioningInfo(
      List<String> buildingIdentifiers) async {
    return await methodChannel.invokeMethod("prefetchPositioningInfo", {
      "buildingIdentifiers": buildingIdentifiers,
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
    List<dynamic> geofencesData = arguments['geofences'];
    List<Geofence> geofencesList = createGeofences(geofencesData);
    if (geofencesList.isNotEmpty) {
      onEnteredGeofencesCallback
          ?.call(OnEnteredGeofenceResult(geofences: geofencesList));
    }
  }

  void _onExitGeofences(arguments) {
    List<dynamic> geofencesData = arguments['geofences'];
    List<Geofence> geofencesList = createGeofences(geofencesData);
    if (geofencesList.isNotEmpty) {
      onExitedGeofencesCallback
          ?.call(OnExitedGeofenceResult(geofences: geofencesList));
    }
  }
}
