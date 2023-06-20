part of situm_flutter_wayfinding;

// The Widget!
class SitumMapView extends StatefulWidget {
  final String situmUser;
  final String situmApiKey;
  final String buildingIdentifier;
  final String situmMapUrl;
  final TextDirection directionality;
  final String searchViewPlaceholder;
  final bool useDashboardTheme;
  final bool showPoiNames;
  final bool hasSearchView;
  final bool enablePoiClustering;
  final bool enableDebugging;
  final bool showNavigationIndications;

  final SitumMapViewCallback loadCallback;
  final SitumMapViewCallback? didUpdateCallback;

  const SitumMapView({
    required Key key,
    required this.situmUser,
    required this.situmApiKey,
    required this.buildingIdentifier,
    required this.loadCallback,
    this.situmMapUrl = "https://map-viewer.situm.com",
    this.didUpdateCallback,
    this.directionality = TextDirection.ltr,
    this.searchViewPlaceholder = "Situm Flutter Wayfinding",
    this.useDashboardTheme = true,
    this.hasSearchView = true,
    this.showPoiNames = true,
    this.enablePoiClustering = true,
    this.enableDebugging = false,
    this.showNavigationIndications = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SitumMapViewState();
}

class _SitumMapViewState extends State<SitumMapView> {
  SitumFlutterWYF? wyfController;
  late final WebViewController webViewController;

  String _createUri() {
    String uri =
        "${widget.situmMapUrl}/?email=${widget.situmUser}&apikey=${widget.situmApiKey}&buildingid=${widget.buildingIdentifier}&mode=embed";
    List<String> elementsToHide = [];
    if (!widget.hasSearchView) {
      elementsToHide.add("ec");
    }
    if (!widget.showPoiNames) {
      elementsToHide.add("pn");
    }
    if (!widget.enablePoiClustering) {
      elementsToHide.add("pcl");
    }
    if (widget.showNavigationIndications) {
      elementsToHide.add("ni");
    }
    if (elementsToHide.isNotEmpty) {
      uri = "$uri&hide=${elementsToHide.join(',')}";
    }
    return uri;
  }

  @override
  void initState() {
    super.initState();

    final WebViewController controller;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      controller = WebViewController.fromPlatformCreationParams(
          WebKitWebViewControllerCreationParams(
              limitsNavigationsToAppBoundDomains: true));
    } else {
      controller = WebViewController.fromPlatformCreationParams(
          const PlatformWebViewControllerCreationParams());
    }

    final String uri = _createUri();

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
              wyfController = SitumFlutterWYF(
                widget: widget,
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
            if (request.url.startsWith(widget.situmMapUrl)) {
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
      )
      ..loadRequest(Uri.parse(uri));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(widget.enableDebugging);
    }
    webViewController = controller;
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
      layoutDirection: widget.directionality,
    );
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
