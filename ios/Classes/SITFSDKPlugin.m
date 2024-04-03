//
//  SITFSDKPlugin.m
//  situm_flutter
//
//  Created by Abraham Barros Barros on 30/9/22.
//

#import "SITFSDKPlugin.h"
#import "SITFSDKUtils.h"
#import <SitumSDK/SitumSDK.h>
#import <CoreLocation/CoreLocation.h>
#import "SITNavigationHandler.h"

@interface SITFSDKPlugin() <SITLocationDelegate, SITGeofencesDelegate>

@property (nonatomic, strong) SITCommunicationManager *comManager;
@property (nonatomic, strong) SITLocationManager *locManager;
@property (nonatomic, strong) SITNavigationHandler *navigationHandler;

@property (nonatomic, strong) FlutterMethodChannel *channel;

@end

@implementation SITFSDKPlugin

const NSString* RESULTS_KEY = @"results";

+(void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"situm.com/flutter_sdk" binaryMessenger:[registrar messenger]];
    SITFSDKPlugin* instance = [[SITFSDKPlugin alloc] init];
    instance.comManager = [SITCommunicationManager sharedManager];
    instance.locManager = [SITLocationManager sharedInstance];
    instance.navigationHandler = [SITNavigationHandler sharedInstance];
    instance.navigationHandler.channel = channel;
    [SITNavigationManager.sharedManager addDelegate:instance.navigationHandler];
    instance.channel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"init" isEqualToString:call.method]) {
        [self handleInit:call result:result];
    } else if ([@"initSdk" isEqualToString:call.method]) {
        [self handleInitSdk: call
                     result: result];
    } else if ([@"setDashboardURL" isEqualToString:call.method]) {
        [self handleSetDashboardURL: call
                             result: result];
    } else if ([@"setApiKey" isEqualToString:call.method]) {
        [self handleSetApiKey:call result:result];
    } else if ([@"setConfiguration" isEqualToString:call.method]) {
        [self handleSetConfiguration: call
                              result: result];
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
    } else if ([@"fetchPoiFromBuilding" isEqualToString:call.method]) {
        [self handleFetchPoiFromBuilding:call
                                  result:result];
    } else if ([@"fetchCategories" isEqualToString:call.method]) {
        [self handleFetchCategories:call
                             result:result];
    } else if ([@"geofenceCallbacksRequested" isEqualToString:call.method]){
        [self handleGeofenceCallbacksRequested: call
                                        result: result];
    } else if ([@"fetchBuildings" isEqualToString:call.method]) {
        [self handleFetchBuildings:call
                            result:result];
    } else if ([@"fetchBuildingInfo" isEqualToString:call.method]) {
        [self handleFetchBuildingInfo:call
                               result:result];
    } else if ([@"getDeviceId" isEqualToString:call.method]) {
        [self getDeviceId:call result:result];
    } else if ([@"requestNavigation" isEqualToString:call.method]) {
        [self requestNavigation:call
                         result:result];
    } else if ([@"requestDirections" isEqualToString:call.method]) {
        [self requestDirections:call
                         result:result];
    } else if ([@"stopNavigation" isEqualToString:call.method]){
        [self stopNavigation:call
                      result:result];
    } else if ([@"openUrlInDefaultBrowser" isEqualToString:call.method]) {
        [self openUrlInDefaultBrowser:call
                               result:result];
    } else if ([@"addExternalLocation" isEqualToString:call.method]){
        [self addExternalLocation:call
                      result:result];
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
    
    // TODO: por que está esto aquí?
    [SITServices setUseRemoteConfig:YES];

    // Start listening location updates as soon as the SDK gets initialized:
    [self.locManager addDelegate:self];

    result(@"DONE");
}

- (void)handleInitSdk:(FlutterMethodCall*)call result:(FlutterResult)result {
    // Start listening location updates as soon as the SDK gets initialized:
    [self.locManager addDelegate:self];

    result(@"DONE");
}

