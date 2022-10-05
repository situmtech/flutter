part of situm_flutter_wayfinding;

class SitumFlutterWayfinding {
  late final MethodChannel methodChannel;
  OnPoiSelectedCallback? onPoiSelectedCallback;
  OnPoiDeselectedCallback? onPoiDeselectedCallback;

  SitumFlutterWayfinding(int id) {
    methodChannel = MethodChannel('${CHANNEL_ID}_$id');
    methodChannel.setMethodCallHandler(_methodCallHandler);
  }

  // Calls:

  Future<String?> load(SitumMapViewCallback situmMapResultCallback,
      Map<String, dynamic> creationParams) async {
    log("Dart load called, methodChannel will be invoked.");
    final result =
        await methodChannel.invokeMethod<String>('load', creationParams);
    situmMapResultCallback(this);
    return result;
  }

  Future<String?> selectPoi(String id, String buildingId) async {
    log("Dart selectPoi called, methodChannel will be invoked.");
    return await methodChannel.invokeMethod<String>('selectPoi',
        <String, dynamic>{'id': id, 'buildingId': buildingId});
  }

  Future<String?> startPositioning() async {
    log("Dart startPositioning called, methodChannel will be invoked.");
    return await methodChannel.invokeMethod<String>('startPositioning');
  }

  Future<String?> stopPositioning() async {
    log("Dart stopPositioning called, methodChannel will be invoked.");
    return await methodChannel.invokeMethod<String>('stopPositioning');
  }

  void onPoiSelected(OnPoiSelectedCallback callback) {
    onPoiSelectedCallback = callback;
  }

  void onPoiDeselected(OnPoiDeselectedCallback callback) {
    onPoiDeselectedCallback = callback;
  }

  // Callbacks:

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'onPoiSelected':
        _onPoiSelected(call.arguments);
        break;
      case 'onPoiDeselected':
        _onPoiDeselected(call.arguments);
        break;
      default:
        print('Method ${call.method} not found!');
    }
  }

  void _onPoiSelected(arguments) {
    onPoiSelectedCallback?.call(OnPoiSelectedResult(
        buildingId: arguments['buildingId'],
        buildingName: arguments['buildingName'],
        floorId: arguments['floorId'],
        floorName: arguments['floorName'],
        poiId: arguments['poiId'],
        poiName: arguments['poiName']));
  }

  void _onPoiDeselected(arguments) {
    onPoiDeselectedCallback?.call(OnPoiDeselectedResult(
        buildingId: arguments['buildingId'],
        buildingName: arguments['buildingName']));
  }
}
