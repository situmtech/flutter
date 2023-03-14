##[Unreleased]

### Added
* Added a new method `setDirectionsRequest(DirectionsRequest)` to `SitumFlutterWayfinding` that
  allows customizing the parameters used to calculate routes in WYF.
* Added new types `DirectionsRequest` and `Circle` used with `setDirectionsRequest()` to add
  exclusion circles in the calculation of routes. When requesting directions between two points,
  the new parameter allows you to specify exclusion areas. The route will never contain a path that
  collides with the given areas.
