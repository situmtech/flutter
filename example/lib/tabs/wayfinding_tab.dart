import 'package:flutter/material.dart';
import 'package:situm_flutter/wayfinding.dart';
import 'package:situm_flutter_example/config.dart';
import 'package:situm_flutter_example/utils/controller_holder.dart';
import 'package:situm_flutter_example/utils/logger.dart';

class WayfindingTab extends StatefulWidget {

  const WayfindingTab({
    super.key,
  });

  @override
  State<WayfindingTab> createState() => _WayfindingTabState();
}

class _WayfindingTabState extends State<WayfindingTab> {
  MapViewController? mapViewController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    MapViewControllerHolder().reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MapView(
      key: const Key("situm_map"),
      configuration: MapViewConfiguration(
        // Your Situm credentials.
        // Copy config.dart.example if you haven't already.
        situmApiKey: situmApiKey,
        // Set your building identifier:
        buildingIdentifier: buildingIdentifier,
        // Your settings profile, if any:
        profile: profile,
        // The viewer domain:
        viewerDomain: viewerDomain,
        apiDomain: apiDomain,
      ),
      // Load callback:
      onLoad: _onLoad,
      // Optional error callback:
      onError: _onError,
    );
  }

  void _onLoad(MapViewController controller) {
    // Use MapViewController to communicate with the map: methods and callbacks
    // are available to perform actions and listen to events (e.g., listen to
    // POI selections, intercept navigation options, navigate to POIs, etc.).
    // You need to wait until the map is properly loaded to do so.
    mapViewController = controller;

    // Utility used to coordinate access to the MapViewController.
    // Actions such as selecting a POI or starting navigation may be triggered
    // from outside the map screen (e.g., from a list or a notification). In
    // these cases, the map must be opened first, and the controller is only
    // available once the MapView finishes loading.
    // MapViewControllerHolder exposes an awaitable ensureMapViewController()
    // that resolves when the controller is ready, using a Dart Completer
    // internally. This allows any part of the app to safely call map functions
    // without needing to manually manage controller initialization timing.
    MapViewControllerHolder().setController(controller);

    //Example on how to automatically launch positioning when opening the map.
    // situmSdk.requestLocationUpdates(LocationRequest(
    //   buildingIdentifier: buildingIdentifier, //"-1"
    //   useDeadReckoning: false,
    // ));

    //Example on how to automatically center the map on the user location when
    // it become available
    //controller.followUser();

    controller.onCarSaved((floorIdentifier, coordinate) {
      Logger.info("Car saved on floor: $floorIdentifier");
    });
    controller.onPoiSelected((poiSelectedResult) {
      Logger.info("Poi SELECTED: ${poiSelectedResult.poi.name}");
    });
    controller.onPoiDeselected((poiDeselectedResult) {
      Logger.info("Poi DESELECTED: ${poiDeselectedResult.poi.name}");
    });
    controller.onNavigationRequestInterceptor((navigationRequest) {
      Logger.info("Navigation interceptor: ${navigationRequest.toMap()}");
      //   navigationRequest.distanceToGoalThreshold = 10.0;
      //   ...
    });

    // widget.onLoad(controller);
  }

  void _onError(MapViewError error) {
    Logger.error("Error ${error.code} loading MapView: ${error.message}");
  }
}
