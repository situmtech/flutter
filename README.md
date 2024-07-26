<p align="center"> <img width="233" src="https://situm.com/wp-content/themes/situm/img/logo-situm.svg" style="margin-bottom:1rem" />
<h1 align="center">@situm/flutter</h1>
</p>

<p align="center" style="text-align:center">

[Situm Wayfinding](https://situm.com/wayfinding) for Flutter. Integrate plug&play navigation experience with floorplans, POIs, routes and turn-by-turn directions in no time. With the power of [Situm](https://www.situm.com/).

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

1. Add the `ACCESS_FINE_LOCATION` permission to your `AndroidManifest.xml` file if you have configured Situm SDK to [use GPS](<https://developers.situm.com/sdk_documentation/android/javadoc/latest/es/situm/sdk/location/locationrequest#useGps()>):

```xml
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

2. Set the `minSdkVersion` to 21 or later on your app's `build.gradle` file.

### iOS

1. Remove the "use_frameworks!" directive in the `Podfile` of your iOS project:

2. Run `pod install` or `pod update` to bring the dependencies to your project.

3. Declare the following permissions in your app's `Info.plist` file to successfully start positioning:

```
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location is required to find out where you are</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Location is required to find out where you are</string>
<key>NSMotionUsageDescription</key>
<string>We use your phone sensors (giroscope, accelerometer and altimeter) to improve location quality</string>
```

4. For offline support you will have to add the underlying web application's domain inside the entry `WKAppBoundDomains` on `Info.plist` as follows:

```
<key>WKAppBoundDomains</key>
<array>
	<string>map-viewer.situm.com</string>
</array>
```

## Migrate from the old [Situm Flutter Wayfinding plugin](https://pub.dev/packages/situm_flutter_wayfinding)

The new Situm Flutter package breaks compatibility with the previous [Situm Flutter Wayfinding plugin](https://pub.dev/packages/situm_flutter_wayfinding).
Integrating the new version is simpler and more straightforward. If you want to migrate your application, follow the steps described in the [Situm documentation](https://situm.com/docs/flutter-wayfinding-migration-guide).

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
