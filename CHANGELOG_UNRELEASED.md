## Unreleased
### Changed
* Updated plugin dependencies (and also example dependencies).

### Fixed
* Fixed SDK navigation callbacks being overwritten when using the Wayfinding module.
* Fixed `PlatformWebViewWidget` being instantiated repeatedly, causing inconsistent behaviour in
  different versions of [webview_flutter_android](https://pub.dev/packages/webview_flutter_android).