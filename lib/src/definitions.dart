part of situm_flutter_wayfinding;

// Public definitions:

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

  const NavigationSettings({
    this.outsideRouteThreshold = -1,
  });

  Map<String, dynamic> toMap() {
    return {"outsideRouteThreshold": outsideRouteThreshold};
  }
}

// Result callbacks.

// WYF load callback.
typedef SitumMapViewCallback = void Function(SitumFlutterWayfinding controller);
// POI selection callback.
typedef OnPoiSelectedCallback = void Function(
    OnPoiSelectedResult poiSelectedResult);
// POI deselection callback.
typedef OnPoiDeselectedCallback = void Function(
    OnPoiDeselectedResult poiDeselectedResult);
// Navigation callbacks
typedef OnNavigationRequestedCallback = void Function(String destinationId);
typedef OnNavigationErrorCallback = void Function(
    String destinationId, String errorMessage);
typedef OnNavigationFinishedCallback = void Function(String destinationId);
