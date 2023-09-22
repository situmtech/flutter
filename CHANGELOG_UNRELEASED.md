## Unreleased

### Added

* New **type** parameter for Error class that indicates whether the error received from **onLocationError()** will stop positioning or not.

### Changed

* Unified some native errors from the Android and iOS SDKs. See new [Error] (https://pub.dev/documentation/situm_flutter/latest/sdk/Error-class.html) class documentation.
* Improved the method use to handle the native LocationStatus from both platforms. Now LocationStatusAdapter will be in charge of sending common LocationStatus between Android & iOS to map-viewer, so now this will be broadly the positioning statuses flow:
    1. **CALCULATING**. This status will be sent once when the SDK starts calculating the user's location.
    2. **USER_NOT_IN_BUILDING**. This status will be sent once alongside the last location recieved from native SDKs. The representation of this location inside map-viewer will be a grey-dot.
    3. **STOPPED**. This status will be sent once to map-viewer alognside the last location recieved from native SDKs. This status will stop navigation inside mapviewer while keeping this last location drawed.
* Refactor setCurrentLocation() parameter from **dynamic** to **Location**.
* Refactor format and default value for MapViewConfiguration.viewerDomain parameter. Now specifying viewerDomain with the "https://" protocol is not needed anymore.
