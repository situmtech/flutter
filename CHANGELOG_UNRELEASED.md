## Unreleased
### Added
- Added new callbacks to `SitumSdk`:
  - `onNavigationStart` to receive notifications when navigation starts.
  - `onNavigationCancellation` to get notified when a route is cancelled.
  - `onDirectionsRequested` for receiving notifications when a route is requested.

### Changed
- Renamed `onNavigationFinished` as `onNavigationDestinationReached` to
  differentiate it from `onNavigationCancellation`.
