import 'package:flash/flash.dart';
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
    return MaterialApp(
      routes: {
        '/': (context) => HomeScreen(),
        '/map': (context) => MapScreen(10),
        '/otherMap': (context) => MapScreen(50)
      },
      title: _title,
      //home: MyTabs(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_title),
      ),
      body: Card(
        child: Column(
          children: [
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/map');
                    },
                    child: const Text('Go to map!')),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/otherMap');
                    },
                    child: const Text('Go to other map!')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  double sizedBoxHeight;


  MapScreen(
    this.sizedBoxHeight,
  );

  @override
  State<StatefulWidget> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<String> filters = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_title),
      ),
      body: Column(
        children: [
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/');
                },
                child: const Text('Go to Home!'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (filters.isEmpty) {
                      filters.add("1");
                    } else {
                      filters.clear();
                    }
                  });
                },
                child: const Text('Toggle coffee'),
              ),
            ],
          ),
          Container(
            height: widget.sizedBoxHeight,
            color: Colors.black45,
          ),
          Expanded(
            child: SitumMapView(
              key: const Key("situm_map"),
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
              initialZoom: 20,
              showNavigationIndications: true,
              showFloorSelector: true,
              navigationSettings: const NavigationSettings(
                outsideRouteThreshold: 40,
                distanceToGoalThreshold: 8,
              ),
              loadCallback: _onSitumMapLoaded,
              didUpdateCallback: _onSitumMapUpdated,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onSitumMapLoaded(SitumFlutterWayfinding controller) {
    controller.onPoiSelected((poiSelectedResult) {
      _showMessage("Selected ${poiSelectedResult.poiName}!!!");
    });
  }

  void _onSitumMapUpdated(SitumFlutterWayfinding controller) {
    controller.filterPoisBy(filters);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    print("Snack message: $message");
    showFlash(
      context: context,
      duration: const Duration(seconds: 3),
      builder: (_, controller) {
        return Flash(
          controller: controller,
          position: FlashPosition.top,
          behavior: FlashBehavior.fixed,
          child: FlashBar(
            icon: const Icon(
              Icons.info,
              size: 36.0,
              color: Colors.black54,
            ),
            content: Text(message),
          ),
        );
      },
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
  SitumFlutterSDK? situmSdk;
  SitumFlutterWayfinding? wayfinding;
  List<String> filters = [];

  late final List<Widget> _tabBarWidgets;

   void _onSitumMapLoaded(SitumFlutterWayfinding controller) {
    wayfinding = controller;
    // The Situm map was successfully loaded, use the given controller to
    // call the WYF API methods.
    print("WYF> Situm Map loaded!");
    controller.onPoiSelected((poiSelectedResult) {
      print("WYF> Poi ${poiSelectedResult.poiName} selected!");
      _showMessage("Selected ${poiSelectedResult.poiName}!!!");
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

    _buildTabls();
  }

  void _requestUpdates() async {
    situmSdk?.requestLocationUpdates(_MyLocationListener(), {});
  }

  void _removeUpdates() async {
    situmSdk?.removeUpdates();
  }

  void _clearCache() async {
    situmSdk?.clearCache();
  }

  void _prefetch() async {
    var prefetch = await situmSdk?.prefetchPositioningInfo(
      [buildingIdentifier],
      options: PrefetchOptions(
        preloadImages: true,
      ),
    );
    print("SDK RESPONSE: PREFETCH = $prefetch");
  }

  void _fetchPois() async {
    var pois = await situmSdk?.fetchPoisFromBuilding(buildingIdentifier);
    print("SDK RESPONSE: POIS = $pois");
  }

  void _fetchCategories() async {
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
      floatingActionButton: FloatingActionButton(
        onPressed: _onFilterCoffee,
        child: const Icon(Icons.coffee),
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

  void _onTitleTapped() {
    // situmSdk?.selectPoi("126713");
    // situmSdk?.filterPois(); // {"categories" : ["Coffee"]}
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 1) {
        _onTitleTapped();
      }
    });
  }

  void _onFilterCoffee() {
    if (filters.isEmpty) {
      filters.add("1");
    } else {
      filters.clear();
    }
    wayfinding?.filterPoisBy(filters);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    print("Snack message: $message");
    showFlash(
      context: context,
      duration: const Duration(seconds: 3),
      builder: (_, controller) {
        return Flash(
          controller: controller,
          position: FlashPosition.top,
          behavior: FlashBehavior.fixed,
          child: FlashBar(
            icon: const Icon(
              Icons.info,
              size: 36.0,
              color: Colors.black54,
            ),
            content: Text(message),
          ),
        );
      },
    );
  }
  
  void _buildTabls() {
    _tabBarWidgets = <Widget>[
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
              TextButton(
                  onPressed: () {
                    _clearCache();
                  },
                  child: const Text('Clear cache')),
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
    SitumMapView(
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
      showFloorSelector: true,
      navigationSettings: const NavigationSettings(
        outsideRouteThreshold: 40,
        distanceToGoalThreshold: 8,
      ),
      loadCallback: _onSitumMapLoaded,
    )
  ];
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
