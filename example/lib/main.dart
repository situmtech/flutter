import 'package:flutter/material.dart';
import 'package:situm_flutter/sdk.dart';
import 'package:situm_flutter_example/tabs/home_tab.dart';
import 'package:situm_flutter_example/tabs/wayfinding_tab.dart';

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
  static const _wyfTabIndex = 1;

  @override
  void initState() {
    situmSdk = SitumSdk();
    // In case you want to use our SDK before initializing our MapView widget,
    // you can set up your credentials with this line of code:
    situmSdk.init();
    // Authenticate with your account and API key.
    // You can find yours at https://dashboard.situm.com/accounts/profile
    situmSdk.setApiKey(situmApiKey);
    situmSdk.setDashboardURL(apiDomain);
    // Configure SDK before authenticating.
    situmSdk.setConfiguration(ConfigurationOptions(
        // In case you want to use our remote configuration (https://dashboard.situm.com/settings).
        // With this practical dashboard you can edit your location request and other SDK configurations
        // with ease and no code changes.
        useRemoteConfig: true));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // The typical app widget with bottom navigation:
    return Scaffold(
      appBar: AppBar(
        title: const Text(_title),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Home:
          HomeTab(onWayfindingTabPressed: () => {_onItemTapped(_wyfTabIndex)}),
          // Wayfinding:
          const WayfindingTab(),
        ],
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
}
