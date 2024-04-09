part of wayfinding;

// Public definitions:

/// The [MapView] settings.
///
/// ```dart
/// MapView(
///   key: const Key("situm_map"),
///   configuration: MapViewConfiguration(
///   // Your Situm credentials.
///     situmUser: "YOUR-SITUM-USER",
///     situmApiKey: "YOUR-SITUM-API-KEY",
///   // Set your building identifier:
///     buildingIdentifier: "YOUR-SITUM-BUILDING-IDENTIFIER",
///   // Alternatively, you can set an identifier that allows you to remotely configure all map settings.
///   // For now, you need to contact Situm to obtain yours.
///   // remoteIdentifier: null;
///     viewerDomain: "map-viewer.situm.com",
///     apiDomain: "dashboard.situm.com",
///     directionality: TextDirection.ltr,
///     enableDebugging: false,
///   ),
/// ),
/// ```
class MapViewConfiguration {
  /// Your Situm user.
  final String? situmUser;

  /// Your Situm API key.
  final String situmApiKey;

  /// The building that will be loaded on the map. Alternatively you can pass a
  /// remoteIdentifier (that will be prioritized).
  final String? buildingIdentifier;

  /// A String identifier that allows you to remotely configure all map settings.
  /// Alternatively you can pass a buildingIdentifier, remoteIdentifier
  /// will be prioritized.
  final String? remoteIdentifier;

  /// A String parameter that allows you to specify
  /// which domain will be displayed inside our webview.
  ///
  /// Default is [map-viewer.situm.com] (https://map-viewer.situm.com).
  ///
  ///[viewerDomain] should include only the domain (e.g., "map-viewer.situm.com").
  late final String viewerDomain;

  /// A String parameter that allows you to choose the API you will be retrieving
  /// our cartography from. Default is [dashboard.situm.com](https://dashboard.situm.com).
  ///
  /// [apiDomain] should include only the domain (e.g., "dashboard.situm.com").
  /// * **Note**: When using [SitumSdk.setDashboardURL], make sure you introduce the same domain.
  final String apiDomain;

  /// Sets the directionality of the texts that will be displayed inside [MapView].
  /// Default is [TextDirection.ltr].
  final TextDirection directionality;

  /// Whether to enable the platform's webview content debugging tools.
  /// See [AndroidWebViewController.enableDebugging].
  ///
  /// Default is false.
  final bool enableDebugging;

  /// When set to true, the camera will be locked to the building so the user can't move it away. Also the minimum zoom will be set
  /// to an internally calculated value so the building remains visible when the user does zoom out.
  ///
  /// Default is false.
  final bool? lockCameraToBuilding;

  /// When set to true, the underlying WebView will persist over MapView disposals.
  ///
  /// As a consequence, the WebView widget will not be reloaded even when the
  /// MapView widget is disposed or rebuilt. This can lead to improved
  /// performance in cases where the WebView's content remains consistent
  /// between widget rebuilds. However, it also means that the WebView may
  /// persist in memory until the entire Flutter application is removed
  /// from memory.
  ///
  /// Default is false.
  final bool? persistUnderlyingWidget;

  /// Sets the UI language based on the given ISO 639-1 code. Checkout the
  /// [Situm docs](https://situm.com/docs/query-params/) to see the list of
  /// supported languages.
  final String? language;

  /// The [MapView] settings. Required fields are your Situm user and API key,
  /// but also a buildingIdentifier or remoteIdentifier.
  MapViewConfiguration({
    this.situmUser,
    required this.situmApiKey,
    this.buildingIdentifier,
    this.remoteIdentifier,
    String? viewerDomain,
    this.apiDomain = "dashboard.situm.com",
    this.directionality = TextDirection.ltr,
    this.enableDebugging = false,
    this.lockCameraToBuilding,
    this.persistUnderlyingWidget = false,
    this.language,
  }) {
    if (viewerDomain != null) {
      if (!viewerDomain.startsWith("https://") &&
          !viewerDomain.startsWith("http://")) {
        viewerDomain = "https://$viewerDomain";
      }
      if (viewerDomain.endsWith("/")) {
        viewerDomain = viewerDomain.substring(0, viewerDomain.length - 1);
      }
      this.viewerDomain = viewerDomain;
    } else {
      this.viewerDomain = "https://map-viewer.situm.com";
    }
  }

  String get _internalApiDomain {
    String finalApiDomain = apiDomain.replaceFirst(RegExp(r'https://'), '');

    if (finalApiDomain.endsWith('/')) {
      finalApiDomain = finalApiDomain.substring(0, finalApiDomain.length - 1);
    }

    return finalApiDomain;
  }

  String _getViewerURL() {
    var base = viewerDomain;
    var query = "apikey=$situmApiKey&domain=$_internalApiDomain&mode=embed";
    if (lockCameraToBuilding != null) {
      query = "$query&lockCameraToBuilding=$lockCameraToBuilding";
    }
    if (language != null) {
      query = "$query&lng=$language";
    }

    if (remoteIdentifier?.isNotEmpty == true &&
        buildingIdentifier?.isNotEmpty == true) {
      return "$base/id/$remoteIdentifier?$query&buildingid=$buildingIdentifier";
    } else if (remoteIdentifier?.isNotEmpty == true) {
      return "$base/id/$remoteIdentifier?$query";
    } else if (buildingIdentifier?.isNotEmpty == true) {
      return "$base/?$query&buildingid=$buildingIdentifier";
    }
    throw ArgumentError(
        'Missing configuration: remoteIdentifier or buildingIdentifier must be provided.');
  }
}

