part of situm_flutter_sdk;

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

/// Parameters to request a route.
class DirectionsOptions {
  // buildingId populated in the constructor body.
  late String buildingIdentifier;
  final Point from;
  final Point to;
  final double? bearingFrom;
  final bool? minimizeFloorChanges;

  DirectionsOptions({
    required this.from,
    required this.to,
    this.bearingFrom,
    this.minimizeFloorChanges,
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
      map['bearingFrom'] = bearingFrom;
    }
    return map;
  }
}

class NavigationOptions {
  final double outsideRouteThreshold;
  final double distanceToGoalThreshold;

  const NavigationOptions({
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
        "latitude": coordinate.latitude,
        "longitude": coordinate.longitude,
        "accuracy": accuracy,
        "bearing": bearing?.degreesClockwise,
        "buildingIdentifier": buildingIdentifier,
        "floorIdentifier": floorIdentifier,
        "isIndoor": isIndoor,
        "isOutdoor": !isIndoor,
        "hasBearing": hasBearing,
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
        "polygonPoints": polygonPoints,
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
  final double latitude;
  final double longitude;
  final double x;
  final double y;

  Point({
    required this.buildingIdentifier,
    required this.floorIdentifier,
    required this.latitude,
    required this.longitude,
    required this.x,
    required this.y,
  });

  Map<String, dynamic> toMap() => {
        "buildingIdentifier": buildingIdentifier,
        "floorIdentifier": floorIdentifier,
        "latitude": latitude,
        "longitude": longitude,
        "x": x,
        "y": y,
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