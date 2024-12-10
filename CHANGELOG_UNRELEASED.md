## Unreleased

### Added

* Added `ErrorCodes.foregroundServiceNotAllowed` to handle the case where the application tries to
  start the Situm Foreground Service from the background. On Android 12+ (API level 31 and above),
  apps are generally restricted from starting Foreground Services while running in the background,
  except in certain [specific exemptions](https://developer.android.com/develop/background-work/services/foreground-services#background-start-restriction-exemptions).
  If you try to start the Situm Foreground Service from the background, the SDK will capture the
  Operating System exception and will throw this error through the `onLocationError` callback.  
