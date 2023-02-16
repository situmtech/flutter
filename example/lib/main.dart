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
