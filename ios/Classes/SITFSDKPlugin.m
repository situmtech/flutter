//
//  SITFSDKPlugin.m
//  situm_flutter_wayfinding
//
//  Created by Abraham Barros Barros on 30/9/22.
//

#import "SITFSDKPlugin.h"

#import <SitumSDK/SitumSDK.h>

#import <CoreLocation/CoreLocation.h>

#import "SITFNativeMapView.h"

// static FlutterMethodChannel *channel;

@interface SITFSDKPlugin() <SITLocationDelegate, SITGeofencesDelegate>

@property (nonatomic, strong) SITCommunicationManager *comManager;
@property (nonatomic, strong) SITLocationManager *locManager;

@property (nonatomic, strong) FlutterMethodChannel *channel;

@end

@implementation SITFSDKPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
    SITFNativeMapViewFactory* factory =
          [[SITFNativeMapViewFactory alloc] initWithMessenger:registrar.messenger];
      [registrar registerViewFactory:factory withId:@"<platform-view-type>"];

    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"situm.com/flutter_sdk" binaryMessenger:[registrar messenger]];
    SITFSDKPlugin* instance = [[SITFSDKPlugin alloc] init];
    instance.comManager = [SITCommunicationManager sharedManager];
    instance.locManager = [SITLocationManager sharedInstance];
    instance.channel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
    
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"init" isEqualToString:call.method]) {
        [self handleInit:call result:result];
    } else if ([@"clearCache" isEqualToString:call.method]) {
        [self handleClearCache:call result:result];
    } else if ([@"requestLocationUpdates" isEqualToString:call.method]) {
        [self handleRequestLocationUpdates:call
                                    result:result];
    } else if ([@"removeUpdates" isEqualToString: call.method]) {
        [self handleRemoveUpdates:call
                           result:result];
    } else if ([@"prefetchPositioningInfo" isEqualToString:call.method]) {
        [self handlePrefetchPositioningInfo:call
                                     result:result];
    } else if ([@"fetchPoisFromBuilding" isEqualToString:call.method]) {
        [self handleFetchPoisFromBuilding:call
                                   result:result];
    } else if ([@"fetchCategories" isEqualToString:call.method]) {
        [self handleFetchCategories:call
                             result:result];
    } else if ([@"geofenceCallbacksRequested" isEqualToString:call.method]){
        [self handleGeofenceCallbacksRequested: call
                                        result: result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleInit:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *situmUser = call.arguments[@"situmUser"];
    NSString *situmApiKey = call.arguments[@"situmApiKey"];
    
    if (!situmUser || !situmApiKey) {
        NSLog(@"error providing credentials");
        // TODO: Send error to dart
    }
    
    [SITServices provideAPIKey:situmApiKey
                      forEmail:situmUser];
    
    
    [SITServices setUseRemoteConfig:YES];
    
    result(@"DONE");
}

- (void)handleClearCache:(FlutterMethodCall *)call
                  result:(FlutterResult)result {
    [SITServices clearData];
    [SITServices clearAllData];
    
    result(@"DONE");
}


- (void)handleRequestLocationUpdates:(FlutterMethodCall*)call
                              result:(FlutterResult)result {
    
    CLLocationManager *lManager = [CLLocationManager new];
    
    [lManager requestWhenInUseAuthorization];
    
    self.locManager.delegate = self;
    [self.locManager requestLocationUpdates:nil];
    
    result(@"DONE");
}

- (void)handleRemoveUpdates:(FlutterMethodCall*)call result:(FlutterResult)result {
    [self.locManager removeUpdates];
    
    result(@"DONE");
}

- (void)handlePrefetchPositioningInfo:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSArray *buildingIdentifiers = call.arguments[@"buildingIdentifiers"];
    
    if (!buildingIdentifiers) {
        FlutterError *error = [FlutterError errorWithCode:@"errorPrefetch"
                                                  message:@"Unable to retrieve buildingIdentifiers string on arguments"
                                                  details:nil];

        result(error); // Send error
        return;
    }
    
    [self.comManager prefetchPositioningInfoForBuildings:buildingIdentifiers
                                             withOptions:nil
                                          withCompletion:^(NSError * _Nullable error) {
        if (error) {
            FlutterError *ferror = [FlutterError errorWithCode:@"errorPrefetch"
                                                      message:[NSString stringWithFormat:@"Failed with error: %@", error]
                                                      details:nil];
            result(ferror); // Send error
        } else {
            result(@"DONE");
        }
    }];
}

