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
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(
            const PlatformWebViewControllerCreationParams());

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'map-viewer-channel',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse('https://map-viewer.situm.com/'));

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
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
}
