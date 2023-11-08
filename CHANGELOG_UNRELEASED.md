## Unreleased

### Added

* Added a new parameter `MapViewConfiguration.persistUnderlyingWidget`. When set to true, the
  underlying WebView will persist over MapView disposals. As a consequence, the WebView widget will
  not be reloaded even when the MapView widget is disposed or rebuilt. This can lead to improved
  performance in cases where the WebView's content remains consistent between widget rebuilds.
  However, it also means that the WebView may persist in memory until the entire Flutter application
  is removed from memory.

### Fixed

* Fixed a crash occurred when the plugin is attached/detached repeatedly. 