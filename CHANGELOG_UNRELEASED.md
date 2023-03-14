##[Unreleased]

### Added

- Added `Building`, `Floor`, `Event` and `BuildingInfo` objects.
- Added fields `buildingIdentifier`, `floorIdentifier`, `polygonPoints`, `customFields`, `createdAt` and `updatedAt` to `Geofence` entity.
- Added `fetchBuildings` and `fetchBuildingInfo` functions to plugin.

### Changed

- Unified mapping functions on both iOS and Android.
- Added mapping for `startCustomPoiCreation`, `selectCustomPoi`, `deleteCustomPoi` and `getCustomPoi`.
- New widget to display find my car functionality.
- Updated WYF version to 2.59.0
