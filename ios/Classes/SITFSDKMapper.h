#import <SitumSDK/SitumSDK.h>

@interface SITFSDKMapper : NSObject

+ (NSDictionary *) buildingToDict:(SITBuilding *) building;
+ (NSDictionary *) poiToDict:(SITPOI *) poi;

@end
