## Unreleased

### Changed
* Now the native layer subscribe to location updates as soon as the plugin is initialized.
  This does not mean that the positioning is started. This change makes it easier to handle
  background/foreground transitions.

### Fixed
* Fixed an error that produced missing native messages while navigating, after the app transitions
  to background and back again to foreground.