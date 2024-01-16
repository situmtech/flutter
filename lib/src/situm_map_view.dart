part of wayfinding;

/// MapView is the main component and entry point for Situm Flutter Wayfinding.
/// This widget will load your Situm building on a map, based on the given
/// [MapViewConfiguration].
class MapView extends StatefulWidget {
  final MapViewConfiguration configuration;
  final MapViewCallback onLoad;
  final MapViewCallback? didUpdateCallback;
  final String _retryScreenURL =
      "packages/situm_flutter/html/retry_screen.html";

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
  static MapViewController? wyfController;
  static PlatformWebViewController? webViewController;
  static PlatformWebViewWidget? webViewWidget;
  late MapViewConfiguration mapViewConfiguration;

  @override
  void initState() {
    super.initState();
    mapViewConfiguration = widget.configuration;

    // Avoid re-initializations of the underlying WebView (PlatformView) if
    // persistUnderlyingWidget is set to true.
    if (webViewWidget != null &&
        mapViewConfiguration.persistUnderlyingWidget == true) {
      return;
    }

    PlatformWebViewControllerCreationParams params =
        defaultTargetPlatform == TargetPlatform.android
            ? AndroidWebViewControllerCreationParams()
            : WebKitWebViewControllerCreationParams(
                limitsNavigationsToAppBoundDomains: true,
              );

    webViewController = PlatformWebViewController(params);
    webViewController!
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
            debugPrint("Situm> WYF> Page loaded.");
          })
          ..setOnWebResourceError((WebResourceError error) {
            debugPrint('''
              Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
                url: ${error.url}
            ''');
            bool shouldDisplayRetryScreen =
                error.isForMainFrame != null && error.isForMainFrame!;

            if (shouldDisplayRetryScreen &&
                ConnectionErrors.values.contains(error.errorCode)) {
              webViewController!.loadFlutterAsset(widget._retryScreenURL);
            }
          })
          ..setOnNavigationRequest((dynamic request) {
            if (request.url.startsWith(mapViewConfiguration.viewerDomain) ||
                request.url.endsWith(widget._retryScreenURL)) {
              return NavigationDecision.navigate;
            }
            wyfController?._onExternalLinkClicked(request.url);
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
      ..addJavaScriptChannel(JavaScriptChannelParams(
        name: OFFLINE_CHANNEL,
        onMessageReceived: (JavaScriptMessage message) {
          _loadWithConfig(widget.configuration);
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
    wyfController ??= MapViewController(
      situmApiKey: mapViewConfiguration.situmApiKey,
    );
    wyfController!._widgetUpdater = _loadWithConfig;
    wyfController!._widgetLoadCallback = widget.onLoad;
    wyfController!._webViewController = webViewController!;

    PlatformWebViewWidgetCreationParams webViewParams =
        defaultTargetPlatform == TargetPlatform.android
            ? AndroidWebViewWidgetCreationParams(
                controller: webViewController!,
                displayWithHybridComposition: true,
                layoutDirection: widget.configuration.directionality,
              )
            : PlatformWebViewWidgetCreationParams(
                controller: webViewController!,
                layoutDirection: widget.configuration.directionality,
              );
    webViewWidget = PlatformWebViewWidget(webViewParams);
    _loadWithConfig(mapViewConfiguration);
  }

  void _loadWithConfig(MapViewConfiguration configuration) async {
    if (webViewController is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(configuration.enableDebugging);
    }

    bool? isDeviceLowPeformant = await wyfController?.isLowPerformantDevice();
    if (isDeviceLowPeformant != null && isDeviceLowPeformant) {
      mapViewConfiguration.performanceMode = PerformanceMode.LOW;
    }

    final String mapViewUrl = mapViewConfiguration._getViewerURL();
    // Load the composed URL in the WebView.
    webViewController
        ?.loadRequest(LoadRequestParams(uri: Uri.parse(mapViewUrl)));
  }

  @override
  Widget build(BuildContext context) {
    // In the example of the plugin (https://pub.dev/packages/webview_flutter_android/example),
    // PlatformWebViewWidget is instantiated in each call to the 'build' method.
    // However, we avoid doing so because it is causing a native view to be
    // generated with each 'build' call, resulting in flashes and even crashes.
    // To solve this, we store a reference to the PlatformWebViewWidget and
    // invoke its 'build' method.
    return webViewWidget!.build(context);
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
