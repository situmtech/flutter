part of situm_flutter_sdk;

class LocationRequest {
  final String buildingIdentifier;
  final bool useDeadReckoning;

  LocationRequest({
    this.buildingIdentifier = "-1",
    this.useDeadReckoning = false,
  });

  Map<String, dynamic> toJson() => {
        "buildingIdentifier": buildingIdentifier,
        "useDeadReckoning": useDeadReckoning,
      };
}

class Location {
  final Coordinate coordinate;
  final CartesianCoordinate cartesianCoordinate;
  final String buildingId;
  final String floorId;
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
    required this.buildingId,
    required this.floorId,
    required this.accuracy,
    required this.isIndoor,
    required this.hasBearing,
    required this.hasCartesianBearing,
    this.bearing,
    this.cartesianBearing,
    required this.timestamp,
  });

  String toMapViewer() {
    return "{latitude: ${coordinate.latitude}, longitude: ${coordinate.longitude}, accuracy: $accuracy, bearing: ${bearing?.degreesClockwise}, buildingId: $buildingId, floorId: $floorId, isIndoor: $isIndoor, isOutdoor: ${!isIndoor}, hasBearing: $hasBearing}";
  }

  static Location fromArguments(dynamic args) {
    return Location(
      coordinate: Coordinate(
        latitude: args["coordinate"]["latitude"],
        longitude: args["coordinate"]["longitude"],
      ),
      cartesianCoordinate: CartesianCoordinate(
        x: args["cartesianCoordinate"]["x"],
        y: args["cartesianCoordinate"]["y"],
      ),
      bearing: Bearing(
        degrees: args["bearing"]["degrees"],
        degreesClockwise: args["bearing"]["degreesClockwise"],
        radians: args["bearing"]["radians"],
        radiansMinusPiPi: args["bearing"]["radiansMinusPiPi"],
      ),
      cartesianBearing: Bearing(
        degrees: args["cartesianBearing"]["degrees"],
        degreesClockwise: args["cartesianBearing"]["degreesClockwise"],
        radians: args["cartesianBearing"]["radians"],
        radiansMinusPiPi: args["cartesianBearing"]["radiansMinusPiPi"],
      ),
      accuracy: args["accuracy"],
      buildingId: args["buildingIdentifier"],
      floorId: args["floorIdentifier"],
      hasBearing: args["hasBearing"],
      hasCartesianBearing: args["hasCartesianBearing"],
      isIndoor: args["isIndoor"],
      timestamp: args["timestamp"],
    );
  }
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
  final String id;
  final String name;

  const NamedResource({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toJson() => {"id": id, "name": name};

  @override
  String toString() {
    return const JsonEncoder.withIndent('\t').convert(toJson());
  }
}

class Coordinate {
  final double latitude;
  final double longitude;

  Coordinate({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() =>
      {"latitude": latitude, "longitude": longitude};
}

class CartesianCoordinate {
  final double x;
  final double y;

  CartesianCoordinate({
    required this.x,
    required this.y,
  });

  Map<String, dynamic> toJson() => {"x": x, "y": y};
}

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

  Map<String, dynamic> toJson() => {
        "northEast": northEast.toJson(),
        "northWest": northWest.toJson(),
        "southEast": southEast.toJson(),
        "southWest": southWest.toJson()
      };
}

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
}

class BuildingInfo extends NamedResource {
  final Building building;
  final List<Floor> floors;
  final List<Poi> indoorPois;
  final List<Poi> outdoorPois;
  final List<Geofence> geofences;
  final List<Event> events;

  BuildingInfo({
    required super.id,
    required super.name,
    required this.building,
    required this.floors,
    required this.indoorPois,
    required this.outdoorPois,
    required this.geofences,
    required this.events,
  });

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "building": building.toJson(),
        "floors": floors.map((i) => i.toJson()).toList(),
        "indoorPOIs": indoorPois.map((i) => i.toJson()).toList(),
        "outdoorPOIs": outdoorPois.map((i) => i.toJson()).toList(),
        "geofences": geofences.map((i) => i.toJson()).toList(),
        "events": events.map((i) => i.toJson()).toList()
      };
}

class Floor extends NamedResource {
  final String buildingId;
  final int floorIndex;
  final String mapUrl;
  final double scale;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> customFields;

  Floor(
      {required super.id,
      required super.name,
      required this.buildingId,
      required this.floorIndex,
      required this.mapUrl,
      required this.scale,
      required this.createdAt,
      required this.updatedAt,
      required this.customFields});

  @override
  Map<String, dynamic> toJson() => {
        "buildingId": buildingId,
        "floorIndex": floorIndex,
        "mapUrl": mapUrl,
        "scale": scale,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "customFields": customFields
      };
}

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
    required super.id,
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
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "address": address,
        "bounds": bounds.toJson(),
        "boundsRotated": boundsRotated.toJson(),
        "center": center.toJson(),
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

  Map<String, dynamic> toJson() => {
        "center": center.toJson(),
        "radius": radius,
      };
}

class Event extends NamedResource {
  final Map<String, dynamic> customFields;
  final CircleArea trigger;

  Event({
    required super.id,
    required super.name,
    required this.customFields,
    required this.trigger,
  });

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "trigger": trigger.toJson(),
        "customFields": customFields,
      };
}

class Geofence extends NamedResource {
  final String buildingId;
  final String floorId;
  final List<Point> polygonPoints;
  final Map<String, dynamic> customFields;
  final String createdAt;
  final String updatedAt;

  Geofence({
    required super.id,
    required super.name,
    required this.buildingId,
    required this.floorId,
    required this.polygonPoints,
    required this.createdAt,
    required this.updatedAt,
    required this.customFields,
  });

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "buildingId": buildingId,
        "floorId": floorId,
        "polygonPoints": polygonPoints,
        "customFields": customFields,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
      };
}

class Poi extends NamedResource {
  final String buildingId;
  final PoiCategory poiCategory;
  final Point position;
  final Map<String, dynamic> customFields;

  Poi({
    required super.id,
    required super.name,
    required this.buildingId,
    required this.poiCategory,
    required this.position,
    required this.customFields,
  });

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "buildingId": buildingId,
        "poiCategory": poiCategory.toJson(),
        "position": position.toJson(),
        "customFields": customFields,
      };
}

class Point {
  final String buildingId;
  final String floorId;
  final double latitude;
  final double longitude;

  Point({
    required this.buildingId,
    required this.floorId,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        "buildingId": buildingId,
        "floorId": floorId,
        "latitude": latitude,
        "longitude": longitude,
      };
}

class PoiCategory extends NamedResource {
  PoiCategory({
    required super.id,
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
  final Int code;
  final String message;

  const Error({required this.code, required this.message});
}

// Result callbacks.

// Location.
typedef OnLocationChangeCallback = void Function(Location location);
typedef OnStatusChangeCallback = void Function(String status);
typedef OnErrorCallback = void Function(Error error);

// On enter geofences.
typedef OnEnteredGeofencesCallback = void Function(
    OnEnteredGeofenceResult onEnterGeofenceResult);

// On exit geofences.
typedef OnExitedGeofencesCallback = void Function(
    OnExitedGeofenceResult onExitGeofenceResult);
