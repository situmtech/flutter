part of situm_flutter_sdk;

BuildingInfo createBuildingInfo(Map map) {
  return BuildingInfo(
      id: map["building"]["buildingIdentifier"],
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
    id: map["floorIdentifier"],
    name: map["name"],
    buildingId: map["buildingIdentifier"],
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
      id: map["buildingIdentifier"],
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
    id: map["identifier"],
    name: map["poiName"],
    buildingId: map["buildingIdentifier"],
    poiCategory: createCategory(map["category"]),
    position: createPoint(map["position"]),
    customFields: Map<String, dynamic>.from(map["customFields"]),
  );
}

PoiCategory createCategory(Map map) {
  return PoiCategory(
    id: map["identifier"].toString(),
    name: map["poiCategoryName"],
  );
}

Point createPoint(Map map) {
  return Point(
    buildingId: map["buildingIdentifier"],
    floorId: map["floorIdentifier"],
    latitude: map["coordinate"]["latitude"],
    longitude: map["coordinate"]["longitude"],
    x: map["cartesianCoordinate"]["x"],
    y: map["cartesianCoordinate"]["y"],
  );
}

Geofence createGeofence(Map map) {
  return Geofence(
      id: map["identifier"],
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
      id: map["identifier"].toString(),
      name: map["name"],
      customFields: Map<String, dynamic>.from(map["customFields"]),
      trigger: createCircleArea(map["trigger"]));
}

List<T> createList<T>(List maps, Function mapper) {
  return maps.map((o) => mapper(o)).toList().cast<T>();
}

Location createLocation(dynamic args) => Location(
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

SitumRoute createRoute(arguments) {
  return SitumRoute(
      rawContent: arguments
  );
}

DirectionsOptions createDirectionsOptions(arguments) => DirectionsOptions(
      from: Point(
        buildingId: arguments["from"]["buildingId"],
        floorId: arguments["from"]["floorId"], // Hmm
        latitude: arguments["from"]["lat"],
        longitude: arguments["from"]["lng"],
        x: (arguments["from"]["x"] ?? 0).toDouble(), // TODO: send x and y from WYF.
        y: (arguments["from"]["y"] ?? 0).toDouble(),
      ),
      to: Point(
        buildingId: arguments["to"]["buildingId"],
        floorId: arguments["to"]["floorId"],
        latitude: arguments["to"]["lat"],
        longitude: arguments["to"]["lng"],
        x: (arguments["to"]["x"] ?? 0).toDouble(),
        y: (arguments["to"]["y"] ?? 0).toDouble(),
      ),
      fromBearing: arguments["fromBearing"],
      minimizeFloorChanges: arguments["minimizeFloorChanges"],
    );
