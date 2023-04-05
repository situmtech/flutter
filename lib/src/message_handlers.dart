part of situm_flutter_wayfinding;

abstract class MessageHandler {
  factory MessageHandler(String type) {
    switch (type) {
      case WV_CHANNEL_NAVIGATION_START:
        return NavigationMessageHandler();
      default:
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
    // TODO: request directions & request navigation.
    // TODO: send response to WV using situmFlutterWYF.
  }
}
