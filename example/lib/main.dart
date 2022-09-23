import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:situm_flutter_wayfinding/situm_flutter_wayfinding.dart';
import 'package:situm_flutter_wayfinding_example/config.dart';

void main() => runApp(const MyApp());

const _title = "Situm Flutter Wayfinding";

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

  static const List<Widget> _tabBarWidgets = <Widget>[
    // Home:
    Card(
      child: Center(
        child: Text(
          'Home',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    // The Situm map:
    SitumMapView(
        key: Key("situm_map"),
        // Your Situm credentials and building, see config.dart.
        // Copy config.dart.example if you haven't already.
        situmUser: situmUser,
        situmApiKey: situmApiKey,
        buildingIdentifier: buildingIdentifier,
        useHybridComponents: true,
        showPoiNames: true,
        loadCallback: _onSitumMapLoaded)
  ];

  static void _onSitumMapLoaded(SitumFlutterWayfinding controller) {
    // The Situm map was successfully loaded, use the given controller to
    // call the WYF API methods.
    log("Situm Map loaded!");
    // controller.selectPoi(Poi("104105", "9571"));
    controller.onPoiSelected((poiSelectedResult) {
      log("Poi ${poiSelectedResult.poiName} selected!");
    });
    controller.onPoiDeselected((poiDeselectedResult) {
      log("Poi deselected!");
    });
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
