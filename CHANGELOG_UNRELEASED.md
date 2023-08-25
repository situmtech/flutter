## Unreleased

### Added
* Added **setApiKey(situmApiKey)** method. Use it to authenticate yourself after initializing our SDK with init().
* Added new method **setDashboardURL(url)** in SitumSdk. In order to use correctly this method, you should call respectively init(), setDashboardURL() and then setApiKey(situmApiKey).
* Added MapViewConfiguration.**apiDomain**. When using setDashboardURL(), make sure you introduce the same domain.

### Changed
* Refactor **init()** method, its parameters are now optional. In case you don’t declare its paremeters you won’t authenticate, just initialize our SDK. In future versions parameter usage will be **deprecated**.

* Renamed MapViewConfiguration.**baseUrl** to **viewerDomain**.
    * **WARNING**: This version breaks compatibility with previous versions. Ensure to rename this parameter.
