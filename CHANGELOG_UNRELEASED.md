## Unreleased
### Added
- Added new callback `onNavigationStart` to get notified when navigation starts.
- Also added the callback `onNavigationCancellation` to get notified when a route is cancelled.

### Changed
- Renamed `OnNavigationFinishedCallback` as `OnNavigationDestinationReachedCallback` to
  differentiate it from `OnNavigationCancellationCallback`.