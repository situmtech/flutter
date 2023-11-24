## Unreleased
### Added
* Added `selectedIcon` and `unselectedInco` fields to `PoiCategory`.
* Added new parameters to `LocationRequest`:
  * `useForegroundService` to control whether to start positioning in an Android Foreground Service
    or not.
  * `foregroundServiceNotificationOptions` to customize the notification shown in the system tray
    for the aforementioned Foreground Service.