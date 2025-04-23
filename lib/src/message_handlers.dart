part of '../wayfinding.dart';

abstract class MessageHandler {
  factory MessageHandler(String type) {
    debugPrint("GOT MESSAGE WITH type: $type");
    switch (type) {
      case WV_MESSAGE_MAP_IS_READY:
        return MapIsReadyHandler();
      case WV_MESSAGE_ERROR:
        return MapViewErrorHandler();
      case WV_MESSAGE_DIRECTIONS_REQUESTED:
        return DirectionsMessageHandler();
      case WV_MESSAGE_NAVIGATION_REQUESTED:
        return NavigationMessageHandler();
      case WV_MESSAGE_NAVIGATION_STOP:
        return NavigationStopMessageHandler();
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
    mapViewController._notifyMapIsReady();
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

class DirectionsMessageHandler implements MessageHandler {
  @override
  void handleMessage(
    MapViewController mapViewController,
    Map<String, dynamic> payload,
  ) async {
    var sdk = SitumSdk();
    var directionsMessage = createDirectionsMessage(payload);
    var directionsRequest = createDirectionsRequest(payload);
    // Send DirectionsOptions so it can be intercepted.
    mapViewController._interceptDirectionsRequest(directionsRequest);
    // Populate directionsRequest with information useful for the directions callback:
    populateDirectionsRequest(directionsRequest, directionsMessage);
    // Calculate route and send it to the web-view.
    try {
      SitumRoute situmRoute = await sdk.requestDirections(directionsRequest);
      mapViewController._setRoute(directionsMessage, situmRoute);
    } on PlatformException catch (e) {
      mapViewController._setRouteError(e.code,
          routeIdentifier: directionsMessage.identifier);
    } catch (e) {
      mapViewController._setRouteError(-1,
          routeIdentifier: directionsMessage.identifier);
    }
  }

  void populateDirectionsRequest(
      DirectionsRequest request, DirectionsMessage useful) {
    request.destinationIdentifier = useful.destinationIdentifier;
    request.destinationCategory = useful.destinationCategory;
    request.originIdentifier = useful.originIdentifier;
    request.originCategory = useful.originCategory;
  }
}

class NavigationMessageHandler implements MessageHandler {
  @override
  void handleMessage(
    MapViewController mapViewController,
    Map<String, dynamic> payload,
  ) async {
    mapViewController._usingViewerNavigation = false;
    var sdk = SitumSdk();
    // Calculate route and start navigation. WayfindingController will listen
    // for native callbacks to get up to date with the navigation status, using
    // the internal _methodCallHandler.
    var directionsMessage = createDirectionsMessage(payload);
    var directionsRequest = createDirectionsRequest(payload);
    mapViewController._interceptDirectionsRequest(directionsRequest);
    var navigationRequest =
        createNavigationRequest(payload["navigationRequest"]);
    mapViewController._interceptNavigationRequest(navigationRequest);
    try {
      SitumRoute situmRoute = await sdk.requestNavigation(
        directionsRequest,
        navigationRequest,
      );
      mapViewController._setNavigationRoute(
        directionsMessage.originIdentifier,
        directionsMessage.destinationIdentifier,
        situmRoute,
      );
    } on PlatformException catch (e) {
      mapViewController._setRouteError(e.code);
    } catch (e) {
      mapViewController._setRouteError(-1);
    }
  }
}

class NavigationStopMessageHandler implements MessageHandler {
  @override
  void handleMessage(
      MapViewController mapViewController, Map<String, dynamic> payload) {
    mapViewController._usingViewerNavigation = false;
    var sdk = SitumSdk();
    sdk.stopNavigation();
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
    mapViewController._usingViewerNavigation = true;

    SitumSdk().updateNavigationState(payload);
  }
}
