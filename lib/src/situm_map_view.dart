part of wayfinding;

/// MapView is the main component and entry point for Situm Flutter Wayfinding.
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

  String _createUri() {
    var base = mapViewConfiguration.mapViewUrl;
    var query =
        "email=${mapViewConfiguration.situmUser}&apikey=${mapViewConfiguration.situmApiKey}&mode=embed";
    if (mapViewConfiguration.configurationIdentifier != null) {
      return "$base/id/${mapViewConfiguration.configurationIdentifier}?$query";
    } else if (mapViewConfiguration.buildingIdentifier != null) {
      query = "$query&buildingid=${mapViewConfiguration.buildingIdentifier}";
      return "$base/?$query";
    }
    throw ArgumentError(
        'Missing configuration: configurationIdentifier or buildingIdentifier must be provided.');
  }

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
            if (request.url.startsWith(mapViewConfiguration.mapViewUrl)) {
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
    // Create the final MapView URI.
    final String uri = _createUri();
    // Load the composed URI in the WebView.
    webViewController.loadRequest(Uri.parse(uri));
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
