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

Check the [example/README](./example/README.md) file of this repository to create your first Flutter application using Situm Wayfinding.

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

2. In order for the wayfinding module to successfully activate positioning you will need to declare the following permissions in your app's `Info.plist` file:

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