- (void)handleFetchPoisFromBuilding:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    NSString *buildingId = call.arguments[@"buildingId"];
    
    if (!buildingId) {
        FlutterError *error = [FlutterError errorWithCode:@"errorFetchPois"
                                                  message:@"Unable to retrieve buildingId string on arguments"
                                                  details:nil];

        result(error); // Send error
        return;
    }
    
    [self.comManager fetchPoisOfBuilding:buildingId
                             withOptions:nil
                                 success:^(NSDictionary * _Nullable mapping) {
        
        NSMutableArray *exportedArray = [NSMutableArray new];
        for (SITPOI *poi in mapping[@"results"]) {
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            dict[@"id"] = [NSString stringWithFormat:@"%@", poi.identifier];
            dict[@"name"] = poi.name ? poi.name : @"";
            dict[@"categoryId"] = [NSString stringWithFormat:@"%@", poi.category.identifier];
            dict[@"buildingId"] = [NSString stringWithFormat:@"%@", poi.buildingIdentifier];

            
            
            [exportedArray addObject:dict];
        }
        
        result(exportedArray);
        
    } failure:^(NSError * _Nullable error) {
        FlutterError *ferror = [FlutterError errorWithCode:@"errorPrefetch"
                                                  message:[NSString stringWithFormat:@"Failed with error: %@", error]
                                                  details:nil];
        result(ferror); // Send error
    }];
    
}



- (void)handleFetchCategories:(FlutterMethodCall*)call
                       result:(FlutterResult)result {
    [self.comManager fetchCategoriesWithOptions:nil withCompletion:^(NSArray * _Nullable categories, NSError * _Nullable error) {
        if (error) {
            FlutterError *ferror = [FlutterError errorWithCode:@"errorFetchCategories"
                                                      message:[NSString stringWithFormat:@"Failed with error: %@", error]
                                                      details:nil];
            result(ferror); // Send error
        } else {
            NSMutableArray *exportedArray = [NSMutableArray new];
            
            
            for (SITPOICategory *category in categories) {
                NSMutableDictionary *dict = [NSMutableDictionary new];
                
                dict[@"id"] = [NSString stringWithFormat:@"%@",  category.identifier ];
                dict[@"name"] = category.name.value;
                
                
                [exportedArray addObject:dict];
            }
            
            result(exportedArray);
        }
    }];
}



- (void)locationManager:(id<SITLocationInterface> _Nonnull)locationManager
       didFailWithError:(NSError * _Nullable)error {
    
    NSLog(@"location Manager on error: %@", error);
    
    NSMutableDictionary *args = [NSMutableDictionary new];

    args[@"code"] = [NSString stringWithFormat:@"%ld", (long)error.code];
    args[@"message"] = [NSString stringWithFormat:@"%@", error.userInfo];

    [self.channel invokeMethod:@"onError" arguments:args];

}

- (void)locationManager:(id<SITLocationInterface> _Nonnull)locationManager
      didUpdateLocation:(SITLocation * _Nonnull)location {
    
    NSLog(@"location Manager on location: %@", location);

    NSMutableDictionary *args = [NSMutableDictionary new];
    args[@"buildingId"] = [NSString stringWithFormat:@"%@", location.position.buildingIdentifier];
    // TODO: Complete location conversion
    
    [self.channel invokeMethod:@"onLocationChanged" arguments:args];
}

- (void)locationManager:(id<SITLocationInterface> _Nonnull)locationManager didUpdateState:(SITLocationState)state {
    
    NSLog(@"location Manager on state: %ld", state);

    
    NSMutableDictionary *args = [NSMutableDictionary new];

    args[@"status"] = [NSString stringWithFormat:@"%d", state];
    
    [self.channel invokeMethod:@"onStatusChanged" arguments:args];
}

- (void)locationManager:(id<SITLocationInterface>)locationManager
didInitiatedWithRequest:(SITLocationRequest *)request
{
    
}

- (void)didEnteredGeofences:(NSArray<SITGeofence *> *)geofences {
    NSLog(@"location Manager did entered geofences");
    [self.channel invokeMethod:@"onEnteredGeofences" arguments:[self nativeGeofenceArrayToDart:geofences]];
}

- (void)didExitedGeofences:(NSArray<SITGeofence *> *)geofences {
    NSLog(@"location Manager did exited geofences");
    [self.channel invokeMethod:@"onExitedGeofences" arguments:[self nativeGeofenceArrayToDart:geofences]];
}

-(NSArray<NSDictionary *> *)nativeGeofenceArrayToDart:(NSArray<SITGeofence *> *)nativeGeofences{
    NSMutableArray *dartGeofences = [NSMutableArray new];
    for (SITGeofence * geofence in nativeGeofences){
        NSMutableDictionary *dartGeofence = [NSMutableDictionary new];
        dartGeofence[@"id"] = geofence.identifier;
        dartGeofence[@"name"] = geofence.name;
        [dartGeofences addObject:dartGeofence];
    }
    return dartGeofences;
}

- (void) handleGeofenceCallbacksRequested :(FlutterMethodCall*)call
                                    result:(FlutterResult)result {
    self.locManager.geofenceDelegate = self;
}

@end
