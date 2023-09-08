part of sdk;

/// This private class adapts the native errors
/// received from [Android](https://developers.situm.com/sdk_documentation/android/javadoc/latest/es/situm/sdk/location/locationmanager.code) and [iOS](https://developers.situm.com/sdk_documentation/ios/documentation/enums/sitlocationerror#/) and gives back a proccessed hibrid error.
class _LocationErrorAdapter {
  final bool _isAndroid = Platform.isAndroid;

  Error handleError(arguments) {
    ErrorType processedType = ErrorType.critical;
    switch (arguments["code"]) {
      case "8001": // MISSING_LOCATION_PERMISSION
      case "8": // kSITLocationErrorLocationDisabled
      case "9": // kSITLocationErrorLocationRestricted
        arguments["code"] = "LOCATION_PERMISSION_DENIED";
        break;
      case "8002": // LOCATION_DISABLED
        arguments["code"] = "LOCATION_SENSOR_DISABLED";
        break;
      case "8012": // MISSING_BLUETOOTH_PERMISSION
        arguments["code"] = "BLUETOOTH_PERMISSION_DENIED";
        break;
      case "6": // kSITLocationErrorBluetoothisOff
        arguments["code"] = "BLUETOOTH_SENSOR_DISABLED";
        processedType = _isAndroid ? ErrorType.nonCritical : ErrorType.critical;
        // BLUETOOTH_SENSOR_DISABLED is also sent
        // when BLE_DISABLED_BY_USER (Android) status is received, but with type: nonCritical
        break;
    }

    Error result = Error(
      code: arguments["code"],
      message: arguments["message"],
      type: processedType,
    );

    return result;
  }
}
