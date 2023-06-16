<p align="center"> <img width="233" src="https://situm.com/wp-content/themes/situm/img/logo-situm.svg" style="margin-bottom:1rem" />
<h1 align="center">@situm/flutter-wayfinding</h1>
</p>

<p align="center" style="text-align:center">

[Situm Wayfinding](https://situm.com/wayfinding) for Flutter. Integrate native plug&play navigation experience with floorplans, POIs, routes and turn-by-turn directions in no time. With the power of [Situm](https://www.situm.com/).

</p>

<div align="center" style="text-align:center">

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Pub Version](https://img.shields.io/pub/v/situm_flutter?color=blueviolet)](https://pub.dev/packages/situm_flutter)
[![Flutter](https://img.shields.io/badge/{/}-flutter-blueviolet)](https://flutter.dev/)

</div>

## Getting Started

There is a comprehensive tutorial on how to set-up a new application using this plugin on the Situm [documentation page](https://situm.com/docs/a-basic-flutter-app/).

Below you will find the basic steps to install and configure the plugin on your Flutter project.
These steps have already been done for you in the example application of this repository, but they are required for other projects.

## Running the example

Check the [example/README](./example/README.md) file of this repository to create your first Flutter application using Situm Flutter.

## Configure the plugin on your Flutter project

### Install the plugin

To add the Situm dependency to your Flutter project, you can use the `flutter pub add` command. To add this dependency to your project, you can use the following command in your terminal:

```
flutter pub add situm_flutter
```

### Set up your Situm credentials

Create a new `config.dart` file with your Situm credentials. You can use the contents of `example/config.dart.example` as example.

Follow the [Wayfinding guide](https://situm.com/docs/first-steps-for-wayfinding/) if you haven't set
up a Situm account.

### Android

Include the Situm repository in your project level `build.gradle`:

```groovy
allprojects {
    repositories {
        ...
        maven { url "https://repo.situm.es/artifactory/libs-release-local" }
    }
}
```

### iOS

1. Run `pod install` or `pod update` to bring the dependencies to your project.

2. To successfully start positioning you will need to declare the following permissions in your app's `Info.plist` file:

```
<key>NSLocationWhenInUseUsageDescription</key>
	<string>Location is required to find out where you are</string>
<key>NSBluetoothPeripheralUsageDescription</key>
	<string>Bluetooth is required to find out where you are</string>
<key>NSLocationAlwaysUsageDescription</key>
	<string>Location is required to find out where you are</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
	<string>Location is required to find out where you are</string>
<key>NSBluetoothAlwaysUsageDescription</key>
	<string>Bluetooth is required to find out where you are</string>
```

Once included the app will ask the user for the appropriate permissions.

## Migrate from the old [Situm Flutter Wayfinding plugin](https://pub.dev/packages/situm_flutter_wayfinding)

The new Situm Flutter package breaks compatibility with the previous [Situm Flutter Wayfinding plugin](https://pub.dev/packages/situm_flutter_wayfinding). Integrating the new version is simpler and more straightforward. If you want to migrate your application, follow the steps bellow:

1. Android:
   - `FlutterAppCompatActivity` has been removed from the repository. Therefore, your `MainActivity` no longer needs to extend this class and in turn it can use the Flutter's own classes.
   - The `androidx AppCompat` dependency is not longer required. You can remove if appropriate.
   - Extending `Theme.AppCompat.Light` is also not necessary now. You can use the default values provided by Flutter or customize them as supported by the platform.
   - Google Maps has been replaced by Mapbox. You no longer need to provide a Google Maps Api Key: remove it from your `AndroidManifest`.
2. Flutter:
   - Both package and libraries has been renamed. Update your imports:
   ```dart
   // From:
   import 'package:situm_flutter_wayfinding/situm_flutter_sdk.dart';
   import 'package:situm_flutter_wayfinding/situm_flutter_wayfinding.dart';
   // To:
   import 'package:situm_flutter/sdk.dart';
   import 'package:situm_flutter/wayfinding.dart';
   ```
   - `SitumFlutterSDK` has been renamed to `SitumSdk`.
   - The positioning callbacks has been refactored to be more idiomatic, so you no longer need to create a custom class implementing `LocationListener` (it has been removed):
   ```dart
   	// Set up location callbacks:
   	situmSdk.onLocationChange((location) {
   		// ...
   	});
   	situmSdk.onStatusChange((status) {
   		// ...
   	});
   	situmSdk.onError((error) {
   		// ...
   	});
   ```
   - `SitumMapView` has been renamed to `MapView`. The controller received in the `loadCallback` was also removed to `MapViewController`.
   - All the parameters of the `MapView` widget has been encapsulated into a single `MapViewConfiguration` object. Also you will notice that the number of parameters has decreased dramatically since the new `MapView` can be configured remotely.
   - The new `MapView` is totally independent from the positioning system. Now your are responsible of telling the widget where the user is, which is pretty straightforward using the location callback:
   ```dart
   situmSdk.onLocationChange((location) {
   	mapViewController?.setCurrentLocation(location);
   	// ...
   });
   ```
   - Permissions: now you are responsible of requesting all the app permissions. Check the [Situm documentation](https://situm.com/docs/sdk-permissions/) for more info.

## Versioning

Please refer to [CHANGELOG.md](./CHANGELOG.md) for a list of notable changes for each version of the plugin.

You can also see the [tags on this repository](./tags).

---

## Submitting contributions

You will need to sign a Contributor License Agreement (CLA) before making a submission. [Learn more here](https://situm.com/contributions/).

---

## License

This project is licensed under the MIT - see the [LICENSE](./LICENSE) file for further details.

---

## More information

More info is available at our [Developers Page](https://situm.com/docs/01-introduction/).

---

## Support information

For any question or bug report, please send an email to [support@situm.com](mailto:support@situm.com)
