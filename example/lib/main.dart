import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:situm_flutter/sdk.dart';
import 'package:situm_flutter/wayfinding.dart';

import './config.dart';

ValueNotifier<String> currentOutputNotifier = ValueNotifier<String>('---');

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
  late FlutterTts flutterTts;
  int _selectedIndex = 0;
  List<Poi> pois = [];
  List<Floor> floors = [];
  Poi? poiDropdownValue;
  Floor? floorDropdownValue;
  bool fitCameraToFloor = false;
  Function? mapViewLoadAction;

  MapViewController? mapViewController;

  // Widget to showcase some SDK API functions
  Widget _createHomeTab() {
    // Home:
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
        _poiInteraction(),
        _setCamera(),
        _setFloor(),
        Expanded(
            child: ValueListenableBuilder<String>(
          valueListenable: currentOutputNotifier,
          builder: (context, value, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Text(value),
            );
          },
        ))
      ],
    );
  }

  Card _buttonsGroup(IconData iconData, String title, List<Widget> children) {
    return Card(
      child: Column(children: [
        ExpansionTile(
          shape: const Border(),
          title: _cardTitle(iconData, title),
          children: <Widget>[
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              shrinkWrap: true,
              childAspectRatio: 2.5,
              children: children,
            ),
          ],
        )
      ]),
    );
  }

  Widget _sdkButton(String buttonText, void Function() onPressed) {
    return TextButton(
        onPressed: () {
          onPressed();
        },
        child: Text(buttonText));
  }

  Widget _sdkCheckbox(
      String labelText, bool value, void Function(bool?) onChanged) {
    return Row(
      children: [
        Text(labelText),
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
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

  Card _setCamera() {
    return Card(
      child: ExpansionTile(
        shape: const Border(),
        title: _cardTitle(Icons.video_camera_front_rounded, "Set Camera"),
        children: [
          Row(
            children: <Widget>[
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<Poi>(
                    isExpanded: true,
                    value: poiDropdownValue,
                    elevation: 16,
                    onChanged: (Poi? value) {
                      setState(() {
                        poiDropdownValue = value!;
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
              _sdkButton("Set", (() => _setCameraViewer(poiDropdownValue))),
            ],
          ),
        ],
      ),
    );
  }

  Card _setFloor() {
    return Card(
      child: ExpansionTile(
        shape: const Border(),
        title: _cardTitle(Icons.video_camera_front_rounded, "Set floor"),
        children: [
          Row(
            children: <Widget>[
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<Floor>(
                    isExpanded: true,
                    value: floorDropdownValue,
                    elevation: 16,
                    onChanged: (Floor? value) {
                      setState(() {
                        floorDropdownValue = value!;
                      });
                    },
                    items: floors.map((value) {
                      return DropdownMenuItem<Floor>(
                        value: value,
                        child: Text(value.name),
                      );
                    }).toList(),
                  ),
                ),
              ),
              _sdkButton("Set", (() => _selectFloor(floorDropdownValue))),
              _sdkCheckbox(
                "Fit",
                fitCameraToFloor,
                (bool? newValue) {
                  setState(() {
                    fitCameraToFloor = newValue ?? !fitCameraToFloor;
                  });
                },
              )
            ],
          ),
        ],
      ),
    );
  }

  Card _poiInteraction() {
    return Card(
      child: ExpansionTile(
        shape: const Border(),
        title: _cardTitle(Icons.interests, "POI Interaction"),
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<Poi>(
                    isExpanded: true,
                    value: poiDropdownValue,
                    elevation: 16,
                    onChanged: (Poi? value) {
                      setState(() {
                        poiDropdownValue = value!;
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
              _sdkButton("Select", (() => _selectPoi(poiDropdownValue))),
              _sdkButton("Navigate", (() => _navigateToPoi(poiDropdownValue))),
            ],
          )
        ],
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
          ),
          onLoad: _onLoad,
          onError: (response) => {
                _echo(
                    "Situm> Mapviewer> Error Received>> ${response.toString()}.")
              }),
    ]);
  }

  void printWarning(String text) {
    debugPrint('\x1B[33m$text\x1B[0m');
  }

  void printError(String text) {
    debugPrint('\x1B[31m$text\x1B[0m');
  }

  void _onLoad(MapViewController controller) {
    // Use MapViewController to communicate with the map: methods and callbacks
    // are available to perform actions and listen to events (e.g., listen to
    // POI selections, intercept navigation options, navigate to POIs, etc.).
    // You need to wait until the map is properly loaded to do so.
    mapViewController = controller;

    //Example on how to automatically launch positioning when opening the map.
    // situmSdk.requestLocationUpdates(LocationRequest(
    //   buildingIdentifier: buildingIdentifier, //"-1"
    //   useDeadReckoning: false,
    // ));

    _callMapviewLoadAction();

    //Example on how to automatically center the map on the user location when
    // it become available
    //controller.followUser();

    controller.onPoiSelected((poiSelectedResult) {
      printWarning("WYF> Poi SELECTED: ${poiSelectedResult.poi.name}");
    });
    controller.onPoiDeselected((poiDeselectedResult) {
      printWarning("WYF> Poi DESELECTED: ${poiDeselectedResult.poi.name}");
    });
    controller.onNavigationRequestInterceptor((navigationRequest) {
      printWarning("WYF> Navigation interceptor: ${navigationRequest.toMap()}");
      //   navigationRequest.distanceToGoalThreshold = 10.0;
      //   ...
    });

    // Flutter-Android webview lacks proper support for TTS technology so we
    // fallback to third-party libraries
    controller.onSpeakAloudText((speakaloudTextResult) async {
      _echo("Situm > SDK > Speak aloud: ${speakaloudTextResult.text}");
      if (speakaloudTextResult.lang != null) {
        flutterTts.setLanguage(speakaloudTextResult.lang!);
      }
      if (speakaloudTextResult.rate != null) {
        flutterTts.setSpeechRate(speakaloudTextResult.rate!);
      }
      if (speakaloudTextResult.volume != null) {
        flutterTts.setVolume(speakaloudTextResult.volume!);
      }
      if (speakaloudTextResult.pitch != null) {
        flutterTts.setPitch(speakaloudTextResult.pitch!);
      }

      await flutterTts.speak(speakaloudTextResult.text);
    });
  }

  void _setCameraViewer(Poi? poi) {
    Camera c = Camera();
    c.center = poi?.position.coordinate;
    mapViewController?.setCamera(c);
    setState(() {
      _selectedIndex = 1;
    });
  }

  void _selectFloor(Floor? floor) {
    int floorId = int.tryParse(floor?.identifier ?? "") ?? 0;
    if (floorId != 0) {
      SelectCartographyOptions options = SelectCartographyOptions();
      options.fitCamera = fitCameraToFloor;

      mapViewController?.selectFloor(floorId, options: options);

      setState(() {
        _selectedIndex = 1;
      });
    }
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

  void _callMapviewLoadAction() {
    mapViewLoadAction?.call();
    mapViewLoadAction = null;
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

  void _downloadPois(String buildingIdentifier) async {
    var poiList = await situmSdk.fetchPoisFromBuilding(buildingIdentifier);
    setState(() {
      pois = poiList;
      poiDropdownValue = pois[0];
    });
  }

  void _downloadFloors(String buildingIdentifier) async {
    var info = await situmSdk.fetchBuildingInfo(buildingIdentifier);
    setState(() {
      floors = info.floors;
      floorDropdownValue = floors[0];
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
        Time diff: ${location.timestamp - DateTime.now().millisecondsSinceEpoch}
        B=${location.buildingIdentifier},
        F=${location.floorIdentifier},
        C=${location.coordinate.latitude.toStringAsFixed(5)}, ${location.coordinate.longitude.toStringAsFixed(5)}
      """);
    });
    situmSdk.onLocationStatus((status) {
      _echo("Situm> SDK> STATUS: $status");
    });
    situmSdk.onLocationError((Error error) {
      _echo("Situm> SDK> Error ${error.code}:\n${error.message}");
    });
    // Set up listener for events on geofences
    situmSdk.onEnterGeofences((geofencesResult) {
      _echo("Situm> SDK> Enter geofences: ${geofencesResult.geofences}.");
    });
    situmSdk.onExitGeofences((geofencesResult) {
      _echo("Situm> SDK> Exit geofences: ${geofencesResult.geofences}.");
    });
    _downloadPois(buildingIdentifier);
    _downloadFloors(buildingIdentifier);

    flutterTts = FlutterTts();

    super.initState();
  }

  void _echo(String output) {
    currentOutputNotifier.value = output;
    printWarning(output);
  }

  // SDK auxiliary functions

  void _requestLocationUpdates() async {
    var hasPermissions = await _requestPermissions();
    if (!hasPermissions) {
      _echo("You need to accept permissions to start positioning.");
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
