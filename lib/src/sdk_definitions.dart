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

// TODO: this class already exists
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

class Building extends NamedResource {
  final String address;
  final Bounds bounds;
  final Bounds boundsRotated;
  final Coordinate center;
  final double width;
  final double height;
  final String infoHtml;
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
    required this.infoHtml,
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
    return "$name:$id - NAME($name) - USER ID($userIdentifier) - DIMENSIONS(${width.toStringAsFixed(2)}, ${height.toStringAsFixed(2)})";
  }
}

class Geofence extends NamedResource {
  Geofence({
    required super.id,
    required super.name,
  });
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
    return "$name:$id - CAT(${poiCategory.name}:${poiCategory.id}) - POS(${position.latitude}, ${position.longitude}) - CUSTOM_FIELDS($customFields)";
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
