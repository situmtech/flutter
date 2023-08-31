## Unreleased

### Changed

* Improved the method use to parse the native LocationStatus. Now LocationStatusAdapter will be in charge of sending common LocationStatus to map-viewer:
    1. **LocationStatus.CALCULATING**. This status goes alognside any location recieved from SDK, either outdoor or indoor. The representation of this location inside map-viewer will be a blue-dot, blue-arrow (in case we also have bearing) or green-dot (global mode).
    2. **LocationStatus.USER_NOT_IN_BUILDING**. This status will be sent alongside the last location recieved from native every second.
    3. **LocationStatus.STOPPED**. This status will be sent once to map-viewer alognside the last location recieved from SDK. This status will stop navigation inside mapviewer but also keeping this last location drawed.
* Refactor setCurrentLocation() parameter from **dynamic** to **Location**.
* Refactor format and default value for MapViewConfiguration.viewerDomain parameter. Now specifying viewerDomain with the https:// protocol is not needed anymore.
