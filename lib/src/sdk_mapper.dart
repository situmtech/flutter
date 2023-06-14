part of situm_flutter_sdk;

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
  return Coordinate(latitude: map["latitude"], longitude: map["longitude"]);
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
  );
}

Point createPoint(Map map) {
  return Point(
    buildingIdentifier: map["buildingIdentifier"],
    floorIdentifier: map["floorIdentifier"],
    coordinate: Coordinate(
      latitude: map["coordinate"]["latitude"],
      longitude: map["coordinate"]["longitude"],
    ),
    cartesianCoordinate: CartesianCoordinate(
      x: map["cartesianCoordinate"]["x"],
      y: map["cartesianCoordinate"]["y"],
    ),
  );
}

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
  //Temporal fix to typo in ios sdk. Has to be removed when corrected in ios SDK
  var hasCartesianBearing = args["hasCartesianBearing"] ?? args["hasBearing"];
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
      degreesClockwise: args["bearing"]["degreesClockwise"] ,
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
    buildingIdentifier: args["buildingIdentifier"],
    floorIdentifier: args["floorIdentifier"],
    hasBearing: args["hasBearing"],
    hasCartesianBearing: hasCartesianBearing,
    isIndoor: args["isIndoor"],
    timestamp: args["timestamp"].toInt(),
  );
}

SitumRoute createRoute(arguments) {
  return SitumRoute(rawContent: arguments);
}

DirectionsOptions createDirectionsOptions(arguments) => DirectionsOptions(
      from: Point(
        buildingIdentifier: arguments["from"]["buildingIdentifier"],
        floorIdentifier: arguments["from"]["floorIdentifier"], // Hmm
        coordinate: Coordinate(
          latitude: arguments["from"]["coordinate"]["latitude"],
          longitude: arguments["from"]["coordinate"]["longitude"],
        ),
        cartesianCoordinate: CartesianCoordinate(
          x: (arguments["from"]["cartesianCoordinate"]["x"] ?? 0).toDouble(),
          y: (arguments["from"]["cartesianCoordinate"]["y"] ?? 0).toDouble(),
        ),
      ),
      to: Point(
        buildingIdentifier: arguments["to"]["buildingIdentifier"],
        floorIdentifier: arguments["to"]["floorIdentifier"],
        coordinate: Coordinate(
          latitude: arguments["to"]["coordinate"]["latitude"],
          longitude: arguments["to"]["coordinate"]["longitude"],
        ),
        cartesianCoordinate: CartesianCoordinate(
          x: (arguments["to"]["cartesianCoordinate"]["x"] ?? 0).toDouble(),
          y: (arguments["to"]["cartesianCoordinate"]["y"] ?? 0).toDouble(),
        ),
      ),
      bearingFrom: Angle(
          radians: (arguments["bearingFrom"] != null ? arguments["bearingFrom"]["radians"] : 0).toDouble(),
      ),
      minimizeFloorChanges: arguments["minimizeFloorChanges"],
    );
