## [3.16.2] - Unreleased

### Added

- New navigation engine. When [Map Viewer](https://situm.com/docs/built-in-wayfinding-ui/) is present, you can use the navigation of the Map Viewer instead of the SDK navigation. This type of navigation improves routes, indications and performance. To use it you need to set the _navigation-computation library_ to **webAssembly** in your remote configuration file. In case you don't have one, you can set [useViewerNavigation](https://pub.dev/documentation/situm_flutter/latest/wayfinding/MapViewConfiguration/useViewerNavigation.html) to true in your MapViewConfiguration like this:

```dart
    MapView(
        configuration: MapViewConfiguration(
            situmApiKey: situmApiKey,
            buildingIdentifier: buildingIdentifier,
            useViewerNavigation: true,
        ),
        onLoad: () {},
    ),
```
