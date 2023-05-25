//
//  SITNavigation.m
//  situm_flutter_wayfinding
//
//  Created by fsvilas on 9/5/23.
//

#import "SITNavigationHandler.h"
#import <SitumSDK/SitumSDK.h>

@interface SITNavigationHandler()<SITNavigationDelegate, SITLocationDelegate>
@end

@implementation SITNavigationHandler

+ (instancetype)sharedInstance {
    static SITNavigationHandler *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SITNavigationHandler alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        //We use a shared manager to ensure that the location delegate of the NavigationManager will be always de same
        [SITLocationManager.sharedInstance addDelegate:self];
    }
    return self;
}


#pragma mark - SITNavigationDelegate methods

- (void)navigationManager:(id<SITNavigationInterface> _Nonnull)navigationManager destinationReachedOnRoute:(SITRoute * _Nonnull)route {
    NSLog(@"Navigation-> Destination Reached");
    [self.channel invokeMethod:@"onNavigationFinished" arguments: nil];
}

- (void)navigationManager:(id<SITNavigationInterface> _Nonnull)navigationManager didFailWithError:(NSError * _Nonnull)error {
    NSLog(@"Navigation-> Failed");
}

- (void)navigationManager:(id<SITNavigationInterface> _Nonnull)navigationManager didUpdateProgress:(SITNavigationProgress * _Nonnull)progress onRoute:(SITRoute * _Nonnull)route {
    NSLog(@"Navigation-> User Updated Progress");
    [self.channel invokeMethod:@"onNavigationProgress" arguments: [progress toDictionary]];
}

- (void)navigationManager:(id<SITNavigationInterface> _Nonnull)navigationManager userOutsideRoute:(SITRoute * _Nonnull)route {
    NSLog(@"Navigation-> User Outside Route");
    [self.channel invokeMethod:@"onUserOutsideRoute" arguments: nil];
}



#pragma mark - SITLocationDelegate methods

- (void)locationManager:(id<SITLocationInterface> _Nonnull)locationManager didFailWithError:(NSError * _Nullable)error {
    if ([SITNavigationManager sharedManager].isRunning){
        [SITNavigationManager.sharedManager removeUpdates];
    }
}

- (void)locationManager:(id<SITLocationInterface> _Nonnull)locationManager didUpdateLocation:(SITLocation * _Nonnull)location {
    if ([SITNavigationManager sharedManager].isRunning){
        [SITNavigationManager.sharedManager updateWithLocation:location];
    }
}

- (void)locationManager:(id<SITLocationInterface> _Nonnull)locationManager didUpdateState:(SITLocationState)state {
}

@end
