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
    var directionsRequest = directionsMessage.directionsRequest;
    situmFlutterWYF._onDirectionsRequested(directionsRequest);
    SitumRoute situmRoute = await sdk.requestDirections(directionsRequest);
    // TODO: implement native requestDirections!!!
    // TODO: map SitumRoute from native response!!!
    situmFlutterWYF.setRoute(situmRoute);
  }
}

class NavigationMessageHandler implements MessageHandler {
  @override
  void handleMessage(
    SitumFlutterWYF situmFlutterWYF,
    Map<String, dynamic> payload,
  ) async {
    var sdk = SitumFlutterSDK();
    debugPrint("Navigation payload: $payload");
    String buildingId = "${payload["buildingID"]}";
    String poiId = "${payload["destination"]}";
    var poi = await sdk.fetchPoiFromBuilding(buildingId, poiId);
    debugPrint("Got POI: ${poi?.toMap()}");
    // TODO: SDK: simplify navigation???
    // TODO: request directions & request navigation.
    // TODO: send response to WV using situmFlutterWYF.
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
