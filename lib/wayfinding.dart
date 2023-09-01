library wayfinding;
// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:situm_flutter/sdk.dart';

// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';

// WebView:
// Not necessary, also included with webview_flutter_platform_interface:
// import 'package:webview_flutter/webview_flutter.dart' hide NavigationRequest;
// WebView Platform interface:
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart'
    hide NavigationRequest;

// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

part 'src/controller.dart';

part 'src/definitions.dart';

part 'src/mapper.dart';

part 'src/message_handlers.dart';

part 'src/situm_map_view.dart';

const WV_CHANNEL = "ReactNativeWebView";

// Events from map-viewer:
const WV_MESSAGE_DIRECTIONS_REQUESTED = "directions.requested";
const WV_MESSAGE_NAVIGATION_REQUESTED = "navigation.requested";
const WV_MESSAGE_NAVIGATION_STOP = "navigation.stopped";
const WV_MESSAGE_CARTOGRAPHY_POI_SELECTED = "cartography.poi_selected";
const WV_MESSAGE_CARTOGRAPHY_POI_DESELECTED = "cartography.poi_deselected";
const WV_MESSAGE_MAP_IS_READY = "app.map_is_ready";

// Actions sent to map-viewer:
const WV_MESSAGE_LOCATION = "location.update";
const WV_MESSAGE_DIRECTIONS_UPDATE = "directions.update";
const WV_MESSAGE_NAVIGATION_START = "navigation.start";
const WV_MESSAGE_NAVIGATION_TO_LOCATION = "navigation.to_location";
const WV_MESSAGE_NAVIGATION_UPDATE = "navigation.update";
const WV_MESSAGE_NAVIGATION_CANCEL = "navigation.cancel";
const WV_MESSAGE_CARTOGRAPHY_SELECT_POI = "cartography.select_poi";
const WV_MESSAGE_UI_SET_LANGUAGE = "ui.set_language";
const WV_MESSAGE_CAMERA_FOLLOW_USER = "camera.follow_user";
