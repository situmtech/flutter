part of wayfinding;

DirectionsMessage createDirectionsMessage(arguments) => DirectionsMessage(
      buildingIdentifier: arguments["buildingIdentifier"],
      originIdentifier: stringFromArgsOrEmptyId(arguments, "originIdentifier"),
      originCategory: arguments["originCategory"],
      destinationIdentifier: stringFromArgsOrEmptyId(arguments, "destinationIdentifier"),
      destinationCategory: arguments["destinationCategory"],
      identifier: (arguments["identifier"] ?? "").toString(),
      accessibilityMode:
          createAccessibilityMode(arguments["directionsRequest"]),
    );