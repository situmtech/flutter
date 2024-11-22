part of '../sdk.dart';

BuildingInfo createBuildingInfo(Map map) {
  return BuildingInfo(
      identifier: map["building"]["buildingIdentifier"],
      name: map["building"]["name"],
      building: createBuilding(map["building"]),
      floors: createList<Floor>(map["floors"], createFloor),
      indoorPois: createList<Poi>(map["indoorPOIs"], createPoi),
      outdoorPois: createList<Poi>(map["outdoorPOIs"], createPoi),
      geofences: createList<Geofence>(map["geofences"], createGeofence),
      events: createList<Event>(map["events"], createEvent));
}

Coordinate createCoordinate(Map map) {
  return Coordinate(
    latitude: (map["latitude"] ?? 0).toDouble(),
    longitude: (map["longitude"] ?? 0).toDouble(),
  );
}

CartesianCoordinate createCartesianCoordinate(Map map) {
  return CartesianCoordinate(
    x: (map["x"] ?? 0).toDouble(),
    y: (map["y"] ?? 0).toDouble(),
  );
}

Bounds createBounds(Map map) {
  return Bounds(
      northEast: createCoordinate(map["northEast"]),
      northWest: createCoordinate(map["northWest"]),
      southEast: createCoordinate(map["southEast"]),
      southWest: createCoordinate(map["southWest"]));
}

Floor createFloor(Map map) {
  return Floor(
    identifier: map["floorIdentifier"],
    name: map["name"],
    buildingIdentifier: map["buildingIdentifier"],
    floorIndex: map["floor"],
    mapUrl: map["mapUrl"],
    scale: map["scale"],
    createdAt: map["createdAt"],
    updatedAt: map["updatedAt"],
    customFields: Map<String, dynamic>.from(map["customFields"]),
  );
}

Building createBuilding(Map map) {
  return Building(
      identifier: map["buildingIdentifier"],
      name: map["name"],
      address: map["address"],
      bounds: createBounds(map["bounds"]),
      boundsRotated: createBounds(map["boundsRotated"]),
      center: createCoordinate(map["center"]),
      width: map["dimensions"]["width"],
      height: map["dimensions"]["height"],
      pictureThumbUrl: map["pictureThumbUrl"],
      pictureUrl: map["pictureUrl"],
      rotation: map["rotation"],
      userIdentifier: map["userIdentifier"],
      customFields: Map<String, dynamic>.from(map["customFields"]),
      createdAt: map["createdAt"],
      updatedAt: map["updatedAt"]);
}

Poi createPoi(Map map) {
  return Poi(
    identifier: map["identifier"],
    name: map["poiName"],
    buildingIdentifier: map["buildingIdentifier"],
    poiCategory: createCategory(map["category"]),
    position: createPoint(map["position"]),
    customFields: Map<String, dynamic>.from(map["customFields"]),
  );
}

PoiCategory createCategory(Map map) {
  return PoiCategory(
    identifier: map["identifier"].toString(),
    name: map["poiCategoryName"],
    iconSelected: map["icon_selected"],
    // Android icon_unselected vs iOS icon_deselected:
    iconUnselected: map["icon_unselected"] ?? map["icon_deselected"],
  );
}

Point createPoint(arguments) => Point(
      buildingIdentifier: arguments["buildingIdentifier"],
      floorIdentifier: arguments["floorIdentifier"],
      coordinate: createCoordinate(arguments["coordinate"]),
      cartesianCoordinate:
          createCartesianCoordinate(arguments["cartesianCoordinate"]),
    );

Geofence createGeofence(Map map) {
  return Geofence(
      identifier: map["identifier"],
      name: map["name"],
      buildingId: map["buildingIdentifier"],
      floorId: map["floorIdentifier"],
      polygonPoints: createList<Point>(map["polygonPoints"], createPoint),
      customFields: Map<String, dynamic>.from(map["customFields"]),
      createdAt: map["createdAt"],
      updatedAt: map["updatedAt"]);
}

CircleArea createCircleArea(Map map) {
  return CircleArea(
    center: createPoint(map["center"]),
    radius: map["radius"],
  );
}

Event createEvent(Map map) {
  return Event(
      identifier: map["identifier"].toString(),
      name: map["name"],
      customFields: Map<String, dynamic>.from(map["customFields"]),
      trigger: createCircleArea(map["trigger"]));
}

