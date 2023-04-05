library situm_flutter_wayfinding;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:situm_flutter_wayfinding/situm_flutter_sdk.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'src/controller.dart';
part 'src/definitions.dart';
part 'src/mapper.dart';
part 'src/message_handlers.dart';
part 'src/situm_map_view.dart';

const CHANNEL_ID = 'situm.com/flutter_wayfinding';

const WV_CHANNEL = "ReactNativeWebView";
const WV_CHANNEL_LOCATION = "situm.location";
const WV_CHANNEL_NAVIGATION_START = "situm.navigation.start";
