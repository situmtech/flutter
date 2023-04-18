part of situm_flutter_wayfinding;

DirectionsMessage createDirectionsMessage(arguments) => DirectionsMessage(
      buildingId: arguments["buildingId"],
      originCategory: arguments["originCategory"],
      destinationCategory: arguments["destinationCategory"],
      directionsOptions:
          createDirectionsOptions(arguments["directionsOptions"]),
    );
