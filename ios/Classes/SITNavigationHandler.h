//
//  SITNavigationHandler.h
//  situm_flutter_wayfinding
//
//  Created by fsvilas on 9/5/23.
//

#import <Foundation/Foundation.h>
#import <SitumSDK/SitumSDK.h>
#import <Flutter/Flutter.h>


NS_ASSUME_NONNULL_BEGIN

@interface SITNavigationHandler : NSObject

@property (nonatomic,strong) FlutterMethodChannel *channel;
+ (instancetype)sharedInstance;
@end

NS_ASSUME_NONNULL_END
