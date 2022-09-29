part of situm_flutter_sdk;

class OnLocationChangedResult {
  final String buildingId;

  const OnLocationChangedResult({
    required this.buildingId,
  });
}

class OnEnterGeofenceResult {
  final String geofenceId;
  final String geofenceName;

  const OnEnterGeofenceResult({
    required this.geofenceId,
    required this.geofenceName,
  });
}

class Error {
  final Int code;
  final String message;

  const Error({required this.code, required this.message});
}

// Result callbacks.

// Location updates.

abstract class LocationListener {
  void onError(Error error);

  void onLocationChanged(OnLocationChangedResult locationChangedResult);

  void onStatusChanged(String status);
}

// On enter geofences.
typedef OnEnterGeofenceCallback = void Function(
    List<OnEnterGeofenceResult> onEnterGeofenceResult);
