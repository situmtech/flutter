## Unreleased

### Added
* Added new positioning callbacks: `onLocationUpdate()`, `onLocationUpdate()` and `onLocationError()`. These
  callbacks are a replacement for the previous `LocationListener`.
* Added `Location` class. Now the callback `onLocationChange()` will receive coordinates, bearing
  and more info at every location update.
* Added a new method `requestDirections(...)` to calculate a route between two points.
* Added a new method `requestNavigation(...)` to calculate a route and start receiving navigation updates over that route. Also added the method `stopNavigation()`.
* Added navigation callbacks: `onNavigationFinished()`, `onNavigationProgress()` and `onNavigationOutOfRoute()` to receive navigation updates.


### Changed
* Updated the name of both package and libraries to `situm_flutter`, `situm_flutter/wayfinding` and `situm_flutter/sdk`.
* Refactored `requestLocationUpdates()` to receive a single `LocationRequest` parameter.
* Replaced native WYF implementations with the brand new [Situm map-viewer](https://situm.com/docs/map-viewer-quickstart-guide/).
