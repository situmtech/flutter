## Unreleased
### Added
* `android.useAndroidX=true` in the example project.
  Add it to the `gradle.properties` file of your project if you encounter errors during the Android build.

### Changed
* Updated Android WYF to version 0.23.0.
* Updated gradle plugin version to 7.1.3.
* Modified internal mappings to use the new SDK [MapperInterface](https://developers.situm.com/sdk_documentation/android/javadoc/latest/es/situm/sdk/model/mapperinterface).

### Fixed
* Fixed `clearCache` in Android.