part of sdk;

/// Enum that allows to specify whether the geolocations computed should be sent
/// to Situm Platform, and if so with which periodicity (time interval).
enum RealtimeUpdateInterval {
  never,
  batterySaver,
  slow,
  normal,
  fast,
  realtime,
}

extension RealtimeUpdateIntervalExtension on RealtimeUpdateInterval {
  String get name {
    switch (this) {
      case RealtimeUpdateInterval.never:
        return 'NEVER';
      case RealtimeUpdateInterval.batterySaver:
        return 'BATTERY_SAVER';
      case RealtimeUpdateInterval.slow:
        return 'SLOW';
      case RealtimeUpdateInterval.fast:
        return 'FAST';
      case RealtimeUpdateInterval.realtime:
        return 'REALTIME';
      default:
        return 'NORMAL';
    }
  }
}

/// When you build the [LocationRequest], this data object configures the Global
/// Mode options.
class OutdoorLocationOptions {
  final bool? enableOutdoorPositions;

  OutdoorLocationOptions({
    this.enableOutdoorPositions,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    _addToMapIfNotNull("enableOutdoorPositions", enableOutdoorPositions, map);
    return map;
  }
}

/// A data object that allows you to configure the positioning parameters.
class LocationRequest {
  final String? buildingIdentifier;
  final bool? useDeadReckoning;
  final bool? useForegroundService;
  final ForegroundServiceNotificationOptions?
      foregroundServiceNotificationOptions;
  final OutdoorLocationOptions? outdoorLocationOptions;
  final RealtimeUpdateInterval? realtimeUpdateInterval;
  final bool? useBle;
  final bool? useGps;

  /// Only for Android.
  final bool? useWifi;

  LocationRequest({
    this.buildingIdentifier,
    this.useDeadReckoning,
    this.useForegroundService,
    this.foregroundServiceNotificationOptions,
    this.outdoorLocationOptions,
    this.realtimeUpdateInterval,
    this.useWifi,
    this.useBle,
    this.useGps,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    _addToMapIfNotNull("buildingIdentifier", buildingIdentifier, map);
    _addToMapIfNotNull("useDeadReckoning", useDeadReckoning, map);
    _addToMapIfNotNull("useForegroundService", useForegroundService, map);
    _addToMapIfNotNull("foregroundServiceNotificationOptions",
        foregroundServiceNotificationOptions?.toMap(), map);
    _addToMapIfNotNull(
        "outdoorLocationOptions", outdoorLocationOptions?.toMap(), map);
    _addToMapIfNotNull(
        "realtimeUpdateInterval", realtimeUpdateInterval?.name, map);
    _addToMapIfNotNull("useWifi", useWifi, map);
    _addToMapIfNotNull("useBle", useBle, map);
    _addToMapIfNotNull("useGps", useGps, map);
    return map;
  }
}

/// A data object that let you customize the Foreground Service Notification
/// that will be shown in the system's tray when the app is running as a
/// Foreground Service.
/// To be used with [LocationRequest].
/// Only applies for Android.
class ForegroundServiceNotificationOptions {
  late String? title;
  late String? message;
  late bool? showStopAction;
  late String? stopActionText;

