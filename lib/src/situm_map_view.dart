part of situm_flutter_wayfinding;

// The Widget!
class SitumMapView extends StatefulWidget {
  final String situmUser;
  final String situmApiKey;
  final String buildingIdentifier;
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
    this.didUpdateCallback,
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
  SitumFlutterWYF? wyfController;
  late final WebViewController webViewController;

  @override
  void initState() {
    super.initState();

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(
            const PlatformWebViewControllerCreationParams());

    //const mapViewBaseUrl = "http://192.168.1.132:5173";
    const mapViewBaseUrl = "https://map-viewer.situm.com";

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
            wyfController = SitumFlutterWYF(
              webViewController: webViewController,
            );
            wyfController!.situmMapLoaded = true;
            widget.loadCallback(wyfController!);
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
        WV_CHANNEL,
        onMessageReceived: (JavaScriptMessage message) {
          debugPrint(
              "Channel situm.location received message: ${message.message}");
        },
      )
      ..loadRequest(Uri.parse(
          "$mapViewBaseUrl/?email=${widget.situmUser}&apikey=${widget.situmApiKey}&buildingid=${widget.buildingIdentifier}&mode=embed"));

    webViewController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: webViewController);
  }

  @override
  void didUpdateWidget(covariant SitumMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (wyfController?.situmMapLoaded == true) {
      widget.didUpdateCallback?.call(wyfController!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    wyfController?.onWidgetDisposed();
  }
}
