## Unreleased
### Added
- Added new callbacks to `SitumSdk`:
  - `onNavigationStart` to receive notifications when navigation starts.
  - `onNavigationCancellation` to get notified when a route is cancelled.
- Added new callback to `MapViewController`:
  - `onDirectionsRequested` for receiving notifications when the user requests a route to a
    destination.

### Changed
- Renamed `onNavigationFinished` as `onNavigationDestinationReached` to
  differentiate it from `onNavigationCancellation`.