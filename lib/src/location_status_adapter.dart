part of sdk;

/// [LocationStatusAdapter]
/// This class is in charge of handling the native LocationStatus
/// that we are recieving from the native SDKs (Android and iOS),
/// and giving a common status and behaviour between platforms.
class _LocationStatusAdapter {
  late bool _isAndroid;
  String? _lastStatus;

  _LocationStatusAdapter() {
    _isAndroid = Platform.isAndroid;
  }

  String? handleStatus(String status) {
    return _isAndroid ? _handleAndroidStatus(status) : _handleIOSStatus(status);
  }

  // Native Android statuses
  String? _handleAndroidStatus(String status) {
    String? parsedStatus;
    switch (status) {
      case "CALCULATING":
      case "USER_NOT_IN_BUILDING":
        if (shouldNotifyStatus(status)) {
          parsedStatus = status;
          _lastStatus = parsedStatus;
        }
        break;
      case "AUTO_ENABLE_BLE_FORBIDDEN":
      case "COMPASS_CALIBRATION_NEEDED":
      case "COMPASS_CALIBRATION_NOT_NEEDED":
      case "WIFI_SCAN_THROTTLED":
      case "TIME_SETTINGS_MANUAL":
      case "LOCATION_DISABLED":
      case "BLE_SENSOR_DISABLED_BY_USER":
      case "BLE_NOT_AVAILABLE":
      case "ALARM_PERMISSIONS_NEEDED_TO_AVOID_DOZE":
      case "GEOFENCES_NOT_AVAILABLE":
      case "GLOBAL_LOCATION_NOT_FOUND":
      case "STOPPED":
        parsedStatus = status;
        break;
      // Ignore these following cases for Android:
      //    case "STARTING":
      //    case "PREPARING_POSITIONING_MODEL":
      //    case "STARTING_DOWNLOADING_POSITIONING_MODEL":
      //    case "RETRY_DOWNLOAD_POSITIONING_MODEL":
      //    case "PROCESSING_POSITIONING_MODEL":
      //    case "STARTING_POSITIONING":
    }

    return parsedStatus;
  }

  // Native IOS statuses
  String? _handleIOSStatus(String status) {
    String? parsedStatus;
    switch (status) {
      case "COMPASS_CALIBRATION_NEEDED":
      case "CALCULATING":
      case "STOPPED":
        parsedStatus = status;
        break;
      case "USER_NOT_IN_BUILDING":
        if (shouldNotifyStatus(status)) {
          parsedStatus = status;
          _lastStatus = parsedStatus;
        }
        break;
      // Ignore these following cases for iOS:
      //  case "STARTING":
    }

    return parsedStatus;
  }

  bool shouldNotifyStatus(String newStatus) {
    return newStatus != _lastStatus || _lastStatus == null;
  }
}
