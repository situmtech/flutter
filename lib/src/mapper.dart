part of situm_flutter_wayfinding;

NavigationResult createNavigationResult(arguments) {
  Route route = Route(
    distance: arguments['routeDistance'],
  );
  NavigationResult result = NavigationResult(
    destinationId: arguments['destinationId'],
    route: route,
  );
  return result;
}

CustomPoi createCustomPoi(Map map) {
  return CustomPoi(
      name: map["name"],
      description: map["description"],
      buildingId: map["buildingId"],
      levelId: map["levelId"],
      mapPosition: createMapPosition(map["mapPosition"]));
}

MapPosition createMapPosition(Map map) {
  return MapPosition(latitude: map["latitude"], longitude: map["longitude"]);
}
