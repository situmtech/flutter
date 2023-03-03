#import <SitumSDK/SitumSDK.h>

@interface SITFSDKMapper : NSObject

+ (NSDictionary *) buildingToDict:(SITBuilding *);
+ (NSDictionary *) poiToDict:(SITPOI *);

@end