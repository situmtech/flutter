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

  /// Your configuration identifier. Alternatively you can pass a
  /// buildingIdentifier, but configurationIdentifier will be prioritized.
  final String? configurationIdentifier;
  final String mapViewUrl;

  String get _internalMapViewUrl {
    if (mapViewUrl.endsWith("/")) {
      return mapViewUrl.substring(0, mapViewUrl.length - 1);
    }
    return mapViewUrl;
  }

  final TextDirection directionality;
  final bool enableDebugging;

  /// The [MapView] settings. Required fields are your Situm user and API key,
  /// but also a buildingIdentifier or configurationIdentifier.
  MapViewConfiguration({
    required this.situmUser,
    required this.situmApiKey,
    this.buildingIdentifier,
    this.configurationIdentifier,
    this.mapViewUrl = "https://map-viewer.situm.com",
    this.directionality = TextDirection.ltr,
    this.enableDebugging = false,
  });
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
