part of '../wayfinding.dart';

abstract class MessageHandler {
  factory MessageHandler(String type) {
    debugPrint("GOT MESSAGE WITH type: $type");
    switch (type) {
      case WV_MESSAGE_MAP_IS_READY:
        return MapIsReadyHandler();
      case WV_MESSAGE_FIND_MY_CAR_SAVED:
        return CarSavedHandler();
      case WV_MESSAGE_ERROR:
        return MapViewErrorHandler();
      case WV_MESSAGE_CARTOGRAPHY_POI_SELECTED:
        return PoiSelectedMessageHandler();
      case WV_MESSAGE_CARTOGRAPHY_POI_DESELECTED:
        return PoiDeselectedMessageHandler();
      case WV_MESSAGE_CALIBRATION_POINT_CLICKED:
        return CalibrationPointClickedMessageHandler();
      case WV_MESSAGE_CALIBRATION_STOPPED:
        return CalibrationStoppedMessageHandler();
      case WV_MESSAGE_UI_SPEAK_ALOUD_TEXT:
        return SpeakAloudTextMessageHandler();
      case WV_VIEWER_NAVIGATION_STARTED:
      case WV_VIEWER_NAVIGATION_UPDATED:
      case WV_VIEWER_NAVIGATION_STOPPED:
        return ViewerNavigationMessageHandler();
      default:
        debugPrint("EmptyMessageHandler handles message of type: $type");
        return EmptyMessageHandler();
    }
  }

  void handleMessage(
    MapViewController mapViewController,
    Map<String, dynamic> payload,
  );
}

class EmptyMessageHandler implements MessageHandler {
  @override
  void handleMessage(
    MapViewController mapViewController,
    Map<String, dynamic> payload,
  ) {
    // Do nothing.
    debugPrint("EmptyMessageHandler handles message from map-viewer: $payload");
  }
}

class MapIsReadyHandler implements MessageHandler {
  @override
  void handleMessage(
      MapViewController mapViewController, Map<String, dynamic> payload) {
    mapViewController._onMapIsReady();
  }
}

class CarSavedHandler implements MessageHandler {
  @override
  void handleMessage(
      MapViewController mapViewController, Map<String, dynamic> payload) {
    mapViewController._onCarSavedCallback?.call(
      payload['floorIdentifier'].toString(),
      createCoordinate(payload['coordinate']),
    );
  }
}

class MapViewErrorHandler implements MessageHandler {
  @override
  void handleMessage(
      MapViewController mapViewController, Map<String, dynamic> payload) {
    String code = payload['code'] ?? '';
    MapViewError? errorPayload;

    switch (code) {
      case 'NO_NETWORK_ERROR':
        errorPayload = MapViewError.noNetworkError();
        break;
      default:
        break;
    }

    if (errorPayload != null) {
      mapViewController._notifyMapViewError(errorPayload);
    }
  }
}

abstract class PoiSelectionMessageHandler implements MessageHandler {
  @override
  void handleMessage(
      MapViewController mapViewController, Map<String, dynamic> payload) async {
    if (mapViewController._onPoiSelectedCallback == null &&
        mapViewController._onPoiDeselectedCallback == null) {
      return;
    }
    var poiId = "${payload["identifier"]}";
    if (poiId == FIND_MY_CAR_POI_ID) {
      return;
    }
    var buildingId = "${payload["buildingIdentifier"]}";
    var sdk = SitumSdk();
    var poi = await sdk.fetchPoiFromBuilding(buildingId, poiId);
    if (poi != null) {
      handlePoiInteraction(mapViewController, poi);
    }
  }

  void handlePoiInteraction(MapViewController mapViewController, Poi poi);
}

class PoiSelectedMessageHandler extends PoiSelectionMessageHandler {
  @override
  void handlePoiInteraction(MapViewController mapViewController, Poi poi) {
    mapViewController._onPoiSelectedCallback
        ?.call(OnPoiSelectedResult(poi: poi));
  }
}

class PoiDeselectedMessageHandler extends PoiSelectionMessageHandler {
  @override
  void handlePoiInteraction(MapViewController mapViewController, Poi poi) {
    mapViewController._onPoiDeselectedCallback
        ?.call(OnPoiDeselectedResult(poi: poi));
  }
}

class SpeakAloudTextMessageHandler implements MessageHandler {
  @override
  void handleMessage(
      MapViewController mapViewController, Map<String, dynamic> payload) async {
    var text = "${payload["text"]}";
    if (payload["text"] == null || payload["text"] == "null") return;

    var lang =
        payload["lang"]?.toString().isNotEmpty == true ? payload["lang"] : null;
    var pitch = payload["pitch"] > 0 ? payload["pitch"].toDouble() : null;
    var volume = payload["volume"] > 0 ? payload['volume'].toDouble() : null;
    var rate = payload["rate"] > 0 ? payload['rate'].toDouble() : null;

    if (mapViewController._onSpeakAloudTextCallback != null) {
      mapViewController._onSpeakAloudTextCallback!.call(OnSpeakAloudTextResult(
          text: text, lang: lang, pitch: pitch, rate: rate, volume: volume));
    } else {
      mapViewController._speakAloudText(OnSpeakAloudTextResult(
          text: text, lang: lang, pitch: pitch, rate: rate, volume: volume));
    }
  }
}

class CalibrationPointClickedMessageHandler implements MessageHandler {
  @override
  void handleMessage(
      MapViewController mapViewController, Map<String, dynamic> payload) {
    var data = createCalibrationPointData(payload);
    mapViewController._onCalibrationPointClickedCallback?.call(data);
  }
}

class CalibrationStoppedMessageHandler implements MessageHandler {
  @override
  void handleMessage(
      MapViewController mapViewController, Map<String, dynamic> payload) {
    var status = createCalibrationFinishedStatus(payload);
    mapViewController._onCalibrationFinishedCallback?.call(status);
  }
}

class ViewerNavigationMessageHandler implements MessageHandler {
  @override
  void handleMessage(
      MapViewController mapViewController, Map<String, dynamic> payload) {
    SitumSdk().updateNavigationState(payload);
  }
}
