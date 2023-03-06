#import <SitumSDK/SitumSDK.h>

@interface SITFSDKUtils : NSObject

+ (NSArray<NSDictionary *> *) toDictArray:(NSArray<NSObject<SITMapperProtocol> *> *) objects;

@end
