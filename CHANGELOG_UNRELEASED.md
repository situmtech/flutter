## Unreleased
### Added
- Added new callback `onNavigationStart` to get notified when navigation starts.

### Changed
- Updated `OnNavigationFinishedCallback` to include a `LocationStatus` parameter, so you can
  determine the reason for navigation completion, whether it's cancellation or reaching the
  destination.