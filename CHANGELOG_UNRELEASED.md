## Unreleased

### Added

- Added the following options to the `LocationRequest`:
    - `OutdoorLocationOptions`: configures the Global Mode options. Now you can
      use `enableOutdoorPositions` to specify if the SDK will notify (or not) outdoor locations
      through your `onLocationUpdate` callback.
    - `realtimeUpdateInterval`: allows to specify whether the geolocations computed should be sent
      to Situm Platform, and if so with which periodicity (time interval).
