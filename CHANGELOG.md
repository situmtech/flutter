# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

All non released changes should be in CHANGELOG_UNRELEASED.md file

---
## [0.0.9] - 2023-03-06

### Added
* Added `showPositioningButton` parameter to show or hide the positioning button on Wayfinding. The
  default value is `true`.
* Added `minZoom` and `maxZoom` parameters to limit the underlying map zoom levels.
* Now you can override the remote configuration with an specific building identifier on calls to
  `requestLocationUpdates(LocationListener listener, Map<String, dynamic> locationRequest)`. This is
  possible by setting a `buildingIdentifier` to the `locationRequest` parameter.

### Changed
* Update WYF iOS to [0.18.2](https://situm.com/docs/ios-wyf-changelog/).
* Update WYF Android to [0.26.0](https://situm.com/docs/android-wyf-changelog/#version-0260alpha--march-3-2023).
* Updated plugin so that Wayfinding can react to the positioning even if it was started using
  `SitumFlutterSDK`.
* Changed default values for `useRemoteConfig`, `useDashboardTheme` and `showPoiNames` to `true`.

### Fixed
* Fixed `STOPPED` status not being communicated on calls to `removeUpdates()`.
* Fixed `unload()` method.

## [0.0.8] - 2023-02-20

### Added
* Added `navigateToPoi(String id, String buildingId)` method. Starts the navigation to a poi in the specified building. This will:
    - Start the positioning if needed
    - Calculate and draw the route from the current user location to the poi
    - Provide the step-by-step instructions to reach the poi

## [0.0.7] - 2023-01-30

### Added

- customFields field to Poi object

## [0.0.6] - 2023-01-11

### Changed

- Updated Android WYF to version 0.23.0.
- Updated gradle plugin version to 7.1.3.
- Modified internal mappings to use the new SDK [MapperInterface](https://developers.situm.com/sdk_documentation/android/javadoc/latest/es/situm/sdk/model/mapperinterface).

### Fixed

- Fixed `clearCache` in Android.

## [0.0.5] - 2022-12-27

- Code refactoring
- Updated WYF iOS version to 0.17.1

## [0.0.4] - 2022-12-02

- Update WYF Android version to 0.21.0.
- Now `SitumMapView#loadCallback` is always called after widget's `dispose()`. This change makes `SitumMapView` compatible with `Navigator`.

## [0.0.1] - 2022-09-22
