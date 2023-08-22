part of wayfinding;

/// MapView is the main component and entry point for Situm Flutter Wayfinding.
/// This widget will load your Situm building on a map, based on the given
/// [MapViewConfiguration].
class MapView extends StatefulWidget {
  final MapViewConfiguration configuration;
  final MapViewCallback onLoad;
  final MapViewCallback? didUpdateCallback;

  /// MapView is the main component and entry point for Situm Flutter Wayfinding.
  /// This widget will load your Situm building on a map, based on the given
  /// [MapViewConfiguration].
  const MapView({
    required Key key,
    required this.configuration,
    required this.onLoad,
    this.didUpdateCallback,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  MapViewController? wyfController;
  late final PlatformWebViewController webViewController;
  late final PlatformWebViewWidget webViewWidget;
  late MapViewConfiguration mapViewConfiguration;

  @override
  void initState() {
    super.initState();

    PlatformWebViewControllerCreationParams params =
        defaultTargetPlatform == TargetPlatform.android
            ? AndroidWebViewControllerCreationParams()
            : WebKitWebViewControllerCreationParams(
                limitsNavigationsToAppBoundDomains: true,
              );

    PlatformWebViewController controller = PlatformWebViewController(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setPlatformNavigationDelegate(
        PlatformNavigationDelegate(
          const PlatformNavigationDelegateCreationParams(),
        )
          ..setOnProgress((int progress) {
            // Do nothing.
          })
          ..setOnPageStarted((String url) {
            // Do nothing.
          })
          ..setOnPageFinished((String url) {
            _onMapReady(url);
          })
          ..setOnWebResourceError((WebResourceError error) {
            debugPrint('''
              Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
            ''');
          })
          ..setOnNavigationRequest((dynamic request) {
            if (request.url.startsWith(mapViewConfiguration.viewerDomain)) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          })
          ..setOnUrlChange((UrlChange change) {
            debugPrint('url change to ${change.url}');
          }),
      )
      ..addJavaScriptChannel(JavaScriptChannelParams(
        name: WV_CHANNEL,
        onMessageReceived: (JavaScriptMessage message) {
          Map<String, dynamic> map = jsonDecode(message.message);
          wyfController?.onMapViewerMessage(map["type"], map["payload"] ?? {});
        },
      ))
      ..setOnPlatformPermissionRequest(
        (PlatformWebViewPermissionRequest request) {
          debugPrint(
            'requesting permissions for ${request.types.map((WebViewPermissionResourceType type) => type.name)}',
          );
          request.grant();
        },
      );
    webViewController = controller;
    PlatformWebViewWidgetCreationParams webViewParams =
        defaultTargetPlatform == TargetPlatform.android
            ? AndroidWebViewWidgetCreationParams(
                controller: webViewController,
                displayWithHybridComposition: true,
                layoutDirection: widget.configuration.directionality,
              )
            : PlatformWebViewWidgetCreationParams(
                controller: webViewController,
                layoutDirection: widget.configuration.directionality,
              );
    webViewWidget = PlatformWebViewWidget(webViewParams);
    _loadWithConfig(widget.configuration);
  }

  void _loadWithConfig(MapViewConfiguration configuration) {
    // Keep configuration.
    mapViewConfiguration = configuration;
    if (webViewController is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(configuration.enableDebugging);
    }
    final String mapViewUrl = mapViewConfiguration._getViewerURL();
    // Load the composed URL in the WebView.
    webViewController
        .loadRequest(LoadRequestParams(uri: Uri.parse(mapViewUrl)));
  }

  void _onMapReady(String url) {
    if (wyfController == null) {
      wyfController = MapViewController(
        situmUser: mapViewConfiguration.situmUser,
        situmApiKey: mapViewConfiguration.situmApiKey,
        sdkDomain: mapViewConfiguration.sdkDomain,
        widgetUpdater: _loadWithConfig,
        webViewController: webViewController,
      );
      widget.onLoad(wyfController!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // In the example of the plugin (https://pub.dev/packages/webview_flutter_android/example),
    // PlatformWebViewWidget is instantiated in each call to the 'build' method.
    // However, we avoid doing so because it is causing a native view to be
    // generated with each 'build' call, resulting in flashes and even crashes.
    // To solve this, we store a reference to the PlatformWebViewWidget and
    // invoke its 'build' method.
    return webViewWidget.build(context);
  }

  @override
  void didUpdateWidget(covariant MapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (wyfController != null) {
      widget.didUpdateCallback?.call(wyfController!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    // wyfController?.onWidgetDisposed();
  }
}
