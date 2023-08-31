## Unreleased
### Added
- Added `onPoiDeselected` callback to get notified when the user deselects a POI.
- Added the method `selectPoi(String identifier)` to select the given POI in the map.
- Added the method `navigateToPoi(String identifier, {AccessibilityMode? accessibilityMode}` to
  programmatically start navigation to the given POI, with the (optional) desired route type.
- Added the method `cancelNavigation()` to cancel the current navigation, if any.
- Added a new method `setLanguage(String lang)` to set the UI language based on the given ISO 639-1 
  code.
- Added methods `followUser()` and `unfollowUser()` to keep the map camera centered on the user 
  position (and stop doing so).
### Fixed
- Fixed an issue where the remote config was consistently being overwritten with local
  (default) parameters.