part of situm_flutter_wayfinding;

class SitumFlutterWayfinding {
  late final MethodChannel methodChannel;

  // Load callback/Update callback.
  SitumMapViewCallback? situmMapLoadCallback;
  SitumMapViewCallback? situmMapDidUpdateCallback;

  // Keep loaded state.
  bool situmMapLoaded = false;

  // Both loading and loaded will block new native load calls.
  // loaded is used also in situm_map_view to delegate didUpdateCallback calls
  // only if WYF was completely loaded.
  bool situmMapLoading = false;
  OnPoiSelectedCallback? onPoiSelectedCallback;
  OnPoiDeselectedCallback? onPoiDeselectedCallback;
  OnNavigationRequestedCallback? onNavigationRequestedCallback;
  OnNavigationErrorCallback? onNavigationErrorCallback;
  OnNavigationFinishedCallback? onNavigationFinishedCallback;
  OnNavigationStartedCallback? onNavigationStartedCallback;

  static final SitumFlutterWayfinding _controller =
      SitumFlutterWayfinding._internal();

  factory SitumFlutterWayfinding() {
    // Factory: ensure only one controller exists.
    return _controller;
  }

  SitumFlutterWayfinding._internal() {
    _initializeMethodChannel();
  }

  _initializeMethodChannel() {
    methodChannel = const MethodChannel(CHANNEL_ID);
    methodChannel.setMethodCallHandler(_methodCallHandler);
  }

  // Calls:

  Future<String?> load({
      SitumMapViewCallback? situmMapLoadCallback,
      SitumMapViewCallback? situmMapDidUpdateCallback,
      Map<String, dynamic>? creationParams,
  }) async {

    if (situmMapLoadCallback != null) {
      this.situmMapLoadCallback = situmMapLoadCallback;
    }
    if (situmMapDidUpdateCallback != null) {
      this.situmMapDidUpdateCallback = situmMapDidUpdateCallback;
    }

    print("Situm> Dart load() invoked.");
    if (defaultTargetPlatform == TargetPlatform.android) {
      // iOS will handle multiple load calls with presentInNewView().
      // Android will handle multiple load calls by returning immediately.
      if (situmMapLoading) {
        return "ALREADY_LOADING";
      }
      if (situmMapLoaded) {
        return "ALREADY_DONE";
      }
    }
    print("Situm> MethodChannel will be invoked.");
    situmMapLoading = true;
    final result = await methodChannel.invokeMethod<String>('load', creationParams);
    print("Situm> Got load result: $result");
    situmMapLoaded = true;
    situmMapLoadCallback?.call(this);
    situmMapDidUpdateCallback?.call(this);
    return result;
  }

  Future<void> unload() async {
    await methodChannel.invokeMethod("unload");
    situmMapLoaded = false;
    situmMapLoading = false;
  }

  Future<void> updateView() async {
    // TODO: probably this can be deleted using didUpdateWidget.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await load();
    }
  }

  Future<String?> selectPoi(String id, String buildingId) async {
    log("Dart selectPoi called, methodChannel will be invoked.");
    return await methodChannel.invokeMethod<String>(
        'selectPoi', <String, dynamic>{'id': id, 'buildingId': buildingId});
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

  Future<String?> stopNavigation() async {
    log("Dart stopNavigation called, methodChannel will be invoked.");
    return await methodChannel.invokeMethod<String>('stopNavigation');
  }

  void onPoiSelected(OnPoiSelectedCallback callback) {
    onPoiSelectedCallback = callback;
  }

  void onPoiDeselected(OnPoiDeselectedCallback callback) {
    onPoiDeselectedCallback = callback;
  }

  void onNavigationRequested(OnNavigationRequestedCallback callback) {
    onNavigationRequestedCallback = callback;
  }

  void onNavigationError(OnNavigationErrorCallback callback) {
    onNavigationErrorCallback = callback;
  }

  void onNavigationFinished(OnNavigationFinishedCallback callback) {
    onNavigationFinishedCallback = callback;
  }

  void onNavigationStarted(OnNavigationStartedCallback callback) {
    onNavigationStartedCallback = callback;
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
      case 'onNavigationRequested':
        _onNavigationRequested(call.arguments);
        break;
      case 'onNavigationFinished':
        _onNavigationFinished(call.arguments);
        break;
      case 'onNavigationError':
        _onNavigationError(call.arguments);
        break;
      case 'onNavigationStarted':
        _onNavigationStarted(call.arguments);
        break;
      default:
        print('Method ${call.method} not found!');
    }
  }

  void _onPoiSelected(arguments) {
    print("Situm> _onPoiSelected invoked.");

    onPoiSelectedCallback?.call(OnPoiSelectedResult(
      buildingId: arguments['buildingId'],
      buildingName: arguments['buildingName'],
      floorId: arguments['floorId'],
      floorName: arguments['floorName'],
      poiId: arguments['poiId'],
      poiName: arguments['poiName'],
      poiInfoHtml: arguments['poiInfoHtml'],
    ));
  }

  void _onPoiDeselected(arguments) {
    print("Situm> _onPoiDeselected invoked.");

    onPoiDeselectedCallback?.call(OnPoiDeselectedResult(
        buildingId: arguments['buildingId'],
        buildingName: arguments['buildingName']));
  }

  void _onNavigationRequested(arguments) {
    print("Situm> _onNavigationRequested invoked.");

    // TODO: pass NavigationResult.
    onNavigationRequestedCallback?.call(arguments['destinationId']);
  }

  void _onNavigationFinished(arguments) {
    print("Situm> _onNavigationFinished invoked.");

    // TODO: pass NavigationResult.
    onNavigationFinishedCallback?.call(arguments['destinationId']);
  }

  void _onNavigationError(arguments) {
    print("Situm> _onNavigationError invoked.");

    // TODO: pass NavigationResult.
    onNavigationErrorCallback?.call(
      arguments['destinationId'],
      arguments['error'],
    );
  }

  void _onNavigationStarted(arguments) {
    print("Situm> _onNavigationStarted invoked.");
    onNavigationStartedCallback?.call(createNavigationResult(arguments));
  }
}
