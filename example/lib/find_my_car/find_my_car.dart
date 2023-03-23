import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:situm_flutter_wayfinding/situm_flutter_wayfinding.dart';

class FindMyCar extends StatefulWidget {
  // Instance of the WYF library
  final SitumFlutterWayfinding? wyfController;
  // Identifier of current building
  final String? buildingIdentifier;
  // Image path for selected icon
  final String? selectedIconPath;
  // Image path for unselected icon
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
    // Initialize state attributes
    _setupState();
    // Define the listeners for custom poi changes
    _setUpListeners();
  }

  @override
  Widget build(BuildContext context) {
    // Find my car floating action button
    return Container(
        margin: const EdgeInsets.only(top: 110.0, right: 20.0),
        alignment: Alignment.topRight,
        child: FloatingActionButton(
          onPressed: () async {
            // Check if we have a custom poi stored, if not we start the custom
            // poi creation by passing the corresponding name, description and icons.
            // If there is a custom poi stored, we focus on the custom POI and we select it.
            if (_customPoi == null) {
              // Selected icon encoded on base 64
              String? encodedSelectedIcon =
                  await _imageToBase64(widget.selectedIconPath);
              // Unselected icon encoded on base 64
              String? encodedUnSelectedIcon =
                  await _imageToBase64(widget.unSelectedIconPath);
              // Call API method to start custom poi creation
              widget.wyfController?.startCustomPoiCreation("My car",
                  "This is my car", encodedSelectedIcon, encodedUnSelectedIcon);
            } else {
              // Call API method to select custom poi currently stored
              widget.wyfController?.selectCustomPoi(_customPoi!.id);
            }
          },
          backgroundColor: const Color.fromARGB(255, 40, 51, 128),
          child: Icon(_findMyCarIcon),
        ));
  }

  void _setupState() async {
    // Get stored custom poi
    var customPoi = await widget.wyfController?.getCustomPoi();
    // If there is a custom poi stored and the building associated
    // to the custom poi is the same as the identifier of the current building
    if (customPoi != null &&
        customPoi.buildingId.toString() == widget.buildingIdentifier) {
      setState(() {
        // Initialize instance of the custom poi. We use this later on to decide
        // what the floating action button does (either start custom poi creation or
        // selecting the custom poi currently stored)
        _customPoi = customPoi;
        // Set up icon for the floating action button
        _findMyCarIcon = Icons.local_parking;
      });
    }
  }

  void _setUpListeners() {
    // This method will be called when a custom POI has been successfully created
    widget.wyfController?.onCustomPoiCreated((customPoi) {
      print("WYF> Custom POI created: $customPoi");
      setState(() {
        _customPoi = customPoi;
        _findMyCarIcon = Icons.local_parking;
      });
    });
    // This method will be called when a custom POI has been successfully removed
    widget.wyfController?.onCustomPoiRemoved((customPoi) {
      print("WYF> Custom POI removed: $customPoi");
      setState(() {
        _customPoi = null;
        _findMyCarIcon = Icons.directions_car_filled_rounded;
      });
    });
    // This method will be called when a custom POI has been selected
    widget.wyfController?.onCustomPoiSelected((customPoi) {
      print("WYF> Custom POI selected: $customPoi");
    });
    // This method will be called when a custom POI has been deselected
    widget.wyfController?.onCustomPoiDeselected((customPoi) {
      print("WYF> Custom POI deselected: $customPoi");
    });
  }

  /*
  * This auxiliary function allows us to encode an image to base 64. It takes the 
  * image path as an argument which is used to load the image which will be encoded.
  * The encoded string is passed to the plugin, which decodes it as needed and forwards it 
  * to the Wayfinding module.
  */
  Future<String?> _imageToBase64(String? imagePath) async {
    if (imagePath == null) return null;
    try {
      ByteData imageData = await rootBundle.load(imagePath);
      Uint8List bytes = imageData.buffer.asUint8List();
      return base64Encode(bytes);
    } catch (e) {
      print(
          "FIND MY CAR> Could not encode image: ${e.toString()}. The default icon will be used.");
      return null;
    }
  }
}
