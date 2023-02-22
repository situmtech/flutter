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

  // The parent widget of SitumMapView may be disposed, for example, on calls
  // to Navigator.pushReplacementNamed(...). In such a case, if the map view was
  // already loaded, the native load() will not be called again, skipping future
  // calls to onMapLoadCallback. Any code relying on onMapLoadCallback will not
  // be called after the widget dispose() and any callback/closure established
  // before dispose() will get out of context (unmounted state).
  // To avoid this situation, check if dispose() was called to scale up
  // onMapLoadCallback in the next load call. If the parent widget is destroyed
  // and restored, it will receive the onMapLoadCallback again and its state
  // will be the expected one.
  bool onDisposeCalled = false;

  OnPoiSelectedCallback? onPoiSelectedCallback;
  OnPoiDeselectedCallback? onPoiDeselectedCallback;
  OnNavigationRequestedCallback? onNavigationRequestedCallback;
  OnNavigationErrorCallback? onNavigationErrorCallback;
  OnNavigationFinishedCallback? onNavigationFinishedCallback;
  OnNavigationStartedCallback? onNavigationStartedCallback;
  OnCustomPoiSelectedCallback? onCustomPoiSelectedCallback;
  OnCustomPoiDeselectedCallback? onCustomPoiDeselectedCallback;
  OnCustomPoiSetCallback? onCustomPoiSetCallback;
  OnCustomPoiRemovedCallback? onCustomPoiRemovedCallback;

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
      // TODO: check iOS onDisposeCalled.
      if (situmMapLoading) {
        return "ALREADY_LOADING";
      }
      if (situmMapLoaded) {
        notifyLoadCallbacksIfNeeded();
        return "ALREADY_DONE";
      }
    }
    print("Situm> MethodChannel will be invoked.");
    situmMapLoading = true;
    final result =
        await methodChannel.invokeMethod<String>('load', creationParams);
    print("Situm> Got load result: $result");
    situmMapLoading = false;
    situmMapLoaded = true;
    notifyLoadCallbacks();
    return result;
  }

  void notifyLoadCallbacksIfNeeded() {
    if (onDisposeCalled) {
      onDisposeCalled = false;
      notifyLoadCallbacks();
    }
  }

  void notifyLoadCallbacks() {
    situmMapLoadCallback?.call(this);
    situmMapDidUpdateCallback?.call(this);
  }

  void onWidgetDisposed() {
    onDisposeCalled = true;
  }

  Future<void> unload() async {
    print("Situm> unload() method called.");
    //if (!situmMapLoading) {
    // TODO: this needs furder analysis: native "unload" is only removing the view.
    print("Situm> MethodChannel will be invoked for unload().");
    await methodChannel.invokeMethod("unload");
    situmMapLoaded = false;
    situmMapLoading = false;
    //}
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

  Future<String?> startCustomPoiCreation(String name, String description,
      String encodedSelectedIcon, String encodedUnSelectedIcon) async {
    log("Dart startCustomPoiCreation called, methodChannel will be invoked.");
    return await methodChannel
        .invokeMethod<String>('startCustomPoiCreation', <String, String>{
      'name': name,
      'description': description,
      'selectedIcon': encodedSelectedIcon,
      'unSelectedIcon': encodedUnSelectedIcon
    });
  }

  Future<String?> removeCustomPoi(int poiId) async {
    log("Dart removeCustomPoi called, methodChannel will be invoked.");
    return await methodChannel
        .invokeMethod<String>('removeCustomPoi', <String, int>{'poiId': poiId});
  }

  Future<String?> selectCustomPoi(int poiId) async {
    log("Dart selectCustomPoi called, methodChannel will be invoked.");
    return await methodChannel
        .invokeMethod<String>('selectCustomPoi', <String, int>{'poiId': poiId});
  }

  Future<CustomPoi?> getCustomPoi() async {
    log("Dart getCustomPoi called, methodChannel will be invoked.");
    var result = await methodChannel.invokeMethod('getCustomPoi');
    return result != null ? createCustomPoi(result) : null;
  }

  Future<CustomPoi?> getCustomPoiById(int poiId) async {
    log("Dart getCustomPoi called, methodChannel will be invoked.");
    var result = await methodChannel
        .invokeMethod('getCustomPoiById', <String, int>{'poiId': poiId});
    return result != null ? createCustomPoi(result) : null;
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

  void onCustomPoiSet(OnCustomPoiSetCallback callback) {
    onCustomPoiSetCallback = callback;
  }

  void onCustomPoiRemoved(OnCustomPoiRemovedCallback callback) {
    onCustomPoiRemovedCallback = callback;
  }

  void onCustomPoiSelected(OnCustomPoiSelectedCallback callback) {
    onCustomPoiSelectedCallback = callback;
  }

  void onCustomPoiDeselected(OnCustomPoiDeselectedCallback callback) {
    onCustomPoiDeselectedCallback = callback;
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
      case 'onCustomPoiSet':
        _onCustomPoiSet(call.arguments);
        break;
      case 'onCustomPoiRemoved':
        _onCustomPoiRemoved(call.arguments);
        break;
      case 'onCustomPoiSelected':
        _onCustomPoiSelected(call.arguments);
        break;
      case 'onCustomPoiDeselected':
        _onCustomPoiDeselected(call.arguments);
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

  void _onCustomPoiSet(arguments) {
    print("Situm> _onCustomPoiSet invoked.");
    onCustomPoiSetCallback?.call(createCustomPoi(arguments));
  }

  void _onCustomPoiRemoved(arguments) {
    print("Situm> _onCustomPoiRemoved invoked.");
    onCustomPoiRemovedCallback?.call(arguments["poiId"]);
  }

  void _onCustomPoiSelected(arguments) {
    print("Situm> _onCustomPoiSelected invoked.");
    onCustomPoiSelectedCallback?.call(arguments["poiId"]);
  }

  void _onCustomPoiDeselected(arguments) {
    print("Situm> _onCustomPoiDeselected invoked.");
    onCustomPoiDeselectedCallback?.call(arguments["poiId"]);
  }
}
