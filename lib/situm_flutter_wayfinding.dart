import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

const CHANNEL_ID = 'situm.com/flutter_wayfinding';

class SitumFlutterWayfinding {
  late final MethodChannel methodChannel;
  OnPoiSelectedCallback? onPoiSelectedCallback;

  SitumFlutterWayfinding(int id) {
    methodChannel = MethodChannel('${CHANNEL_ID}_$id');
    methodChannel.setMethodCallHandler(_methodCallHandler);
  }

  // Calls:

  Future<String?> load(SitumMapViewCallback situmMapResultCallback,
      Map<String, dynamic> creationParams) async {
    log("Dart load called, methodChannel will be invoked.");
    final result =
        await methodChannel.invokeMethod<String>('load', creationParams);
    situmMapResultCallback(this);
    return result;
  }

  Future<String?> selectPoi(Poi poi) async {
    log("Dart selectPoi called, methodChannel will be invoked.");
    return await methodChannel.invokeMethod<String>('selectPoi',
        <String, dynamic>{'id': poi.id, 'buildingId': poi.buildingId});
  }

  void onPoiSelected(OnPoiSelectedCallback callback) {
    onPoiSelectedCallback = callback;
  }

  // Callbacks:

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'onPoiSelected':
        _onPoiSelected(call.arguments);
        break;
      default:
        print('Method ${call.method} not found!');
    }
  }

  void _onPoiSelected(arguments) {
    onPoiSelectedCallback?.call(OnPoiSelectedResult(
        buildingId: arguments['buildingId'],
        buildingName: arguments['buildingName'],
        floorId: arguments['floorId'],
        floorName: arguments['floorName'],
        poiId: arguments['poiId'],
        poiName: arguments['poiName']));
  }
}

// Classes for method channel communication:

class Poi {
  final String id;
  final String buildingId;

  Poi(this.id, this.buildingId);
}

class OnPoiSelectedResult {
  final String buildingId;
  final String buildingName;
  final String floorId;
  final String floorName;
  final String poiId;
  final String poiName;

  const OnPoiSelectedResult(
      {required this.buildingId,
      required this.buildingName,
      required this.floorId,
      required this.floorName,
      required this.poiId,
      required this.poiName});
}

// Result callback.
typedef SitumMapViewCallback = void Function(SitumFlutterWayfinding controller);
typedef OnPoiSelectedCallback = void Function(
    OnPoiSelectedResult poiSelectedResult);

// The Widget!
class SitumMapView extends StatefulWidget {
  final String situmUser;
  final String situmApiKey;
  final String buildingIdentifier;
  final bool useHybridComponents;
  final bool enablePoiClustering;

  const SitumMapView(
      {required Key key,
      required this.situmUser,
      required this.situmApiKey,
      required this.buildingIdentifier,
      required this.loadCallback,
      this.useHybridComponents = true,
      this.enablePoiClustering = true})
      : super(key: key);

  final SitumMapViewCallback loadCallback;

  @override
  State<StatefulWidget> createState() => _SitumMapViewState();
}

class _SitumMapViewState extends State<SitumMapView> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> platformViewParams = <String, dynamic>{
      // TODO: add view specific creation params.
    };
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _buildAndroidView(context, platformViewParams);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _buildiOS(context, platformViewParams);
    }
    return Text('$defaultTargetPlatform is not supported by the Situm plugin');
  }

  Future<void> _onPlatformViewCreated(int id) async {
    Map<String, dynamic> loadParams = <String, dynamic>{
      "situmUser": widget.situmUser,
      "situmApiKey": widget.situmApiKey,
      "buildingIdentifier": widget.buildingIdentifier,
      "enablePoiClustering": widget.enablePoiClustering,
      "useHybridComponents": widget.useHybridComponents
    };
    var controller = SitumFlutterWayfinding(id);
    controller.load(widget.loadCallback, loadParams);
  }

  // ==========================================================================
  // iOS
  // ==========================================================================

  Widget _buildiOS(BuildContext context, Map<String, dynamic> creationParams) {
    const String viewType = '<platform-view-type>';

    return UiKitView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  // ==========================================================================
  // ANDROID
  // ==========================================================================

  Widget _buildAndroidView(
      BuildContext context, Map<String, dynamic> creationParams) {
    if (widget.useHybridComponents) {
      return _buildHybrid(context, creationParams);
    }
    return _buildVirtualDisplay(context, creationParams);
  }

  Widget _buildHybrid(
      BuildContext context, Map<String, dynamic> creationParams) {
    log("Using hybrid components");
    return PlatformViewLink(
      viewType: CHANNEL_ID,
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as ExpensiveAndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        final AndroidViewController controller =
            PlatformViewsService.initExpensiveAndroidView(
          id: params.id,
          viewType: CHANNEL_ID,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () {
            params.onFocusChanged(true);
          },
        );
        controller
            .addOnPlatformViewCreatedListener(params.onPlatformViewCreated);
        controller.addOnPlatformViewCreatedListener(_onPlatformViewCreated);
        controller.create();
        return controller;
      },
    );
  }

  Widget _buildVirtualDisplay(
      BuildContext context, Map<String, dynamic> creationParams) {
    log("Using virtual display");
    return AndroidView(
      viewType: CHANNEL_ID,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: _onPlatformViewCreated,
    );
  }
}