List<T> createList<T>(List maps, Function mapper) {
  return maps.map((o) => mapper(o)).toList().cast<T>();
}

Location createLocation(dynamic args) {
  return Location(
    coordinate: Coordinate(
      latitude: args["coordinate"]["latitude"],
      longitude: args["coordinate"]["longitude"],
    ),
    cartesianCoordinate: CartesianCoordinate(
      x: args["cartesianCoordinate"]["x"] ?? 0,
      y: args["cartesianCoordinate"]["y"] ?? 0,
    ),
    bearing: Angle(
      degrees: args["bearing"]["degrees"],
      degreesClockwise: args["bearing"]["degreesClockwise"],
      radians: args["bearing"]["radians"],
      radiansMinusPiPi: args["bearing"]["radiansMinusPiPi"],
    ),
    accuracy: args["accuracy"],
    buildingIdentifier: args["buildingIdentifier"],
    floorIdentifier: args["floorIdentifier"],
    hasBearing: args["hasBearing"],
    isIndoor: args["isIndoor"],
    isOutdoor: args["isOutdoor"],
    timestamp: args["timestamp"].toInt(),
  );
}

SitumRoute createRoute(arguments) {
  Poi? poi;
  var poiTo = arguments["poiTo"];
  if (poiTo != null) {
    Map map = arguments["poiTo"];
    poi = createPoi(map);
  }
  return SitumRoute(rawContent: arguments, poiTo: poi);
}

DirectionsRequest createDirectionsRequest(arguments) {
  String? poiToIdentifier;
  Map directionsRequestArgs = arguments["directionsRequest"];
  if (!directionsRequestArgs.containsKey("poiToIdentifier") &&
      arguments["destinationCategory"] == "POI") {
    poiToIdentifier =
        stringFromArgsOrEmptyId(arguments, "destinationIdentifier");
  }
  var directionsRequest = DirectionsRequest(
    from: createPoint(directionsRequestArgs["from"]),
    to: createPoint(directionsRequestArgs["to"]),
    poiToIdentifier: poiToIdentifier,
    bearingFrom: Angle.fromRadians(
      (directionsRequestArgs["bearingFrom"] != null
              ? directionsRequestArgs["bearingFrom"]["radians"]
              : 0)
          .toDouble(),
    ),
    minimizeFloorChanges: directionsRequestArgs["minimizeFloorChanges"],
    originIdentifier: stringFromArgsOrEmptyId(arguments, "originIdentifier"),
    originCategory: arguments["originCategory"],
    destinationIdentifier:
        stringFromArgsOrEmptyId(arguments, "destinationIdentifier"),
    destinationCategory: arguments["destinationCategory"],
  );
  directionsRequest.accessibilityMode =
      createAccessibilityMode(directionsRequestArgs);
  return directionsRequest;
}

AccessibilityMode? createAccessibilityMode(arguments) {
  if (arguments != null && arguments["accessibilityMode"] != null) {
    return AccessibilityMode.values.firstWhere(
        (element) => element.name == arguments["accessibilityMode"]);
  }
  return null;
}

NavigationRequest createNavigationRequest(arguments) => NavigationRequest(
      distanceToGoalThreshold: arguments['distanceToGoalThreshold'],
      outsideRouteThreshold: arguments['outsideRouteThreshold'],
      distanceToIgnoreFirstIndication:
          arguments['distanceToIgnoreFirstIndication'],
      distanceToFloorChangeThreshold:
          arguments['distanceToFloorChangeThreshold'],
      distanceToChangeIndicationThreshold:
          arguments['distanceToChangeIndicationThreshold'],
      indicationsInterval: arguments['indicationsInterval'],
      timeToFirstIndication: arguments['timeToFirstIndication'],
      roundIndicationsStep: arguments['roundIndicationsStep'],
      timeToIgnoreUnexpectedFloorChanges:
          arguments['timeToIgnoreUnexpectedFloorChanges'],
      ignoreLowQualityLocations: arguments['ignoreLowQualityLocations'],
    );

/// Returns the value of arguments[key] or "-1" if the value is null.
String stringFromArgsOrEmptyId(arguments, String key) {
  return (arguments[key] ?? -1).toString();
}
