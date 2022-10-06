//
//  SITFNativeMapView.m
//  situm_flutter_wayfinding
//
//  Created by Abraham Barros Barros on 13/9/22.
//

#import "SITFNativeMapView.h"

@import SitumWayfinding;
// #import <SitumWayfinding/SitumWayfinding-umbrella.h>

@implementation SITFNativeMapViewFactory {
    NSObject<FlutterBinaryMessenger>* _messenger;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
  self = [super init];
  if (self) {
    _messenger = messenger;
  }
  return self;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
  return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id _Nullable)args {
    
  return [[SITFNativeMapView alloc] initWithFrame:frame
                              viewIdentifier:viewId
                                   arguments:args
                             binaryMessenger:_messenger];
}

@end

@interface SITFNativeMapView()


@end

@implementation SITFNativeMapView {
   UIView *_view;
}

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {

    if (self = [super init]) {
        _view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];

        Builder *settingsBuilder = [[Builder alloc] init];
        
        NSString *situmUser = [args valueForKey:@"situmUser"];
        NSString *apiKey = [args valueForKey:@"situmApiKey"];
        NSString *buildingIdentifier = [args valueForKey:@"buildingIdentifier"];
        NSString *googleMapsApiKey = [args valueForKey:@"googleMapsApiKey"];
        
        Credentials *credentials = [[Credentials alloc]initWithUser:situmUser
                                                               apiKey:apiKey
                                                     googleMapsApiKey:googleMapsApiKey];
        [settingsBuilder setCredentialsWithCredentials:credentials];
        [settingsBuilder setBuildingIdWithBuildingId:buildingIdentifier];
        
        [settingsBuilder setEnablePoiClusteringWithEnablePoisClustering:YES];
        
        [settingsBuilder setShowPoiNamesWithShowPoiNames:YES];
          
        FlutterViewController *rootController = (FlutterViewController*)[[
                                             [[UIApplication sharedApplication]delegate] window] rootViewController];
        
        
        SitumMapsLibrary *library = [[SitumMapsLibrary alloc]initWithContainedBy:_view
                                                                    controlledBy:rootController
                                                                    withSettings:[settingsBuilder build]];
        
        
        NSError *error;
        [library loadAndReturnError:&error];
          
        if (error) {
            NSLog(@"Unable to load wayfinding library");
        }

  }
  return self;
}

- (UIView*)view {
  return _view;
}

@end
