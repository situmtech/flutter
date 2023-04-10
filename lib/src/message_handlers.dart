part of situm_flutter_wayfinding;

abstract class MessageHandler {
  factory MessageHandler(String type) {
    switch (type) {
      case WV_CHANNEL_NAVIGATION_START:
        return NavigationMessageHandler();
      case WV_CHANNEL_POI_SELECTED:
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

class NavigationMessageHandler implements MessageHandler {
  @override
  void handleMessage(
    SitumFlutterWYF situmFlutterWYF,
    Map<String, dynamic> payload,
  ) async {
    var sdk = SitumFlutterSDK();
    String buildingId = "${payload["buildingID"]}";
    String poiId = "${payload["destination"]}";
    var poi = await sdk.fetchPoiFromBuilding(buildingId, poiId);
    debugPrint("Got POI: ${poi?.toJson()}");
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
    situmFlutterWYF.onPoiSelectedCallback?.call(OnPoiSelectedResult(
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
