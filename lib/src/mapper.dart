part of wayfinding;

DirectionsMessage createDirectionsMessage(arguments) => DirectionsMessage(
      buildingIdentifier: arguments["buildingIdentifier"],
      originIdentifier: stringFromArgsOrEmptyId(arguments, "originIdentifier"),
      originCategory: arguments["originCategory"],
      destinationIdentifier:
          stringFromArgsOrEmptyId(arguments, "destinationIdentifier"),
      destinationCategory: arguments["destinationCategory"],
      identifier: (arguments["identifier"] ?? "").toString(),
      accessibilityMode:
          createAccessibilityMode(arguments["directionsRequest"]),
    );

CalibrationPointData createCalibrationPointData(Map<String, dynamic> payload) {
  final buildingId = payload["buildingIdentifier"];
  final floorId = payload["floorIdentifier"];
  final lat = payload["lat"];
  final lng = payload["lng"];
  final isIndoor = payload["isIndoor"];

  if (buildingId == null ||
      floorId == null ||
      lat == null ||
      lng == null ||
      isIndoor == null) {
    throw Exception('Invalid payload at createCalibrationPointData.');
  }

  if (lat is! double || lng is! double) {
    throw Exception('Invalid type for lat/lng at createCalibrationPointData.');
  }

  return CalibrationPointData(
    buildingIdentifier: "$buildingId",
    floorIdentifier: "$floorId",
    coordinate: Coordinate(
      latitude: lat,
      longitude: lng,
    ),
  );
}

CalibrationFinishedStatus createCalibrationFinishedStatus(payload) {
  final statusString = payload['status'];
  if (statusString == null) {
    throw Exception('Invalid payload at createCalibrationFinishedStatus.');
  }
  switch (statusString) {
    case 'success':
      return CalibrationFinishedStatus.success;
    case 'undo':
      return CalibrationFinishedStatus.undo;
    case 'cancelled':
      return CalibrationFinishedStatus.cancelled;
    default:
      throw Exception('Status $statusString not defined.');
  }
}
