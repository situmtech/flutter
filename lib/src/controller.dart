part of situm_flutter_wayfinding;

class SitumFlutterWayfinding {
  late final MethodChannel methodChannel;
  bool situmMapLoaded = false;
  OnPoiSelectedCallback? onPoiSelectedCallback;
  OnPoiDeselectedCallback? onPoiDeselectedCallback;

  SitumFlutterWayfinding(int id) {
    methodChannel = MethodChannel('${CHANNEL_ID}_$id');
    methodChannel.setMethodCallHandler(_methodCallHandler);
  }

  // Calls:

  Future<String?> load(
      SitumMapViewCallback situmMapLoadCallback,
      SitumMapViewCallback? situmMapDidUpdateCallback,
    Map<String, dynamic> creationParams
  ) async {
    print("Situm> Dart load called, methodChannel will be invoked.");
    final result = await methodChannel.invokeMethod<String>('load', creationParams);
    print("Situm> Got load result: $result");
    situmMapLoaded = true;
    situmMapLoadCallback(this);
    situmMapDidUpdateCallback?.call(this);
    return result;
  }

  Future<void> unload() async {
    await methodChannel.invokeMethod("unload");
    situmMapLoaded = false;
  }

  Future<String?> selectPoi(String id, String buildingId) async {
    log("Dart selectPoi called, methodChannel will be invoked.");
    return await methodChannel.invokeMethod<String>('selectPoi',
        <String, dynamic>{'id': id, 'buildingId': buildingId});
  }

  Future<void> filterPoisBy(List<String> categoryIdsFilter) async {
    log("Dart filterPoisBy called, methodChannel will be invoked.");
    return await methodChannel.invokeMethod<void>('filterPoisBy',
        <String, List<String>>{'categoryIdsFilter': categoryIdsFilter});
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
