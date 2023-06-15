library wayfinding;
// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:situm_flutter/sdk.dart';
// WebView:
import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

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

// Actions sent to map-viewer:
const WV_MESSAGE_LOCATION = "location.update";
const WV_MESSAGE_DIRECTIONS_UPDATE = "directions.update";
const WV_MESSAGE_NAVIGATION_START = "navigation.start";
const WV_MESSAGE_NAVIGATION_UPDATE = "navigation.update";
