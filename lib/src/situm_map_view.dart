part of wayfinding;

/// MapView is the main component and entry point for Situm Flutter Wayfinding.
/// This widget will load your Situm building on a map, based on the given
/// [MapViewConfiguration].
class MapView extends StatefulWidget {
  final MapViewConfiguration mapViewConfiguration;
  final MapViewCallback loadCallback;
  final MapViewCallback? didUpdateCallback;

  /// MapView is the main component and entry point for Situm Flutter Wayfinding.
  /// This widget will load your Situm building on a map, based on the given
  /// [MapViewConfiguration].
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
            _onMapReady(url);
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
          onNavigationRequest: (dynamic request) {
            if (request.url.startsWith(mapViewConfiguration.baseUrl)) {
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

    webViewController = controller;
    _loadWithConfig(widget.mapViewConfiguration);
  }

  void _loadWithConfig(MapViewConfiguration configuration) {
    // Keep configuration.
    mapViewConfiguration = configuration;
    if (webViewController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(configuration.enableDebugging);
    }
    final String mapViewUrl = mapViewConfiguration._getMapViewerUrl();
    // Load the composed URL in the WebView.
    webViewController.loadRequest(Uri.parse(mapViewUrl));
  }

  void _onMapReady(String url) {
    if (wyfController == null) {
      debugPrint('Page finished loading, created wyfController: $url');
      wyfController = MapViewController(
        situmUser: mapViewConfiguration.situmUser,
        situmApiKey: mapViewConfiguration.situmApiKey,
        widgetUpdater: _loadWithConfig,
        webViewController: webViewController,
      );
      wyfController!.mapViewLoaded = true;
      widget.loadCallback(wyfController!);
    }
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
    if (wyfController?.mapViewLoaded == true) {
      widget.didUpdateCallback?.call(wyfController!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    wyfController?.onWidgetDisposed();
  }
}
