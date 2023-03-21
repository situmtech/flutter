<p align="center"> <img width="233" src="https://situm.com/wp-content/themes/situm/img/logo-situm.svg" style="margin-bottom:1rem" />
<h1 align="center">Situm Flutter Wayfinding Example</h1>
</p>

<div align="center" style="text-align:center">

A sample Flutter application to start learning the power of [Situm's Flutter Wayfinding Plugin](../README.md).

</div>

<div align="center" style="text-align:center">

[![npm](https://img.shields.io/npm/dm/react-native-situm-plugin.svg)](https://www.npmjs.com/package/react-native-situm-plugin) [![npm](https://img.shields.io/npm/v/react-native-situm-plugin.svg)](https://www.npmjs.com/package/react-native-situm-plugin) [![TypeScript](https://badges.frapsoft.com/typescript/code/typescript.svg?v=101)](https://github.com/ellerbrock/typescript-badges/)

</div>

## Getting Started

<div align="center" style="display: flex;">
    <img src="./docs/assets/home_preview.png" alt="home_preview">
    <img src="./docs/assets/wyf_preview.png" alt="wyf_preview">
</div>

## What's in here <a name="whatsinhere"/>

This folder contains the necessary source code for an example application using the **SitumWayfinding plugin**. It also showcases how to implement a Find My Car using the Wayfinding module.

## How to run the app <a name="howtorun"/>

### Step 1: Install the dependencies <a name="dependencies"/>

The first step is to download this repo:

```bash
git clone https://github.com/situmtech/flutter-wayfinding.git
```

And then install the plugin dependencies alongside the `example` app dependecies as follows:

```bash
cd flutter-wayfinding/example
flutter pub get
```

### Step 2: Set your Situm credentials and Google Maps <a name="config"/>

Your credentials should be stored inside a file by the name of `config.dart`, this file also includes a google API key and the building identifier of the building that is to be used inside the Wayfinding module. This example provides you with a template on `lib/config.dart.example`:

```dart
const situmUser = "YOUR-SITUM-USER";
const situmApiKey = "YOUR-SITUM-API-KEY";
const buildingIdentifier = "YOUR-SITUM-BUILDING-IDENTIFIER";
const googleMapsApiKey = "YOUR-GOOGLE-MAPS-API-KEY";
```

To set up the credentials on Flutter simply rename the file `lib/config.dart.example` to `lib/config.dart` and replace the contents of the file with your own data.

#### Android

Additionally on Android, add your Google Maps API Key also to the project string resources.
The awaited identifier is `@string/google_api_key`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="google_api_key">YOUR_GOOGLE_MAPS_API_KEY</string>
    ...
```

### Step 3: Sign your app <a name="signapplication"></a> (iOS only)

In iOS: check the project [code signing](https://developer.apple.com/support/code-signing/) before you run the example.

### Step 4: Run the app <a name="runapplication"></a>

Finally, in order to run the app, from the `example` folder execute the following command which works on both Android and iOS devices:

```bash
flutter run
```

You can also execute it from your IDE:

- On Android: open `example/android/` with Android Studio.
- On iOS: open `example/ios/Runner.xcworkspace` with XCode.

## Documentation <a name="documentation"/>

More information on how to use the official Flutter plugin and the set of APIs, the functions, parameters and results each function accepts and provides can be found in our [API Reference](https://pub.dev/documentation/situm_flutter_wayfinding/latest/).

### Examples

In case you want to learn how to use our plugin, you may want to take a look at our code samples of the basics functionalities:

1. [**Find my Car**]():
