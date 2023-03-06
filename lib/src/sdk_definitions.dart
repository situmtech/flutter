part of situm_flutter_sdk;

class OnLocationChangedResult {
  final String buildingId;

  const OnLocationChangedResult({
    required this.buildingId,
  });
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

  @override
  String toString() {
    return "$name:$id";
  }
}

class Coordinate {
  final double latitude;
  final double longitude;
  Coordinate({
    required this.latitude,
    required this.longitude,
  });
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
}

class BuildingInfo {
  final Building building;
  final List<Floor> floors;
  final List<Poi> indoorPois;
  final List<Poi> outdoorPois;
  final List<Geofence> geofences;
  final List<Event> events;
  BuildingInfo({
    required this.building,
    required this.floors,
    required this.indoorPois,
    required this.outdoorPois,
    required this.geofences,
    required this.events,
  });

  @override
  String toString() {
    return "${building.name}: ${building.id} - \nFLOORS(${floors.join("\n")})\n - \nINDOOR_POIS(${indoorPois.join("\n")})\n - \nOUTDOOR_POIS(${outdoorPois.join("\n")})\n - \nGEOFENCES(${geofences.join("\n")})";
  }
}

class Floor extends NamedResource {
  final String buildingIdentifier;
  final int floorIndex;
  final String mapUrl;
  final double scale;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> customFields;
  Floor(
      {required super.id,
      required super.name,
      required this.buildingIdentifier,
      required this.floorIndex,
      required this.mapUrl,
      required this.scale,
      required this.createdAt,
      required this.updatedAt,
      required this.customFields});
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
  String toString() {
    return "$name: $id - NAME($name) - USER_ID($userIdentifier) - DIMENSIONS(${width.toStringAsFixed(2)}, ${height.toStringAsFixed(2)})";
  }
}

class CircleArea {
  final Point center;
  final double radius;
  CircleArea({
    required this.center,
    required this.radius,
  });
}

class Event extends NamedResource {
  final String buildingIdentifier;
  final String floorIdentifier;
  final Map<String, dynamic> customFields;
  final CircleArea trigger;
  Event({
    required super.id,
    required super.name,
    required this.buildingIdentifier,
    required this.floorIdentifier,
    required this.customFields,
    required this.trigger,
  });
}

class Geofence extends NamedResource {
  final String buildingIdentifier;
  final String floorIdentifier;
  final List<Point> polygonPoints;
  final Map<String, dynamic> customFields;
  final String createdAt;
  final String updatedAt;
  Geofence({
    required super.id,
    required super.name,
    required this.buildingIdentifier,
    required this.floorIdentifier,
    required this.polygonPoints,
    required this.createdAt,
    required this.updatedAt,
    required this.customFields,
  });

  @override
  String toString() {
    return "$name: $id - BUILDING_ID($buildingIdentifier) - FLOOR_ID($floorIdentifier) POINTS($polygonPoints) - CUSTOM_FIELDS($customFields)";
  }
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
  String toString() {
    return "$name:$id - CAT(${poiCategory.name}:${poiCategory.id}) - POS($position) - CUSTOM_FIELDS($customFields)";
  }
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

  @override
  String toString() {
    return "($latitude, $longitude)";
  }
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

// Location updates.

abstract class LocationListener {
  void onError(Error error);

  void onLocationChanged(OnLocationChangedResult locationChangedResult);

  void onStatusChanged(String status);
}

// On enter geofences.
typedef OnEnteredGeofencesCallback = void Function(
    OnEnteredGeofenceResult onEnterGeofenceResult);

// On exit geofences.
typedef OnExitedGeofencesCallback = void Function(
    OnExitedGeofenceResult onExitGeofenceResult);
