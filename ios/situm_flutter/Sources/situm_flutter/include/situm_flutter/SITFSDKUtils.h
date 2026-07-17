//
//  SITFSDKUtils.h
//  situm_flutter
//
//  Created by albasitum on 6/3/23.
//

#import <SitumSDK/SitumSDK.h>

@interface SITFSDKUtils : NSObject

+ (NSArray<NSDictionary *> *) toArrayDict:(NSArray<NSObject<SITMapperProtocol> *> *) objects;
+ (BOOL)isNullArgument:(NSString *)value;
+ (BOOL)isValidIdentifier:(NSString *)identifier;
+ (BOOL)isGlobalModeIdentifier:(NSString *)identifier;

@end
