import 'package:situm_flutter/sdk.dart';

/// [LocationStatusAdapter]
/// This class is in charge of parsing the native LocationStatus that we are recieving form the native SDK (Android and iOS).
class LocationStatusAdapter {
  late bool _isAndroid;

  LocationStatusAdapter(bool isAndroid) {
    _isAndroid = isAndroid;
  }

  LocationStatus parseStatus(String status) {
    return _isAndroid ? _parseAndroidStatus(status) : _parseIOSStatus(status);
  }

  // Native Android statuses
  LocationStatus _parseAndroidStatus(String status) {
    LocationStatus parsedStatus;
    switch (status) {
      case "USER_NOT_IN_BUILDING":
        parsedStatus = LocationStatus.USER_NOT_IN_BUILDING;
        break;
      case "STOPPED":
        parsedStatus = LocationStatus.STOPPED;
        break;
      // defaulf includes the following cases:
      //  case "STARTING":
      //  case "AUTO_ENABLE_BLE_FORBIDDEN":
      //  case "COMPASS_CALIBRATION_NEEDED":
      //  case "PREPARING_POSITIONING_MODEL":
      //  case "STARTING_DOWNLOADING_POSITIONING_MODEL":
      //  case "PROCESSING_POSITIONING_MODEL":
      //  case "STARTING_POSITIONING":
      //  case "CALCULATING":
      default:
        parsedStatus = LocationStatus.CALCULATING;
        break;
    }

    return parsedStatus;
  }

  // Native IOS statuses
  LocationStatus _parseIOSStatus(String status) {
    LocationStatus parsedStatus = LocationStatus.STOPPED;
    switch (status) {
      case "USER_NOT_IN_BUILDING":
        parsedStatus = LocationStatus.USER_NOT_IN_BUILDING;
        break;
      case "STOPPED":
        parsedStatus = LocationStatus.STOPPED;
        break;
      // defaulf includes the following cases:
      //  case "CALCULATING":
      //  case "COMPASS_CALIBRATION_NEEDED":
      //  case "STARTING":
      default:
        parsedStatus = LocationStatus.CALCULATING;
        break;
    }

    return parsedStatus;
  }
}
