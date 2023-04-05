## Unreleased

### Added
* Added new positioning callbacks: `onLocationChange()`, `onStatusChange()` and `onError()`. These
  callbacks are a replacement for the previous `LocationListener`.
* Added `Location` class. Now the callback `onLocationChange()` will receive coordinates, bearing
  and more info at every location update.

### Changed
* Refactored `requestLocationUpdates()` to receive a single `LocationRequest` parameter.
* Replaced native WYF implementations with the brand new map-viewer.

WIP!!!