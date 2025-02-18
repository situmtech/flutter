## Unreleased

### Added

- Added bearing and accuracy as optional parameters
  in [ExternalLocation](https://pub.dev/documentation/situm_flutter/latest/sdk/ExternalLocation-class.html)
  model.
- Added `ErrorCodes.foregroundServiceNotAllowed` to handle the case where the application tries to
  start the Situm Foreground Service from the background. On Android 12+ (API level 31 and above),
  apps are generally restricted from starting Foreground Services while running in the background,
  except in
  certain [specific exemptions](https://developer.android.com/develop/background-work/services/foreground-services#background-start-restriction-exemptions).
  If you try to start the Situm Foreground Service from the background, the SDK will capture the
  Operating System exception and will throw this error through the `onLocationError` callback.
- Added a new attribute `diagnosticsOptions` to the `LocationRequest` to manage configuration
  options related to remote diagnostic and telemetry.

- added 2 new actions sent to mapview:
  - deselect current poi
  - calculate static directions
