part of situm_flutter_wayfinding;

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
    try {
      SitumRoute situmRoute = await sdk.requestDirections(directionsOptions);
      situmFlutterWYF._setRoute(
        directionsMessage.originId,
        directionsMessage.destinationId,
        situmRoute,
      );
    } on PlatformException catch (e) {
      situmFlutterWYF._setRouteError(e.code);
    } catch (e) {
      situmFlutterWYF._setRouteError(-1);
    }
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
    var navigationOptions = NavigationOptions();
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
    try {
      situmFlutterWYF._setNavigationRoute(
        directionsMessage.originId,
        directionsMessage.destinationId,
        situmRoute,
      );
    } on PlatformException catch (e) {
      situmFlutterWYF._setRouteError(e.code);
    } catch (e) {
      situmFlutterWYF._setRouteError(-1);
    }
  }
}

class NavigationStopMessageHandler implements MessageHandler {
  @override
  void handleMessage(
      SitumFlutterWYF situmFlutterWYF, Map<String, dynamic> payload) {
    var sdk = SitumFlutterSDK();
    sdk.stopNavigation();
  }
}

class PoiSelectedMessageHandler implements MessageHandler {
  @override
  void handleMessage(
      SitumFlutterWYF situmFlutterWYF, Map<String, dynamic> payload) async {
    var poiId = "${payload["id"]}";
    if (situmFlutterWYF._onPoiSelectedCallback != null) {
      var poi = await situmFlutterWYF._fetchPoiFromCurrentBuilding(poiId);
      if (poi != null) {
        situmFlutterWYF._onPoiSelectedCallback
            ?.call(OnPoiSelectedResult(poi: poi));
      }
    }
  }
}
