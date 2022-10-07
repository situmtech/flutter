//
//  SITFNativeMapView.m
//  situm_flutter_wayfinding
//
//  Created by Abraham Barros Barros on 13/9/22.
//

#import "SITFNativeMapView.h"

@import SitumWayfinding;
// #import <SitumWayfinding/SitumWayfinding-umbrella.h>

@interface SITFNativeMapViewFactory()
@end


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
        NSString *searchViewPlaceholder = [args valueForKey:@"searchViewPlaceholder"];
        NSNumber *showPoiNames = [args valueForKey:@"showPoiNames"];
        NSNumber *hasSearchView = [args valueForKey:@"hasSearchView"];
        NSNumber *useDashboardTheme = [args valueForKey:@"useDashboardTheme"];
        NSNumber *showNavigationIndications = [args valueForKey:@"showNavigationIndications"];
        NSNumber *enablePoiClustering = [args valueForKey:@"enablePoiClustering"];
        
        Credentials *credentials = [[Credentials alloc]initWithUser:situmUser
                                                               apiKey:apiKey
                                                     googleMapsApiKey:googleMapsApiKey];
        
        [settingsBuilder setCredentialsWithCredentials:credentials];
        [settingsBuilder setBuildingIdWithBuildingId:buildingIdentifier];
        [settingsBuilder setSearchViewPlaceholderWithSearchViewPlaceholder:searchViewPlaceholder];
        
        [settingsBuilder setEnablePoiClusteringWithEnablePoisClustering:[enablePoiClustering boolValue]];
        [settingsBuilder setShowPoiNamesWithShowPoiNames:[showPoiNames boolValue]];
        [settingsBuilder setShowSearchBarWithShowSearchBar:[hasSearchView boolValue]];
        [settingsBuilder setUseDashboardThemeWithUseDashboardTheme:[useDashboardTheme boolValue]];
        [settingsBuilder setShowNavigationIndicationsWithShowNavigationIndications:[showNavigationIndications boolValue]];
          
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
    }
  return self;
}

- (UIView*)view {
  return _view;
}

@end
