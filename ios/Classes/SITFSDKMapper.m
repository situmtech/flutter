#import "SITFSDKMapper.h"
#import <SitumSDK/SitumSDK.h>

@implementation SITFSDKMapper

NSString* emptyStrCheck(NSString *str) {
    if (!str || str == nil) {
        return @"";
    } else {
        str = [NSString stringWithFormat:@"%@", str];
    }
    return str;
}

+ (NSDictionary *) dimensionsToDict:(SITDimensions *) dimensions {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"width"] =[NSNumber numberWithFloat: dimensions.width];
    dict[@"height"] =[NSNumber numberWithFloat: dimensions.height];
    
    return dict.copy;
}

+ (NSDictionary *) boundsToDict:(SITBounds) bounds {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"southWest"] = [SITFSDKMapper coordinateToDict: bounds.southWest];
    dict[@"southEast"] = [SITFSDKMapper coordinateToDict: bounds.southEast];
    dict[@"northEast"] = [SITFSDKMapper coordinateToDict: bounds.northEast];
    dict[@"northWest"] = [SITFSDKMapper coordinateToDict: bounds.northWest];
    
    return dict.copy;
}

+ (NSDictionary *) coordinateToDict:(CLLocationCoordinate2D) coordinate {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"latitude"] =[NSNumber numberWithFloat: coordinate.latitude];
    dict[@"longitude"] =[NSNumber numberWithFloat: coordinate.longitude];
    
    return dict.copy;
}

+ (NSDictionary *) pointToDict:(SITPoint *) point {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"buildingIdentifier"] = emptyStrCheck([NSString stringWithFormat:@"%@", point.buildingIdentifier]);
    dict[@"floorIdentifier"] = emptyStrCheck([NSString stringWithFormat:@"%@", point.floorIdentifier]);
    dict[@"coordinate"] = [SITFSDKMapper coordinateToDict: point.coordinate];
    
    return dict.copy;
}

+ (NSDictionary *) buildingToDict:(SITBuilding *) building {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    // TODO: checks for when strings are null
    dict[@"identifier"] = emptyStrCheck(building.identifier);
    dict[@"address"] = emptyStrCheck(building.address);
    dict[@"name"] = emptyStrCheck(building.name);
    dict[@"infoHtml"] = emptyStrCheck(building.infoHTML);
    dict[@"pictureThumbUrl"] = emptyStrCheck(building.pictureThumbURL);
    dict[@"pictureUrl"] = emptyStrCheck(building.pictureURL);
    dict[@"rotation"] = [NSNumber numberWithFloat: building.rotation.radians];
    dict[@"userIdentifier"] = emptyStrCheck(building.userIdentifier);
    
    dict[@"dimensions"] = [SITFSDKMapper dimensionsToDict: building.dimensions];
    dict[@"center"] = [SITFSDKMapper coordinateToDict: building.center];
    dict[@"bounds"] = [SITFSDKMapper boundsToDict: building.bounds];
    dict[@"boundsRotated"] = [SITFSDKMapper boundsToDict: building.rotatedBounds];
    
    return dict.copy;
}

+ (NSDictionary *) poiToDict:(SITPOI *) poi {
     NSMutableDictionary *dict = [NSMutableDictionary new];
     dict[@"identifier"] = emptyStrCheck([NSString stringWithFormat:@"%@", poi.identifier]);
     dict[@"poiName"] = poi.name ? poi.name : @"";
     dict[@"categoryId"] = emptyStrCheck([NSString stringWithFormat:@"%@", poi.category.identifier]);
     dict[@"buildingIdentifier"] = emptyStrCheck([NSString stringWithFormat:@"%@", poi.buildingIdentifier]);
     dict[@"customFields"] = poi.customFields ? poi.customFields : [NSDictionary new];

     dict[@"poiCategory"] =[NSMutableDictionary new];
     dict[@"poiCategory"][@"id"] = emptyStrCheck([NSString stringWithFormat:@"%@", poi.category.identifier]);
     dict[@"poiCategory"][@"poiCategoryName"] = poi.category.name.value;

     dict[@"position"] = [SITFSDKMapper pointToDict: poi.position];
     return dict.copy;
}
@end
