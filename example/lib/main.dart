import 'package:flutter/material.dart';
import 'package:flutterWayfindingPlugin/config.dart';
import 'package:situm_flutter_wayfinding/situm_flutter_sdk.dart';
import 'package:situm_flutter_wayfinding/situm_flutter_wayfinding.dart';

void main() => runApp(const MyApp());

const _title = "Situm Flutter Wayfinding";

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: MyTabs(),
    );
  }
}

class MyTabs extends StatefulWidget {
  const MyTabs({super.key});

  @override
  State<MyTabs> createState() => _MyTabsState();
}

class _MyTabsState extends State<MyTabs> {
  late SitumFlutterSDK situmSdk;
  int _selectedIndex = 0;
  String currentOutput = "---";

  SitumFlutterWYF? situmFlutterWYF;

  // Widget to showcase some SDK API functions
  Widget _createHomeTab() {
    // Home:
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'SitumSdk',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          SizedBox(
              height: 225,
              child: GridView.count(
                  crossAxisCount: 4,
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  shrinkWrap: true,
                  childAspectRatio: 1.5,
                  children: [
                    _sdkButton('Start', _requestUpdates),
                    _sdkButton('Global', _requestUpdatesGlobal),
                    _sdkButton('Stop', _removeUpdates),
                    /*
                    _sdkButton('Device Id', _getDeviceId),
                    _sdkButton('Prefetch', _prefetch),
                    _sdkButton('Clear cache', _clearCache),
                    _sdkButton('Pois', _fetchPois),
                    _sdkButton('Categories', _fetchCategories),
                    _sdkButton('Buildings', _fetchBuildings),
                    _sdkButton('Building Info', _fetchBuildingInfo),
                    */
                  ])),
          Expanded(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Text(currentOutput)))
        ],
      ),
    );
  }

  Widget _sdkButton(String buttonText, void Function() onPressed) {
    return TextButton(
        onPressed: () {
          onPressed();
        },
        child: Text(buttonText));
  }

  // Widget that for the Wayfinding module
  Widget _createSitumMapTab() {
    // The Situm map:
    return Stack(children: [
      SitumMapView(
        key: const Key("situm_map"),
        // Your Situm credentials and building, see config.dart.
        // Copy config.dart.example if you haven't already.
        searchViewPlaceholder: "Situm Flutter Wayfinding",
        situmUser: situmUser,
        situmApiKey: situmApiKey,
        buildingIdentifier: buildingIdentifier,
        // Config:
        situmMapUrl: "https://map-viewer-native.situm.com",
        showPoiNames: true,
        hasSearchView: true,
        showNavigationIndications: true,
        enableDebugging: true,
        loadCallback: _onWYFLoaded,
      ),
    ]);
  }

  void _onWYFLoaded(SitumFlutterWYF controller) {
    situmFlutterWYF = controller;
    controller.onPoiSelected((poiSelectedResult) {
      debugPrint("WYF> onPoiSelected: ${poiSelectedResult.poi.name}");
    });
  }

  /*
  * On the state initialization of this widget, we initialize Situm SDK
  */
  @override
  void initState() {
    situmSdk = SitumFlutterSDK();
    // Set up your credentials
    situmSdk.init(situmUser, situmApiKey);
    // Configure SDK
    situmSdk.setConfiguration(ConfigurationOptions(
      useRemoteConfig: true,
    ));
    // Set up location listeners:
    situmSdk.onLocationChange((location) {
      _echo("""SDK> Location changed:
        B=${location.buildingId},
        F=${location.floorId},
        C=${location.coordinate.latitude}, ${location.coordinate.longitude}
      """);
      situmFlutterWYF?.setCurrentLocation(location);
    });
    situmSdk.onStatusChange((status) {
      _echo("SDK> STATUS: $status");
    });
    situmSdk.onError((error) {
      _echo("SDK> Error: ${error.message}");
    });
    // Set up listener for events on geofences
    situmSdk.onEnterGeofences((geofencesResult) {
      _echo("SDK> Enter geofences: ${geofencesResult.geofences}.");
    });
    situmSdk.onExitGeofences((geofencesResult) {
      _echo("SDK> Exit geofences: ${geofencesResult.geofences}.");
    });
    super.initState();
  }

  void _echo(String output) {
    setState(() {
      currentOutput = output;
      debugPrint(currentOutput);
    });
  }

  /*
  * SDK auxiliary functions
  */
  void _requestUpdates() async {
    situmSdk.requestLocationUpdates(LocationRequest(
      buildingIdentifier: buildingIdentifier, //"-1"
      useDeadReckoning: false,
    ));
  }

  void _requestUpdatesGlobal() async {
    situmSdk.requestLocationUpdates(LocationRequest(
      buildingIdentifier: "-1",
      useDeadReckoning: false,
    ));
  }

  void _removeUpdates() async {
    situmSdk.removeUpdates();
  }

  void _clearCache() async {
    _echo("SDK> RESPONSE: CLEAR CACHE...");
    await situmSdk.clearCache();
    _echo("SDK> RESPONSE: CLEAR CACHE = DONE");
  }

  void _prefetch() async {
    _echo("SDK> PREFETCH...");
    var prefetch = await situmSdk.prefetchPositioningInfo(
      [buildingIdentifier],
      options: PrefetchOptions(
        preloadImages: true,
      ),
    );
    _echo("SDK> RESPONSE: PREFETCH = $prefetch");
  }

  void _fetchPois() async {
    _echo("SDK> POIS...");
    var pois = await situmSdk.fetchPoisFromBuilding(buildingIdentifier);
    _echo("SDK> RESPONSE: POIS = \n\n$pois");
  }

  void _fetchCategories() async {
    _echo("SDK> CATEGORIES...");
    var categories = await situmSdk.fetchPoiCategories();
    _echo("SDK> RESPONSE: CATEGORIES = \n\n$categories");
  }

  void _fetchBuildingInfo() async {
    _echo("SDK> BUILDING INFO...");
    var building = await situmSdk.fetchBuildingInfo(buildingIdentifier);
    _echo("SDK> RESPONSE: BUILDING INFO = \n\n$building)");
  }

  void _fetchBuildings() async {
    _echo("SDK> BUILDINGS...");
    var buildings = await situmSdk.fetchBuildings();
    _echo("SDK> RESPONSE: BUILDINGS = \n\n$buildings");
  }

    void _getDeviceId() async {
    _echo("SDK> Device Id...");
    var deviceId = await situmSdk.getDeviceId();
    _echo("SDK> RESPONSE: DEVICEID = \n\n$deviceId");
  }

  /* --- */

  @override
  Widget build(BuildContext context) {
    // The typical app widget with bottom navigation:
    return Scaffold(
      appBar: AppBar(
        title: const Text(_title),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [_createHomeTab(), _createSitumMapTab()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Wayfinding',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
