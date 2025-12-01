### Changed

- Updated the selectFloor method so it now receives a String identifier instead of an Int, ensuring
  consistent API design across all methods.

- Refactored the example app to be more granular and easier to understand.
  Added MapViewControllerHolder, a small utility that demonstrates a common use case: triggering
  actions such as selecting a POI or starting navigation from outside the map screen (e.g., from a
  list or a notification). Since the MapViewController is only available once the MapView has fully
  loaded, this helper provides a simple, awaitable ensureMapViewController() method—powered by a
  Dart Completer—that resolves automatically when the controller becomes ready.