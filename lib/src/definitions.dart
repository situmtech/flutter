part of '../wayfinding.dart';

// Public definitions:

/// The [MapView] settings.
///
/// ```dart
/// MapView(
///   key: const Key("situm_map"),
///   configuration: MapViewConfiguration(
///     // Your Situm credentials.
///     situmUser: "YOUR-SITUM-USER",
///     situmApiKey: "YOUR-SITUM-API-KEY",
///     // Set your building identifier:
///     buildingIdentifier: "YOUR-SITUM-BUILDING-IDENTIFIER",
///     // Alternatively, you can set a profile name that allows you to remotely configure all map settings.
///     // profile: null;
///     viewerDomain: "map-viewer.situm.com",
///     apiDomain: "api.situm.com",
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
  /// profile (that will be prioritized).
  final String? buildingIdentifier;

  /// A String identifier that allows you to remotely configure all map settings.
  /// Alternatively you can pass a buildingIdentifier, remoteIdentifier
  /// will be prioritized.
  @Deprecated('Use profile instead')
  final String? remoteIdentifier;

  /// A String that specifies the selected profile name for configuring the [MapView]
  /// with its corresponding remote settings.
  ///
  /// When you set this attribute, the [MapView] will load the configuration associated
  /// with the provided profile name. This allows your application to dynamically adjust
  /// the MapView’s appearance and behavior based on predefined profiles.
  ///
  /// Alternatively you can pass a buildingIdentifier, profile will be prioritized.
  final String? profile;

  /// A String parameter that allows you to specify
  /// which domain will be displayed inside our webview.
  ///
  /// Default is [map-viewer.situm.com] (https://map-viewer.situm.com).
  ///
  ///[viewerDomain] should include only the domain (e.g., "map-viewer.situm.com").
  late final String viewerDomain;

  /// A String parameter that allows you to choose the API you will be retrieving
  /// our cartography from. Default is [api.situm.com](https://api.situm.com).
  ///
  /// [apiDomain] should include only the domain (e.g., "api.situm.com").
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

  /// Determine whether the underlying webview containing the map will use hybrid composition or not.
  /// Only for Android, see: https://docs.flutter.dev/platform-integration/android/platform-views
  /// The default value is true.
  final bool displayWithHybridComposition;

  /// Sets the UI language based on the given ISO 639-1 code. Checkout the
  /// [Situm docs](https://situm.com/docs/query-params/) to see the list of
  /// supported languages.
  final String? language;

  /// The [MapView] settings. Required fields are your Situm user and API key,
  /// but also a buildingIdentifier or profile.
  MapViewConfiguration({
    this.situmUser,
    required this.situmApiKey,
    this.buildingIdentifier,
    @Deprecated('Use profile instead') this.remoteIdentifier,
    this.profile,
    String? viewerDomain,
    this.apiDomain = "api.situm.com",
    this.directionality = TextDirection.ltr,
    this.enableDebugging = false,
    this.lockCameraToBuilding,
    this.persistUnderlyingWidget = false,
    this.displayWithHybridComposition = true,
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

  String? get _effectiveProfile =>
      profile?.isNotEmpty == true ? profile : remoteIdentifier;

  String get _internalApiDomain {
    String finalApiDomain = apiDomain.replaceFirst(RegExp(r'https://'), '');

    if (finalApiDomain.endsWith('/')) {
      finalApiDomain = finalApiDomain.substring(0, finalApiDomain.length - 1);
    }

    return finalApiDomain;
  }

  String _getViewerURL(String? deviceId) {
    if (buildingIdentifier == null && _effectiveProfile == null) {
      throw ArgumentError(
          'Missing configuration: profile or buildingIdentifier must be provided.');
    }
    var base = viewerDomain;
    var query = "apikey=$situmApiKey&domain=$_internalApiDomain&mode=embed";
    if (lockCameraToBuilding != null) {
      query = "$query&lockCameraToBuilding=$lockCameraToBuilding";
    }
    if (language != null) {
      query = "$query&lng=$language";
    }
    if (deviceId != null) {
      query = "$query&deviceId=$deviceId";
    }
    if (_effectiveProfile?.isNotEmpty == true) {
      base = "$base/id/$_effectiveProfile";
    }
    if (buildingIdentifier?.isNotEmpty == true && buildingIdentifier != "-1") {
      query = "$query&buildingid=$buildingIdentifier";
    }

    return "$base?$query";
  }
}

class DirectionsMessage {
  // ignore: constant_identifier_names
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

class SelectCartographyOptions {
  /// Set the [fitCamera] to true or false
  ///
  /// The truth value provokes that the camera will fit to cartographic element selected.
  ///
  /// Value defaults to false.
  bool? fitCamera;

  SelectCartographyOptions({this.fitCamera});

  toMap() {
    Map<String, Object> result = {};
    if (fitCamera != null) {
      result["fitCamera"] = fitCamera!;
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

/// This class represents the object that contains the message passed from
/// the viewer to the application. This message represents the requirement to
/// read aloud a text with some parameters like language, volume, etc
class OnSpeakAloudTextResult {
  /// A [String] that will be read aloud using TTS
  final String text;

  /// A [String] that represents the language code, i.e. es-ES
  final String? lang;

  /// A [Double] that represents the volume from 0.0 to 1.0
  final double? volume;

  /// A [Double] that represents the speech pitch from 0.0 to 1.0
  final double? pitch;

  /// A [Double] that represents the speech rate from 0.0 to 1.0
  final double? rate;

  const OnSpeakAloudTextResult(
      {required this.text, this.lang, this.volume, this.pitch, this.rate});

  toMap() {
    Map<String, Object> result = {};
    result["text"] = text;
    if (lang != null) {
      result["lang"] = lang!;
    }
    if (volume != null) {
      result["volume"] = volume!;
    }
    if (pitch != null) {
      result["pitch"] = pitch!;
    }
    if (rate != null) {
      result["rate"] = rate!;
    }

    return result;
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('\t').convert(toMap());
  }
}

class SearchFilter {
  /// Text used in the searchbar to filter and display the search results
  /// whose name or description matches the filter.
  ///
  /// An empty string will clear the current text filter (if any).
  /// A null value will apply no change.
  String? text;

  /// A [PoiCategory] identifier used to filter
  /// and display the POIs that belong to the given category.
  ///
  /// An empty string will clear the current category filter (if any).
  /// A null value will apply no change.
  String? poiCategoryIdentifier;

  SearchFilter({
    this.text,
    this.poiCategoryIdentifier,
  });

  toMap() {
    Map<String, Object> result = {};
    if (text != null) {
      result["text"] = text!;
    }
    if (poiCategoryIdentifier != null) {
      result["poiCategoryIdentifier"] = poiCategoryIdentifier!;
    }

    return result;
  }
}

enum ARStatus {
  /// The AR module has been presented successfully.
  success,

  /// There was an error while trying to present the AR module.
  error,

  /// The AR module has been hidden and finished working.
  finished,
}

// Connection errors
class ConnectionErrors {
  // ignore: constant_identifier_names
  static const ANDROID_NO_CONNECTION = -2;

  // ignore: constant_identifier_names
  static const ANDROID_SOCKET_NOT_CONNECTED = -6;

  // ignore: constant_identifier_names
  static const IOS_NO_CONNECTION = -1009;

  // ignore: constant_identifier_names
  static const IOS_HOSTNAME_NOT_RESOLVED = -1003;

  static const List<int> values = [
    ANDROID_NO_CONNECTION,
    ANDROID_SOCKET_NOT_CONNECTED,
    IOS_NO_CONNECTION,
    IOS_HOSTNAME_NOT_RESOLVED
  ];
}

class MapViewError {
  final String code;
  final String message;

  const MapViewError({required this.code, required this.message});

  static MapViewError noNetworkError() {
    return const MapViewError(
      code: "NO_NETWORK_ERROR",
      message:
          "There is no internet connection, unable to download all the resources",
    );
  }

  Map<String, dynamic> toMap() => {
        "code": code,
        "message": message,
      };

  @override
  String toString() {
    return const JsonEncoder.withIndent('\t').convert(toMap());
  }
}

class MapViewDirectionsOptions {
  List<String>? excludedTags;
  List<String>? includedTags;

  MapViewDirectionsOptions({this.excludedTags, this.includedTags});
}

/// # Don't use this class, it is intended for internal use.
/// Encapsulates the data of a calibration point. Each calibration point is
/// received from the [MapView] when it is in mode [UIMode.calibration].
class CalibrationPointData {
  final String buildingIdentifier;
  final String floorIdentifier;
  final Coordinate coordinate;

  CalibrationPointData({
    required this.buildingIdentifier,
    required this.floorIdentifier,
    required this.coordinate,
  });
}

/// # Don't use this enum, it is intended for internal use.
/// Status received when the [MapView] is in mode [UIMode.calibration] and the
/// user stops the current calibration.
/// The user may want to save ([success]) or cancel ([cancelled]) the
/// calibration. When saving, the last calibration point may be discarded ([undo]).
enum CalibrationFinishedStatus {
  success,
  undo,
  cancelled,
}

/// [MapView] UI Modes.
enum UIMode {
  calibration,
  explore,
}

// Result callbacks.

// WYF load callback.
typedef MapViewCallback = void Function(MapViewController controller);
// POI selection callback.
typedef OnPoiSelectedCallback = void Function(
    OnPoiSelectedResult poiSelectedResult);
// Car saved callback.
typedef OnCarSavedCallback = void Function(
    String floorIdentifier, Coordinate coordinate);
typedef OnMapViewErrorCallback = void Function(MapViewError error);
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
// TTS callback.
typedef OnSpeakAloudTextCallback = void Function(OnSpeakAloudTextResult data);

// Calibrations.
typedef OnCalibrationPointClickedCallback = void Function(
    CalibrationPointData data);
typedef OnCalibrationFinishedCallback = void Function(
    CalibrationFinishedStatus status);
