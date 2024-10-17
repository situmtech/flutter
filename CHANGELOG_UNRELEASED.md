## Unreleased

### Added

- New method `requestAutoStop(AutoStopCriteria)` to request the SDK to stop positioning
  automatically under the given criteria.
  By now `AutoStopCriteria` accepts a timeout `consecutiveOutOfBuildingTimeout` that determines the
  seconds elapsed receiving consecutive `StatusNames.userNotInBuilding` after which positioning will
  stop.
  This method only takes effect in Android.
- Also added `removeAutoStop()` to disable any `AutoStopCriteria` previously requested.
  This method only takes effect in Android.
- Added a new class `StatusNames` that contains a reference list of the positioning status received
  in `onLocationStatus(status)`.