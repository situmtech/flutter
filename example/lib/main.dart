import 'package:flutter/material.dart';
import 'package:situm_flutter_wayfinding/situm_flutter_sdk.dart';
import 'package:situm_flutter_wayfinding/situm_flutter_wayfinding.dart';
import 'package:situm_flutter_wayfinding_example/config.dart';

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

  Widget _createHomeTab() {
    // Home:
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 0),
      child: Column(
        children: [
          const Text(
            'SitumSdk',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          SizedBox(
              height: 150,
              child: GridView.count(
                  crossAxisCount: 4,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  shrinkWrap: true,
                  childAspectRatio: 1.5,
                  children: [
                    _sdkButton('Start', _requestUpdates),
                    _sdkButton('Stop', _removeUpdates),
                    _sdkButton('Pois', _fetchPois),
                    _sdkButton('Building Info', _fetchBuildingInfo),
                    _sdkButton('Clear cache', _clearCache),
                    _sdkButton('Prefetch', _prefetch),
                    _sdkButton('Categories', _fetchCategories),
                    _sdkButton('Buildings', _fetchBuildings),
                  ])),
          Expanded(
              child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
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

  Widget _createSitumMapTab() {
    // The Situm map:
    return SitumMapView(
      key: const Key("situm_map"),
      // Your Situm credentials and building, see config.dart.
      // Copy config.dart.example if you haven't already.
      searchViewPlaceholder: "Situm Flutter Wayfinding",
      situmUser: situmUser,
      situmApiKey: situmApiKey,
      buildingIdentifier: buildingIdentifier,
      googleMapsApiKey: googleMapsApiKey,
      useHybridComponents: true,
      //showPoiNames: true,
      hasSearchView: true,
      lockCameraToBuilding: true,
      //useRemoteConfig: true,
      initialZoom: 20,
      minZoom: 19,
      maxZoom: 20,
      showNavigationIndications: true,
      showFloorSelector: true,
      showPositioningButton: true,
      navigationSettings: const NavigationSettings(
        outsideRouteThreshold: 40,
        distanceToGoalThreshold: 8,
      ),
      loadCallback: _onSitumMapLoaded,
    );
  }

  void _onSitumMapLoaded(SitumFlutterWayfinding controller) {
    // The Situm map was successfully loaded, use the given controller to
    // call the WYF API methods.
    print("WYF> Situm Map loaded!");
    controller.onPoiSelected((poiSelectedResult) {
      print("WYF> Poi ${poiSelectedResult.poiName} selected!");
    });
    controller.onPoiDeselected((poiDeselectedResult) {
      print("WYF> Poi deselected!");
    });
    controller.onNavigationStarted((navigation) {
      print("WYF> Nav started, distance = ${navigation.route?.distance}");
    });
    //controller.startPositioning();
    //controller.selectPoi(MY_POI_ID, buildingIdentifier);
  }

  @override
  void initState() {
    // SitumSdk for flutter:
    situmSdk = SitumFlutterSDK();
    situmSdk.init(situmUser, situmApiKey);
    situmSdk.setConfiguration(ConfigurationOptions(
      useRemoteConfig: true,
    ));
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
      print(currentOutput);
    });
  }

  void _requestUpdates() async {
    situmSdk.requestLocationUpdates(
      _MyLocationListener(echoer: _echo),
      {"buildingIdentifier": buildingIdentifier},
    );
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
    final String parsedPois = pois.join('\n\n');
    _echo("SDK> RESPONSE: POIS = \n\n$parsedPois");
  }

  void _fetchCategories() async {
    _echo("SDK> CATEGORIES...");
    var categories = await situmSdk.fetchPoiCategories();
    final String parsedCategories = categories.join('\n');
    _echo("SDK> RESPONSE: CATEGORIES = \n\n$parsedCategories");
  }

  void _fetchBuildingInfo() async {
    _echo("SDK> BUILDING INFO...");
    var building = await situmSdk.fetchBuildingInfo(buildingIdentifier);
    _echo("SDK> RESPONSE: BUILDING INFO = \n\n$building");
  }

  void _fetchBuildings() async {
    _echo("SDK> BUILDINGS...");
    var buildings = await situmSdk.fetchBuildings();
    final String parsedBuildings = buildings.join('\n\n');
    _echo("SDK> RESPONSE: BUILDINGS = \n\n$parsedBuildings");
  }

  @override
  Widget build(BuildContext context) {
    // The typical app widget with bottom navigation:
    return Scaffold(
      appBar: AppBar(
        title: const Text(_title),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _createHomeTab(),
          _createSitumMapTab(),
        ],
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
          )
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

class _MyLocationListener implements LocationListener {
  final Function echoer;

  _MyLocationListener({required this.echoer});

  @override
  void onError(Error error) {
    echoer("SDK> ERROR: ${error.message}");
  }

  @override
  void onLocationChanged(OnLocationChangedResult locationChangedResult) {
    echoer(
        "SDK> Location changed, building ID is: ${locationChangedResult.buildingId}");
  }

  @override
  void onStatusChanged(String status) {
    echoer("SDK> STATUS: $status");
  }
}
