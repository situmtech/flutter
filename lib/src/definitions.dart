part of wayfinding;

// Public definitions:

/// The [MapView] settings.
class MapViewConfiguration {
  /// Your Situm user.
  final String situmUser;

  /// Your Situm API key.
  final String situmApiKey;

  /// The building that will be loaded on the map. Alternatively you can pass a
  /// configurationIdentifier (that will be prioritized).
  final String? buildingIdentifier;

  /// A String identifier that allows you to remotely configure all map settings.
  /// Alternatively you can pass a buildingIdentifier, but configurationIdentifier
  /// will be prioritized.
  final String? remoteIdentifier;
  final String viewerDomain;
  final String apiDomain;
  final TextDirection directionality;
  final bool enableDebugging;

  /// The [MapView] settings. Required fields are your Situm user and API key,
  /// but also a buildingIdentifier or configurationIdentifier.
  MapViewConfiguration({
    required this.situmUser,
    required this.situmApiKey,
    this.buildingIdentifier,
    this.remoteIdentifier,
    this.viewerDomain = "https://map-viewer.situm.com",
    this.apiDomain = "https://dashboard.situm.com",
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

    if (finalApiDomain.endsWith('/')){
      finalApiDomain = finalApiDomain.substring(0, finalApiDomain.length - 1);
    }

    return finalApiDomain;
  }

  String _getViewerURL() {
    var base = _internalViewerDomain;
    var query = "email=$situmUser&apikey=$situmApiKey&domain=$_internalApiDomain&mode=embed";
    if (remoteIdentifier != null) {
      return "$base/id/$remoteIdentifier?$query";
    } else if (buildingIdentifier != null) {
      query = "$query&buildingid=$buildingIdentifier";
      return "$base/?$query";
    }
    throw ArgumentError(
        'Missing configuration: configurationIdentifier or buildingIdentifier must be provided.');
  }
}

class DirectionsMessage {
  static const CATEGORY_POI = "POI";
  static const CATEGORY_LOCATION = "LOCATION";
  static const EMPTY_ID = "-1";

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
  });
}

class OnPoiSelectedResult {
  final Poi poi;

  const OnPoiSelectedResult({
    required this.poi,
  });
}

class OnPoiDeselectedResult {
  final String buildingId;

  const OnPoiDeselectedResult({
    required this.buildingId,
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
