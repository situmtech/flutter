library situm_flutter_wayfinding;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:situm_flutter_wayfinding/situm_flutter_sdk.dart';
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
const WV_MESSAGE_LOCATION = "situm.location";
const WV_MESSAGE_DIRECTIONS_REQUEST = "situm.directions.request";
const WV_MESSAGE_NAVIGATION_START = "situm.navigation.start";
const WV_MESSAGE_POI_SELECTED = "situm.poi.select";
