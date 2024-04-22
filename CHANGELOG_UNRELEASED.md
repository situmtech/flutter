## Unreleased

### Added

- Added a new method `setUserPass(user, pass)` to authenticate yourself into our SDK using user
  and password (instead of an API key).
- Added a new method `logout()` to invalidate user's token and remove it from internal credentials,
  if exist.
- Added the following parameters to the `LocationRequest`
    - useBle and useGps for both Android and iOS.
    - useWifi, just for Android.
- Added methods to enter and exit calibration mode on the `MapView`. These methods are intended for
  internal use only. 