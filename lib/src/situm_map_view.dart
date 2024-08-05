part of wayfinding;

/// MapView is the main component and entry point for Situm Flutter Wayfinding.
/// This widget will load your Situm building on a map, based on the given
/// [MapViewConfiguration].
class MapView extends StatefulWidget {
  final MapViewConfiguration configuration;
  final MapViewCallback onLoad;
  final MapViewCallback? didUpdateCallback;
  static const String _retryScreenURL =
      "packages/situm_flutter/html/retry_screen.html";

  /// On Webkit rendering engine, when there is some iframe whith the content
  /// embedded in a srcdoc tag, the webViewController ask for a navigation request.
  /// We need to allow this url in order to show the content of such iframes.
  static const String _iframeHTMLURL = "about:srcdoc";

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

  bool _shouldDisplayBlankScreen = true;

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
            _displayBlankScreen(false);
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
              webViewController!.loadFlutterAsset(MapView._retryScreenURL);
            }
          })
          ..setOnNavigationRequest((dynamic request) {
            if (request.url.startsWith(mapViewConfiguration.viewerDomain) ||
                request.url.endsWith(MapView._retryScreenURL) ||
                request.url == MapView._iframeHTMLURL) {
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
          // Retry attempt might fail,
          // so cover the android native error screen
          _displayBlankScreen(true);
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

    if (webViewController is WebKitWebViewController) {
      (webViewController as WebKitWebViewController)
          .setInspectable(configuration.enableDebugging);
    }
    var sdk = SitumSdk();
    final String deviceId = await sdk.getDeviceId();
    final String mapViewUrl = mapViewConfiguration._getViewerURL(deviceId);
    // Load the composed URL in the WebView.
    webViewController
        ?.loadRequest(LoadRequestParams(uri: Uri.parse(mapViewUrl)));
  }

  // Display this screen only when webview
  // is going to display the android native error screen.
  void _displayBlankScreen(bool value) {
    setState(() {
      _shouldDisplayBlankScreen =
          defaultTargetPlatform == TargetPlatform.android ? value : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _shouldDisplayBlankScreen
        ? Container(color: Colors.white)
        // In the example of the plugin (https://pub.dev/packages/webview_flutter_android/example),
        // PlatformWebViewWidget is instantiated in each call to the 'build' method.
        // However, we avoid doing so because it is causing a native view to be
        // generated with each 'build' call, resulting in flashes and even crashes.
        // To solve this, we store a reference to the PlatformWebViewWidget and
        // invoke its 'build' method.
        : webViewWidget!.build(context);
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
