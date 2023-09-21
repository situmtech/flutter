part of wayfinding;

abstract class MessageHandler {
  factory MessageHandler(String type) {
    debugPrint("GOT MESSAGE WITH type: $type");
    switch (type) {
      case WV_MESSAGE_MAP_IS_READY:
        return MapIsReadyHandler();
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
    var sdk = SitumSdk();
    // Calculate route and start navigation. WayfindingController will listen
    // for native callbacks to get up to date with the navigation status, using
    // the internal _methodCallHandler.
    var directionsMessage = createDirectionsMessage(payload);
    var directionsRequest =
        createDirectionsRequest(payload["directionsRequest"]);
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
