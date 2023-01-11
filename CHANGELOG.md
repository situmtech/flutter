# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

All non released changes should be in CHANGELOG_UNRELEASED.md file

---------
## [0.0.6] - 2023-01-11

### Changed
* Updated Android WYF to version 0.23.0.
* Updated gradle plugin version to 7.1.3.
* Modified internal mappings to use the new SDK [MapperInterface](https://developers.situm.com/sdk_documentation/android/javadoc/latest/es/situm/sdk/model/mapperinterface).

### Fixed
* Fixed `clearCache` in Android.

## [0.0.5] - 2022-12-27
- Code refactoring
- Updated WYF iOS version to 0.17.1

## [0.0.4] - 2022-12-02

- Update WYF Android version to 0.21.0.
- Now `SitumMapView#loadCallback` is always called after widget's `dispose()`. This change makes `SitumMapView` compatible with `Navigator`.


## [0.0.1] - 2022-09-22