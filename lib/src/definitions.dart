part of situm_flutter_wayfinding;

// Public definitions:

class DirectionsMessage {
  static const CATEGORY_POI = "POI";
  static const CATEGORY_LOCATION = "LOCATION";
  static const EMPTY_ID = "-1";

  final String buildingId;
  final String originCategory;
  final String originId;
  final String destinationCategory;
  final String destinationId;
  final DirectionsRequest directionsRequest;

  DirectionsMessage({
    required this.buildingId,
    required this.originCategory,
    this.originId = EMPTY_ID,
    required this.destinationCategory,
    this.destinationId = EMPTY_ID,
    required this.directionsRequest,
  });
}

class OnPoiSelectedResult {
  final String buildingId;
  final String buildingName;
  final String floorId;
  final String floorName;
  final String poiId;
  final String poiName;
  final String poiInfoHtml;

  const OnPoiSelectedResult({
    required this.buildingId,
    required this.buildingName,
    required this.floorId,
    required this.floorName,
    required this.poiId,
    required this.poiName,
    required this.poiInfoHtml,
  });
}

class OnPoiDeselectedResult {
  final String buildingId;
  final String buildingName;

  const OnPoiDeselectedResult({
    required this.buildingId,
    required this.buildingName,
  });
}

class NavigationSettings {
  final double outsideRouteThreshold;
  final double distanceToGoalThreshold;

  const NavigationSettings({
    this.outsideRouteThreshold = -1,
    this.distanceToGoalThreshold = -1,
  });

  Map<String, dynamic> toMap() {
    return {
      "outsideRouteThreshold": outsideRouteThreshold,
      "distanceToGoalThreshold": distanceToGoalThreshold
    };
  }
}

class NavigationResult {
  final String destinationId;
  final SitumRoute? route;

  const NavigationResult({
    required this.destinationId,
    this.route,
  });
}

// Result callbacks.

// WYF load callback.
typedef SitumMapViewCallback = void Function(SitumFlutterWYF controller);
// POI selection callback.
typedef OnPoiSelectedCallback = void Function(
    OnPoiSelectedResult poiSelectedResult);
// POI deselection callback.
typedef OnPoiDeselectedCallback = void Function(
    OnPoiDeselectedResult poiDeselectedResult);
// DirectionsRequest interceptor.
typedef OnDirectionsRequestInterceptor = void Function(
    DirectionsRequest directionsRequest);
// Navigation callbacks
typedef OnNavigationRequestedCallback = void Function(String destinationId);
typedef OnNavigationErrorCallback = void Function(
    String destinationId, String errorMessage);
typedef OnNavigationFinishedCallback = void Function(String destinationId);
typedef OnNavigationStartedCallback = void Function(
    NavigationResult navigation);
