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
const OFFLINE_CHANNEL = "OfflineChannel";

// EVENTS from map-viewer:
const WV_MESSAGE_DIRECTIONS_REQUESTED = "directions.requested";
const WV_MESSAGE_NAVIGATION_REQUESTED = "navigation.requested";
const WV_MESSAGE_NAVIGATION_STOP = "navigation.stopped";
const WV_MESSAGE_CARTOGRAPHY_POI_SELECTED = "cartography.poi_selected";
const WV_MESSAGE_CARTOGRAPHY_POI_DESELECTED = "cartography.poi_deselected";
const WV_MESSAGE_MAP_IS_READY = "app.map_is_ready";
const WV_MESSAGE_LOCATION_START = "location.start";
const WV_MESSAGE_AR_REQUESTED = "augmented_reality.requested";

// ACTIONS sent to map-viewer:

// Location actions
const WV_MESSAGE_LOCATION = "location.update";
const WV_MESSAGE_LOCATION_STATUS = "location.update_status";

// Directions actions
const WV_MESSAGE_DIRECTIONS_UPDATE = "directions.update";
const WV_MESSAGE_DIRECTIONS_SET_OPTIONS = "directions.set_options";

// Navigation actions
const WV_MESSAGE_NAVIGATION_START = "navigation.start";
const WV_MESSAGE_NAVIGATION_UPDATE = "navigation.update";
const WV_MESSAGE_NAVIGATION_CANCEL = "navigation.cancel";

// Cartogaphy actions
const WV_MESSAGE_CARTOGRAPHY_SELECT_POI = "cartography.select_poi";
const WV_MESSAGE_CARTOGRAPHY_SELECT_POI_CATEGORY =
    "cartography.select_poi_category";
const WV_MESSAGE_CARTOGRAPHY_SELECT_FLOOR = "cartography.select_floor";
const WV_MESSAGE_CARTOGRAPHY_FILTER_POIS = "cartography.filter_pois";
const WV_MESSAGE_UI_SET_LANGUAGE = "ui.set_language";

// Camera actions
const WV_MESSAGE_CAMERA_FOLLOW_USER = "camera.follow_user";
const WV_MESSAGE_CAMERA_SET = "camera.set";

// AR actions
const WV_MESSAGE_AR_UPDATE_STATUS = "augmented_reality.update_status";
