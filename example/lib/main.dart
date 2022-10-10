import 'package:flutter/material.dart';
import 'package:situm_flutter_wayfinding/situm_flutter_sdk.dart';
import 'package:situm_flutter_wayfinding/situm_flutter_wayfinding.dart';
import 'package:situm_flutter_wayfinding_example/config.dart';

void main() => runApp(const MyApp());

const _title = "Situm Flutter Wayfinding";
const MY_POI_ID = "YOUR-SITUM-POI-IDENTIFIER";

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
  int _selectedIndex = 0;
  static SitumFlutterSDK? situmSdk;

  final List<Widget> _tabBarWidgets = <Widget>[
    // Home:
    Card(
      child: Column(
        children: [
          const Text(
            'SitumSdk',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    _requestUpdates();
                  },
                  child: const Text('Start')),
              TextButton(
                  onPressed: () {
                    _removeUpdates();
                  },
                  child: const Text('Stop')),
            ],
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    _fetchPois();
                  },
                  child: const Text('Pois')),
              TextButton(
                  onPressed: () {
                    _fetchCategories();
                  },
                  child: const Text('Categories')),
              TextButton(
                  onPressed: () {
                    _prefetch();
                  },
                  child: const Text('Prefetch')),
            ],
          ),
        ],
      ),
    ),
    // The Situm map:
    const SitumMapView(
        key: Key("situm_map"),
        // Your Situm credentials and building, see config.dart.
        // Copy config.dart.example if you haven't already.
        searchViewPlaceholder: "Situm Flutter Wayfinding",
        situmUser: situmUser,
        situmApiKey: situmApiKey,
        buildingIdentifier: buildingIdentifier,
        googleMapsApiKey: googleMapsApiKey,
        useHybridComponents: true,
        showPoiNames: true,
        hasSearchView: true,
        lockCameraToBuilding: true,
        useRemoteConfig: true,
        initialZoom: 15,
        showNavigationIndications: true,
        loadCallback: _onSitumMapLoaded)
  ];

  static void _onSitumMapLoaded(SitumFlutterWayfinding controller) {
    // The Situm map was successfully loaded, use the given controller to
    // call the WYF API methods.
    print("WYF> Situm Map loaded!");
    controller.onPoiSelected((poiSelectedResult) {
      print("WYF> Poi ${poiSelectedResult.poiName} selected!");
    });
    controller.onPoiDeselected((poiDeselectedResult) {
      print("WYF> Poi deselected!");
    });
    //controller.startPositioning();
    //controller.selectPoi(MY_POI_ID, buildingIdentifier);
  }

  @override
  void initState() {
    // SitumSdk for flutter:
    situmSdk = SitumFlutterSDK();
    situmSdk?.init(situmUser, situmApiKey);
    situmSdk?.setConfiguration(ConfigurationOptions(
      useRemoteConfig: true,
    ));
    situmSdk?.onEnterGeofences((geofencesResult) {
      print("SDK> Enter geofences: ${geofencesResult.geofences}.");
    });
    situmSdk?.onExitGeofences((geofencesResult) {
      print("SDK> Exit geofences: ${geofencesResult.geofences}.");
    });
    super.initState();
  }

  static void _requestUpdates() async {
    situmSdk?.requestLocationUpdates(_MyLocationListener(), {});
  }

  static void _removeUpdates() async {
    situmSdk?.removeUpdates();
  }

  static void _prefetch() async {
    var prefetch = await situmSdk?.prefetchPositioningInfo(
      [buildingIdentifier],
      options: PrefetchOptions(
        preloadImages: true,
      ),
    );
    print("SDK RESPONSE: PREFETCH = $prefetch");
  }

  static void _fetchPois() async {
    var pois = await situmSdk?.fetchPoisFromBuilding(buildingIdentifier);
    print("SDK RESPONSE: POIS = $pois");
  }

  static void _fetchCategories() async {
    var categories = await situmSdk?.fetchPoiCategories();
    print("SDK RESPONSE: CATEGORIES = $categories");
  }

  @override
  Widget build(BuildContext context) {
    // The typical app widget with bottom navigation:
    return Scaffold(
      appBar: AppBar(
        title: const Text(_title),
      ),
      body: Center(
        child: _tabBarWidgets.elementAt(_selectedIndex),
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
  @override
  void onError(Error error) {
    print("SDK> ERROR: ${error.message}");
  }

  @override
  void onLocationChanged(OnLocationChangedResult locationChangedResult) {
    print(
        "SDK> Location changed, building ID is: ${locationChangedResult.buildingId}");
  }

  @override
  void onStatusChanged(String status) {
    print("SDK> STATUS: $status");
  }
}
