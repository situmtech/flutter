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
        Credentials *credentials = [[Credentials alloc]initWithUser:@"place_situm_user_here"
                                                               apiKey:@"place_situm_apikey_here"
                                                     googleMapsApiKey:@"place_googlemaps_apikey_here"];
        [settingsBuilder setCredentialsWithCredentials:credentials];
        [settingsBuilder setBuildingIdWithBuildingId:@"place_building_identifier_here"];
        
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
