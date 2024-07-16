## Unreleased

### Added

- Added `ForegroundServiceNotificationTapAction` enum with three possible actions:
    * `LAUNCH_APP` (default): launch the app's main activity using the information returned by
      `PackageManager#getLaunchIntentForPackage(String)`.
    * `DO_NOTHING`: do nothing when tapping the Notification.
    * `LAUNCH_SETTINGS`: launch the operating system settings screen for the current app.

### Changed

- ForegroundNotification behaviour changed:
    * Now the notification will launch the app by default on tap.
    * `ForegroundServiceNotificationOptions.showStopAction` is now `true` by default, causing the
      stop button to appear in the Foreground Service Notification.