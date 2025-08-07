part of '../wayfinding.dart';

/// MapView is the main component and entry point for Situm Flutter Wayfinding.
/// This widget will load your Situm building on a map, based on the given
/// [MapViewConfiguration].
class MapView extends StatefulWidget {
  final MapViewConfiguration configuration;
  final MapViewCallback onLoad;
  final OnMapViewErrorCallback? onError;
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
    this.onError,
    this.didUpdateCallback,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  static MapViewController? wyfController;
  late MapViewConfiguration mapViewConfiguration;

  bool _shouldDisplayBlankScreen =
      defaultTargetPlatform == TargetPlatform.android ? true : false;

  @override
  void initState() {
    super.initState();
    mapViewConfiguration = widget.configuration;

    // Avoid re-initializations of the underlying WebView (PlatformView) if
    // persistUnderlyingWidget is set to true.
    // if (webViewWidget != null &&
    // TODO: mapViewConfiguration.persistUnderlyingWidget == true) {
    // TODO: _shouldDisplayBlankScreen = false;??? Xa se encarga nativo???
    // return;
    // }
    wyfController ??= MapViewController(
      situmApiKey: mapViewConfiguration.situmApiKey,
    );
    wyfController!._widgetLoadCallback = widget.onLoad;
    wyfController!._onMapViewErrorCallBack = widget.onError;

    _loadWithConfig(mapViewConfiguration);
  }

  void _loadWithConfig(MapViewConfiguration configuration) async {
    var sdk = SitumSdk();
    // TODO: sobra esto todo non?
    final String deviceId = await sdk.getDeviceId();
    final String mapViewUrl = mapViewConfiguration._getViewerURL(deviceId);
    // // Load the composed URL in the WebView.
    // webViewController
    //     ?.loadRequest(LoadRequestParams(uri: Uri.parse(mapViewUrl)));
  }

  // TODO: sobraría.
  void _displayBlankScreen(bool value) {
    if (mounted) {
      setState(() {
        _shouldDisplayBlankScreen =
            defaultTargetPlatform == TargetPlatform.android ? value : false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return buildWebViewHybrid(context);
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return buildIOS(context);
    }
    throw UnsupportedError('Unsupported platform view');
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
