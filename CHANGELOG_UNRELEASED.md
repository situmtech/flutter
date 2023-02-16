##[Unreleased]

### Added
* customFields field to Poi object
* Added `minZoom` and `maxZoom` parameters to limit the underlying map min and max zoom levels.
* Changed default values for `useRemoteConfig`, `useDashboardTheme` and `showPoiNames` to `true`.

### Changed
* Update WYF iOS to 0.18.0.
* Update WYF Android to 0.25.0.
* Updated `SitumFlutterSDKPlugin.kt` so that Wayfinding can react to the positioning even if it was
  started from outside (using `SitumFlutterSDK`).

### Fixed
* Fixed STOPPED status not being communicated on calls to `removeUpdates()`.
