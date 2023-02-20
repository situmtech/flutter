##[Unreleased]

### Added
* Added `navigateToPoi(String id, String buildingId)` method. Starts the navigation to a poi in the specified building. This will:
    - Start the positioning if needed
    - Calculate and draw the route from the current user location to the poi
    - Provide the step-by-step instructions to reach the poi