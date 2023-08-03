part of wayfinding;

abstract class MessageHandler {
  factory MessageHandler(String type) {
    debugPrint("GOT MESSAGE WITH type: $type");
    switch (type) {
      case WV_MESSAGE_DIRECTIONS_REQUESTED:
        return DirectionsMessageHandler();
      case WV_MESSAGE_NAVIGATION_REQUESTED:
        return NavigationMessageHandler();
      case WV_MESSAGE_NAVIGATION_STOP:
        return NavigationStopMessageHandler();
      case WV_MESSAGE_CARTOGRAPHY_POI_SELECTED:
        return PoiSelectedMessageHandler();
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

class DirectionsMessageHandler implements MessageHandler {
  @override
  void handleMessage(
    MapViewController mapViewController,
    Map<String, dynamic> payload,
  ) async {
    var sdk = SitumSdk();
    var directionsMessage = createDirectionsMessage(payload);
    var directionsRequest =
        createDirectionsRequest(payload["directionsRequest"]);
    // Send DirectionsOptions so it can be intercepted.
    mapViewController._onDirectionsRequested(directionsRequest);
    // Calculate route and send it to the web-view.
    try {
      SitumRoute situmRoute = await sdk.requestDirections(directionsRequest);
      mapViewController._setRoute(
        directionsMessage.originIdentifier,
        directionsMessage.destinationIdentifier,
        directionsRequest.accessibilityMode?.name,
        situmRoute,
      );
    } on PlatformException catch (e) {
      mapViewController._setRouteError(e.code);
    } catch (e) {
      mapViewController._setRouteError(-1);
    }
  }
}

class NavigationMessageHandler implements MessageHandler {
  @override
  void handleMessage(
    MapViewController mapViewController,
    Map<String, dynamic> payload,
  ) async {
    var sdk = SitumSdk();
    // Calculate route and start navigation. WayfindingController will listen
    // for native callbacks to get up to date with the navigation status, using
    // the internal _methodCallHandler.
    var directionsMessage = createDirectionsMessage(payload);
    var directionsRequest =
        createDirectionsRequest(payload["directionsRequest"]);
    mapViewController._onDirectionsRequested(directionsRequest);
    var navigationRequest =
        createNavigationRequest(payload["navigationRequest"]);
    mapViewController._onNavigationRequested(navigationRequest);
    SitumRoute situmRoute = await sdk.requestNavigation(
      directionsRequest,
      navigationRequest,
    );
    try {
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
    var sdk = SitumSdk();
    sdk.stopNavigation();
  }
}

class PoiSelectedMessageHandler implements MessageHandler {
  @override
  void handleMessage(
      MapViewController mapViewController, Map<String, dynamic> payload) async {
    if (mapViewController._onPoiSelectedCallback != null) {
      var poiId = "${payload["identifier"]}";
      var buildingId = "${payload["buildingIdentifier"]}";
      var sdk = SitumSdk();
      var poi = await sdk.fetchPoiFromBuilding(buildingId, poiId);
      if (poi != null) {
        mapViewController._onPoiSelectedCallback
            ?.call(OnPoiSelectedResult(poi: poi));
      }
    }
  }
}
