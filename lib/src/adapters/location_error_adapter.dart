part of '../../sdk.dart';

/// This private class adapts the native errors
/// received from [Android](https://developers.situm.com/sdk_documentation/android/javadoc/latest/es/situm/sdk/location/locationmanager.code) and [iOS](https://developers.situm.com/sdk_documentation/ios/documentation/enums/sitlocationerror#/) and gives back a proccessed hybrid error.
class _LocationErrorAdapter {
  // TODO: The error codes might repeat between domains,
  // so check also the domain when differentiating errors.

  // TODO: Fix BLUETOOTH_DISABLED. Fix native behaviour differences:
  //  - ANDROID: we only send this error once positioning is started. In case we start positioning with this sensor OFF, we would not notify it.
  //  - ANDROID: we only send this error in building mode, global mode not supported.
  //  - ANDROID keeps positioning after this status, iOS stops the positioning.
  //  - Should we stop positioning when useBle=true or a nonCritical error is enough?

  // TODO: Fix LOCATION_DISABLED. Fix native behaviour differences:
  //  - ANDROID: we only send this error before starting positioning.

  Error handleError(arguments) {
    switch (arguments["code"]) {
      case "8001": // MISSING_LOCATION_PERMISSION
      case "8": // kSITLocationErrorLocationDisabled
      case "9": // kSITLocationErrorLocationRestricted
      case "10": // kSITLocationErrorLocationAuthStatusNotDetermined
        arguments["code"] = ErrorCodes.locationPermissionDenied;
        break;
      case "8002": // LOCATION_DISABLED
        arguments["code"] = ErrorCodes.locationDisabled;
        break;
      case "8012": // MISSING_BLUETOOTH_PERMISSION
        arguments["code"] = ErrorCodes.bluetoothPermissionDenied;
        break;
      case "6": // kSITLocationErrorBluetoothisOff
        arguments["code"] = ErrorCodes.bluetoothDisabled;
        // BLUETOOTH_DISABLED is also sent
        // when BLE_DISABLED_BY_USER (Android) status is received, but with type: nonCritical
        break;
      case "14": // iOS kSITLocationErrorBuildingNotCalibrated
      case "8003": // Android
        arguments["code"] = ErrorCodes.buildingNotCalibrated;
        break;
      case "8004":
        arguments["code"] = ErrorCodes.buildingModelDownloadError;
        break;
      case "13": // iOS kSITLocationErrorBuildingModelNotAvaliable
      case "8005": // Android
        arguments["code"] = ErrorCodes.buildingModelProcessingError;
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
