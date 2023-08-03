part of wayfinding;

/// MapView is the main component and entry point for Situm Flutter Wayfinding.
/// This widget will load your Situm building on a map, based on the given
/// [MapViewConfiguration].
class MapView extends StatefulWidget {
  final MapViewConfiguration configuration;
  final MapViewCallback onLoad;
  final MapViewCallback? didUpdateCallback;

  String? navigationDestination;

  /// MapView is the main component and entry point for Situm Flutter Wayfinding.
  /// This widget will load your Situm building on a map, based on the given
  /// [MapViewConfiguration].
  MapView({
    required Key key,
    required this.configuration,
    required this.onLoad,
    this.didUpdateCallback,
    this.navigationDestination,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  MapViewController? wyfController;
  late final PlatformWebViewController webViewController;
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
            if (request.url.startsWith(mapViewConfiguration.baseUrl)) {
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
    _loadWithConfig(widget.configuration);
  }

  void _loadWithConfig(MapViewConfiguration configuration) {
    // Keep configuration.
    mapViewConfiguration = configuration;
    if (webViewController is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(configuration.enableDebugging);
    }
    final String mapViewUrl = mapViewConfiguration._getMapViewerUrl();
    // Load the composed URL in the WebView.
    webViewController
        .loadRequest(LoadRequestParams(uri: Uri.parse(mapViewUrl)));
  }

  void _onMapReady(String url) {
    if (wyfController == null) {
      wyfController = MapViewController(
        situmUser: mapViewConfiguration.situmUser,
        situmApiKey: mapViewConfiguration.situmApiKey,
        widgetUpdater: _loadWithConfig,
        webViewController: webViewController,
      );
      widget.onLoad(wyfController!);
    }
  }

  @override
  Widget build(BuildContext context) {
    PlatformWebViewWidgetCreationParams params =
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

    return PlatformWebViewWidget(params).build(context);
  }

  @override
  void didUpdateWidget(covariant MapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (wyfController != null) {
      widget.didUpdateCallback?.call(wyfController!);
    }
    if (widget.navigationDestination != null &&
        oldWidget.navigationDestination != widget.navigationDestination) {
      wyfController?.navigateToPoi(
          widget.navigationDestination!, "BUILDING_ID");
      // TODO: xestionar cando nullear navigationDestination, por si navegas
      // dúas veces seguidas ao mismo poi.
      // TODO: seguramente navigationDestination non sexa só un string, debería
      // ser un obxecto que tamén inclua o building ID.
    }
  }

  // método_reactivo_reacciona_cando_cambia_myNavigationDestination {
  //   wyfController.navigateToPoi(id, buildingId)
  // }

  @override
  void dispose() {
    super.dispose();
    // wyfController?.onWidgetDisposed();
  }
}
