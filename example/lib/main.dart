import "dart:io";
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:situm_flutter/sdk.dart';
import 'package:situm_flutter/wayfinding.dart';

import './config.dart';

const floorIdentifier = "35594";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Situm Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// PATRAS
// List<double> LATITUDES = [38.29424, 38.29424, 38.29423, 38.29425, 38.29425];
// List<double> LONGITUDES = [21.79592, 21.79629, 21.79657, 21.79689, 21.79716];
// MRMQA
List<double> LATITUDES = [43.01170, 43.01100, 43.01061, 43.01012, 43.00980, 43.00983, 43.00945, 43.00913, 43.00852, 43.00830, 43.00923];
List<double> LONGITUDES = [-8.45287, -8.45305, -8.45311, -8.45321, -8.45279, -8.45217, -8.45294, -8.45287, -8.45258, -8.45341, -8.45133];
// OFICINA CORE
// List<double> LATITUDES = [42.86367, 42.86393, 42.86416];
// List<double> LONGITUDES = [-8.54299, -8.54318, -8.54332];

class _MyHomePageState extends State<MyHomePage> {
  late SitumSdk situmSdk;
  MapViewController? mapViewController;
  bool useExternalLocations = true;
  int index = 0;
  String poiIdentifier = '';

  @override
  void initState() {
    super.initState();
    // Initialize SitumSdk class
    _useSitum();
  }

  void toggleExternalLocation() {
    setState(() {
      useExternalLocations = !useExternalLocations;
      index = 0;

      // Stop positioning and start again
      situmSdk.removeUpdates().then((result) {
        debugPrint("Situm> sdk> Finished positioning");
        debugPrint(
            "Situm> sdk> Starting positioning with useExternalLocations to $useExternalLocations");

        situmSdk.setConfiguration(
            ConfigurationOptions(useExternalLocations: useExternalLocations));
        situmSdk.requestLocationUpdates(
            LocationRequest(buildingIdentifier: buildingIdentifier));

        if (useExternalLocations) {
          situmSdk.addExternalLocation(ExternalLocation(
              coordinate: Coordinate(
                  latitude: LATITUDES[index], longitude: LONGITUDES[index]),
              buildingIdentifier: buildingIdentifier,
              floorIdentifier: floorIdentifier));
        }
      });
    });
  }

  void navigateToPoi() {
    mapViewController?.navigateToPoi(poiIdentifier);
  }

  void updateExternalLocation() {
    if (useExternalLocations) {
      setState(() {
        index = (index + 1) % LATITUDES.length;
        situmSdk.addExternalLocation(ExternalLocation(
            coordinate: Coordinate(
                latitude: LATITUDES[index], longitude: LONGITUDES[index]),
            buildingIdentifier: buildingIdentifier,
            floorIdentifier: floorIdentifier));
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Situm Flutter'),
      ),
      body: Stack(
        children: [
          // Fullscreen MapView
          Positioned.fill(
            child: MapView(
              key: const Key("situm_map"),
              configuration: MapViewConfiguration(
                  situmApiKey: situmApiKey,
                  buildingIdentifier: buildingIdentifier,
                  viewerDomain: viewerDomain,
                  remoteIdentifier: remoteIdentifier,
                  enableDebugging: true),
              onLoad: _onLoad,
            ),
          ),
          // Positioned button overlay
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding:
                  const EdgeInsets.all(16.0), // Add some padding for spacing
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20), // Spacing between elements
                  const SizedBox(height: 8), // Spacing between elements
                  ElevatedButton(
                    onPressed: navigateToPoi,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Navigate To Poi',
                    ),
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Id de POI',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        poiIdentifier = value; // Update state on input change
                      });
                    },
                  ),
                ]
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsets.all(16.0), // Add some padding for spacing
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: updateExternalLocation,
                    child: const Text('Update External Location'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: toggleExternalLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          useExternalLocations ? Colors.green : Colors.red,
                    ),
                    child: Text(
                      useExternalLocations
                          ? 'Use Simulated Location'
                          : 'Use External Location',
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onLoad(MapViewController controller) {
    // Map successfully loaded: now you can register callbacks and perform
    // actions over the map.
    mapViewController = controller;
    debugPrint("Situm> wayfinding> Map successfully loaded.");
    controller.onPoiSelected((poiSelectedResult) {
      debugPrint(
          "Situm> wayfinding> Poi selected: ${poiSelectedResult.poi.name}");
    });
  }

  //Step 4 - Positioning
  void _useSitum() async {
    situmSdk = SitumSdk();
    // Set up your credentials
    situmSdk.init();
    situmSdk.setApiKey(situmApiKey);
    // Set up location callbacks:
    situmSdk.onLocationUpdate((location) {
      debugPrint(
          "Situm> sdk> Location updated: ${location.toMap().toString()}");
    });
    situmSdk.onLocationStatus((status) {
      debugPrint("Situm> sdk> Status: $status");
    });
    situmSdk.onLocationError((error) {
      debugPrint("Situm> sdk> Error: ${error.message}");
    });

    // Positioning
    // Check permissions:
    var hasPermissions = await _requestPermissions();
    if (hasPermissions) {
      // Happy path: start positioning using the default options.
      // The MapView will automatically draw the user location.
      situmSdk
          .setConfiguration(ConfigurationOptions(useExternalLocations: true));
      situmSdk.requestLocationUpdates(
          LocationRequest(buildingIdentifier: buildingIdentifier));
      situmSdk.addExternalLocation(ExternalLocation(
          coordinate: Coordinate(
              latitude: LATITUDES[index], longitude: LONGITUDES[index]),
          buildingIdentifier: buildingIdentifier,
          floorIdentifier: floorIdentifier));
    } else {
      // Handle permissions denial.
      debugPrint("Situm> sdk> Permissions denied!");
    }
  }

  // Requests positioning permissions
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
