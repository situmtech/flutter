import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:situm_flutter/sdk.dart';
import 'package:situm_flutter/wayfinding.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix3, Vector3, Vector4;

import './config.dart';
import 'ar/math.dart';

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
  int _selectedIndex = 0;
  List<Poi> pois = [];
  Poi? dropdownValue;
  Function? mapViewLoadAction;
  MapViewController? mapViewController;

  // More AR Core vars
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  late ARAnchorManager arAnchorManager;

  // AR Core vars
  List<ARNode> poiNodes = [];
  List<ARAnchor> poiAnchors = [];
  List<ARNode> routeNodes = [];
  List<ARAnchor> routeAnchors = [];
  double rotationY = 0;
  double rotationX = 0;
  double rotationZ = 0;

  // Transformation vars
  double dx = 0;
  double dy = 0;
  double angle = 0;
  Matrix3? transformationMatrix = Matrix3.identity();

  // Situm vars
  Location? currentLocation;
  Building? currentBuilding;
  dynamic navigationSegments;

  // Aux vars
  bool debug = false;

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

  Card _poiInteraction() {
    return Card(
      child: Column(
        children: [
          _cardTitle(Icons.interests, "POI Interaction"),
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
              _sdkButton("Select", (() => _selectPoi(dropdownValue))),
              _sdkButton("Navigate", (() => _navigateToPoi(dropdownValue))),
            ],
          ),
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
      ),
    ]);
  }

  List<Widget> _buildDebugTexts() {
    return [
      Text(
          'Location cartesian coords (${currentLocation?.cartesianCoordinate.x}, ${currentLocation?.cartesianCoordinate.y})'),
      Text('Dx ${dx.toStringAsFixed(3)}'),
      Text('Dy ${dy.toStringAsFixed(3)}'),
      Text('Angle ${angle.toStringAsFixed(3)}'),
      Text('Rotation X ${rotationX.toStringAsFixed(3)}'),
      Text('Rotation Y ${rotationY.toStringAsFixed(3)}'),
      Text('Rotation Z ${rotationZ.toStringAsFixed(3)}'),
      Text(
          'Situm Cartesian Rotation Y ${currentLocation?.cartesianBearing?.radians.toStringAsFixed(3)}'),
      Text(
          'Situm Cartesian Rotation Y in [-pi, pi] ${currentLocation?.cartesianBearing?.radiansMinusPiPi.toStringAsFixed(3)}'),
      Text(
          'Situm Rotation Y ${currentLocation?.bearing?.radians.toStringAsFixed(3)}'),
    ];
  }

  // Widget that shows ARView.
  Widget _createARTab() {
    return Stack(children: [
      ARView(
        onARViewCreated: onARViewCreated,
        planeDetectionConfig: PlaneDetectionConfig.horizontal,
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (debug) ..._buildDebugTexts(),
          ElevatedButton(
            onPressed: toggleDebug,
            child: const Text('Debug'),
          ),
          ElevatedButton(
            onPressed: updateScene,
            child: const Text('Update object positions'),
          ),
        ],
      ),
    ]);
  }

  Widget _createSplitScreen() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: _createARTab(),
        ),
        Expanded(
          flex: 1,
          child: _createSitumMapTab(),
        ),
      ],
    );
  }

  void updateScene() async {
    if (currentLocation == null) return;

    // Define transformation matrix based on camera pose and situm pose
    transformationMatrix = await syncWorldView(currentLocation!);
    // testTransformationMatrix();
    if (transformationMatrix == null) return;

    // Add pois
    List<Poi> nearPois =
        filterPoisByDistanceAndFloor(pois, currentLocation!, 10000);
    List<Vector3>? transformedPoiPositions = await generateTransformedPositions(
        nearPois.map((poi) => poi.position).toList(), transformationMatrix!);

    if (transformedPoiPositions != null) {
      addPoisToScene(nearPois, transformedPoiPositions);
    }

    // Add navigation
    if (navigationSegments != null) {
      List<Point> routePoints =
          getRouteByFloor(navigationSegments!, currentLocation!);
      List<Vector3>? transformedRoutePoints =
          await generateTransformedPositions(
              routePoints, transformationMatrix!);

      if (transformedRoutePoints != null) {
        List<Vector3> interpolatedRoutePoints =
            generateInterpolatedPoints(transformedRoutePoints, 5);
        addNavigationRouteToScene(interpolatedRoutePoints);
      }
    }

    List<List<double>> filteredPoisPositions = nearPois
        .map((poi) => [
              poi.position.cartesianCoordinate.x,
              poi.position.cartesianCoordinate.y
            ])
        .toList();

    // printALBA("Diff Angle: $angle");
    // printALBA("Dx: $dx");
    // printALBA("Dy: $dy");
    // printALBA("Current position: ${[
    //   currentLocation?.cartesianCoordinate.x,
    //   currentLocation?.cartesianCoordinate.y
    // ]}");
    printALBA("Camera bearing $rotationY");
    // printALBA("Location bearing ${currentLocation?.bearing?.radians}");
    printALBA(
        "Location cartesian bearing ${currentLocation?.cartesianBearing?.radians}");
    printALBA(
        "Location cartesian bearing in [-pi, pi] ${currentLocation?.cartesianBearing?.radiansMinusPiPi}");
    // printALBA("Building rotation ${currentBuilding?.rotation}");
    // printALBA("Filtered pois: $filteredPoisPositions");
    // printALBA("Transformed filtered pois: $arcorePositions");
  }

  void toggleDebug() {
    setState(() {
      debug = !debug;
    });
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;

    this.arSessionManager!.onInitialize(
          showFeaturePoints: false,
          showPlanes: true,
          customPlaneTexturePath: "Images/triangle.png",
          showWorldOrigin: true,
        );
    this.arObjectManager!.onInitialize();

    Timer.periodic(const Duration(milliseconds: 100), (Timer t) async {
      Vector3 rotation = await obtainRotationFromMatrix();
      setState(() {
        rotationX = rotation.x;
        rotationY = rotation.y;
        rotationZ = rotation.z;
      });
    });

    Timer.periodic(const Duration(milliseconds: 20000), (Timer t) async {});
  }

  Future<void> cleanPoisFromScene() async {
    for (var node in poiNodes) {
      arObjectManager.removeNode(node);
    }
    for (var anchor in poiAnchors) {
      arAnchorManager.removeAnchor(anchor);
    }
    poiNodes = [];
    poiAnchors = [];
  }

  Future<void> cleanNavigationFromScene() async {
    for (var node in routeNodes) {
      arObjectManager.removeNode(node);
    }
    for (var anchor in routeAnchors) {
      arAnchorManager.removeAnchor(anchor);
    }
    routeNodes = [];
    routeAnchors = [];
  }

  List<Poi> filterPoisByDistanceAndFloor(
      List<Poi> pois, Location location, double maxDistance) {
    return pois.where((poi) {
      // Verificar si el Poi está en la misma planta
      bool sameFloor = poi.buildingIdentifier == location.buildingIdentifier &&
          poi.position.floorIdentifier == location.floorIdentifier;

      if (sameFloor) {
        // Calcular la distancia entre la ubicación y el Poi
        double distance = calculateDistance(location, poi.position);
        // Verificar si la distancia es menor que la distancia máxima
        return distance < maxDistance;
      }

      return false;
    }).toList();
  }

  List<Point> getRouteByFloor(dynamic navigationSegments, Location location) {
    var filteredRouteByFloor = (navigationSegments as List)
        .where(
            (segment) => segment["floorIdentifier"] == location.floorIdentifier)
        .toList();

    List<Point> routePoints = filteredRouteByFloor
        .map<List<Point>>((segment) {
          var points = segment["points"] as List;
          return points.map<Point>((point) {
            return createPoint(point);
          }).toList();
        })
        .expand((pointsList) => pointsList)
        .toList();

    return routePoints;
  }

  String getNodeURIBasedOnCategory(PoiCategory category) {
    switch (category.name) {
      case "Big icon category":
        return "resources/models/BigIconPoi/BigIconPoi.gltf";
      case "Test Category":
        return "resources/models/TestPoi/TestPoi.gltf";
      case "Hello Categories":
        return "resources/models/HelloPoi/HelloPoi.gltf";
      case "No category":
        return "resources/models/BasePoi/BasePoi.gltf";
      case "Test subcategory":
        return "resources/models/TestSubcatPoi/TestSubcatPoi.gltf";
      default:
        return "resources/models/BasePoi/BasePoi.gltf";
    }
  }

  void addPoisToScene(List<Poi> nearPois, List<Vector3> arcorePositions) async {
    cleanPoisFromScene();
    for (int i = 0; i < nearPois.length; i++) {
      Poi poi = nearPois[i];
      Vector3 arcorePosition = arcorePositions[i];
      Matrix4 anchorPose = Matrix4.identity()
        ..translate(arcorePosition[0], 0.0, arcorePosition[2]);
      var newAnchor = ARPlaneAnchor(transformation: anchorPose);

      bool? didAddAnchor = await arAnchorManager.addAnchor(newAnchor);

      if (didAddAnchor!) {
        poiAnchors.add(newAnchor);
        ARNode objectNode = ARNode(
            type: NodeType.localGLTF2,
            uri: getNodeURIBasedOnCategory(poi.poiCategory),
            scale: Vector3(1, 1, 1),
            position: Vector3(0.0, -1.0, 0.0),
            rotation: Vector4(1.0, 0.0, 0.0, 0.0),
            data: {"onTapText": poi.name});
        poiNodes.add(objectNode);
        arObjectManager.addNode(objectNode, planeAnchor: newAnchor);
      }
    }
  }

  void addNavigationRouteToScene(List<Vector3> navigationRoutePoints) async {
    cleanNavigationFromScene();
    for (var point in navigationRoutePoints) {
      Matrix4 anchorPose = Matrix4.identity()
        ..translate(point[0], 0.0, point[2]);
      var newAnchor = ARPlaneAnchor(transformation: anchorPose);

      bool? didAddAnchor = await arAnchorManager.addAnchor(newAnchor);

      if (didAddAnchor!) {
        routeAnchors.add(newAnchor);
        ARNode objectNode = ARNode(
            type: NodeType.localGLTF2,
            uri: "resources/models/TestSubcatPoi/TestSubcatPoi.gltf",
            scale: Vector3(0.5, 0.5, 0.5),
            position: Vector3(0.0, -1.0, 0.0),
            rotation: Vector4(1.0, 0.0, 0.0, 0.0));
        routeNodes.add(objectNode);
        arObjectManager.addNode(objectNode, planeAnchor: newAnchor);
      }
    }
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
      dropdownValue = pois[0];
    });
  }

  void _downloadBuilding(String buildingIdentifier) async {
    BuildingInfo buildingInfo =
        await situmSdk.fetchBuildingInfo(buildingIdentifier);
    setState(() {
      currentBuilding = buildingInfo.building;
    });
  }

  ///////////////////////////////////////////////////////////

  Future<Vector3> obtainRotationFromMatrix() async {
    Matrix4? cameraTransform = await arSessionManager.getCameraPose();
    if (cameraTransform == null) return Vector3.zero();

    Matrix3 rotation = cameraTransform.getRotation();

    double r11 = rotation.storage[0];
    double r12 = rotation.storage[1];
    double r13 = rotation.storage[2];

    // ignore: unused_local_variable
    double r21 = rotation.storage[3];
    double r22 = rotation.storage[4];
    double r23 = rotation.storage[5];

    // ignore: unused_local_variable
    double r31 = rotation.storage[6];
    // ignore: unused_local_variable
    double r32 = rotation.storage[7];
    // ignore: unused_local_variable
    double r33 = rotation.storage[8];

    double rotationX = atan2(-r23, r22);
    double rotationY = atan2(r13, r11);
    double rotationZ = atan2(-r12, r11);

    return Vector3(rotationX, rotationY, rotationZ);
  }

  ///////////////////////////////////////////////////////////

  Future<Matrix3?> syncWorldView(Location location) async {
    Matrix4? cameraTransform = await arSessionManager.getCameraPose();

    if (cameraTransform == null) return null;

    Vector3 cameraPosition = cameraTransform.getTranslation();
    // Compute relative situm position with respect to camera
    double diffX = cameraPosition.x - location.cartesianCoordinate.x;
    double diffY = -cameraPosition.z - location.cartesianCoordinate.y;

    // First inverse situm rotation (range -pi, pi to match camera range)
    // and compute relative rotation with respect to camera
    // idk why i need a 90 degree rotation
    double diffAngle =
        (-location.cartesianBearing!.radiansMinusPiPi - rotationY) + (pi / 2);
    // double diffAngle =
    //     ((2 * pi - location.cartesianBearing!.radians) - rotationY) + (pi / 2);

    List<double> rotationOrigin = [
      location.cartesianCoordinate.x,
      location.cartesianCoordinate.y
    ];

    setState(() {
      dx = diffX;
      dy = diffY;
      angle = diffAngle;
    });

    return computeTransformationMatrix(diffAngle, diffX, diffY, rotationOrigin);
  }

  ///////////////////////////////////////////////////////////

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
      // Modify location for test purposes
      Location modifiedLocation = location;
      // modifiedLocation.cartesianCoordinate.x = 122;
      // modifiedLocation.cartesianCoordinate.y = 40;

      setState(() {
        currentLocation = modifiedLocation;
      });

      mapViewController?.sendMessage(
          WV_MESSAGE_LOCATION, modifiedLocation.toMap());
      _echo("""SDK> Location changed:
        Time diff: ${location.timestamp - DateTime.now().millisecondsSinceEpoch}
        cartesianBearing : ${location?.cartesianBearing?.radians}, bearing: ${location?.bearing?.radians}
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
    situmSdk.onNavigationStart((route) {
      setState(() {
        navigationSegments = route.rawContent["segments"];
      });
    });
    situmSdk.onNavigationProgress((progress) {
      setState(() {
        navigationSegments = progress.rawContent["segments"];
      });
    });
    situmSdk.onNavigationCancellation(() {
      setState(() {
        navigationSegments = null;
      });
    });
    situmSdk.onNavigationDestinationReached(() {
      setState(() {
        navigationSegments = null;
      });
    });
    _downloadPois(buildingIdentifier);
    _downloadBuilding(buildingIdentifier);
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
        children: [_createHomeTab(), _createSplitScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.toys),
            label: 'AR',
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
