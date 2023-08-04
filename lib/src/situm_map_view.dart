part of situm_flutter_wayfinding;

// The Widget!
class SitumMapView extends StatefulWidget {
  final String situmUser;
  final String situmApiKey;
  final String buildingIdentifier;
  final String googleMapsApiKey;
  final bool useHybridComponents;
  final TextDirection directionality;
  final bool enablePoiClustering;
  final String searchViewPlaceholder;
  final bool useDashboardTheme;
  final bool showPoiNames;
  final bool hasSearchView;
  final bool lockCameraToBuilding;
  final bool useRemoteConfig;
  final int initialZoom;
  final int minZoom;
  final int maxZoom;
  final bool showNavigationIndications;
  final bool showFloorSelector;
  final bool showPositioningButton;
  final NavigationSettings? navigationSettings;
  final DirectionsSettings? directionsSettings;

  final SitumMapViewCallback loadCallback;
  final SitumMapViewCallback? didUpdateCallback;

  const SitumMapView({
    required Key key,
    required this.situmUser,
    required this.situmApiKey,
    required this.buildingIdentifier,
    required this.loadCallback,
    this.googleMapsApiKey = "",
    this.didUpdateCallback,
    this.useHybridComponents = true,
    this.directionality = TextDirection.ltr,
    this.enablePoiClustering = true,
    this.searchViewPlaceholder = "Situm Flutter Wayfinding",
    this.useDashboardTheme = true,
    this.showPoiNames = true,
    this.hasSearchView = true,
    this.lockCameraToBuilding = false,
    this.useRemoteConfig = true,
    this.initialZoom = 18,
    this.minZoom = 15,
    this.maxZoom = 21,
    this.showNavigationIndications = true,
    this.showFloorSelector = true,
    this.showPositioningButton = true,
    this.navigationSettings,
    this.directionsSettings,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SitumMapViewState();
}

class _SitumMapViewState extends State<SitumMapView> {
  SitumFlutterWayfinding? controller;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> platformViewParams = <String, dynamic>{
      // TODO: add view specific creation params.
    };
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _buildAndroidView(
          context, platformViewParams, widget.directionality);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _buildiOS(context, platformViewParams, widget.directionality);
    }
    return Text('$defaultTargetPlatform is not supported by the Situm plugin');
  }

  Future<void> _onPlatformViewCreated(int id) async {
    print("Situm> _onPlatformViewCreated called");
    Map<String, dynamic> loadParams = _createLoadParams();
    controller = SitumFlutterWayfinding();
    controller!.load(
        situmMapLoadCallback: widget.loadCallback,
        situmMapDidUpdateCallback: widget.didUpdateCallback,
        creationParams: loadParams);
  }

  @override
  void didUpdateWidget(covariant SitumMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (controller?.situmMapLoaded == true) {
      widget.didUpdateCallback?.call(controller!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller?.onWidgetDisposed();
  }

  // ==========================================================================
  // iOS
  // ==========================================================================

  Widget _buildiOS(
    BuildContext context,
    Map<String, dynamic> creationParams,
    TextDirection directionality,
  ) {
    const String viewType = '<platform-view-type>';

    Map<String, dynamic> loadParams = _createLoadParams();

    return UiKitView(
      viewType: viewType,
      layoutDirection: directionality,
      creationParams: loadParams,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: _onPlatformViewCreated,
    );
  }

  Map<String, dynamic> _createLoadParams() {
    return <String, dynamic>{
      "situmUser": widget.situmUser,
      "situmApiKey": widget.situmApiKey,
      "buildingIdentifier": widget.buildingIdentifier,
      "googleMapsApiKey": widget.googleMapsApiKey,
      "enablePoiClustering": widget.enablePoiClustering,
      "useHybridComponents": widget.useHybridComponents,
      "searchViewPlaceholder": widget.searchViewPlaceholder,
      "useDashboardTheme": widget.useDashboardTheme,
      "showPoiNames": widget.showPoiNames,
      "hasSearchView": widget.hasSearchView,
      "lockCameraToBuilding": widget.lockCameraToBuilding,
      "useRemoteConfig": widget.useRemoteConfig,
      "initialZoom": widget.initialZoom,
      "minZoom": widget.minZoom,
      "maxZoom": widget.maxZoom,
      "showFloorSelector": widget.showFloorSelector,
      "showPositioningButton": widget.showPositioningButton,
      "navigationSettings": widget.navigationSettings?.toMap(),
      "directionsSettings": widget.directionsSettings?.toMap(),
      "showNavigationIndications": widget.showNavigationIndications,
    };
  }

  // ==========================================================================
  // ANDROID
  // ==========================================================================

  Widget _buildAndroidView(
    BuildContext context,
    Map<String, dynamic> creationParams,
    TextDirection directionality,
  ) {
    if (widget.useHybridComponents) {
      return _buildHybrid(context, creationParams, directionality);
    }
    return _buildVirtualDisplay(context, creationParams);
  }

  Widget _buildHybrid(
    BuildContext context,
    Map<String, dynamic> creationParams,
    TextDirection directionality,
  ) {
    return PlatformViewLink(
      viewType: CHANNEL_ID,
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as ExpensiveAndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        final AndroidViewController controller =
            PlatformViewsService.initExpensiveAndroidView(
          id: params.id,
          viewType: CHANNEL_ID,
          layoutDirection: directionality,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () {
            params.onFocusChanged(true);
          },
        );
        controller
            .addOnPlatformViewCreatedListener(params.onPlatformViewCreated);
        controller.addOnPlatformViewCreatedListener(_onPlatformViewCreated);
        controller.create();
        return controller;
      },
    );
  }

  Widget _buildVirtualDisplay(
      BuildContext context, Map<String, dynamic> creationParams) {
    print("Situm> Using virtual display");
    return AndroidView(
      viewType: CHANNEL_ID,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: _onPlatformViewCreated,
    );
  }
}