- (void)handleSetDashboardURL:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *url = call.arguments[@"url"];
    [SITServices setDashboardURL: url];
    result(@"DONE");
}

- (void)handleSetApiKey:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *situmUser = call.arguments[@"situmUser"];
    NSString *situmApiKey = call.arguments[@"situmApiKey"];
    
    if (!situmUser || !situmApiKey) {
        NSLog(@"error providing credentials");
        // TODO: Send error to dart
    }
    
    [SITServices provideAPIKey:situmApiKey
                      forEmail:situmUser];
    result(@"DONE");
}

- (void)handleSetConfiguration:(FlutterMethodCall*)call result:(FlutterResult)result {
    BOOL useRemoteConfig = [call.arguments[@"useRemoteConfig"] boolValue];
    [SITServices setUseRemoteConfig:useRemoteConfig];
    result(@"DONE");
}

- (void)handleClearCache:(FlutterMethodCall *)call
                  result:(FlutterResult)result {
    [[SITCommunicationManager sharedManager] clearCache];
    result(@"DONE");
}


- (void)handleRequestLocationUpdates:(FlutterMethodCall*)call
                              result:(FlutterResult)result {
    if ([call.arguments objectForKey:@"useExternalLocations"]) {
        [SITServices setUseExternalLocations:true];
    }
    SITLocationRequest * locationRequest = [self createLocationRequest:call.arguments];
    [self.locManager requestLocationUpdates:locationRequest];
    result(@"DONE");
}

-(SITOutdoorLocationOptions *)createOutdoorLocationOptions:(NSDictionary *)arguments {
    SITOutdoorLocationOptions *options = [[SITOutdoorLocationOptions alloc] init];
    if ([arguments objectForKey:@"enableOutdoorPositions"]) {
        bool enableOutdoorPositions = [arguments[@"enableOutdoorPositions"] boolValue];
        options.enableOutdoorPositions = enableOutdoorPositions;
    }
    return options;
}

SITRealtimeUpdateInterval createRealtimeUpdateInterval(NSString *name) {
    const NSDictionary *stringToEnum = @{
        @"NEVER": @(kSITUpdateNever),
        @"BATTERY_SAVER": @(kSITUpdateIntervalBatterySaver),
        @"SLOW": @(kSITUpdateIntervalSlow),
        @"NORMAL": @(kSITUpdateIntervalNormal),
        @"FAST": @(kSITUpdateIntervalFast),
        @"REALTIME": @(kSITUpdateIntervalRealtime)
    };
    NSNumber *enumNumber = stringToEnum[name];
    if (enumNumber != nil) {
        return (SITRealtimeUpdateInterval)enumNumber.unsignedIntegerValue;
    } else {
        return kSITUpdateIntervalNormal;
    }
}

-(SITLocationRequest *)createLocationRequest:(NSDictionary *)arguments{
    SITLocationRequest *locationRequest = [SITLocationRequest new];
    NSString *buildingID = arguments[@"buildingIdentifier"];
    if ([SITFSDKUtils isValidIdentifier:buildingID]){
        locationRequest.buildingID = buildingID;
    } else if ([SITFSDKUtils isGlobalModeIdentifier:buildingID]){
        locationRequest.buildingID = @"";
    }
    NSString *useDeadReckoning = arguments[@"useDeadReckoning"];
    if (![SITFSDKUtils isNullArgument:useDeadReckoning]){
        locationRequest.useDeadReckoning = [useDeadReckoning boolValue];
    }
    NSString *realtimeUpdateInterval = arguments[@"realtimeUpdateInterval"];
    if (realtimeUpdateInterval != nil) {
        locationRequest.realtimeUpdateInterval = createRealtimeUpdateInterval(realtimeUpdateInterval);
    }
    NSDictionary *outdoorOptionsMap = arguments[@"outdoorLocationOptions"];
    if (outdoorOptionsMap != nil) {
        locationRequest.outdoorLocationOptions = [self createOutdoorLocationOptions:arguments[@"outdoorLocationOptions"]];
    }
    return locationRequest;
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
    
    NSString *buildingId = call.arguments[@"buildingIdentifier"];
    
    if (!buildingId) {
        FlutterError *error = [FlutterError errorWithCode:@"errorFetchPoisFromBuilding"
                                                  message:@"Unable to retrieve buildingId string on arguments"
                                                  details:nil];
        
        result(error); // Send error
        return;
    }
    
    [self.comManager fetchPoisOfBuilding:buildingId
                             withOptions:nil
                                 success:^(NSDictionary * _Nullable mapping) {
                                    result([SITFSDKUtils toArrayDict: mapping[RESULTS_KEY]]);
                                 } 
                                 failure:^(NSError * _Nullable error) {
        FlutterError *ferror = [FlutterError errorWithCode:@"errorFetchPoisFromBuilding"
                                                   message:[NSString stringWithFormat:@"Failed with error: %@", error]
                                                   details:nil];
        result(ferror); // Send error
    }];
}

