part of situm_flutter_sdk;

Poi createPoi(Map map) {
  return Poi(
    id: map["id"],
    name: map["name"],
    buildingId: map["buildingId"],
    poiCategory: createCategory(map["poiCategory"]),
    position: createPoint(map["position"]),
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
    name: map["name"],
  );
}

Point createPoint(Map map) {
  return Point(
    buildingId: map["buildingId"],
    floorId: map["floorId"],
    latitude: map["latitude"],
    longitude: map["longitude"],
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
    id: map["id"],
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
