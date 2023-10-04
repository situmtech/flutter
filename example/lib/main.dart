import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:situm_flutter/sdk.dart';
import 'package:situm_flutter/wayfinding.dart';

import './config.dart';

void main() => runApp(const MyApp());

const _title = "Situm Flutter";

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
  late SitumSdk situmSdk;
  int _selectedIndex = 0;
  String currentOutput = "---";
  List<Poi> pois = [];
  Poi? dropdownValue;

  // Camera section
  TextEditingController zoomFieldController = TextEditingController(text: "20");
  TextEditingController bearingFieldController =
      TextEditingController(text: "180");
  TextEditingController pitchFieldController =
      TextEditingController(text: "180");
  TextEditingController durationFieldController =
      TextEditingController(text: "1");
  TextEditingController latitudeFieldController =
      TextEditingController(text: "42.86380171196485");
  TextEditingController longitudeFieldController =
      TextEditingController(text: "-8.543060641214014");

  // Cartography section
  TextEditingController levelFieldController = TextEditingController(text: "0");

  Function? mapViewLoadAction;

  MapViewController? mapViewController;

  // Widget to showcase some SDK API functions
  Widget _createHomeTab() {
    // Home:
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
            flex: 3,
            child: SingleChildScrollView(
                child: Column(
              children: [
                _buttonsGroup(Icons.my_location, "Positioning", [
                  _sdkButton('Start', _requestLocationUpdates),
                  _sdkButton('Stop', _removeUpdates),
                ]),
                _buttonsGroup(Icons.cloud_download, "Fetch resources", [
                  _sdkButton('Prefetch', _prefetch),
                  _sdkButton('Clear cache', _clearCache),
                  _sdkButton('Pois', _fetchPois),
                  _sdkButton('Categories', _fetchCategories),
                  _sdkButton('Buildings', _fetchBuildings),
                  _sdkButton('Building Info', _fetchBuildingInfo),
                ]),
                _cartographyInteractions(),
                _cameraInteractions(),
              ],
            ))),
        Flexible(
            flex: 1,
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(30), child: Text(currentOutput)))
      ],
    );
  }

  Card _buttonsGroup(IconData iconData, String title, List<Widget> children) {
    return Card(
      child: Column(
        children: [
          _cardTitle(iconData, title),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            shrinkWrap: true,
            childAspectRatio: 2.5,
            children: children,
          ),
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

  Padding _cardTitle(IconData iconData, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Row(
        children: [
          Icon(iconData, color: Colors.black45),
          const SizedBox(width: 16.0),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Card _cartographyInteractions() {
    return Card(
      child: Column(
        children: [
          _cardTitle(Icons.map, "Cartography Interaction"),
          Row(
            children: <Widget>[
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<Poi>(
                    isExpanded: true,
                    value: dropdownValue,
                    elevation: 16,
                    onChanged: (Poi? value) {
                      setState(() {
                        dropdownValue = value!;
                      });
                    },
                    items: pois.map((value) {
                      return DropdownMenuItem<Poi>(
                        value: value,
                        child: Text(value.name),
                      );
                    }).toList(),
                  ),
                ),
              ),
              _sdkButton("selectPoi", (() => _selectPoi(dropdownValue))),
              _sdkButton(
                  "navigateToPoi", (() => _navigateToPoi(dropdownValue))),
            ],
          ),
          _rowWithPadding(3.0, [
            Expanded(
              child: _sdkButton("selectLevel", () {
                _selectLevel(levelFieldController.text);
              }),
            ),
            _expandedTextField("level", "0", levelFieldController),
          ]),
        ],
      ),
    );
  }

  Card _cameraInteractions() {
    return Card(
      child: Column(children: [
        _cardTitle(Icons.camera_alt, "Camera Interactions"),
        _rowWithPadding(10.0, [
          Expanded(
            child: _sdkButton("setCamera", () {
              _setCamera(
                zoom: zoomFieldController.text,
                bearing: bearingFieldController.text,
                pitch: pitchFieldController.text,
                transitionDuration: durationFieldController.text,
                latitude: latitudeFieldController.text,
                longitude: longitudeFieldController.text,
              );
            }),
          ),
          Expanded(
            child: Column(
              children: [
                _rowWithPadding(3.0, [
                  _expandedTextField("Zoom", "14 - 21", zoomFieldController)
                ]),
                _rowWithPadding(3.0, [
                  _expandedTextField(
                      "Bearing", "0 - 180", bearingFieldController)
                ]),
                _rowWithPadding(3.0, [
                  _expandedTextField("Pitch", "0 - 180", pitchFieldController)
                ]),
                _rowWithPadding(3.0, [
                  _expandedTextField(
                      "Duration", "1 second", durationFieldController)
                ]),
                _rowWithPadding(
                  3.0,
                  [
                    _expandedTextField("Lat", "", latitudeFieldController),
                    _expandedTextField("Lng", "", longitudeFieldController),
                  ],
                )
              ],
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _rowWithPadding(double padding, List<Widget> children) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: children,
      ),
    );
  }

  Widget _expandedTextField(
      String label, String hintText, TextEditingController controller) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true, signed: true),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'^-?\d+\.?\d*')),
        ],
        decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.all(8.0),
            constraints: BoxConstraints.loose(const Size.square(40)),
            hintText: hintText),
      ),
    );
  }

  // Widget that shows the Situm MapView.
  Widget _createSitumMapTab() {
    return Stack(children: [
      MapView(
        key: const Key("situm_map"),
        configuration: MapViewConfiguration(
          // Your Situm credentials.
          // Copy config.dart.example if you haven't already.
          situmApiKey: situmApiKey,
          // Set your building identifier:
          buildingIdentifier: buildingIdentifier,
          // Your remote identifier, if any:
          remoteIdentifier: remoteIdentifier,
          // The viewer domain:
          viewerDomain: viewerDomain,
          enableDebugging: true,
        ),
        onLoad: _onLoad,
      ),
    ]);
  }

  void _onLoad(MapViewController controller) {
    // Use MapViewController to communicate with the map: methods and callbacks
    // are available to perform actions and listen to events (e.g., listen to
    // POI selections, intercept navigation options, navigate to POIs, etc.).
    // You need to wait until the map is properly loaded to do so.
    mapViewController = controller;
    _callMapviewLoadAction();
    controller.onPoiSelected((poiSelectedResult) {
      debugPrint("WYF> Poi SELECTED: ${poiSelectedResult.poi.name}");
    });
    controller.onPoiDeselected((poiDeselectedResult) {
      debugPrint("WYF> Poi DESELECTED: ${poiDeselectedResult.poi.name}");
    });
    controller.onNavigationRequestInterceptor((navigationRequest) {
      debugPrint("WYF> Navigation interceptor: ${navigationRequest.toMap()}");
      //   navigationRequest.distanceToGoalThreshold = 10.0;
      //   ...
    });
  }

  void _callMapviewLoadAction() {
    mapViewLoadAction?.call();
    mapViewLoadAction = null;
  }

  void _selectPoi(Poi? poi) {
    if (poi == null) {
      return;
    }
    setState(() {
      _selectedIndex = 1;
    });
    mapViewLoadAction = () {
      mapViewController?.selectPoi(poi.identifier);
    };
    if (mapViewController != null) {
      _callMapviewLoadAction();
    }
  }

  void _selectLevel(String? level) {
    int newLevel = 0;
    try {
      newLevel = int.tryParse(level ?? "0") ?? 0;
    } catch (e) {
      debugPrint("$e");
    }

    mapViewLoadAction = () {
      mapViewController?.selectLevel(newLevel);
    };

    if (mapViewController != null) {
      _callMapviewLoadAction();
    }
  }

  void _navigateToPoi(Poi? poi) {
    if (poi == null) {
      return;
    }
    setState(() {
      _selectedIndex = 1;
    });
    mapViewLoadAction = () {
      mapViewController?.navigateToPoi(poi.identifier);
    };
    if (mapViewController != null) {
      _callMapviewLoadAction();
    }
  }

  void _setCamera(
      {String? zoom,
      String? bearing,
      String? pitch,
      String? transitionDuration,
      String? latitude,
      String? longitude}) {
    Camera newCamera = Camera();

    try {
      newCamera = Camera(
        zoom: double.tryParse(zoom ?? "0.0"),
        bearing: double.tryParse(bearing ?? "0.0"),
        pitch: double.tryParse(pitch ?? "0.0"),
        transitionDuration: int.tryParse(transitionDuration ?? "0"),
        center: LatLng(
          latitude: double.tryParse(latitude ?? "0.0"),
          longitude: double.tryParse(longitude ?? "0.0"),
        ),
      );
    } catch (e) {
      debugPrint("$e");
    }

    mapViewLoadAction = () {
      mapViewController?.setCamera(newCamera);
    };

    if (mapViewController != null) {
      _callMapviewLoadAction();
    }
  }

  void _downloadPois(String buildingIdentifier) async {
    var poiList = await situmSdk.fetchPoisFromBuilding(buildingIdentifier);
    setState(() {
      pois = poiList;
      dropdownValue = pois[0];
    });
  }

  @override
  void initState() {
    situmSdk = SitumSdk();
    // In case you wan't to use our SDK before initializing our MapView widget,
    // you can set up your credentials with this line of code :
    situmSdk.init();
    // Authenticate with your account and API key.
    // You can find yours at https://dashboard.situm.com/accounts/profile
    situmSdk.setApiKey(situmApiKey);
    // Configure SDK before authenticating.
    situmSdk.setConfiguration(ConfigurationOptions(
        // In case you want to use our remote configuration (https://dashboard.situm.com/settings).
        // With this practical dashboard you can edit your location request and other SDK configurations
        // with ease and no code changes.
        useRemoteConfig: true));
    // Set up location listeners:
    situmSdk.onLocationUpdate((location) {
      _echo("""SDK> Location changed:
        B=${location.buildingIdentifier},
        F=${location.floorIdentifier},
        C=${location.coordinate.latitude.toStringAsFixed(5)}, ${location.coordinate.longitude.toStringAsFixed(5)}
      """);
    });
    situmSdk.onLocationStatus((status) {
      _echo("SDK> STATUS: $status");
    });
    situmSdk.onLocationError((Error error) {
      _echo("SDK> Error ${error.code}:\n${error.message}");
    });
    // Set up listener for events on geofences
    situmSdk.onEnterGeofences((geofencesResult) {
      _echo("Situm> SDK> Enter geofences: ${geofencesResult.geofences}.");
    });
    situmSdk.onExitGeofences((geofencesResult) {
      _echo("Situm> SDK> Exit geofences: ${geofencesResult.geofences}.");
    });
    _downloadPois(buildingIdentifier);
    super.initState();
  }

  void _echo(String output) {
    setState(() {
      currentOutput = output;
      debugPrint(currentOutput);
    });
  }

  // SDK auxiliary functions

  void _requestLocationUpdates() async {
    var hasPermissions = await _requestPermissions();
    if (!hasPermissions) {
      _echo("You need to accept permissions to start positioning.");
      return;
    }
    // Start positioning using the native SDK. You will receive location and
    // status updates (as well as possible errors) in the defined callbacks.
    // You don't need to do anything to draw the user's position on the map; the
    // library handles it all internally for you.
    situmSdk.requestLocationUpdates(LocationRequest(
      buildingIdentifier: buildingIdentifier, //"-1"
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

  // ---

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

  /// Example of a function that request permissions and check the result:
  Future<bool> _requestPermissions() async {
    var permissions = <Permission>[
      Permission.locationWhenInUse,
    ];
    if (Platform.isAndroid) {
      permissions.addAll([
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
      ]);
    }
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    return statuses.values.every((status) => status.isGranted);
  }
}
