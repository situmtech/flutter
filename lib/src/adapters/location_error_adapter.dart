part of sdk;

/// This private class adapts the native errors
/// received from [Android](https://developers.situm.com/sdk_documentation/android/javadoc/latest/es/situm/sdk/location/locationmanager.code) and [iOS](https://developers.situm.com/sdk_documentation/ios/documentation/enums/sitlocationerror#/) and gives back a proccessed hybrid error.
class _LocationErrorAdapter {
  // TODO: The error codes might repeat between domains,
  // so check also the domain when differentiating errors.
  Error handleError(arguments) {
    switch (arguments["code"]) {
      case "8001": // MISSING_LOCATION_PERMISSION
      case "9": // kSITLocationErrorLocationRestricted
      case "10": // kSITLocationErrorLocationAuthStatusNotDetermined
        arguments["code"] = "LOCATION_PERMISSION_DENIED";
        break;
      case "8002": // LOCATION_DISABLED
      case "8": // kSITLocationErrorLocationDisabled
        arguments["code"] = "LOCATION_DISABLED";
        break;
      case "8012": // MISSING_BLUETOOTH_PERMISSION
        arguments["code"] = "BLUETOOTH_PERMISSION_DENIED";
        break;
      case "6": // kSITLocationErrorBluetoothisOff
        arguments["code"] = "BLUETOOTH_DISABLED";
        // BLUETOOTH_DISABLED is also sent
        // when BLE_DISABLED_BY_USER (Android) status is received, but with type: nonCritical
        break;
    }

    Error result = Error(
      code: arguments["code"],
      message: arguments["message"],
      type: ErrorType.critical,
    );

    return result;
  }
}
