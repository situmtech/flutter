part of sdk;

/// A data object that allows you to configure the positioning parameters.
class LocationRequest {
  final String buildingIdentifier;
  final bool useDeadReckoning;

  LocationRequest({
    this.buildingIdentifier = "-1",
    this.useDeadReckoning = false,
  });

  Map<String, dynamic> toMap() => {
        "buildingIdentifier": buildingIdentifier,
        "useDeadReckoning": useDeadReckoning,
      };
}

/// Available accessibility modes used in the [DirectionsRequest].
enum AccessibilityMode {
  /// The route should choose the best route, without taking into account if it is accessible or not.
  /// This option is the default so you don't have to do anything in order to use it.
  CHOOSE_SHORTEST,

  /// The route should always use accessible nodes.
  ONLY_ACCESSIBLE,

  /// The route should never use accessible floor changes (use this to force routes not to use lifts).
  ONLY_NOT_ACCESSIBLE_FLOOR_CHANGES,
}

/// Parameters to request a route.
class DirectionsRequest {
  final Point from;
  final Point to;
  Angle? bearingFrom;
  bool? minimizeFloorChanges;
  AccessibilityMode? accessibilityMode;

  // buildingId populated in the constructor body.
  late String buildingIdentifier;

  DirectionsRequest({
    required this.from,
    required this.to,
    this.bearingFrom,
    this.minimizeFloorChanges,
    this.accessibilityMode,
  }) {
    // This buildingId is useful on the native side.
    buildingIdentifier = from.buildingIdentifier;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "buildingIdentifier": buildingIdentifier,
      "from": from.toMap(),
      "to": to.toMap(),
    };
    if (minimizeFloorChanges != null) {
      map['minimizeFloorChanges'] = minimizeFloorChanges;
    }
    if (bearingFrom != null) {
      map['bearingFrom'] = bearingFrom?.toMap();
    }
    if (accessibilityMode != null) {
      map['accessibilityMode'] = accessibilityMode!.name;
    }
    return map;
  }
}

/// A data object that allows you to configure the navigation parameters.
class NavigationRequest {
  /// Distance threshold to consider reaching the goal (meters).
  int? distanceToGoalThreshold;

  /// Distance threshold to consider being outside the route (meters).
  int? outsideRouteThreshold;

  /// Maximum distance to ignore the first indication when navigating (meters).
  int? distanceToIgnoreFirstIndication;

  /// Distance threshold from when a floor change is considered reached (meters).
  int? distanceToFloorChangeThreshold;

  /// Distance threshold to change the indication (meters).
  int? distanceToChangeIndicationThreshold;

  /// Interval between indications (milliseconds).
  int? indicationsInterval;

  /// Time to wait until the first indication is returned (milliseconds).
  int? timeToFirstIndication;

  /// Step to round indications (meters).
  int? roundIndicationsStep;

  /// Time to ignore the locations received during navigation, when the next indication is a floor change,
  /// if the locations are on a wrong floor (not in origin or destination floors) (milliseconds).
  int? timeToIgnoreUnexpectedFloorChanges;

  /// Ignore low-quality locations.
  bool? ignoreLowQualityLocations;

