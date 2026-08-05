//
//  SITFSDKUtils.m
//  situm_flutter
//
//  Created by albasitum on 6/3/23.
//

#import "SITFSDKUtils.h"

@implementation SITFSDKUtils

+ (NSArray<NSDictionary *> *) toArrayDict:(NSArray<NSObject<SITMapperProtocol> *> *) objects {
    NSMutableArray *exportedArray = [NSMutableArray new];
    for (NSObject<SITMapperProtocol> * o in objects) {
        [exportedArray addObject:o.toDictionary];
    }
    return exportedArray;
}

+ (BOOL)isNullArgument:(NSString *)value {
    return (!value || [value isKindOfClass:[NSNull class]]);
}

+ (BOOL)isValidIdentifier:(NSString *)identifier {
    if ([self isNullArgument:identifier]) {
        return NO;
    }
    @try {
        NSInteger number = [identifier integerValue];
        return (number > 0);
    } @catch (NSException *exception) {
        return NO;
    }
}

+ (BOOL)isGlobalModeIdentifier:(NSString *)identifier {
    if ([self isNullArgument:identifier]) {
        return NO;
    }
    // Respect both Android ("-1") and iOS (empty string).
    return ([identifier isEqualToString:@"-1"] ||
            [identifier stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0);
}

@end
