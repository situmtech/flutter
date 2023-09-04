part of wayfinding;

// Public definitions:

/// The [MapView] settings.
///
/// ```dart
/// MapView(
///   key: const Key("situm_map"),
///   configuration: MapViewConfiguration(
///   // Your Situm credentials.
///     situmUser: "YOUR-SITUM-USER",
///     situmApiKey: "YOUR-SITUM-API-KEY",
///   // Set your building identifier:
///     buildingIdentifier: "YOUR-SITUM-BUILDING-IDENTIFIER",
///   // Alternatively, you can set an identifier that allows you to remotely configure all map settings.
///   // For now, you need to contact Situm to obtain yours.
///   // remoteIdentifier: null;
///     viewerDomain: "https://map-viewer.situm.com",
///     apiDomain: "dashboard.situm.com",
///     directionality: TextDirection.ltr,
///     enableDebugging: false,
///   ),
/// ),
/// ```
class MapViewConfiguration {
  /// Your Situm user.
  final String? situmUser;

  /// Your Situm API key.
  final String situmApiKey;

  /// The building that will be loaded on the map. Alternatively you can pass a
  /// remoteIdentifier (that will be prioritized).
  final String? buildingIdentifier;

  /// A String identifier that allows you to remotely configure all map settings.
  /// Alternatively you can pass a buildingIdentifier, but remoteIdentifier
  /// will be prioritized.
  final String? remoteIdentifier;

  /// A String parameter that allows you to specify
  /// which domain will be displayed inside our webview.
  ///
  /// Default is https://map-viewer.situm.com.
  ///
  ///[viewerDomain] should include the protocol and the domain (e.g. https://map-viewer.situm.com).
  final String viewerDomain;

  /// A String parameter that allows you to choose the API you will be retrieving
  /// our cartography from. Default is [dashboard.situm.com](https://dashboard.situm.com).
  ///
  /// [apiDomain] should include only the domain (e.g., "dashboard.situm.com")
  /// * **Note**: When using [SitumSdk.setDashboardURL], make sure you introduce the same domain.
  final String apiDomain;

  /// Sets the directionality of the texts that will be displayed inside [MapView].
  /// Default is [TextDirection.ltr].
  final TextDirection directionality;

  /// Whether to enable the platform's webview content debugging tools.
  /// See [AndroidWebViewController.enableDebugging].
  ///
  /// Default is false.
  final bool enableDebugging;

  /// The [MapView] settings. Required fields are your Situm user and API key,
  /// but also a buildingIdentifier or remoteIdentifier.
  MapViewConfiguration({
    this.situmUser,
    required this.situmApiKey,
    this.buildingIdentifier,
    this.remoteIdentifier,
    this.viewerDomain = "https://map-viewer.situm.com",
    this.apiDomain = "dashboard.situm.com",
    this.directionality = TextDirection.ltr,
    this.enableDebugging = false,
  });

  String get _internalViewerDomain {
    if (viewerDomain.endsWith("/")) {
      return viewerDomain.substring(0, viewerDomain.length - 1);
    }
    return viewerDomain;
  }

  String get _internalApiDomain {
    String finalApiDomain = apiDomain.replaceFirst(RegExp(r'https://'), '');

    if (finalApiDomain.endsWith('/')) {
      finalApiDomain = finalApiDomain.substring(0, finalApiDomain.length - 1);
    }

    return finalApiDomain;
  }

  String _getViewerURL() {
    var base = _internalViewerDomain;
    var query =
        "apikey=$situmApiKey&domain=$_internalApiDomain&mode=embed&global=true";
    if (remoteIdentifier != null) {
      return "$base/id/$remoteIdentifier?$query";
    } else if (buildingIdentifier != null) {
      query = "$query&buildingid=$buildingIdentifier";
      return "$base/?$query";
    }
    throw ArgumentError(
        'Missing configuration: remoteIdentifier or buildingIdentifier must be provided.');
  }
}

class DirectionsMessage {
  static const CATEGORY_POI = "POI";
  static const CATEGORY_LOCATION = "LOCATION";
  static const EMPTY_ID = "-1";

  // Identifier used by the map-viewer to
  String? identifier;
  final String buildingIdentifier;
  final String originCategory;
  final String originIdentifier;
  final String destinationCategory;
  final String destinationIdentifier;

  DirectionsMessage({
    required this.buildingIdentifier,
    required this.originCategory,
    this.originIdentifier = EMPTY_ID,
    required this.destinationCategory,
    this.destinationIdentifier = EMPTY_ID,
    this.identifier
  });
}

class OnPoiSelectedResult {
  final Poi poi;

  const OnPoiSelectedResult({
    required this.poi,
  });
}

class OnPoiDeselectedResult {
  final Poi poi;

  const OnPoiDeselectedResult({
    required this.poi,
  });
}

// Result callbacks.

// WYF load callback.
typedef MapViewCallback = void Function(MapViewController controller);
// POI selection callback.
typedef OnPoiSelectedCallback = void Function(
    OnPoiSelectedResult poiSelectedResult);
// POI deselection callback.
typedef OnPoiDeselectedCallback = void Function(
    OnPoiDeselectedResult poiDeselectedResult);
// Directions and navigation interceptor.
typedef OnDirectionsRequestInterceptor = void Function(
    DirectionsRequest directionsRequest);
typedef OnNavigationRequestInterceptor = void Function(
    NavigationRequest navigationRequest);
