#import "SITFSDKMapper.h"
#import <SitumSDK/SitumSDK.h>

@implementation SITFSDKMapper

NSString* const DATE_FORMAT = @"E MMM dd HH:mm:ss Z yyyy";

NSString* enforceToString(NSString *str) {
    if (!str || str == nil) {
        return @"";
    }
    return [NSString stringWithFormat:@"%@", str];
}

+ (NSDictionary *) dimensionsToDict:(SITDimensions *) dimensions {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"width"] = @(dimensions.width);
    dict[@"height"] = @(dimensions.height);
    
    return dict;
}

+ (NSDictionary *) boundsToDict:(SITBounds) bounds {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"southWest"] = [SITFSDKMapper coordinateToDict: bounds.southWest];
    dict[@"southEast"] = [SITFSDKMapper coordinateToDict: bounds.southEast];
    dict[@"northEast"] = [SITFSDKMapper coordinateToDict: bounds.northEast];
    dict[@"northWest"] = [SITFSDKMapper coordinateToDict: bounds.northWest];
    
    return dict;
}

+ (NSDictionary *) coordinateToDict:(CLLocationCoordinate2D) coordinate {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"latitude"] = @(coordinate.latitude);
    dict[@"longitude"] = @(coordinate.longitude);
    
    return dict;
}

+ (NSDictionary *) pointToDict:(SITPoint *) point {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"buildingIdentifier"] = enforceToString(point.buildingIdentifier);
    dict[@"floorIdentifier"] = enforceToString(point.floorIdentifier);
    dict[@"coordinate"] = [SITFSDKMapper coordinateToDict: point.coordinate];
    
    return dict;
}

+ (NSArray *) pointsToDictArray:(NSArray<SITPoint *> *) points {
    NSMutableArray *array = [NSMutableArray new];
    for (SITPoint* point in points) {
        [array addObject:[SITFSDKMapper pointToDict:point]];
    }
    return array;
}

+ (NSArray *) poiCategoriesToDictArray:(NSArray<SITPOICategory *> *) categories {
    NSMutableArray *array = [NSMutableArray new];
    for (SITPOICategory* category in categories) {
        [array addObject:[SITFSDKMapper poiCategoryToDict:category]];
    }
    return array;
}

+ (NSDictionary *) poiCategoryToDict:(SITPOICategory *) poiCategory {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"identifier"] = poiCategory ? enforceToString(poiCategory.identifier) : @"";
    dict[@"poiCategoryName"] = poiCategory ? enforceToString(poiCategory.name.value) : @"";
    
    return dict;
}

+ (NSDictionary *) circleAreaToDict:(SITCircularArea *) circle {
    NSMutableDictionary *dict  = [NSMutableDictionary new];
    dict[@"center"] = [SITFSDKMapper pointToDict:circle.center];
    dict[@"radius"] = circle.radius;
    
    return dict;
}

+ (NSArray *) eventsToDictArray:(NSArray<SITEvent *> *) events {
    NSMutableArray *array = [NSMutableArray new];
    for (SITEvent* event in events) {
        [array addObject:[SITFSDKMapper eventToDict:event]];
    }
    return array;
}

+ (NSDictionary *) eventToDict:(SITEvent *) event {
    NSMutableDictionary *dict  = [NSMutableDictionary new];
    dict[@"identifier"] = event.identifier;
    dict[@"buildingIdentifier"] = enforceToString(event.trigger.center.buildingIdentifier);
    dict[@"floorIdentifier"] = enforceToString(event.trigger.center.floorIdentifier);
    dict[@"name"] = enforceToString(event.name);
    dict[@"trigger"] = [SITFSDKMapper circleAreaToDict:event.trigger];
    dict[@"customFields"] = event.customFields ? event.customFields : [NSDictionary new];
    
    return dict;
}

+ (NSArray *) geofencesToDictArray:(NSArray<SITGeofence *> *) geofences {
    NSMutableArray *array = [NSMutableArray new];
    for (SITGeofence* geofence in geofences) {
        [array addObject:[SITFSDKMapper geofenceToDict:geofence]];
    }
    return array;
}

+ (NSDictionary *) geofenceToDict:(SITGeofence *) geofence {
    NSMutableDictionary *dict  = [NSMutableDictionary new];
    
    dict[@"identifier"] = enforceToString(geofence.identifier);
    dict[@"buildingIdentifier"] = enforceToString(geofence.buildingIdentifier);
    dict[@"floorIdentifier"] = enforceToString(geofence.floorIdentifier);
    dict[@"name"] = enforceToString(geofence.name);
    dict[@"polygonPoints"] = [SITFSDKMapper pointsToDictArray: geofence.polygonPoints];
    dict[@"customFields"] = geofence.customFields ? geofence.customFields : [NSDictionary new];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:DATE_FORMAT];
    dict[@"createdAt"] = enforceToString([formatter stringFromDate:geofence.createdAt]);
    dict[@"updatedAt"] = enforceToString([formatter stringFromDate:geofence.updatedAt]);
    
    return dict;
}

