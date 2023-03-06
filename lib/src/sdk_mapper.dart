part of situm_flutter_sdk;

BuildingInfo createBuildingInfo(Map map) {
  return BuildingInfo(
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
    id: map["identifier"],
    name: map["poiCategoryName"],
  );
}

Point createPoint(Map map) {
  return Point(
    buildingId: map["buildingIdentifier"],
    floorId: map["floorIdentifier"],
    latitude: map["coordinate"]["latitude"],
    longitude: map["coordinate"]["longitude"],
  );
}

Geofence createGeofence(Map map) {
  return Geofence(
      id: map["identifier"],
      name: map["name"],
      buildingIdentifier: map["buildingIdentifier"],
      floorIdentifier: map["floorIdentifier"],
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
      id: map["identifier"],
      name: map["name"],
      buildingIdentifier: map["buildingIdentifier"],
      floorIdentifier: map["floorIdentifier"],
      customFields: Map<String, dynamic>.from(map["customFields"]),
      trigger: createCircleArea(map["trigger"]));
}

List<T> createList<T>(List maps, Function mapper) {
  return maps.map((o) => mapper(o)).toList().cast<T>();
}