  /// Configure the navigation parameters.
  NavigationRequest({
    this.distanceToGoalThreshold,
    this.outsideRouteThreshold,
    this.distanceToIgnoreFirstIndication,
    this.distanceToFloorChangeThreshold,
    this.distanceToChangeIndicationThreshold,
    this.indicationsInterval,
    this.timeToFirstIndication,
    this.roundIndicationsStep,
    this.timeToIgnoreUnexpectedFloorChanges,
    this.ignoreLowQualityLocations,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    if (distanceToGoalThreshold != null && distanceToGoalThreshold! > 0) {
      map['distanceToGoalThreshold'] = distanceToGoalThreshold!;
    }
    if (outsideRouteThreshold != null && outsideRouteThreshold! > 0) {
      map['outsideRouteThreshold'] = outsideRouteThreshold!;
    }
    if (distanceToIgnoreFirstIndication != null &&
        distanceToIgnoreFirstIndication! > 0) {
      map['distanceToIgnoreFirstIndication'] = distanceToIgnoreFirstIndication!;
    }
    if (distanceToFloorChangeThreshold != null &&
        distanceToFloorChangeThreshold! > 0) {
      // Android vs iOS inconsistency.
      map['distanceToChangeFloorThreshold'] = distanceToFloorChangeThreshold!;
      map['distanceToFloorChangeThreshold'] = distanceToFloorChangeThreshold!;
    }
    if (distanceToChangeIndicationThreshold != null &&
        distanceToChangeIndicationThreshold! > 0) {
      map['distanceToChangeIndicationThreshold'] =
          distanceToChangeIndicationThreshold!;
    }
    if (indicationsInterval != null && indicationsInterval! > 0) {
      map['indicationsInterval'] = indicationsInterval!;
    }
    if (timeToFirstIndication != null && timeToFirstIndication! > 0) {
      map['timeToFirstIndication'] = timeToFirstIndication!;
    }
    if (roundIndicationsStep != null && roundIndicationsStep! > 0) {
      map['roundIndicationsStep'] = roundIndicationsStep!;
    }
    if (timeToIgnoreUnexpectedFloorChanges != null &&
        timeToIgnoreUnexpectedFloorChanges! > 0) {
      map['timeToIgnoreUnexpectedFloorChanges'] =
          timeToIgnoreUnexpectedFloorChanges!;
    }
    if (ignoreLowQualityLocations != null) {
      map['ignoreLowQualityLocations'] = ignoreLowQualityLocations!;
    }
    return map;
  }
}

/// A location. It can be indoor or outdoor, check isIndoor and isOutdoor.
/// A valid indoor location has floorIdentifier and cartesianCoordinate.
class Location {
  final Coordinate coordinate;
  final CartesianCoordinate cartesianCoordinate;
  final String buildingIdentifier;
  final String floorIdentifier;
  final Bearing? bearing;
  final Bearing? cartesianBearing;
  final double accuracy;
  final bool isIndoor;
  final bool hasBearing;
  final bool hasCartesianBearing;
  final int timestamp;

  Location({
    required this.coordinate,
    required this.cartesianCoordinate,
    required this.buildingIdentifier,
    required this.floorIdentifier,
    required this.accuracy,
    required this.isIndoor,
    required this.hasBearing,
    required this.hasCartesianBearing,
    this.bearing,
    this.cartesianBearing,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'coordinate': {
          'latitude': coordinate.latitude,
          'longitude': coordinate.longitude,
        },
        'cartesianCoordinate': {
          'x': cartesianCoordinate.x,
          'y': cartesianCoordinate.y,
        },
        'buildingIdentifier': buildingIdentifier,
        'floorIdentifier': floorIdentifier,
        'bearing': bearing?.toMap(),
        'cartesianBearing': cartesianBearing?.toMap(),
        'accuracy': accuracy,
        'isIndoor': isIndoor,
        'hasBearing': hasBearing,
        'hasCartesianBearing': hasCartesianBearing,
        'timestamp': timestamp,
      };
}

class OnEnteredGeofenceResult {
  final List<Geofence> geofences;

  const OnEnteredGeofenceResult({
    required this.geofences,
  });
}

class OnExitedGeofenceResult {
  final List<Geofence> geofences;

  const OnExitedGeofenceResult({
    required this.geofences,
  });
}

class NamedResource {
  final String identifier;
  final String name;

  const NamedResource({
    required this.identifier,
    required this.name,
  });

  Map<String, dynamic> toMap() => {
        "identifier": identifier,
        "name": name,
      };

  @override
  String toString() {
    return const JsonEncoder.withIndent('\t').convert(toMap());
  }
}

/// An structure that contains geographical coordinate.
class Coordinate {
  final double latitude;
  final double longitude;

