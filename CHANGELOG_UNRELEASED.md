## Unreleased

### Added

- This release includes adjustments to reduce known issues between Flutter and native WebViews when
  using TalkBack on Android.

### Changed

- compileSdkVersion is now resolved from flutter.compileSdkVersion when available, with a fallback
  to API 36. This ensures backward compatibility across different build environments, whereas
  previously it was always hardcoded.
- Updated default value of viewerDomain to maps.situm.com at MapViewConfiguration.