class DirectionsMessage {
  static const EMPTY_ID = "-1";

  // Identifier used by the map-viewer on the pre-route UI, where multiple
  // routes are calculated asynchronously.
  String? identifier;
  final String buildingIdentifier;
  final String originCategory;
  final String originIdentifier;
  final String destinationCategory;
  final String destinationIdentifier;
  final AccessibilityMode? accessibilityMode;

  DirectionsMessage({
    required this.buildingIdentifier,
    required this.originCategory,
    this.originIdentifier = EMPTY_ID,
    required this.destinationCategory,
    this.destinationIdentifier = EMPTY_ID,
    this.identifier,
    this.accessibilityMode,
  });
}

class Camera {
  /// Set the [zoom] to some value between 0 and 24.
  ///
  /// The value 0 shows a global view of the map and 24 offers a more detailed view. Take a look at [mapbox-gl](https://docs.mapbox.com/mapbox-gl-js/api/map/#map) documentation for further information.
  ///
  /// * **NOTE**: [MapViewConfiguration.lockCameraToBuilding] will set a new minimum value to make sure the building is still visible when zooming out.
  ///
  /// Value defaults to an internally calculated intermediate value.
  double? zoom;

  /// Set the [bearing] to a determined value in [Angle].
  ///
  /// Value defaults to 0° (north direction).
  Angle? bearing;

  /// Set the [pitch] to a determined [Angle] between 0° and 60°.
  ///
  /// Value defaults to 30°.
  Angle? pitch;

  /// Set the [transitionDuration] to a determined value in milliseconds. The value specified must be >= 0 and defining it to 0 will execute an instant camera animation.
  ///
  /// * **NOTE**: We prioritize user interactions with the map, so setting a high value for this parameter
  /// might result in your animation getting cut by the user.
  ///
  /// Value defaults to 1000 milliseconds.
  int? transitionDuration;

  /// Move the [center] of the camera to a [Coordinate] on the map.
  ///
  /// * **NOTE**: With [MapViewConfiguration.lockCameraToBuilding] set to true, introducing a coordinate far away from the building
  /// will result in the camera hitting the building bounds and not reaching the specified coordinate.
  Coordinate? center;

  Camera(
      {this.zoom,
      this.bearing,
      this.pitch,
      this.transitionDuration,
      this.center});

  toMap() {
    Map<String, Object> result = {};
    if (zoom != null) {
      result["zoom"] = zoom!;
    }
    if (bearing != null) {
      result["bearing"] = bearing!.degrees;
    }
    if (pitch != null) {
      result["pitch"] = pitch!.degrees;
    }
    if (transitionDuration != null) {
      result["transitionDuration"] = transitionDuration!;
    }
    if (center?.latitude != null && center?.longitude != null) {
      result["center"] = {
        "lat": center!.latitude,
        "lng": center!.longitude,
      };
    }

    return result;
  }
}

class OnPoiSelectedResult {
  final Poi poi;

  const OnPoiSelectedResult({
    required this.poi,
  });
}

class OnPoiDeselectedResult {
  final Poi poi;

  const OnPoiDeselectedResult({
    required this.poi,
  });
}

class OnExternalLinkClickedResult {
  final String url;

  const OnExternalLinkClickedResult({
    required this.url,
  });
}

enum ARStatus {
  /// The AR module has been presented successfully.
  success,

  /// There was an error while trying to present the AR module.
  error,

  /// The AR module has been hidden and finished working.
  finished,
}

class CalibrationPointData {
  final String buildingIdentifier;
  final String floorIdentifier;
  final Coordinate coordinate;
  final bool isIndoor;

  CalibrationPointData({
    required this.buildingIdentifier,
    required this.floorIdentifier,
    required this.coordinate,
    required this.isIndoor,
  });
}

// Result callbacks.

// WYF load callback.
typedef MapViewCallback = void Function(MapViewController controller);
// POI selection callback.
typedef OnPoiSelectedCallback = void Function(
    OnPoiSelectedResult poiSelectedResult);
// POI deselection callback.
typedef OnPoiDeselectedCallback = void Function(
    OnPoiDeselectedResult poiDeselectedResult);
// Directions and navigation interceptor.
typedef OnDirectionsRequestInterceptor = void Function(
    DirectionsRequest directionsRequest);
typedef OnNavigationRequestInterceptor = void Function(
    NavigationRequest navigationRequest);
// External link click.
typedef OnExternalLinkClickedCallback = void Function(
    OnExternalLinkClickedResult data);
// Calibrations.
// TODO: review names!!!
typedef OnCalibrationPointClickedCallback = void Function(
    CalibrationPointData data);
typedef OnCalibrationFinishedCallback = void Function();

// Connection errors
class ConnectionErrors {
  static const ANDROID_NO_CONNECTION = -2;
  static const ANDROID_SOCKET_NOT_CONNECTED = -6;
  static const IOS_NO_CONNECTION = -1009;
  static const IOS_HOSTNAME_NOT_RESOLVED = -1003;

  static const List<int> values = [
    ANDROID_NO_CONNECTION,
    ANDROID_SOCKET_NOT_CONNECTED,
    IOS_NO_CONNECTION,
    IOS_HOSTNAME_NOT_RESOLVED
  ];
}
