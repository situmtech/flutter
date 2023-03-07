//
//  SITFSDKUtils.m
//  situm_flutter_wayfinding
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

@end
