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

class DirectionsSettings {
  final bool? minimizeFloorChanges;

  const DirectionsSettings({
    this.minimizeFloorChanges,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if (minimizeFloorChanges != null) {
      map['minimizeFloorChanges'] = minimizeFloorChanges;
    }
    return map;
  }
}

class Route {
  final double distance;

  const Route({
    this.distance = -1,
  });
}

class NavigationResult {
  final String destinationId;
  final Route? route;

  const NavigationResult({
    required this.destinationId,
    this.route,
  });
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({
    required this.latitude,
    required this.longitude,
  });

  @override
  String toString() {
    return "$latitude, $longitude";
  }
}

class CustomPoi {
  final int id;
  final String name;
  final String description;
  final int buildingId;
  final int levelId;
  final Coordinates coordinates;

  const CustomPoi(
      {required this.id,
      required this.name,
      required this.description,
      required this.buildingId,
      required this.levelId,
      required this.coordinates});

  @override
  String toString() {
    return "[$id] $name: $description - MAP($coordinates)";
  }
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
// Navigation callbacks
typedef OnNavigationRequestedCallback = void Function(String destinationId);
typedef OnNavigationErrorCallback = void Function(
    String destinationId, String errorMessage);
typedef OnNavigationFinishedCallback = void Function(String destinationId);
typedef OnNavigationStartedCallback = void Function(
    NavigationResult navigation);
typedef OnCustomPoiCreatedCallback = void Function(CustomPoi customPoi);
typedef OnCustomPoiRemovedCallback = void Function(CustomPoi poiId);
typedef OnCustomPoiSelectedCallback = void Function(CustomPoi poiId);
typedef OnCustomPoiDeselectedCallback = void Function(CustomPoi poiId);
