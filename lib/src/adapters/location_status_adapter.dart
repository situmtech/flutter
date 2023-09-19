part of sdk;

/// [_LocationStatusAdapter]
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
    // Directly parse the remaining statuses:
    // case "STARTING":
    // case "AUTO_ENABLE_BLE_FORBIDDEN":
    // case "COMPASS_CALIBRATION_NEEDED":
    // case "COMPASS_CALIBRATION_NOT_NEEDED":
    // case "WIFI_SCAN_THROTTLED":
    // case "TIME_SETTINGS_MANUAL":
    // case "LOCATION_DISABLED":
    // case "BLE_SENSOR_DISABLED_BY_USER":
    // case "BLE_NOT_AVAILABLE":
    // case "ALARM_PERMISSIONS_NEEDED_TO_AVOID_DOZE":
    // case "GEOFENCES_NOT_AVAILABLE":
    // case "GLOBAL_LOCATION_NOT_FOUND":
    // case "STOPPED":
    String? result = status;

    switch (status) {
      case "USER_NOT_IN_BUILDING":
        if (!_shouldNotifyStatus(status)) {
          return null;
        }
        break;
      // Ignore these following cases for Android:
      case "PREPARING_POSITIONING_MODEL":
      case "STARTING_DOWNLOADING_POSITIONING_MODEL":
      case "RETRY_DOWNLOAD_POSITIONING_MODEL":
      case "PROCESSING_POSITIONING_MODEL":
      case "STARTING_POSITIONING":
      case "CALCULATING":
        return null;
    }

    _lastStatus = result;

    return result;
  }

  // Native IOS statuses
  String? _handleIOSStatus(String status) {
    // Directly parse the remaining statuses:
    // case "COMPASS_CALIBRATION_NEEDED":
    // case "STOPPED":
    String? result = status;

    switch (status) {
      case "CALCULATING":
        result = "STARTING";
        break;
      case "USER_NOT_IN_BUILDING":
        if (!_shouldNotifyStatus(status)) {
          return null;
        }
        break;
      // Ignore STARTING status (Android does not have a similar status).
      case "STARTING":
        return null;
    }

    _lastStatus = result;

    return result;
  }

  /// Avoid sending USER_NOT_IN_BUILDING multiple times.
  bool _shouldNotifyStatus(String newStatus) {
    return newStatus != _lastStatus || _lastStatus == null;
  }

  // When some location is received
  // the status must not be USER_NOT_IN_BUILDING anymore.
  void resetUserNotInBuilding() {
    _lastStatus = null;
  }
}