- (void)handleFetchPoiFromBuilding:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    NSString *buildingId = call.arguments[@"buildingIdentifier"];
    NSString *poiId = call.arguments[@"poiIdentifier"];
    
    if (!buildingId || !poiId) {
        FlutterError *error = [FlutterError errorWithCode:@"errorFetchPoiFromBuilding"
                                                  message:@"Unable to retrieve buildingIdentifier or poiIdentifier string on arguments"
                                                  details:nil];
        
        result(error); // Send error
        return;
    }
    
    [self.comManager  fetchIndoorPoi:poiId 
                          ofBuilding:buildingId
                         withOptions:nil
                             success:^(NSDictionary * _Nullable mapping) {
                                    SITPOI *poi = mapping[RESULTS_KEY];
        
                                    result(poi.toDictionary);
                                 }
                             failure:^(NSError * _Nullable error) {
        FlutterError *ferror = [FlutterError errorWithCode:@"errorFetchPoisFromBuilding"
                                                   message:[NSString stringWithFormat:@"Failed with error: %@", error]
                                                   details:nil];
        result(ferror); // Send error
    }];


}

- (void)handleFetchBuildings:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    [self.comManager fetchBuildingsWithOptions: nil
                                       success:^(NSDictionary * _Nullable mapping) {
        
        result([SITFSDKUtils toArrayDict: mapping[RESULTS_KEY]]);
        
    } failure:^(NSError * _Nullable error) {
        FlutterError *ferror = [FlutterError errorWithCode:@"errorFetchBuildings"
                                                   message:[NSString stringWithFormat:@"Failed with error: %@", error]
                                                   details:nil];
        result(ferror); // Send error
    }];
}

- (void)handleFetchBuildingInfo:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    NSString *buildingId = call.arguments[@"buildingIdentifier"];
    
    if (!buildingId) {
        FlutterError *error = [FlutterError errorWithCode:@"errorFetchBuildingInfo"
                                                  message:@"Unable to retrieve buildingId string on arguments"
                                                  details:nil];
        
        result(error); // Send error
        return;
        
    }
    [self.comManager fetchBuildingInfo:buildingId
                           withOptions:nil
                               success:^(NSDictionary * _Nullable mapping) {
        result(((SITBuildingInfo*) mapping[RESULTS_KEY]).toDictionary);
        
    } failure:^(NSError * _Nullable error) {
        FlutterError *ferror = [FlutterError errorWithCode:@"errorFetchBuildingInfo"
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
            result([SITFSDKUtils toArrayDict: categories]);
        }
    }];
}
- (void)getDeviceId:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *deviceID = SITServices.deviceID;
    result(deviceID);
}

