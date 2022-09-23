<p align="center"> <img width="233" src="https://situm.com/wp-content/themes/situm/img/logo-situm.svg" style="margin-bottom:1rem" />
    <h1 align="center">@situm/flutter-wayfinding</h1>
</p>

<p align="center" style="text-align:center">
    Situm Flutter Wayfinding Plugin. Integrate plug&play navigation experience with floorplans, POIs, routes and turn-by-turn directions in no time. with the power of [SITUM](https://www.situm.com/).
</p>

<div align="center" style="text-align:center">
    [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
    ![Flutter](https://img.shields.io/badge/flutter%40lastest-3.3.2-blueviolet)
</div>

## Getting Started

A Flutter plugin package that provides a [Situm Wayfinding](https://situm.com/wayfinding) widget.


### Set up your Situm credentials

1. Copy the contents of `config.dart.example` to a new file `config.dart` and fill your Situm email, API key and building identifier.

NOTE: for iOS to work you will need to replace the values with yours in SITFNativeMapView.m file:
```
Credentials *credentials = [[Credentials alloc] initWithUser:@"place_situm_user_here"
                                                               apiKey:@"place_situm_apikey_here"
                                                     googleMapsApiKey:@"place_googlemaps_apikey_here"];
        [settingsBuilder setCredentialsWithCredentials:credentials];
        [settingsBuilder setBuildingIdWithBuildingId:@"place_building_identifier_here"];
```

### Android

The following steps have already been done for you in the example application of this repository, but we list them as required documentation for a new project:

1. Include the Situm repository in your project level `build.gradle`:
```groovy
allprojects {
    repositories {
        ...
        maven { url "https://repo.situm.es/artifactory/libs-release-local" }
    }
}
```
2. Include the Situm Wayfinding dependency in your app level `build.gradle`. Also add AppCompat:
```groovy
implementation 'androidx.appcompat:appcompat:1.4.1'
implementation ('es.situm:situm-wayfinding-release-0.19.0-flutter-0.1:0.19.0-alpha@aar') {
    transitive = true
}
```
3. Make sure your `MainActivity` extends the provided `FlutterAppCompatActivity`.
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

1. Include the Situm Wayfinding dependency in your ios app directory. We use Cocoapods por this. So create a new Podfile if not already created and update with the following contents:

```
target 'Runner' do
  use_frameworks!
  source 'https://github.com/CocoaPods/Specs.git'
  platform :ios, '10.0'
  pod 'SitumWayfinding', '0.9.0'
end
```

Then run pod install or pod update to bring the dependencies to your project.

2. In order for the wayfinding module to successfully activate positioning you will need to declare the following permissions in your app's Info.plist file:

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

Once included the app will ask the user for the appropiate permissions.

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

For any question or bug report, please send an email to [support@situm.es](mailto:support@situm.es)

