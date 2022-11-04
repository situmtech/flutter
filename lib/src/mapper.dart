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
