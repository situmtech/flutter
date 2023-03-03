#import "SITFSDKMapper.h"

@implementation SITFSDKMapper

+ (NSDictionary *) dimensionsToDict:(SITDimensions *) dimensions {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"width"] =[NSNumber numberWithFloat: dimensions.width];
    dict[@"height"] =[NSNumber numberWithFloat: dimensions.height];

    return dict.copy();
}

+ (NSDictionary *) boundsToDict:(SITBounds *) bounds {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"southWest"] = [SITFSDKMapper coordinateToDict: bounds.southWest];
    dict[@"southEast"] = [SITFSDKMapper coordinateToDict: bounds.southEast];
    dict[@"northEast"] = [SITFSDKMapper coordinateToDict: bounds.northEast];
    dict[@"northWest"] = [SITFSDKMapper coordinateToDict: bounds.northWest];

    return dict.copy();
}

+ (NSDictionary *) coordinateToDict:(CLLocationCoordinate2D *) coordinate {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"latitude"] =[NSNumber numberWithFloat: coordinate.latitude];
    dict[@"longitude"] =[NSNumber numberWithFloat: coordinate.longitude];

    return dict.copy();
}

+ (NSDictionary *) pointToDict:(SITPoint *) point {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"buildingIdentifier"] = [NSString stringWithFormat:@"%@", point.buildingIdentifier];
    dict[@"floorIdentifier"] = [NSString stringWithFormat:@"%@", point.floorIdentifier];
    dict[@"coordinate"] = [SITFSDKMapper coordinateToDict: point.coordinate];

    return dict.copy();
}

+ (NSDictionary *) buildingToDict:(SITBuilding *) building {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"identifier"] = [NSString stringWithFormat:@"%@", building.buildingIdentifier];
    dict[@"address"] = [NSString stringWithFormat:@"%@", building.address];
    dict[@"name"] = [NSString stringWithFormat:@"%@", building.name];
    dict[@"infoHtml"] = [NSString stringWithFormat:@"%@", building.infoHtml];
    dict[@"pictureThumbUrl"] = building.pictureThumbUrl ? building.pictureThumbUrl : @"";
    dict[@"pictureUrl"] = building.pictureUrl ? building.pictureUrl : @"";
    dict[@"rotation"] = [NSNumber numberWithFloat: building.rotation];
    dict[@"userIdentifier"] = [NSString stringWithFormat:@"%@", building.userIdentifier];

    dict[@"dimensions"] = [SITFSDKMapper dimensionsToDict: building.dimensions];
    dict[@"center"] = [SITFSDKMapper coordinateToDict: building.center];
    dict[@"bounds"] = [SITFSDKMapper boundsToDict: building.bounds];
    dict[@"boundsRotated"] = [SITFSDKMapper boundsToDict: building.boundsRotated];

    return dict.copy();
}

// + (NSDictionary *) poiToDict:(SITPOI *) poi {
//     NSMutableDictionary *dict = [NSMutableDictionary new];
//     dict[@"identifier"] = [NSString stringWithFormat:@"%@", poi.identifier];
//     dict[@"poiName"] = poi.name ? poi.name : @"";
//     dict[@"categoryId"] = [NSString stringWithFormat:@"%@", poi.category.identifier];
//     dict[@"buildingIdentifier"] = [NSString stringWithFormat:@"%@", poi.buildingIdentifier];
//     dict[@"customFields"] = poi.customFields ? poi.customFields : [NSDictionary new];
    
//     dict[@"poiCategory"] =[NSMutableDictionary new];
//     dict[@"poiCategory"][@"id"] = [NSString stringWithFormat:@"%@", poi.category.identifier];
//     dict[@"poiCategory"][@"poiCategoryName"] = poi.category.name.value;

//     dict[@"position"] = [SITFSDKMapper pointToDict: poi.position];
//     return dict.copy();
// }