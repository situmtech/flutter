//
//  SITFSDKUtils.h
//  situm_flutter_wayfinding
//
//  Created by albasitum on 6/3/23.
//

#import <SitumSDK/SitumSDK.h>

@interface SITFSDKUtils : NSObject

+ (NSArray<NSDictionary *> *) toArrayDict:(NSArray<NSObject<SITMapperProtocol> *> *) objects;

@end
