import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:situm_flutter/sdk.dart';
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

import 'math.dart';

class ARCoreView extends StatefulWidget {
  final SitumSdk situmSdk;
  final String buildingIdentifier;

  const ARCoreView(
      {Key? key, required this.situmSdk, required this.buildingIdentifier})
      : super(key: key);

  @override
  State<ARCoreView> createState() => _ARCoreViewState();
}

class _ARCoreViewState extends State<ARCoreView> {
  List<Poi> pois = [];

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

  void _downloadPois(String buildingIdentifier) async {
    var poiList =
        await widget.situmSdk.fetchPoisFromBuilding(buildingIdentifier);
    setState(() {
      pois = poiList;
    });
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
            generateInterpolatedPoints(transformedRoutePoints, 2);
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
          showWorldOrigin: true,
        );
    this.arObjectManager!.onInitialize();

    Timer.periodic(const Duration(milliseconds: 100), (Timer t) async {
      Matrix4? cameraTransform = await arSessionManager.getCameraPose();
      if (cameraTransform == null) return;

      Matrix3 cameraRotationMatrix = cameraTransform.getRotation();
      Vector3 rotationVector = obtainRotationFromMatrix(cameraRotationMatrix);
      setState(() {
        rotationX = rotationVector.x;
        rotationY = rotationVector.y;
        rotationZ = rotationVector.z;
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

  @override
  void initState() {
    widget.situmSdk.onLocationUpdate((location) {
      setState(() {
        currentLocation = location;
      });
    });
    widget.situmSdk.onNavigationStart((route) {
      setState(() {
        navigationSegments = route.rawContent["segments"];
      });
    });
    widget.situmSdk.onNavigationProgress((progress) {
      setState(() {
        navigationSegments = progress.rawContent["segments"];
      });
    });
    widget.situmSdk.onNavigationCancellation(() {
      setState(() {
        navigationSegments = [];
      });
    });
    widget.situmSdk.onNavigationDestinationReached(() {
      setState(() {
        navigationSegments = [];
      });
    });

    _downloadPois(widget.buildingIdentifier);
    super.initState();
  }

  // ---

  @override
  Widget build(BuildContext context) {
    // The typical app widget with bottom navigation:
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
}
