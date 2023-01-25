part of situm_flutter_sdk;

Poi createPoi(Map map) {
  return Poi(
    id: map["identifier"],
    name: map["poiName"],
    buildingId: map["buildingIdentifier"],
    poiCategory: createCategory(map["poiCategory"]),
    position: createPoint(map["position"]),
    customFields: createCustomFields(map["customFields"]),
  );
}

CustomFields createCustomFields(Map map) {
  return CustomFields(content: Map<String, String>.from(map));
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
