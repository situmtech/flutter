<p align="center"> <img width="233" src="https://situm.com/wp-content/themes/situm/img/logo-situm.svg" style="margin-bottom:1rem" />
<h1 align="center">@situm/flutter-wayfinding</h1>
</p>

<p align="center" style="text-align:center">

[Situm Wayfinding](https://situm.com/wayfinding) for Flutter. Integrate native plug&play navigation experience with floorplans, POIs, routes and turn-by-turn directions in no time. With the power of [Situm](https://www.situm.com/).

</p>

<div align="center" style="text-align:center">

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Pub Version](https://img.shields.io/pub/v/situm_flutter_wayfinding?color=blueviolet)](https://pub.dev/packages/situm_flutter_wayfinding)
[![Flutter](https://img.shields.io/badge/{/}-flutter-blueviolet)](https://flutter.dev/)

</div>

## Getting Started

There is a comprehensive tutorial on how to set-up a new application using this plugin on the Situm [documentation page](https://situm.com/docs/a-basic-flutter-app/).

Below you will find the basic steps to install and configure the plugin on your Flutter project.

### Set up your Situm credentials

Create a new `config.dart` file with your Situm credentials. You can use the contents of `example/config.dart.example` as example.

Follow the [Wayfinding guide](https://situm.com/docs/first-steps-for-wayfinding/) if you haven't set
up a Situm account.

#### Running the example:

Check the [example/README](./example/README.md) file of this repository to create your first Flutter application using Situm Wayfinding.

### Android

The following steps have already been done for you in the example application of this repository, but they are required for a new project:

1. Include the Situm repository in your project level `build.gradle`:

```groovy
allprojects {
    repositories {
        ...
        maven { url "https://repo.situm.es/artifactory/libs-release-local" }
    }
}
```

2. Make sure AppCompat library is in your `build.gradle` dependencies:

```groovy
implementation 'androidx.appcompat:appcompat:1.4.1'
```

3. Make sure your `MainActivity` extends the provided `FlutterAppCompatActivity`.
   This class was duplicated from `FlutterFragmentActivity` to add support to androidx `AppCompatActivity`, which is not currently supported by Flutter.
   The WYF plugin must also be registered manually from your `MainActivity`:

```kotlin
...
import io.flutter.embedding.android.FlutterAppCompatActivity

class MainActivity : FlutterAppCompatActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        ...
        // Register WYF widget:
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                SitumMapFactory.CHANNEL_ID,
                SitumMapFactory(flutterEngine.dartExecutor.binaryMessenger, this)
            )
    }
}
```

4. Review your `styles.xml` file and make sure the application theme extends `Theme.AppCompat.Light.DarkActionBar`.
   Also remove the action bar in your theme:

```xml
<style name="NormalTheme" parent="Theme.AppCompat.Light.DarkActionBar">
    ...
    <item name="windowActionBar">false</item>
    <item name="windowNoTitle">true</item>
</style>
```

5. Add your Google Maps API Key to the `AndroidManifest.xml` file:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="@string/google_api_key" />
```

### iOS

The following steps have already been done for you in the example application of this project, but we list them as required documentation for a new project:

1. After including the dependecy on your project through Run `pod install` or `pod update` to bring the dependencies to your project.

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

## How does this plugin work?

This plugin uses Platform Views for both [Android](https://docs.flutter.dev/development/platform-integration/android/platform-views)
and [iOS](https://docs.flutter.dev/development/platform-integration/ios/platform-views).
WYF's `PlatformView` implementation ensures that **only one instance of WYF** can be loaded at any time.
This is great for performance because the WYF `load()` is an expensive operation. Once WYF is loaded,
it will not be loaded again and instead it will display the active module.
As a consequence, there can only be one `SitumMapView` widget alive at a time.

This doesn't mean that you can only implement one `SitumMapView` widget in your app. It just means
that only one of them can be alive at the same time: ensure that `dispose()` is called over any
`SitumMapView` before initializing another one.

### [Navigator](https://docs.flutter.dev/development/ui/navigation)

Take care to keep your navigation stack clean. The following sequence will crash your application:

1. State A: app displays page A containing WYF.
2. Navigate to page B using `Navigator.push(routeToB)`.
3. Navigate again to page A: `Navigator.push(routeToA)`.
4. Crashes: `the view returned from PlatformView#getView() was already added to a parent view`.

To solve it:

- Fix the previous sequence calling `Navigator.pop()` instead of `Navigator.push(routeToA)`.
- Or ensure that `dispose()` is called over A, for example replacing `push` with
  `Navigator.pushReplacementNamed()`.

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