  Coordinate({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}

/// An structure that contains cartesian coordinate.
class CartesianCoordinate {
  final double x;
  final double y;

  CartesianCoordinate({
    required this.x,
    required this.y,
  });

  Map<String, dynamic> toMap() => {
        "x": x,
        "y": y,
      };
}

/// An structure that contains an angle in radians.
class Angle {
  final double radians;

  Angle({
    required this.radians,
  });

  Map<String, dynamic> toMap() => {
        "radians": radians,
      };
}

/// Represents a rectangle bounds in a greographic 2D space.
class Bounds {
  final Coordinate northEast;
  final Coordinate northWest;
  final Coordinate southEast;
  final Coordinate southWest;

  Bounds({
    required this.northEast,
    required this.northWest,
    required this.southEast,
    required this.southWest,
  });

  Map<String, dynamic> toMap() => {
        "northEast": northEast.toMap(),
        "northWest": northWest.toMap(),
        "southEast": southEast.toMap(),
        "southWest": southWest.toMap()
      };
}

/// Given a [Location], represents the bearing (in degrees) with respect to the
/// Earth North.
class Bearing {
  final double radiansMinusPiPi;
  final double radians;
  final double degreesClockwise;
  final double degrees;

  const Bearing({
    required this.radiansMinusPiPi,
    required this.radians,
    required this.degreesClockwise,
    required this.degrees,
  });

  Map<String, dynamic> toMap() => {
        "radiansMinusPiPi": radiansMinusPiPi,
        "radians": radians,
        "degreesClockwise": degreesClockwise,
        "degrees": degrees,
      };
}

/// A building and its dependencies: [Floor]s, [Poi]s and [Geofence]s.
class BuildingInfo extends NamedResource {
  final Building building;
  final List<Floor> floors;
  final List<Poi> indoorPois;
  final List<Poi> outdoorPois;
  final List<Geofence> geofences;
  final List<Event> events;

  BuildingInfo({
    required super.identifier,
    required super.name,
    required this.building,
    required this.floors,
    required this.indoorPois,
    required this.outdoorPois,
    required this.geofences,
    required this.events,
  });

  @override
  Map<String, dynamic> toMap() => {
        "identifier": identifier,
        "name": name,
        "building": building.toMap(),
        "floors": floors.map((i) => i.toMap()).toList(),
        "indoorPOIs": indoorPois.map((i) => i.toMap()).toList(),
        "outdoorPOIs": outdoorPois.map((i) => i.toMap()).toList(),
        "geofences": geofences.map((i) => i.toMap()).toList(),
        "events": events.map((i) => i.toMap()).toList()
      };
}

/// Floor of a [Building].
class Floor extends NamedResource {
  final String buildingIdentifier;
  final int floorIndex;
  final String mapUrl;
  final double scale;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> customFields;

  Floor(
      {required super.identifier,
      required super.name,
      required this.buildingIdentifier,
      required this.floorIndex,
      required this.mapUrl,
      required this.scale,
      required this.createdAt,
      required this.updatedAt,
      required this.customFields});

  @override
  Map<String, dynamic> toMap() => {
        "buildingId": buildingIdentifier,
        "floorIndex": floorIndex,
        "mapUrl": mapUrl,
        "scale": scale,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "customFields": customFields
      };
}

/// A building.
class Building extends NamedResource {
  final String address;
  final Bounds bounds;
  final Bounds boundsRotated;
  final Coordinate center;
  final double width;
  final double height;
  final String pictureThumbUrl;
  final String pictureUrl;
  final double rotation;
  final String userIdentifier;
  final Map<String, dynamic> customFields;
  final String createdAt;
  final String updatedAt;

  Building({
    required super.identifier,
    required super.name,
    required this.address,
    required this.bounds,
    required this.boundsRotated,
    required this.center,
    required this.width,
    required this.height,
    required this.pictureThumbUrl,
    required this.pictureUrl,
    required this.rotation,
    required this.userIdentifier,
    required this.customFields,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  Map<String, dynamic> toMap() => {
        "identifier": identifier,
        "name": name,
        "address": address,
        "bounds": bounds.toMap(),
        "boundsRotated": boundsRotated.toMap(),
        "center": center.toMap(),
        "width": width,
        "height": height,
        "pictureThumbUrl": pictureThumbUrl,
        "pictureUrl": pictureUrl,
        "rotation": rotation,
        "userIdentifier": userIdentifier,
        "customFields": customFields,
        "createdAt": createdAt,
        "updatedAt": updatedAt
      };
}

class CircleArea {
  final Point center;
  final double radius;

  CircleArea({
    required this.center,
    required this.radius,
  });

  Map<String, dynamic> toMap() => {
        "center": center.toMap(),
        "radius": radius,
      };
}

class Event extends NamedResource {
  final Map<String, dynamic> customFields;
  final CircleArea trigger;

  Event({
    required super.identifier,
    required super.name,
    required this.customFields,
    required this.trigger,
  });

  @override
  Map<String, dynamic> toMap() => {
        "identifier": identifier,
        "name": name,
        "trigger": trigger.toMap(),
        "customFields": customFields,
      };
}

/// Represents a geographic region in a [Building]. Can be monitored to check if
/// an user enter or exits the polygon and to get analytics.
class Geofence extends NamedResource {
  final String buildingId;
  final String floorId;
  final List<Point> polygonPoints;
  final Map<String, dynamic> customFields;
  final String createdAt;
  final String updatedAt;

  Geofence({
    required super.identifier,
    required super.name,
    required this.buildingId,
    required this.floorId,
    required this.polygonPoints,
    required this.createdAt,
    required this.updatedAt,
    required this.customFields,
  });

  @override
  Map<String, dynamic> toMap() => {
        "identifier": identifier,
        "name": name,
        "buildingId": buildingId,
        "floorId": floorId,
        "polygonPoints": polygonPoints.map((i) => i.toMap()).toList(),
        "customFields": customFields,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
      };
}

/// Point of Interest, associated to a [Building], regardless of whether it's
/// place inside or outside the building.
class Poi extends NamedResource {
  final String buildingIdentifier;
  final PoiCategory poiCategory;
  final Point position;
  final Map<String, dynamic> customFields;

  Poi({
    required super.identifier,
    required super.name,
    required this.buildingIdentifier,
    required this.poiCategory,
    required this.position,
    required this.customFields,
  });

  @override
  Map<String, dynamic> toMap() => {
        "identifier": identifier,
        "name": name,
        "buildingIdentifier": buildingIdentifier,
        "poiCategory": poiCategory.toMap(),
        "position": position.toMap(),
        "customFields": customFields,
      };
}

/// Associate geographical coordinate ([Location]) with [Building] and [Floor]
/// (Cartography) and cartesian coordinate relative to that building.
class Point {
  final String buildingIdentifier;
  final String floorIdentifier;
  final Coordinate coordinate;
  final CartesianCoordinate cartesianCoordinate;

  Point({
    required this.buildingIdentifier,
    required this.floorIdentifier,
    required this.coordinate,
    required this.cartesianCoordinate,
  });

  Map<String, dynamic> toMap() => {
        "buildingIdentifier": buildingIdentifier,
        "floorIdentifier": floorIdentifier,
        "coordinate": coordinate.toMap(),
        "cartesianCoordinate": cartesianCoordinate.toMap(),
      };
}

/// Category of Point of Interest.
class PoiCategory extends NamedResource {
  PoiCategory({
    required super.identifier,
    required super.name,
  });
}

class ConfigurationOptions {
  final bool useRemoteConfig;

  ConfigurationOptions({
    this.useRemoteConfig = true,
  });
}

class PrefetchOptions {
  final bool preloadImages;

  PrefetchOptions({
    this.preloadImages = false,
  });
}

class Error {
  final String code;
  final String message;

  const Error({required this.code, required this.message});
}

class SitumRoute {
  final dynamic rawContent;

  const SitumRoute({
    required this.rawContent,
  });
}

class RouteProgress {
  final dynamic rawContent;

  const RouteProgress({
    required this.rawContent,
  });
}

// Result callbacks.

// Location.
typedef OnLocationChangeCallback = void Function(Location location);
typedef OnStatusChangeCallback = void Function(String status);
typedef OnErrorCallback = void Function(Error error);

// On enter/exit geofences.
typedef OnEnteredGeofencesCallback = void Function(
    OnEnteredGeofenceResult onEnterGeofenceResult);
typedef OnExitedGeofencesCallback = void Function(
    OnExitedGeofenceResult onExitGeofenceResult);

// Navigation.
typedef OnNavigationFinishedCallback = void Function();
typedef OnNavigationProgressCallback = void Function(RouteProgress progress);
typedef OnNavigationOutOfRouteCallback = void Function();
