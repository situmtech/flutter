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
    var directionsRequest = createDirectionsRequest(payload["directionsRequest"]);
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
    var directionsMessage = createDirectionsMessage(payload);
    var directionsRequest = createDirectionsRequest(payload["directionsRequest"]);
    mapViewController._onDirectionsRequested(directionsRequest);
    var navigationRequest = createNavigationRequest(payload["navigationRequest"]);
    mapViewController._onNavigationRequested(navigationRequest);
    // TODO: this will overwrite any previously established callbacks!!!
    // Option 1: add private callbacks in SitumFlutterSDK. SDK and WYF libraries
    // must be merged into one library...
    // Option 2: add public "internal" callbacks.
    // Option 3: replicate callbacks in wayfinding library. Only works if WYF
    // has been loaded...
    // Option 4: delete the following lines, let them be implemented by the
    // integrator (code snippet). All the _internal methods must be exposed...
    sdk.onNavigationFinished(() {
      mapViewController._setNavigationFinished();
    });
    sdk.onNavigationOutOfRoute(() {
      mapViewController._setNavigationOutOfRoute();
    });
    sdk.onNavigationProgress((progress) {
      mapViewController._setNavigationProgress(progress);
    });
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
