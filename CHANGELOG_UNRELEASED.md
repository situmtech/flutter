## Unreleased

### Changed

* Improved the method use to parse the native LocationStatus. Now LocationStatusAdapter will be in charge of sending common LocationStatus to map-viewer:
    1. **CALCULATING**. This status will be sent once when the SDK starts calculating the user's location. The representation of this location inside map-viewer will be a blue-dot, blue-arrow (in case we also have bearing) or green-dot (global mode).
    2. **USER_NOT_IN_BUILDING**. This status will be sent once alongside the last location recieved from native SDKs. The representation of this location inside map-viewer will be a grey-dot.
    3. **STOPPED**. This status will be sent once to map-viewer alognside the last location recieved from SDK. This status will stop navigation inside mapviewer but also keeping this last location drawed.
* Refactor setCurrentLocation() parameter from **dynamic** to **Location**.
* Refactor format and default value for MapViewConfiguration.viewerDomain parameter. Now specifying viewerDomain with the https:// protocol is not needed anymore.
