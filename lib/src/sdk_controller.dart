part of situm_flutter_sdk;

class SitumFlutterSDK {
  late final MethodChannel methodChannel;
  LocationListener? locationListener;
  OnEnterGeofenceCallback? onEnterGeofenceCallback;

  SitumFlutterSDK() {
    methodChannel = const MethodChannel(CHANNEL_SDK_ID);
    methodChannel.setMethodCallHandler(_methodCallHandler);
  }

  // Calls

  Future<void> init(String situmUser, String situmApiKey) async {
    log("Dart selectPoi called, methodChannel will be invoked.");
    await methodChannel.invokeMethod<String>('init',
        <String, dynamic>{'situmUser': situmUser, 'situmApiKey': situmApiKey});
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

  Future<void> onEnterGeofence(OnEnterGeofenceCallback callback) async {
    onEnterGeofenceCallback = callback;
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
      case 'onEnterGeofence':
        _onEnterGeofence(call.arguments);
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

  void _onEnterGeofence(arguments) {
    // TODO: list of OnEnterGeofenceResult?
    // TODO: OnEnterGeofenceResult contains list?
    onEnterGeofenceCallback?.call([
      OnEnterGeofenceResult(
        geofenceId: arguments['geofenceId'],
        geofenceName: arguments['geofenceName'],
      )
    ]);
  }
}
