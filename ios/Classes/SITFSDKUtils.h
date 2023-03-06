#import <SitumSDK/SitumSDK.h>

@interface SITFSDKUtils : NSObject

+ (NSArray<NSDictionary *> *) objectToDictArray:(NSArray<NSObject<SITMapperProtocol> *> *) objects;

@end
