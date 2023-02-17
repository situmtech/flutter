##[Unreleased]

### Added
* customFields field to Poi object
* Added `showPositioningButton` parameter to show or hide the positioning button of the Wayfinding
  module.
* Added `minZoom` and `maxZoom` parameters to limit the underlying map min and max zoom levels.
* Added `buildingIdentifier` to the `locationRequest` Map parameter of `requestLocationUpdates(LocationListener listener, Map<String, dynamic> locationRequest)`.
  This makes possible to override the remote configuration with an specific building identifier.

### Changed
* Update WYF iOS to 0.18.0.
* Update WYF Android to 0.25.0.
* Updated `SitumFlutterSDKPlugin.kt` so that Wayfinding can react to the positioning even if it was
  started from outside (using `SitumFlutterSDK`).
* Changed default values for `useRemoteConfig`, `useDashboardTheme` and `showPoiNames` to `true`.

### Fixed
* Fixed STOPPED status not being communicated on calls to `removeUpdates()`.
