import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:situm_flutter_wayfinding/situm_flutter_wayfinding.dart';

class FindMyCar extends StatefulWidget {
  final SitumFlutterWayfinding? wyfController;
  final String? buildingIdentifier;
  final String? selectedIconPath;
  final String? unSelectedIconPath;

  const FindMyCar(
      {Key? key,
      this.wyfController,
      this.buildingIdentifier,
      this.selectedIconPath,
      this.unSelectedIconPath})
      : super(key: key);

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
          onPressed: () async {
            if (_customPoi == null) {
              var encodedSelectedIcon =
                  await _imageToBase64(widget.selectedIconPath!);
              var encodedUnSelectedIcon =
                  await _imageToBase64(widget.unSelectedIconPath!);
              widget.wyfController?.startCustomPoiCreation("My car",
                  "This is my car", encodedSelectedIcon, encodedUnSelectedIcon);
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
        customPoi.buildingId.toString() == widget.buildingIdentifier) {
      setState(() {
        _customPoi = customPoi;
        _findMyCarIcon = Icons.local_parking;
      });
    }
  }

  void _setUpListeners() {
    widget.wyfController?.onCustomPoiCreated((customPoi) {
      print("WYF> Custom POI created: $customPoi");
      setState(() {
        _customPoi = customPoi;
        _findMyCarIcon = Icons.local_parking;
      });
    });
    widget.wyfController?.onCustomPoiRemoved((customPoi) {
      print("WYF> Custom POI removed: $customPoi");
      setState(() {
        _customPoi = null;
        _findMyCarIcon = Icons.directions_car_filled_rounded;
      });
    });
    widget.wyfController?.onCustomPoiSelected((customPoi) {
      print("WYF> Custom POI selected: $customPoi");
    });
    widget.wyfController?.onCustomPoiDeselected((customPoi) {
      print("WYF> Custom POI deselected: $customPoi");
    });
  }

  Future<String> _imageToBase64(String imagePath) async {
    try {
      ByteData imageData = await rootBundle.load(imagePath);
      Uint8List bytes = imageData.buffer.asUint8List();
      return base64Encode(bytes);
    } catch (e) {
      print(
          "FIND MY CAR> Could not encode image: ${e.toString()} The default icon will be used.");
      return "";
    }
  }
}
