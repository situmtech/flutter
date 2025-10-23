library wayfinding;
// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
const WV_MESSAGE_AR_REQUESTED = "augmented_reality.requested";
const WV_MESSAGE_CARTOGRAPHY_POI_DESELECTED = "cartography.poi_deselected";
const WV_MESSAGE_CARTOGRAPHY_POI_SELECTED = "cartography.poi_selected";
const WV_MESSAGE_DIRECTIONS_REQUESTED = "directions.requested";
const WV_MESSAGE_ERROR = "app.error";
const WV_MESSAGE_FIND_MY_CAR_SAVED = "find_my_car.saved";
const WV_MESSAGE_LOCATION_START = "location.start";
const WV_MESSAGE_MAP_IS_READY = "app.map_is_ready";
const WV_MESSAGE_NAVIGATION_REQUESTED = "navigation.requested";
const WV_MESSAGE_NAVIGATION_STOP = "navigation.stopped";
const WV_VIEWER_NAVIGATION_STARTED = "viewer.navigation.started";
const WV_VIEWER_NAVIGATION_STOPPED = "viewer.navigation.stopped";
const WV_VIEWER_NAVIGATION_UPDATED = "viewer.navigation.updated";

// Calibration events:
const WV_MESSAGE_CALIBRATION_POINT_CLICKED = "calibration.point_clicked";
const WV_MESSAGE_CALIBRATION_STOPPED = "calibration.stopped";

// ACTIONS sent to map-viewer:

// Location actions
const WV_MESSAGE_LOCATION = "location.update";
const WV_MESSAGE_LOCATION_STATUS = "location.update_status";

// Directions actions
const WV_MESSAGE_DIRECTIONS_START = "directions.start";
const WV_MESSAGE_DIRECTIONS_UPDATE = "directions.update";
const WV_MESSAGE_DIRECTIONS_SET_OPTIONS = "directions.set_options";

// Navigation actions
const WV_MESSAGE_NAVIGATION_START = "navigation.start";
const WV_MESSAGE_NAVIGATION_TO_CAR = "navigation.start.to_car";
const WV_MESSAGE_NAVIGATION_UPDATE = "navigation.update";
const WV_MESSAGE_NAVIGATION_CANCEL = "navigation.cancel";

// Cartogaphy actions
const WV_MESSAGE_CARTOGRAPHY_SELECT_BUILDING = "cartography.select_building";
const WV_MESSAGE_CARTOGRAPHY_DESELECT_POI = "cartography.deselect_poi";
const WV_MESSAGE_CARTOGRAPHY_SELECT_POI = "cartography.select_poi";
const WV_MESSAGE_CARTOGRAPHY_SELECT_CAR = "cartography.select_car";
const WV_MESSAGE_CARTOGRAPHY_SELECT_POI_CATEGORY =
    "cartography.select_poi_category";
const WV_MESSAGE_CARTOGRAPHY_SELECT_FLOOR = "cartography.select_floor";
const WV_MESSAGE_FIND_MY_CAR_SAVE = "find_my_car.save";
const WV_MESSAGE_UI_SET_LANGUAGE = "ui.set_language";

// Camera actions
const WV_MESSAGE_CAMERA_FOLLOW_USER = "camera.follow_user";
const WV_MESSAGE_CAMERA_SET = "camera.set";

// AR actions
const WV_MESSAGE_AR_UPDATE_STATUS = "augmented_reality.update_status";

// Filtering actions
const WV_MESSAGE_UI_SET_SEARCH_FILTER = "ui.set_search_filter";

// TTS
const WV_MESSAGE_UI_SPEAK_ALOUD_TEXT = "ui.speak_aloud_text";

// Calibration actions
const WV_MESSAGE_UI_SET_MODE = "ui.set_mode";
const WV_MESSAGE_CALIBRATIONS_SET_LOCAL_CALIBRATIONS =
    "calibration.set_local_calibrations";
const WV_MESSAGE_CALIBRATIONS_STOP_CURRENT = "calibration.stop";

// Calibration events:
const WV_MESSAGE_LOCAL_CALIB_UPLOAD_REQUESTED =
    "calibration.local_calibrations_upload_requested";

// Custom IDs on Viewer
const FIND_MY_CAR_POI_ID = "-3";
