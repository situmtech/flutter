<p align="center"> <img width="233" src="https://situm.com/wp-content/themes/situm/img/logo-situm.svg" style="margin-bottom:1rem" />
<h1 align="center">Situm Flutter Wayfinding Example</h1>
</p>

## Getting Started

Starting point for a Flutter Wayfinding application.

### To run this example application:

1. Rename the file `lib/config.dart.example` to `lib/config.dart` and replace the contents of the file with your own data.
2. In Android: add your Google Maps API Key to your string resources.
   The awaited identifier is `@string/google_api_key`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="google_api_key">YOUR_GOOGLE_MAPS_API_KEY</string>
    ...
```
3. Launch the application: (1) from your IDE opening the project folder or (2) from the command line executing `flutter run`.