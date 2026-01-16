import 'package:flutter/material.dart';
import 'package:situm_flutter/sdk.dart';
import 'package:situm_flutter/wayfinding.dart';
import 'package:situm_flutter_example/config.dart';
import 'package:situm_flutter_example/utils/controller_holder.dart';
import 'package:situm_flutter_example/utils/logger.dart';
import 'package:situm_flutter_example/utils/widgets.dart';

class HomeTab extends StatefulWidget {
  final Function() onWayfindingTabPressed;

  const HomeTab({
    super.key,
    required this.onWayfindingTabPressed,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  SitumSdk situmSdk = SitumSdk();
  ValueNotifier<String> currentOutputNotifier = ValueNotifier<String>('---');
  ValueNotifier<List<Poi>> pois = ValueNotifier([]);
  ValueNotifier<List<Floor>> floors = ValueNotifier([]);
  bool loadingData = true;
  Poi? poiInteractionsPoi;
  Poi? cameraPoi;
  Floor? selectedFloor;

  @override
  void initState() {
    super.initState();
    _setupSitumSdkCallbacks();
    _fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fetchData() async {
    setState(() {
      loadingData = true;
    });
    var buildingInfo = await situmSdk.fetchBuildingInfo(buildingIdentifier);
    pois.value = buildingInfo.indoorPois;
    floors.value = buildingInfo.floors;
    poiInteractionsPoi =
        cameraPoi = pois.value.isEmpty ? null : pois.value.first;
    selectedFloor = floors.value.isEmpty ? null : floors.value.first;
    setState(() {
      loadingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loadingData) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text("LOADING DATA"),
          ],
        ),
      );
    }
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ButtonsGroup(
          iconData: Icons.my_location,
          title: "Positioning",
          children: [
            SdkButton(text: 'Start', onPressed: _requestLocationUpdates),
            SdkButton(text: 'Stop', onPressed: _removeLocationUpdates),
          ],
        ),

        ButtonsGroup(
          iconData: Icons.cloud_download,
          title: "Fetch resources",
          children: [
            SdkButton(text: 'Prefetch', onPressed: _prefetch),
            SdkButton(text: 'Clear cache', onPressed: _clearCache),
            SdkButton(text: 'Pois', onPressed: _fetchPois),
            SdkButton(text: 'Categories', onPressed: _fetchPoiCategories),
            SdkButton(text: 'Buildings', onPressed: _fetchBuildings),
            SdkButton(text: 'Building Info', onPressed: _fetchBuildingInfo),
          ],
        ),

        ButtonsGroupWithSelector(
          iconData: Icons.interests,
          title: "POI Interactions",
          selectorItems: pois,
          callback: (poi) => poiInteractionsPoi = poi as Poi,
          children: [
            SdkButton(text: 'Select', onPressed: _selectPoi),
            SdkButton(text: 'Navigate', onPressed: _navigateToPoi),
          ],
        ),

        ButtonsGroupWithSelector(
          iconData: Icons.video_camera_front_rounded,
          title: "Set Camera",
          selectorItems: pois,
          callback: (poi) => cameraPoi = poi as Poi,
          children: [
            SdkButton(text: 'Set Camera', onPressed: _setCamera),
          ],
        ),

        ButtonsGroupWithSelector(
          iconData: Icons.layers_rounded,
          title: "Set Floor",
          selectorItems: floors,
          callback: (floor) => selectedFloor = floor as Floor,
          children: [
            SdkButton(text: 'Select', onPressed: _selectFloor),
          ],
        ),

        // Logs:
        SizedBox(
          height: 300,
          child: ValueListenableBuilder<String>(
            valueListenable: currentOutputNotifier,
            builder: (context, value, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Text(value),
              );
            },
          ),
        ),
      ],
    );
  }

  // SDK auxiliary functions

  void _setupSitumSdkCallbacks() {
    // Set up location listeners:
    situmSdk.onLocationUpdate((location) {
      _echo("""Location changed:
        Time diff: ${location.timestamp - DateTime.now().millisecondsSinceEpoch}
        B=${location.buildingIdentifier},
        F=${location.floorIdentifier},
        C=${location.coordinate.latitude.toStringAsFixed(5)}, ${location.coordinate.longitude.toStringAsFixed(5)}
      """);
    });
    situmSdk.onLocationStatus((status) {
      _echo("STATUS: $status");
    });
    situmSdk.onLocationError((Error error) {
      _echo("Error ${error.code}:\n${error.message}");
    });
    // Set up listener for events on geofences
    situmSdk.onEnterGeofences((geofencesResult) {
      _echo("Enter geofences: ${geofencesResult.geofences}.");
    });
    situmSdk.onExitGeofences((geofencesResult) {
      _echo("Exit geofences: ${geofencesResult.geofences}.");
    });
  }

  void _requestLocationUpdates() async {
    // Tell the native SDK to automatically request permissions and manage
    // sensor (BLE/Location) issues.
    // This will save you a significant amount of development work.
    situmSdk.enableUserHelper();

    // Start positioning using the native SDK. You will receive location and
    // status updates (as well as possible errors) in the defined callbacks see
    // _setupSitumSdkCallbacks().
    // You don't need to do anything to draw the user's position on the map; the
    // library handles it all internally for you.
    situmSdk.requestLocationUpdates(LocationRequest(
      buildingIdentifier: buildingIdentifier, //"-1"
      useDeadReckoning: false,
    ));
  }

  void _removeLocationUpdates() async {
    situmSdk.removeUpdates();
  }

  void _clearCache() async {
    _echo("RESPONSE: CLEAR CACHE...");
    await situmSdk.clearCache();
    _echo("RESPONSE: CLEAR CACHE = DONE");
  }

  void _prefetch() async {
    _echo("PREFETCH...");
    var prefetch = await situmSdk.prefetchPositioningInfo(
      [buildingIdentifier],
      options: PrefetchOptions(
        preloadImages: true,
      ),
    );
    _echo("RESPONSE: PREFETCH = $prefetch");
  }

  void _fetchPois() async {
    _echo("POIS...");
    var pois = await situmSdk.fetchPoisFromBuilding(buildingIdentifier);
    _echo("RESPONSE: POIS = \n\n$pois");
  }

  void _fetchPoiCategories() async {
    _echo("CATEGORIES...");
    var categories = await situmSdk.fetchPoiCategories();
    _echo("RESPONSE: CATEGORIES = \n\n$categories");
  }

  void _fetchBuildingInfo() async {
    _echo("BUILDING INFO...");
    var building = await situmSdk.fetchBuildingInfo(buildingIdentifier);
    _echo("RESPONSE: BUILDING INFO = \n\n$building)");
  }

  void _fetchBuildings() async {
    _echo("BUILDINGS...");
    var buildings = await situmSdk.fetchBuildings();
    _echo("RESPONSE: BUILDINGS = \n\n$buildings");
  }

  // --- Map interaction:

  void _selectPoi() async {
    widget.onWayfindingTabPressed();
    if (poiInteractionsPoi == null) return;
    final controller =
        await MapViewControllerHolder().ensureMapViewController();
    controller.selectPoi(poiInteractionsPoi!.identifier);
  }

  void _navigateToPoi() async {
    widget.onWayfindingTabPressed();
    if (poiInteractionsPoi == null) return;
    final controller =
        await MapViewControllerHolder().ensureMapViewController();
    controller.navigateToPoi(poiInteractionsPoi!.identifier);
  }

  void _setCamera() async {
    widget.onWayfindingTabPressed();
    if (cameraPoi == null) return;
    final controller =
        await MapViewControllerHolder().ensureMapViewController();
    controller.setCamera(Camera(
      center: cameraPoi!.position.coordinate,
      zoom: 14,
      bearing: Angle.fromDegrees(0),
    ));
  }

  void _selectFloor() async {
    widget.onWayfindingTabPressed();
    if (selectedFloor == null) return;
    final controller =
        await MapViewControllerHolder().ensureMapViewController();
    controller.selectFloor(selectedFloor!.identifier);
  }

  void _echo(String s) {
    currentOutputNotifier.value = s;
    Logger.info(s);
  }
}
