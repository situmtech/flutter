import "dart:io";
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:situm_flutter/sdk.dart';
import 'package:situm_flutter/wayfinding.dart';

import './config.dart';

const floorIdentifier = "38718";

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
// List<double> LATITUDES = [38.29429, 38.29411, 38.29412];
// List<double> LONGITUDES = [21.79631, 21.79665, 21.79719];
// OFICINA CORE
List<double> LATITUDES = [42.86367, 42.86393, 42.86416];
List<double> LONGITUDES = [-8.54299, -8.54318, -8.54332];

class _MyHomePageState extends State<MyHomePage> {
  late SitumSdk situmSdk;
  MapViewController? mapViewController;
  bool useExternalLocations = true;
  int index = 0;

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
    mapViewController?.navigateToPoi("659123");
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
              child: ElevatedButton(
                onPressed: navigateToPoi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Navigate To Poi',
                ),
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
    //mapViewController!.navigateToPoi("659117");
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
    // situmSdk.onNavigationStart((route) {
    //   debugPrint("Situm> sdk> Navigation started: ${route.rawContent}");
    // });
    // situmSdk.onNavigationProgress((progress) {
    //   debugPrint("Situm> sdk> Navigation updated: ${progress.rawContent}");
    // });
    // situmSdk.onNavigationOutOfRoute(() {
    //   debugPrint("Situm> sdk> Navigation ");
    // });
    // situmSdk.onNavigationDestinationReached((route) {
    //   debugPrint("Situm> sdk> Navigation finished ${route.rawContent}");
    // });
    // situmSdk.onNavigationCancellation(() {
    //   debugPrint("Situm> sdk> Navigation has been cancelled");
    // });
    // situmSdk.fetchBuildingInfo(buildingIdentifier).then((buildingInfo) =>
    //     {debugPrint("Situm> sdk> Building info: ${buildingInfo.geofences}")});
    // situmSdk.onEnterGeofences((geofences) {
    //   debugPrint("Situm> sdk> Entered geofences $geofences");
    // });
    // situmSdk.onExitGeofences((geofences) {
    //   debugPrint("Situm> sdk> Exited geofences $geofences");
    // });

    // Positioning
    // Check permissions:
    var hasPermissions = await _requestPermissions();
    if (hasPermissions) {
      // Happy path: start positioning using the default options.
      // The MapView will automatically draw the user location.
      // situmSdk.requestLocationUpdates(
      //     LocationRequest(buildingIdentifier: buildingIdentifier));
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

//
//     var route = await situmSdk.requestDirections(DirectionsRequest(
//         from: Point(
//             buildingIdentifier: buildingIdentifier,
//             floorIdentifier: floorIdentifier,
//             coordinate: Coordinate(latitude: 42.86396, longitude: -8.54321),
//             cartesianCoordinate:
//                 CartesianCoordinate(x: 127.04024, y: 31.55724)),
//         to: Point(
//             buildingIdentifier: buildingIdentifier,
//             floorIdentifier: "38713",
//             coordinate: Coordinate(latitude: 42.86388, longitude: -8.54298),
//             cartesianCoordinate:
//                 CartesianCoordinate(x: 111.71700, y: 17.81241))));
//
    // debugPrint("Situm > sdk > Route computed ${route.rawContent.toString()}");
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