+ (NSArray *) floorsToDictArray:(NSArray<SITFloor *> *) floors {
    NSMutableArray *array = [NSMutableArray new];
    for (SITFloor* floor in floors) {
        [array addObject:[SITFSDKMapper floorToDict:floor]];
    }
    return array;
}

+ (NSDictionary *) floorToDict:(SITFloor *) floor {
    NSMutableDictionary *dict  = [NSMutableDictionary new];
    
    dict[@"buildingIdentifier"] = enforceToString(floor.buildingIdentifier);
    dict[@"floorIdentifier"] = enforceToString(floor.identifier);
    dict[@"floor"] = @(floor.floor);
    dict[@"name"] = enforceToString(floor.name);
    dict[@"mapUrl"] = enforceToString(floor.mapURL.direction);
    dict[@"scale"] = @(floor.scale);
    dict[@"customFields"] = floor.customFields ? floor.customFields : [NSDictionary new];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:DATE_FORMAT];
    dict[@"createdAt"] = enforceToString([formatter stringFromDate:floor.createdAt]);
    dict[@"updatedAt"] = enforceToString([formatter stringFromDate:floor.updatedAt]);
    
    return dict;
}


+ (NSDictionary *) buildingToDict:(SITBuilding *) building {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"buildingIdentifier"] = enforceToString(building.identifier);
    dict[@"address"] = enforceToString(building.address);
    dict[@"name"] = enforceToString(building.name);
    dict[@"pictureThumbUrl"] = building.pictureThumbURL ? enforceToString(building.pictureThumbURL.direction) : @"";
    dict[@"pictureUrl"] = building.pictureURL ? enforceToString(building.pictureURL.direction) : @"";
    dict[@"rotation"] = @(building.rotation.radians);
    dict[@"userIdentifier"] = enforceToString(building.userIdentifier);
    dict[@"customFields"] = building.customFields ? building.customFields : [NSDictionary new];
    dict[@"dimensions"] = [SITFSDKMapper dimensionsToDict: building.dimensions];
    dict[@"center"] = [SITFSDKMapper coordinateToDict: building.center];
    dict[@"bounds"] = [SITFSDKMapper boundsToDict: building.bounds];
    dict[@"boundsRotated"] = [SITFSDKMapper boundsToDict: building.rotatedBounds];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATE_FORMAT];
    dict[@"createdAt"] = enforceToString([formatter stringFromDate: building.createdAt]);
    dict[@"updatedAt"] = enforceToString([formatter stringFromDate: building.updatedAt]);
    
    return dict.copy;
}

+ (NSArray *) poisToDictArray:(NSArray<SITPOI *> *) pois {
    NSMutableArray *array = [NSMutableArray new];
    for (SITPOI* poi in pois) {
        [array addObject:[SITFSDKMapper poiToDict:poi]];
    }
    return array;
}

+ (NSDictionary *) poiToDict:(SITPOI *) poi {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"identifier"] = enforceToString(poi.identifier);
    dict[@"poiName"] = enforceToString(poi.name);
    // TODO: what is this?¿?
    dict[@"categoryId"] = poi.category ? enforceToString(poi.category.identifier) : @"";
    dict[@"buildingIdentifier"] = enforceToString(poi.buildingIdentifier);
    dict[@"customFields"] = poi.customFields ? poi.customFields : [NSDictionary new];
    dict[@"category"] = [SITFSDKMapper poiCategoryToDict:poi.category];
    dict[@"position"] = [SITFSDKMapper pointToDict: poi.position];
    
    return dict;
}

+ (NSDictionary *) buildingInfoToDict:(SITBuildingInfo *) buildingInfo {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"building"] = [SITFSDKMapper buildingToDict:buildingInfo.building];
    dict[@"floors"] = [SITFSDKMapper floorsToDictArray:buildingInfo.floors];
    dict[@"indoorPOIs"] = [SITFSDKMapper poisToDictArray:buildingInfo.indoorPois];
    dict[@"outdoorPOIs"] = [SITFSDKMapper poisToDictArray:buildingInfo.outdoorPois];
    dict[@"geofences"] = [SITFSDKMapper geofencesToDictArray:buildingInfo.geofences];
    dict[@"events"] = [SITFSDKMapper eventsToDictArray:buildingInfo.events];
    
    return dict;
}

@end
