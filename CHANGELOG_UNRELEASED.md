## Unreleased

### Changed

* Improved the method use to handle the native LocationStatus from both platforms. Now LocationStatusAdapter will be in charge of sending common LocationStatus between Android & iOS to map-viewer, so now this will be broadly the positioning statuses flow:
    1. **STARTING**. This status will be received after calling requestLocationUpdates(). This status means the positioning is starting.
    2. **CALCULATING**. This status will be sent once when the SDK starts calculating the user's location.
    3. **USER_NOT_IN_BUILDING**. This status will be sent once alongside the last location recieved from native SDKs. The representation of this location inside map-viewer will be a grey-dot.
    4. **STOPPED**. This status will be sent once to map-viewer alognside the last location recieved from native SDKs. This status will stop navigation inside mapviewer while keeping this last location drawed.
