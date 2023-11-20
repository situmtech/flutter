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
import 'package:vector_math/vector_math_64.dart' show Vector3, Vector4;


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
  int _selectedIndex = 0;
  List<Poi> pois = [];
  Poi? dropdownValue;
  Function? mapViewLoadAction;

  MapViewController? mapViewController;

  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  late ARAnchorManager arAnchorManager;
  late Location currentLocation;
  List<Poi> nearPois = [];
  List<RelativePosition> relativePositions = [];
  //List<Vector3>  arCorePositions = [];  
  List<ARNode> nodes = [];
  List<ARAnchor> anchors = [];

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

  // Widget that shows ARView.
  Widget _createARTab() {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Anchors & Objects on Planes'),
        ),
        body: Stack(children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
        ]));
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

   Timer.periodic(const Duration(milliseconds: 5000), (Timer t) async {
    debugPrint("*************************************************************************************************************************************** START NEAR POIS:}");
    
    debugPrint("**************** currentLocation: ${currentLocation.toString()}");
      this.nearPois = filterPoisByDistanceAndFloor(pois, currentLocation, 120);
           debugPrint("**************** TIME NEAR POIS: ${nearPois.toString()}");
      this.relativePositions = calculateRelativePositions(currentLocation, nearPois);
            debugPrint("**************** TIME RELATIVE POSITIONS: ${relativePositions.toString()}");

      List<Vector3> arcorePositions = await generateARCorePositions(relativePositions,currentLocation );
            debugPrint("**************** TIME arcorePositions POSITIONS: ${arcorePositions.toString()}");

      addPoisToScene(arcorePositions);
 

    });


    Timer.periodic(const Duration(milliseconds: 1000), (Timer t) async {
      Matrix4? camera = await arSessionManager.getCameraPose();

      if (camera != null) {
        var cameraRotation = camera.getRotation();
        currentLocation?.rotationMatrix = cameraRotation.storage;

        // debugPrint("******* TIMER ALBA: ");
        // debugPrint("Camera rotation: $cameraRotation");
        // debugPrint("Location: ${currentLocation.toMap()}");

        mapViewController?.sendMessage(
            WV_MESSAGE_LOCATION, currentLocation.toMap());
      }
    });
  }

  Future<void> removeEverything() async {
    /*nodes.forEach((node) {
      this.arObjectManager.removeNode(node);
    });*/
    anchors.forEach((anchor) {
      this.arAnchorManager!.removeAnchor(anchor);
    });
    anchors = [];
  }

  List<Poi> filterPoisByDistanceAndFloor(List<Poi> pois, Location location, double maxDistance) {
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


void addPoisToScene(List<Vector3> arcorePositions ) async{

    removeEverything();
    for (int i = 0; i < nearPois.length; i++) {
      Poi poi = nearPois[i];
      RelativePosition relativePosition = relativePositions[i];
      Vector3 arcorePosition = arcorePositions[i];
      // Crea un anchor utilizando las coordenadas relativas
      // ARPose anchorPose = ARPose(
      //   translation: ARVector3(relativePosition.relativeX, relativePosition.relativeY, 0.0),
      //   rotation: ARQuaternion.axisAngle(ARVector3.up(), relativePosition.relativeBearing),
      // );
       Matrix4 anchorPose = Matrix4.identity()
        ..translate(arcorePosition[0], 0.0, arcorePosition[2]);
        //..rotateZ(relativePosition.relativeBearing);
     
    var newAnchor = ARPlaneAnchor(transformation: anchorPose);

    bool? didAddAnchor = await this.arAnchorManager!.addAnchor(newAnchor);

      if (didAddAnchor!) {
        this.anchors.add(newAnchor);
        ARNode objectNode = ARNode(
          
              type: NodeType.webGLB,
              uri: "https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF-Binary/Duck.glb",
              scale: Vector3(1, 1, 1),
              position: Vector3(0.0, 0.0, 0.0),
              rotation: Vector4(1.0, 0.0, 0.0, 0.0),
              data: {"onTapText": poi.name}
        );
        // ARText textNode = ARText(
        //   text: poi.name,
        //   position: Vector3(0.0, 2.0, 0.0),  // Posiciona el texto debajo del objeto
        //   scale: Vector3(2.0, 5.0, 5.0),  // Ajusta la escala según tus necesidades
        // );

        bool? didAddNodeToAnchor =
            await this.arObjectManager!.addNode(objectNode, planeAnchor: newAnchor);

      }
    }

}


double calculateDistance(Location location1, Point point) {
  double x1 = location1.cartesianCoordinate.x;
  double y1 = location1.cartesianCoordinate.y;
  double x2 = point.cartesianCoordinate.x;
  double y2 = point.cartesianCoordinate.y;

  // Fórmula para calcular la distancia euclidiana entre dos puntos
  return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
}



RelativePosition calculateRelativePosition(Location currentLocation, Poi poi) {
  
  double relativeX = poi.position.cartesianCoordinate.x - currentLocation.cartesianCoordinate.x;
  double relativeY = poi.position.cartesianCoordinate.y - currentLocation.cartesianCoordinate.y;

//TODO: Calculate bearing

  return RelativePosition(relativeX: relativeX, relativeY: relativeY);
}

List<RelativePosition> calculateRelativePositions(Location currentLocation, List<Poi> nearPois) {
  return nearPois.map((poi) {
    return calculateRelativePosition(currentLocation, poi);
  }).toList();
}

Future<List<Vector3>> generateARCorePositions(List<RelativePosition> relativePositions, Location currentLocation) async {
  // Obtén la transformación de la cámara
  debugPrint("**************** to get cameraTransform:}");

  Matrix4? cameraTransform = await arSessionManager.getCameraPose();
if (cameraTransform != null) {
  debugPrint("**************** camera pose:");
  debugPrint("****************  ${cameraTransform.storage[0]} ${cameraTransform.storage[1]} ${cameraTransform.storage[2]} ${cameraTransform.storage[3]}");
  debugPrint("****************  ${cameraTransform.storage[4]} ${cameraTransform.storage[5]} ${cameraTransform.storage[6]} ${cameraTransform.storage[7]}");
  debugPrint("****************  ${cameraTransform.storage[8]} ${cameraTransform.storage[9]} ${cameraTransform.storage[10]} ${cameraTransform.storage[11]}");
  debugPrint("****************  ${cameraTransform.storage[12]} ${cameraTransform.storage[13]} ${cameraTransform.storage[14]} ${cameraTransform.storage[15]}");
  // x,y ,z
  //  ${cameraTransform.storage[12]} ${cameraTransform.storage[13]} ${cameraTransform.storage[14]
} else {
  debugPrint("Camera transform is null");
}
  if (cameraTransform != null) {
    return relativePositions.map((relativePosition) {
      // Calcula la posición ajustada en el sistema de referencia de ARCore (en el plano x,z)
      Vector3 adjustedRelativePosition = Vector3(relativePosition.relativeX, 0.0, relativePosition.relativeY);
      Vector3 arcoreTranslation = cameraTransform.getTranslation();
        debugPrint("****************arcoreTranslation  ${arcoreTranslation.storage[0]} ${arcoreTranslation.storage[1]} ${arcoreTranslation.storage[2]}");

      // Vector3 arCorePosition = cameraTransform.transform3(adjustedRelativePosition);
      Vector3 arCorePosition = adjustedRelativePosition + arcoreTranslation;
      // Ajusta la posición según la posición actual
      // arCorePosition.x += currentLocation.cartesianCoordinate.x;
      // arCorePosition.z += currentLocation.cartesianCoordinate.y;  // Usamos 'z' en lugar de 'y' en el plano x,z de ARCore

      return arCorePosition;
    }).toList();
  } else {
    // Maneja el caso en el que no se pudo obtener la transformación de la cámara
    return [];
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
      setState(() {
        currentLocation = location;
      });
      _echo("""SDK> Location changed:
        Time diff: ${location.timestamp - DateTime.now().millisecondsSinceEpoch}
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
      useDeadReckoning: true,
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
        children: [_createHomeTab(), _createSitumMapTab(), _createARTab()],
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
