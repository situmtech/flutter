part of situm_flutter_wayfinding;

// The Widget!
class SitumMapView extends StatefulWidget {
  final String? situmUser;
  final String? situmApiKey;
  final String? buildingIdentifier;
  final String? configurationIdentifier;
  final String situmMapUrl;
  final TextDirection directionality;
  final bool enableDebugging;

  final SitumMapViewCallback loadCallback;
  final SitumMapViewCallback? didUpdateCallback;

  const SitumMapView({
    required Key key,
    required this.loadCallback,
    this.situmUser,
    this.situmApiKey,
    this.buildingIdentifier,
    this.situmMapUrl = "https://map-viewer.situm.com",
    this.configurationIdentifier,
    this.didUpdateCallback,
    this.directionality = TextDirection.ltr,
    this.enableDebugging = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SitumMapViewState();
}

class _SitumMapViewState extends State<SitumMapView> {
  SitumFlutterWYF? wyfController;
  late final WebViewController webViewController;

  String _createUri() {
    if (widget.configurationIdentifier != null) {
      return "${widget.situmMapUrl}/id/${widget.configurationIdentifier}?mode=embed";
    }
    if (widget.buildingIdentifier == null ||
        widget.situmUser == null ||
        widget.situmApiKey == null) {
      throw ArgumentError(
          'Missing configuration: (situmMapId) or (buildingIdentifier, situmUser, situmApiKey) must be provided.');
    }
    return "${widget.situmMapUrl}/?email=${widget.situmUser}&apikey=${widget.situmApiKey}&buildingid=${widget.buildingIdentifier}&mode=embed";
  }

  @override
  void initState() {
    super.initState();

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(
            const PlatformWebViewControllerCreationParams());

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
