part of situm_flutter_sdk;

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
      infoHtml: map["infoHtml"],
      pictureThumbUrl: map["pictureThumbUrl"],
      pictureUrl: map["pictureUrl"],
      rotation: map["rotation"],
      userIdentifier: map["userIdentifier"],
      customFields: Map<String, dynamic>.from(map["customFields"]),
      createdAt: map["createdAt"],
      updatedAt: map["updatedAt"]);
}

List<Building> createBuildings(List maps) {
  List<Building> buildings = [];
  for (Map map in maps) {
    buildings.add(createBuilding(map));
  }
  return buildings;
}

Poi createPoi(Map map) {
  return Poi(
    id: map["identifier"],
    name: map["poiName"],
    buildingId: map["buildingIdentifier"],
    poiCategory: createCategory(map["poiCategory"]),
    position: createPoint(map["position"]),
    customFields: Map<String, dynamic>.from(map["customFields"]),
  );
}

List<Poi> createPois(List maps) {
  List<Poi> pois = [];
  for (Map map in maps) {
    pois.add(createPoi(map));
  }
  return pois;
}

PoiCategory createCategory(Map map) {
  return PoiCategory(
    id: map["id"],
    name: map["poiCategoryName"],
  );
}

// TODO: set latitude longitude as coordinates?
Point createPoint(Map map) {
  return Point(
    buildingId: map["buildingIdentifier"],
    floorId: map["floorIdentifier"],
    latitude: map["coordinate"]["latitude"],
    longitude: map["coordinate"]["longitude"],
  );
}

List<PoiCategory> createCategories(List maps) {
  List<PoiCategory> categories = [];
  for (Map map in maps) {
    categories.add(createCategory(map));
  }
  return categories;
}

Geofence createGeofence(Map map) {
  return Geofence(
    id: map["identifier"],
    name: map["name"],
  );
}

List<Geofence> createGeofences(List maps) {
  List<Geofence> geofences = [];
  for (Map map in maps) {
    geofences.add(createGeofence(map));
  }
  return geofences;
}
