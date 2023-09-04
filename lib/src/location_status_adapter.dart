part of sdk;

/// [LocationStatusAdapter]
/// This class is in charge of handling the native LocationStatus
/// that we are recieving from the native SDKs (Android and iOS),
/// and giving a common status and behaviour between platforms.
class LocationStatusAdapter {
  late bool _isAndroid;
  String? lastStatus;

  LocationStatusAdapter() {
    _isAndroid = Platform.isAndroid;
  }

  String? handleStatus(String status) {
    return _isAndroid ? _handleAndroidStatus(status) : _handleIOSStatus(status);
  }

  // Native Android statuses
  String? _handleAndroidStatus(String status) {
    String? parsedStatus;
    switch (status) {
      case "USER_NOT_IN_BUILDING":
        if (shouldNotifyStatus("USER_NOT_IN_BUILDING")) {
          parsedStatus = "USER_NOT_IN_BUILDING";
          lastStatus = parsedStatus;
        }
        break;
      case "STOPPED":
        parsedStatus = "STOPPED";
        break;
      case "CALCULATING":
        if (shouldNotifyStatus("CALCULATING")) {
          parsedStatus = "CALCULATING";
          lastStatus = parsedStatus;
        }
        break;
      // Ignore these following cases for Android:
      //    case "STARTING":
      //    case "AUTO_ENABLE_BLE_FORBIDDEN":
      //    case "COMPASS_CALIBRATION_NEEDED":
      //    case "PREPARING_POSITIONING_MODEL":
      //    case "STARTING_DOWNLOADING_POSITIONING_MODEL":
      //    case "PROCESSING_POSITIONING_MODEL":
      //    case "STARTING_POSITIONING":
    }

    return parsedStatus;
  }

  // Native IOS statuses
  String? _handleIOSStatus(String status) {
    String? parsedStatus;
    switch (status) {
      case "CALCULATING":
        parsedStatus = "CALCULATING";
        break;
      case "USER_NOT_IN_BUILDING":
        if (shouldNotifyStatus("USER_NOT_IN_BUILDING")) {
          parsedStatus = "USER_NOT_IN_BUILDING";
          lastStatus = parsedStatus;
        }
        break;
      case "STOPPED":
        parsedStatus = "STOPPED";
        break;
      case "STARTING":
        // Ignore iOS STARTING statuses
        break;
      // Ignore these following cases for iOS:
      //  case "COMPASS_CALIBRATION_NEEDED":
    }

    return parsedStatus;
  }

  bool shouldNotifyStatus(String newStatus) {
    return newStatus != lastStatus || lastStatus == null;
  }
}
