<p align="center"> <img width="233" src="https://situm.com/wp-content/themes/situm/img/logo-situm.svg" style="margin-bottom:1rem" />
<h1 align="center">Situm Flutter Wayfinding Example</h1>
</p>

# Overview

This folder contains the necessary source code for an example application using the SitumWayfinding plugin. It also showcases how to implement a Find My Car using the Wayfinding module.

## Getting Started

Starting point for a Flutter Wayfinding application.

### To run this example application:

1. Rename the file `lib/config.dart.example` to `lib/config.dart` and replace the contents of the file with your own data.
2. In Android: add your Google Maps API Key also to the project string resources.
   The awaited identifier is `@string/google_api_key`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="google_api_key">YOUR_GOOGLE_MAPS_API_KEY</string>
    ...
```

3. In iOS: check the project [code signing](https://developer.apple.com/support/code-signing/) before you run the example.
4. Launch the application: (1) from your IDE opening the project folder or (2) from the command line executing `flutter run`.

## Find my car

Within this example we added the widget `FindMyCar` which implements the basic functionality of a Find My Car application using the SitumWayfinding plugin under the hood. This Find My Car is implemeted using [custom points of interest](), which let us save points of interest on any location on the map, as long as this location is inside of the current building's canvas.

This custom POIs will be used later on to pinpont the location of our car.

This new widget uses the following methods:

- [`startCustomPoiCreation`](https://pub.dev/documentation/situm_flutter_wayfinding/latest/situm_flutter_wayfinding/SitumFlutterWayfinding/startCustomPoiCreation.html)
- [`getCustomPoi`](https://pub.dev/documentation/situm_flutter_wayfinding/latest/situm_flutter_wayfinding/SitumFlutterWayfinding/getCustomPoi.html)
- [`selectCustomPoi`](https://pub.dev/documentation/situm_flutter_wayfinding/latest/situm_flutter_wayfinding/SitumFlutterWayfinding/selectCustomPoi.html)

First of all we initialize the widget's state and we try to obtain the custom POI currently stored by using the method `getCustomPoi`. From then on, depending on the current state of the application, one of two Wayfinding API methods are used:

- If no custom POI is saved we call `startCustomPoiCreation` to enter the creation mode and to either select a custom location which will be assignated to the custom POI or cancel the operation. In this example the custom POI is saved with a custom icon that is provided to `startCustomPoiCreation` as an argument.
- If there is a custom location saved, the FAB will call `selectCustomPoi`, which results on the camera focusing on the custom POI and its selection.
