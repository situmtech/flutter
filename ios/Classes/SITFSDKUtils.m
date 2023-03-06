#import "SITFSDKUtils.h"

@implementation SITFSDKUtils

+ (NSArray<NSDictionary *> *) toDictArray:(NSArray<NSObject<SITMapperProtocol> *> *) objects {
    NSMutableArray *exportedArray = [NSMutableArray new];
    for (NSObject<SITMapperProtocol> * o in objects) {
        [exportedArray addObject:o.toDictionary];
    }
    return exportedArray;
}

@end