##[Unreleased]

### Added
* Added a new method `setDirectionsSettings(DirectionsSettings)` to `SitumFlutterWayfinding` that
  allows customizing the parameters used to calculate routes in Wayfinding. This method can be
  called at any time and overwrites the widget attribute `directionsSettings`.

### Changed
* `DirectionsSettings` can be used with `setDirectionsSettings()`.
* Now you can add exclusion circles to `DirectionsSettings`. When requesting directions to a given
  location, the new attribute `exclusions` allows you to specify exclusion areas. The route will 
  never contain a path that collides with the given areas.
