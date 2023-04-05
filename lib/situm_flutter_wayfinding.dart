library situm_flutter_wayfinding;

import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:situm_flutter_wayfinding/situm_flutter_sdk.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'src/mapper.dart';
part 'src/definitions.dart';
part 'src/controller.dart';
part 'src/situm_map_view.dart';

const CHANNEL_ID = 'situm.com/flutter_wayfinding';

const WV_CHANNEL = "ReactNativeWebView";
const WV_CHANNEL_LOCATION = "situm.location";

