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
    var directionsMessage = createDirectionsMessage(payload);
    var directionsOptions = directionsMessage.directionsOptions;
    situmFlutterWYF._onDirectionsRequested(directionsOptions);
    var navigationOptions = const NavigationOptions();
    situmFlutterWYF._onNavigationRequested(navigationOptions);
    // TODO: this will overwrite any previously established callbacks!!!
    // Option 1: add private callbacks in SitumFlutterSDK. SDK and WYF libraries
    // must be merged into one library...
    // Option 2: add public "internal" callbacks.
    // Option 3: replicate callbacks in wayfinding library. Only works if WYF
    // has been loaded...
    // Option 4: delete the following lines, let them be implemented by the
    // integrator (code snippet). All the _internal methods must be exposed...
    sdk.onNavigationFinished(() {
      situmFlutterWYF._setNavigationFinished();
    });
    sdk.onNavigationOutOfRoute(() {
      situmFlutterWYF._setNavigationOutOfRoute();
    });
    sdk.onNavigationProgress((progress) {
      situmFlutterWYF._setNavigationProgress(progress);
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
