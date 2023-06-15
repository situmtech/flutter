part of situm_flutter_wayfinding;

// The Widget!
class MapView extends StatefulWidget {
  final MapViewConfiguration mapViewConfiguration;
  final MapViewCallback loadCallback;
  final MapViewCallback? didUpdateCallback;

  const MapView({
    required Key key,
    required this.mapViewConfiguration,
    required this.loadCallback,
    this.didUpdateCallback,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  MapViewController? wyfController;
  late final WebViewController webViewController;

  late MapViewConfiguration mapViewConfiguration;

  @override
  void initState() {
    super.initState();
    mapViewConfiguration = widget.mapViewConfiguration;

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(
            const PlatformWebViewControllerCreationParams());

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Do nothing.
          },
          onPageStarted: (String url) {
            // Do nothing.
          },
          onPageFinished: (String url) {
            if (wyfController == null) {
              debugPrint('Page finished loading, created wyfController: $url');
              wyfController = MapViewController(
                widgetUpdater: _loadWithConfig,
                webViewController: webViewController,
              );
              wyfController!.situmMapLoaded = true;
              widget.loadCallback(wyfController!);
            }
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
            if (request.url.startsWith(mapViewConfiguration.situmMapUrl)) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..addJavaScriptChannel(
        WV_CHANNEL,
        onMessageReceived: (JavaScriptMessage message) {
          Map<String, dynamic> map = jsonDecode(message.message);
          wyfController?.onMapViewerMessage(map["type"], map["payload"] ?? {});
        },
      );

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(
          mapViewConfiguration.enableDebugging);
    }
    webViewController = controller;
    _loadWithConfig(mapViewConfiguration);
  }

  String _createUri() {
    if (mapViewConfiguration.configurationIdentifier != null) {
      return "${mapViewConfiguration.situmMapUrl}/id/${mapViewConfiguration.configurationIdentifier}?mode=embed";
    }
    if (mapViewConfiguration.buildingIdentifier == null ||
        mapViewConfiguration.situmUser == null ||
        mapViewConfiguration.situmApiKey == null) {
      throw ArgumentError(
          'Missing configuration: (configurationIdentifier) or (buildingIdentifier, situmUser, situmApiKey) must be provided.');
    }
    return "${mapViewConfiguration.situmMapUrl}/?email=${mapViewConfiguration.situmUser}&apikey=${mapViewConfiguration.situmApiKey}&buildingid=${mapViewConfiguration.buildingIdentifier}&mode=embed";
  }

  void _loadWithConfig(MapViewConfiguration configuration) {
    mapViewConfiguration = configuration;
    final String uri = _createUri();
    webViewController.loadRequest(Uri.parse(uri));
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return WebViewWidget.fromPlatformCreationParams(
        params: AndroidWebViewWidgetCreationParams(
          controller: webViewController.platform,
          displayWithHybridComposition: true,
        ),
      );
    }
    return WebViewWidget(
      controller: webViewController,
      layoutDirection: mapViewConfiguration.directionality,
    );
  }

  @override
  void didUpdateWidget(covariant MapView oldWidget) {
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
