import 'package:flutter/material.dart';
import 'package:situm_flutter_wayfinding/situm_flutter_wayfinding.dart';
import 'package:situm_flutter_wayfinding_example/config.dart';

class FindMyCar extends StatefulWidget {
  final SitumFlutterWayfinding? wyfController;

  const FindMyCar({Key? key, this.wyfController}) : super(key: key);

  @override
  State<FindMyCar> createState() => _FindMyCarState();
}

class _FindMyCarState extends State<FindMyCar> {
  IconData _findMyCarIcon = Icons.directions_car_filled_rounded;
  CustomPoi? _customPoi;

  @override
  void initState() {
    super.initState();
    _checkState();
    _setUpListeners();
  }

  @override
  Widget build(BuildContext context) {
    // Find my car FAB
    return Container(
        margin: const EdgeInsets.only(top: 110.0, right: 20.0),
        alignment: Alignment.topRight,
        child: FloatingActionButton(
          onPressed: () {
            if (_customPoi == null) {
              widget.wyfController
                  ?.startCustomPoiCreation("My car", "This is my car");
            } else {
              widget.wyfController?.selectCustomPoi(_customPoi!.id);
            }
          },
          backgroundColor: const Color.fromARGB(255, 40, 51, 128),
          child: Icon(_findMyCarIcon),
        ));
  }

  void _checkState() async {
    var customPoi = await widget.wyfController?.getCustomPoi();
    if (customPoi != null &&
        customPoi.buildingId.toString() == buildingIdentifier) {
      setState(() {
        _customPoi = customPoi;
        _findMyCarIcon = Icons.local_parking;
      });
    }
  }

  void _setUpListeners() {
    widget.wyfController?.onCustomPoiSet((customPoi) {
      print("WYF> Custom POI set: $customPoi");
      setState(() {
        _customPoi = customPoi;
        _findMyCarIcon = Icons.local_parking;
      });
    });
    widget.wyfController?.onCustomPoiRemoved((poiId) {
      print("WYF> Custom POI removed: $poiId");
      setState(() {
        _customPoi = null;
        _findMyCarIcon = Icons.directions_car_filled_rounded;
      });
    });
    widget.wyfController?.onCustomPoiSelected((poiId) {
      print("WYF> Custom POI selected: $poiId");
    });
    widget.wyfController?.onCustomPoiDeselected((poiId) {
      print("WYF> Custom POI deselected: $poiId");
    });
  }
}
