part of situm_flutter_wayfinding;

DirectionsMessage createDirectionsMessage(arguments) => DirectionsMessage(
      buildingId: arguments["buildingId"],
      originId: (arguments["originId"] ?? -1).toString(),
      originCategory: arguments["originCategory"],
      destinationId: (arguments["destinationId"] ?? -1).toString(),
      destinationCategory: arguments["destinationCategory"],
      directionsOptions:
          createDirectionsOptions(arguments["directionsOptions"]),
    );
