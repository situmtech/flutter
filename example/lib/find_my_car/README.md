## Find my car

Within this example we added the widget `FindMyCar` which implements the basic functionality of a Find My Car application using the SitumWayfinding plugin under the hood. This Find My Car is implemeted using [custom points of interest]() -> falta referencia a docs de situm, which let us save points of interest on any location on the map, as long as this location is inside of the current building's canvas.

This custom POIs will be used later on to pinpont the location of our car.

This new widget uses the following methods:

- [`startCustomPoiCreation`](https://pub.dev/documentation/situm_flutter_wayfinding/latest/situm_flutter_wayfinding/SitumFlutterWayfinding/startCustomPoiCreation.html)
- [`getCustomPoi`](https://pub.dev/documentation/situm_flutter_wayfinding/latest/situm_flutter_wayfinding/SitumFlutterWayfinding/getCustomPoi.html)
- [`selectCustomPoi`](https://pub.dev/documentation/situm_flutter_wayfinding/latest/situm_flutter_wayfinding/SitumFlutterWayfinding/selectCustomPoi.html)

First of all we initialize the widget's state and we try to obtain the custom POI currently stored by using the method `getCustomPoi`. From then on, depending on the current state of the application, one of two Wayfinding API methods are used:

- If no custom POI is saved we call `startCustomPoiCreation` to enter the creation mode and to either select a custom location which will be assignated to the custom POI or cancel the operation. In this example the custom POI is saved with a custom icon that is provided to `startCustomPoiCreation` as an argument.

- If there is a custom location saved, the widget will call `selectCustomPoi`, which results on the camera focusing on the custom POI and its selection.
