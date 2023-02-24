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
      id: map["id"],
      name: map["name"],
      description: map["description"],
      buildingId: map["buildingId"],
      levelId: map["levelId"],
      coordinates: createCoorindates(map["coordinates"]));
}

Coordinates createCoorindates(Map map) {
  return Coordinates(latitude: map["latitude"], longitude: map["longitude"]);
}
