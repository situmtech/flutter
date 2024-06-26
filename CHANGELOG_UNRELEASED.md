## Unreleased

### Added

- Added a new method `setUserPass(user, pass)` to authenticate yourself into our SDK using user
  and password (instead of an API key).
- Added a new method `logout()` to invalidate user's token and remove it from internal credentials,
  if exist.
- Added the following parameters to the `LocationRequest`
    - `useBle` and `useGps` for both Android and iOS.
    - `useWifi`, just for Android.
- Added a new method `reload()` at `MapViewController`. A call to this method refreshes
  the `MapView` using the original configuration by reloading the underlying platform web view
  controller.
- Exposed the method `openUrlInDefaultBrowser(url)`. This method opens the given URL in the system's
  default browser. It was previously used internally but has been exposed publicly as it is useful
  in common use-cases such as handling `Poi` description interactions.
- Added a new class `ErrorCodes` that eases the error handling when using
  `situmSdk.onLocationError(e)`.
- Added methods to manage calibration mode on the `MapView`. These methods are intended for
  internal use only.

### Changed

- It is no longer necessary to specify the Situm repository in your `build.gradle` file. This plugin
  has already set it up for you.
