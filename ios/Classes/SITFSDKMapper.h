#import <SitumSDK/SitumSDK.h>

@interface SITFSDKMapper : NSObject

+ (NSDictionary *) buildingToDict:(SITBuilding *) building;
+ (NSArray *) poisToDictArray:(NSArray<SITPOI *> *) pois;
+ (NSDictionary *) buildingInfoToDict:(SITBuildingInfo *) buildingInfo;
+ (NSArray *) geofencesToDictArray:(NSArray<SITGeofence *> *) geofences;
+ (NSArray *) poiCategoriesToDictArray:(NSArray<SITPOICategory *> *) categories;

@end
