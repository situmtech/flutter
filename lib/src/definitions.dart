part of wayfinding;

// Public definitions:

class MapViewConfiguration {
  final String situmUser;
  final String situmApiKey;
  final String? buildingIdentifier;
  final String? configurationIdentifier;
  final String mapViewUrl;
  final TextDirection directionality;
  final bool enableDebugging;

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
// DirectionsOptions interceptor.
typedef OnDirectionsOptionsInterceptor = void Function(
    DirectionsOptions directionsOptions);
typedef OnNavigationOptionsInterceptor = void Function(
    NavigationOptions navigationOptions);
