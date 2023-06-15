part of wayfinding;

DirectionsMessage createDirectionsMessage(arguments) => DirectionsMessage(
      buildingIdentifier: arguments["buildingIdentifier"],
      originIdentifier: (arguments["originIdentifier"] ?? -1).toString(),
      originCategory: arguments["originCategory"],
      destinationIdentifier: (arguments["destinationIdentifier"] ?? -1).toString(),
      destinationCategory: arguments["destinationCategory"],
    );