  ForegroundServiceNotificationOptions({
    this.title,
    this.message,
    this.showStopAction = false,
    this.stopActionText,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    _addToMapIfNotNull("title", title, map);
    _addToMapIfNotNull("message", message, map);
    _addToMapIfNotNull("showStopAction", showStopAction, map);
    _addToMapIfNotNull("stopActionText", stopActionText, map);
    return map;
  }
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
  static const CATEGORY_POI = "POI";
  static const CATEGORY_LOCATION = "LOCATION";
  static const EMPTY_ID = "-1";

  final Point from;
  final Point to;

  String? poiToIdentifier;

  /// Identifier of the route destination. Can be [EMPTY_ID] if [destinationCategory] is [CATEGORY_LOCATION].
  String destinationIdentifier;

  /// Informs us of the type of the destination [Point], which can be a [CATEGORY_POI] or a [CATEGORY_LOCATION].
  String destinationCategory;

  /// Identifier of the route destination. Can be [EMPTY_ID] if [originCategory] is [CATEGORY_LOCATION].
  String originIdentifier;

  /// Informs us of the type of the origin [Point], which can be a [CATEGORY_POI] or a [CATEGORY_LOCATION].
  String originCategory;
  Angle? bearingFrom;
  bool? minimizeFloorChanges;
  AccessibilityMode? accessibilityMode;

  // buildingId populated in the constructor body.
  late String buildingIdentifier;

  DirectionsRequest({
    required this.from,
    required this.to,
    this.poiToIdentifier,
    this.bearingFrom,
    this.minimizeFloorChanges,
    this.accessibilityMode,
    this.destinationIdentifier = EMPTY_ID,
    this.destinationCategory = CATEGORY_LOCATION,
    this.originIdentifier = EMPTY_ID,
    this.originCategory = CATEGORY_LOCATION,
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
    if (poiToIdentifier != null) {
      map['poiToIdentifier'] = poiToIdentifier;
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

  void addToMap(String key, dynamic value, Map<String, dynamic> map) {
    if (value != null && value > 0) {
      map[key] = value;
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    addToMap('distanceToGoalThreshold', distanceToGoalThreshold, map);
    addToMap('outsideRouteThreshold', outsideRouteThreshold, map);
    addToMap('distanceToIgnoreFirstIndication', distanceToIgnoreFirstIndication,
        map);
    // Android vs iOS inconsistency: both distanceToChangeFloorThreshold and
    // distanceToFloorChangeThreshold are necessary.
    addToMap(
        'distanceToChangeFloorThreshold', distanceToFloorChangeThreshold, map);
    addToMap(
        'distanceToFloorChangeThreshold', distanceToFloorChangeThreshold, map);
    addToMap('distanceToChangeIndicationThreshold',
        distanceToChangeIndicationThreshold, map);
    addToMap('indicationsInterval', indicationsInterval, map);
    addToMap('timeToFirstIndication', timeToFirstIndication, map);
    addToMap('roundIndicationsStep', roundIndicationsStep, map);
    addToMap('timeToIgnoreUnexpectedFloorChanges',
        timeToIgnoreUnexpectedFloorChanges, map);
    if (ignoreLowQualityLocations != null) {
      map['ignoreLowQualityLocations'] = ignoreLowQualityLocations;
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
  final Angle? bearing;
  final double accuracy;
  final bool isIndoor;
  final bool isOutdoor;
  final bool hasBearing;
  final int timestamp;

  Location({
    required this.coordinate,
    required this.cartesianCoordinate,
    required this.buildingIdentifier,
    required this.floorIdentifier,
    required this.accuracy,
    required this.isIndoor,
    required this.isOutdoor,
    required this.hasBearing,
    this.bearing,
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
        'accuracy': accuracy,
        'isIndoor': isIndoor,
        'isOutdoor': isOutdoor,
        'hasBearing': hasBearing,
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

/// An structure that contains geographical coordinate that follows the [WGS 84](https://es.wikipedia.org/wiki/WGS84#:~:text=El%20WGS%2084%20(World%20Geodetic,x%2Cy%2Cz)) coordinate system standard.
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

/// An structure that contains an angle in radians and in degrees.
class Angle {
  final double radians;
  final double radiansMinusPiPi;
  final double degrees;
  final double degreesClockwise;

  static const double _pi = 3.1415926535897932;

  Angle({
    required this.radians,
    required this.radiansMinusPiPi,
    required this.degrees,
    required this.degreesClockwise,
  });

  Map<String, dynamic> toMap() => {
        "radiansMinusPiPi": radiansMinusPiPi,
        "radians": radians,
        "degreesClockwise": degreesClockwise,
        "degrees": degrees,
      };

  static Angle fromRadians(double radians) {
    double degrees = radians * (180 / _pi);

    return Angle(
        radians: radians,
        radiansMinusPiPi: radians > _pi ? radians - 2 * _pi : radians,
        degrees: degrees,
        degreesClockwise: 360 - degrees);
  }

  static Angle fromDegrees(double degrees) {
    return Angle.fromRadians(degrees * (_pi / 180));
  }
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
  final String? iconSelected;
  final String? iconUnselected;

  PoiCategory({
    required super.identifier,
    required super.name,
    required this.iconSelected,
    required this.iconUnselected,
  });

  @override
  Map<String, dynamic> toMap() => {
        "identifier": identifier,
        "name": name,
        "iconSelected": iconSelected,
        "iconUnselected": iconUnselected,
      };
}

class ConfigurationOptions {
  final bool useRemoteConfig;

  ConfigurationOptions({this.useRemoteConfig = true});
}

class PrefetchOptions {
  final bool preloadImages;

  PrefetchOptions({
    this.preloadImages = false,
  });
}

/// [code] [ErrorCodes.locationPermissionDenied]
/// * type: [ErrorType.critical].
///
/// * **CAUSE**: Location permissions were not granted yet,
/// so SDK won't be able to start positioning. The permissions needed to fix this error are:
///   * ACCESS_FINE_LOCATION (Android)
///   * NSLocationWhenInUseUsageDescription (iOS)
///
/// [code] [ErrorCodes.bluetoothPermissionDenied]
/// * (Android only)
/// * type: [ErrorType.critical].
///
/// * **CAUSE**: BLUETOOTH_CONNECT or BLUETOOTH_SCAN are not granted yet,
/// so SDK won't be able to start positioning.
///
/// [code] [ErrorCodes.bluetoothDisabled]
/// * type: [ErrorType.critical] for iOS but [ErrorType.nonCritical] for Android.
///
/// * **CAUSE**: The bluetooth sensor of the device is off,
/// so iOS will stop positioning and Android won't give a precise location as with this sensor on.
///
/// [code] [ErrorCodes.locationDisabled]
/// * type: [ErrorType.critical].
///
/// * **CAUSE**: The location service is disabled, so SDK won't be able to start positioning.
///
/// There are other errors that we throw directly as we receive them from [Android](https://developers.situm.com/sdk_documentation/android/javadoc/latest/es/situm/sdk/location/locationmanager.code) and [iOS](https://developers.situm.com/sdk_documentation/ios/documentation/enums/sitlocationerror#/).
class Error {
  final String code;
  final String message;
  final ErrorType type;

  const Error({required this.code, required this.message, required this.type});

  static Error bleDisabledError() {
    return const Error(
      code: "BLUETOOTH_DISABLED",
      message:
          "The bluetooth sensor of the device is off, so SDK won't give a precise location as with this sensor on.",
      type: ErrorType.nonCritical,
    );
  }
}

/// Exposes constant error codes useful for error handling in combination with
/// [SitumSdk.onLocationError]:
///
/// ```dart
/// SitumSdk().onLocationError((error) {
///   switch (error.code) {
///     case ErrorCodes.locationDisabled:
///       // Handle location disabled.
///       break;
///     case ErrorCodes.bluetoothDisabled:
///       ...
///   }
/// });
/// ```
class ErrorCodes {
  static const bluetoothDisabled = "BLUETOOTH_DISABLED";
  static const locationDisabled = "LOCATION_DISABLED";
  static const locationPermissionDenied = "LOCATION_PERMISSION_DENIED";
  static const bluetoothPermissionDenied = "BLUETOOTH_PERMISSION_DENIED";
  static const buildingNotCalibrated = "BUILDING_NOT_CALIBRATED";
  static const buildingModelDownloadError = "BUILDING_MODEL_DOWNLOAD_ERROR";
  static const buildingModelProcessingError = "BUILDING_MODEL_PROCESSING_ERROR";
}

enum ErrorType {
  /// An error that must be fixed to be able to start positioning.
  critical,

  /// An error that does not stop positioning but should be fixed because limitates our SDK accuracy.
  nonCritical,
}

class SitumRoute {
  final dynamic rawContent;
  final Poi? poiTo;

  const SitumRoute({required this.rawContent, this.poiTo});
}

class RouteProgress {
  final dynamic rawContent;

  const RouteProgress({
    required this.rawContent,
  });
}

void _addToMapIfNotNull(String key, dynamic value, Map<String, dynamic> map) {
  if (value != null) {
    map[key] = value;
  }
}

// Result callbacks.

// Location.
typedef OnLocationUpdateCallback = void Function(Location location);
typedef OnLocationStatusCallback = void Function(String status);
typedef OnLocationErrorCallback = void Function(Error error);

// On enter/exit geofences.
typedef OnEnteredGeofencesCallback = void Function(
    OnEnteredGeofenceResult onEnterGeofenceResult);
typedef OnExitedGeofencesCallback = void Function(
    OnExitedGeofenceResult onExitGeofenceResult);

// Navigation.
typedef OnNavigationStartCallback = void Function(SitumRoute route);
typedef OnNavigationDestinationReachedCallback = void Function(
    SitumRoute route);
typedef OnNavigationCancellationCallback = void Function();
typedef OnNavigationProgressCallback = void Function(RouteProgress progress);
typedef OnNavigationOutOfRouteCallback = void Function();
// Directions callback.
typedef OnDirectionsRequestedCallback = Function(
    DirectionsRequest directionsRequest);

// Internal definitions:

/// Set of method calls that are being delegated by the SDK.
/// For internal use only.
enum InternalCallType {
  location,
  locationStatus,
  locationError,
  navigationStart,
  navigationDestinationReached,
  navigationProgress,
  navigationOutOfRoute,
  navigationCancellation,
  geofencesEnter,
  geofencesExit,
}

/// Represents an internal method call and encapsulates the type of call and
/// associated data, previously processed by the SDK.
/// For internal use only.
class InternalCall {
  final InternalCallType type;
  final dynamic data;

  InternalCall(this.type, this.data);

  T get<T>() {
    return data as T;
  }

  @override
  String toString() {
    return "$type - ${data.runtimeType}";
  }
}

class _InternalDelegates {
  Function(InternalCall call)? mapViewDelegate;
  Function(InternalCall call)? arDelegate;

  Future<void> call(InternalCall internalCall) async {
    await Future.forEach({mapViewDelegate, arDelegate},
        (Function(InternalCall internalCall)? delegate) async {
      await delegate?.call(internalCall);
    });
  }
}