- (void)requestNavigation:(FlutterMethodCall*)call
                   result:(FlutterResult)result{
    SITDirectionsRequest *directionsRequest = [SITDirectionsRequest fromDictionary:call.arguments[@"directionsRequest"]];
    SITNavigationRequest *navigationRequest = [SITNavigationRequest fromDictionary:call.arguments[@"navigationRequest"]];
    [SITNavigationManager.sharedManager requestNavigationUpdates:navigationRequest directionsRequest:directionsRequest completion:^(SITRoute * _Nullable route, NSError * _Nullable error) {
        if (error || route.routeSteps.count == 0){
            FlutterError *fError = [self creteFlutterErrorCalculatingRoute];
            result(fError);
            return;
        }
        result(route.toDictionary);
    }];
}

- (void)requestDirections:(FlutterMethodCall*)call
                   result:(FlutterResult)result{
    SITDirectionsRequest *directionsRequest = [SITDirectionsRequest fromDictionary:call.arguments];
    [SITDirectionsManager.sharedInstance requestDirections:directionsRequest completion:^(SITRoute * _Nullable route, NSError * _Nullable error) {
        if (error || route.routeSteps.count == 0){
            FlutterError *fError = [self creteFlutterErrorCalculatingRoute];
            result(fError);
            return;
        }
        result(route.toDictionary);
    }];
}

-(FlutterError *)creteFlutterErrorCalculatingRoute{
    FlutterError *fError = [FlutterError errorWithCode:@"errorCalculatingRoute"
                                              message:@"Unable to calulate route"
                                              details:nil];
    return fError;
}

- (void)stopNavigation:(FlutterMethodCall*)call
                   result:(FlutterResult)result{
    [SITNavigationManager.sharedManager removeUpdates];
    result(@"DONE");
}

- (void)openUrlInDefaultBrowser:(FlutterMethodCall*)call
                         result:(FlutterResult)result{
    NSString *urlString = call.arguments[@"url"];
    if (urlString == nil) {
        result(@(NO));
        return;
    }
    NSURL *url = [NSURL URLWithString:urlString];
    if (![[UIApplication sharedApplication] canOpenURL:url]) {
        result(@(NO));
        return;
    }
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    result(@(YES));
}

- (void)addExternalLocation:(FlutterMethodCall*)call
                   result:(FlutterResult)result{
    SITExternalLocation *externalLocation = [[SITExternalLocation alloc] initWithBuildingIdentifier:call.arguments[@"buildingIdentifier"] 
                                                                floorIdentifier:call.arguments[@"floorIdentifier"] 
                                                                latitude:[call.arguments[@"latitude"] doubleValue] 
                                                                longitude:[call.arguments[@"longitude"] doubleValue]];
    [[SITLocationManager sharedInstance] addExternalLocation:externalLocation];
    result(@"DONE");
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
    NSDictionary *args = location.toDictionary;
    [self.channel invokeMethod:@"onLocationChanged" arguments:args];
}

- (void)locationManager:(id<SITLocationInterface> _Nonnull)locationManager
         didUpdateState:(SITLocationState)state {
    NSLog(@"location Manager on state: %ld", state);
    NSMutableDictionary *args = [NSMutableDictionary new];
    SITEnumMapper *enumMapper = [SITEnumMapper new];
    args[@"statusName"] = [enumMapper mapLocationStateToString:state];
    [self.channel invokeMethod:@"onStatusChanged" arguments:args];
}

- (void)locationManager:(id<SITLocationInterface>)locationManager
didInitiatedWithRequest:(SITLocationRequest *)request
{
    
}

- (void)didEnteredGeofences:(NSArray<SITGeofence *> *)geofences {
    NSLog(@"location Manager did entered geofences");
    [self.channel invokeMethod:@"onEnteredGeofences" arguments: [SITFSDKUtils toArrayDict: geofences]];
}

- (void)didExitedGeofences:(NSArray<SITGeofence *> *)geofences {
    NSLog(@"location Manager did exited geofences");
    [self.channel invokeMethod:@"onExitedGeofences" arguments: [SITFSDKUtils toArrayDict: geofences]];
}

- (void) handleGeofenceCallbacksRequested :(FlutterMethodCall*)call
                                    result:(FlutterResult)result {
    self.locManager.geofenceDelegate = self;
    
    result(@"SUCCESS");
}

@end
