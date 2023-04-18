part of situm_flutter_wayfinding;

abstract class MessageHandler {
  factory MessageHandler(String type) {
    switch (type) {
      case WV_MESSAGE_DIRECTIONS_REQUEST:
        return DirectionsMessageHandler();
      case WV_MESSAGE_NAVIGATION_START:
        return NavigationMessageHandler();
      case WV_MESSAGE_POI_SELECTED:
        return PoiSelectedMessageHandler();
      default:
        debugPrint("EmptyMessageHandler handles message of type: $type");
        return EmptyMessageHandler();
    }
  }

  void handleMessage(
    SitumFlutterWYF situmFlutterWYF,
    Map<String, dynamic> payload,
  );
}

class EmptyMessageHandler implements MessageHandler {
  @override
  void handleMessage(
    SitumFlutterWYF situmFlutterWYF,
    Map<String, dynamic> payload,
  ) {
    // Do nothing.
    debugPrint("EmptyMessageHandler handles message from map-viewer: $payload");
  }
}

class DirectionsMessageHandler implements MessageHandler {
  @override
  void handleMessage(
    SitumFlutterWYF situmFlutterWYF,
    Map<String, dynamic> payload,
  ) async {
    var sdk = SitumFlutterSDK();
    debugPrint("Got payload: $payload");
    var directionsMessage = createDirectionsMessage(payload);
    var directionsOptions = directionsMessage.directionsOptions;
    // Send DirectionsOptions so it can be intercepted.
    situmFlutterWYF._onDirectionsRequested(directionsOptions);
    // Calculate route and send it to the web-view.
    SitumRoute situmRoute = await sdk.requestDirections(directionsOptions);
    situmFlutterWYF._setRoute(
      directionsMessage.originId,
      directionsMessage.destinationId,
      situmRoute,
    );
  }
}

class NavigationMessageHandler implements MessageHandler {
  @override
  void handleMessage(
    SitumFlutterWYF situmFlutterWYF,
    Map<String, dynamic> payload,
  ) async {
    var sdk = SitumFlutterSDK();
    debugPrint("Got payload: $payload");
    var directionsMessage = createDirectionsMessage(payload);
    var directionsOptions = directionsMessage.directionsOptions;
    situmFlutterWYF._onDirectionsRequested(directionsOptions);
    var navigationOptions = const NavigationOptions();
    situmFlutterWYF._onNavigationRequested(navigationOptions);
    // TODO: this will overwrite any previously established callbacks!!!
    sdk.onNavigationFinished(() {
      situmFlutterWYF._sendMessage("situm.navigation.response", {
        "type": "destination_reached",
      });
    });
    sdk.onNavigationOutOfRoute(() {
      situmFlutterWYF._sendMessage("situm.navigation.response", {
        "type": "out_of_route",
      });
    });
    sdk.onNavigationProgress((progress) {
      // TODO: send route progress back to the map-viewer.
      debugPrint("ROUTE PROGRESS: $progress");
    });
    SitumRoute situmRoute = await sdk.requestNavigation(
      directionsOptions,
      navigationOptions,
    );
    situmFlutterWYF._setNavigationRoute(
      directionsMessage.originId,
      directionsMessage.destinationId,
      situmRoute,
    );
  }
}

class PoiSelectedMessageHandler implements MessageHandler {
  @override
  void handleMessage(
      SitumFlutterWYF situmFlutterWYF, Map<String, dynamic> payload) async {
    var poiId = "${payload["poiId"]}";
    // TODO: missing data!
    situmFlutterWYF._onPoiSelectedCallback?.call(OnPoiSelectedResult(
      buildingId: "",
      buildingName: "",
      floorId: "",
      floorName: "",
      poiId: poiId,
      poiName: "",
      poiInfoHtml: "",
    ));
  }
}
