part of '../../sdk.dart';

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

  /// Process native Android statuses.
  /// This method will do the following to match the iOS's SDK behaviour:
  /// - Ignore CALCULATING and some other verbose statuses when fetching the building model.
  /// - Only send USER_NOT_IN_BUILDING once.
  String? _handleAndroidStatus(String status) {
    // Directly parse these statuses:
    //  - STARTING
    //  - AUTO_ENABLE_BLE_FORBIDDEN
    //  - COMPASS_CALIBRATION_NEEDED
    //  - COMPASS_CALIBRATION_NOT_NEEDED
    //  - WIFI_SCAN_THROTTLED
    //  - TIME_SETTINGS_MANUAL
    //  - LOCATION_DISABLED
    //  - BLE_NOT_AVAILABLE
    //  - ALARM_PERMISSIONS_NEEDED_TO_AVOID_DOZE
    //  - GEOFENCES_NOT_AVAILABLE
    //  - GLOBAL_LOCATION_NOT_FOUND
    //  - STOPPED
    String? result = status;

    switch (status) {
      case StatusNames.userNotInBuilding:
        if (!_shouldNotifyStatus(status)) {
          return null;
        }
        break;
      case "PREPARING_POSITIONING_MODEL":
      case "START_DOWNLOADING_POSITIONING_MODEL":
      case "RETRY_DOWNLOAD_POSITIONING_MODEL":
      case "PROCESSING_POSITIONING_MODEL":
      case "STARTING_POSITIONING":
      case StatusNames.calculating:
        return null;
    }

    _lastStatus = result;

    return result;
  }

  /// Process native IOS statuses.
  /// This method will do the following to match the Android's SDK behaviour:
  /// - Translate CALCULATING from iOS as the STARTING from Android.
  /// - Ignore STARTING from iOS status (Android does not have a similar status).
  /// - Only send USER_NOT_IN_BUILDING once.
  String? _handleIOSStatus(String status) {
    // Directly parse the remaining statuses:
    // - COMPASS_CALIBRATION_NEEDED
    // - STOPPED
    String? result = status;

    switch (status) {
      case StatusNames.calculating:
        result = StatusNames.starting;
        break;
      case StatusNames.userNotInBuilding:
        if (!_shouldNotifyStatus(status)) {
          return null;
        }
        break;
      case StatusNames.starting:
        return null;
    }

    _lastStatus = result;

    return result;
  }

  /// Avoid sending USER_NOT_IN_BUILDING multiple times.
  bool _shouldNotifyStatus(String newStatus) {
    return newStatus != _lastStatus || _lastStatus == null;
  }

  /// When some location is received
  /// the status must not be USER_NOT_IN_BUILDING anymore.
  void resetUserNotInBuilding() {
    _lastStatus = null;
  }
}
