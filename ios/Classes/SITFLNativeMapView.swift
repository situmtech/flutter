//
//  SITFLNativeMapView.swift
//  situm_flutter_wayfinding
//
//  Created by Abraham Barros Barros on 17/10/22.
//

import Flutter
import UIKit
import SitumWayfinding

@objc public class SITFLNativeMapViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    @objc public init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }

    @objc public func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return SITFLNativeMapView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
}

internal protocol SITFLNativeMapViewDelegate {
    
    func onPoiSelected()
    
    func onPoiDeselected()
    
    func onMapReady()
    
}


@objc public class SITFLNativeMapView: NSObject, FlutterPlatformView, OnMapReadyListener, OnPoiSelectionListener {
    
    
    
    
    private static var mapView: UIView?
    internal static var loaded: Bool = false
    
    private var _view: UIView
    
    internal static var library: SitumMapsLibrary?
    internal static var buildingId: String?
    internal static var delegate: SITFLNativeMapViewDelegate?

    @objc init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        super.init()

        
        let controller = UIApplication.shared.windows.first!.rootViewController as! FlutterViewController

        if SITFLNativeMapView.loaded {            
            SITFLNativeMapView.library?.presentInNewView(_view, controlledBy: controller)
            
            // print(" Map Already loaded")
            
        } else {
                        
            if let arguments = args as? Dictionary<String, Any>,
               let buildingId = arguments["buildingIdentifier"] as? String,
               let situmUser = arguments["situmUser"] as? String,
              let situmApikey = arguments["situmApiKey"] as? String,
              let googleMapsApiKey = arguments["googleMapsApiKey"] as? String,
               let showPoiNames = arguments["showPoiNames"] as? Bool,
               let showSearchBar = arguments["hasSearchView"] as? Bool,
               let enablePoiClustering = arguments["enablePoiClustering"] as? Bool,
               let useRemoteConfig = arguments["useRemoteConfig"] as? Bool
            {
                SITFLNativeMapView.buildingId = buildingId
                let credentials = Credentials(user: situmUser, apiKey: situmApikey, googleMapsApiKey: googleMapsApiKey)
                let settings = LibrarySettings.Builder()
                    .setCredentials(credentials: credentials)
                    .setBuildingId(buildingId: SITFLNativeMapView.buildingId!)
                    .setShowPoiNames(showPoiNames: showPoiNames) // Retrieve parameters from config.dart
                    .setEnablePoiClustering(enablePoisClustering: enablePoiClustering)
                    .setShowSearchBar(showSearchBar: showSearchBar)
                    .setUseRemoteConfig(useRemoteConfig: useRemoteConfig)
                    .setShowBackButton(showBackButton: false)
                    .build()
                
                let library = SitumMapsLibrary(containedBy: _view, controlledBy: controller, withSettings: settings)
                // Set delegates
                library.setOnMapReadyListener(listener: self)
                library.setOnPoiSelectionListener(listener: self)
                if  let navigationsSettings = arguments["navigationSettings"] as? Dictionary<String, AnyObject>, let outsideRouteThreshold = navigationsSettings["outsideRouteThreshold"]{
                    library.addNavigationRequestInterceptor { navigationRequest in
                        navigationRequest.outsideRouteThreshold = outsideRouteThreshold as! Int
                    }
                }
                
                SITFLNativeMapView.library = library
                
                // SITFLNativeMapView.mapView = self
                
                
                do {
                    try SITFLNativeMapView.library!.load()
                            
                    SITFLNativeMapView.loaded = true
                } catch {
                    print("Some Error Happened")
                }
                
            } else {
                print("Unable to find args")
            }
            
            
            
            
            

            
            /*
             
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
             NSNumber *useRemoteConfig = [args valueForKey:@"useRemoteConfig"];
             
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
             [settingsBuilder setUseRemoteConfigWithUseRemoteConfig:[useRemoteConfig boolValue]];
               
             FlutterViewController *rootController = (FlutterViewController*)[[
                                                  [[UIApplication sharedApplication]delegate] window] rootViewController];
             
             SitumMapsLibrary *library = [[SitumMapsLibrary alloc]initWithContainedBy:_view
                                                                         controlledBy:rootController
                                                                         withSettings:[settingsBuilder build]];
             
             */
            
            
            
            
            
        }
        
        
        
        
        // iOS views can be created here
    }
    
    internal static func loadView() -> Bool {
        if library == nil {
            return false
        }
        

        /*
        let controller = UIApplication.shared.windows.first!.rootViewController as! FlutterViewController

            
        if SITFLNativeMapView.loaded {
            library?.presentInNewView(SITFLNativeMapView.mapView!, controlledBy: controller)
        } else {
            do {
                try SITFLNativeMapView.library!.load()
                
                // Retrieve latest view on hierarchy and assign to mapView
                
                for var v in SITFLNativeMapView.view().subviews {
                    
                }
                
                SITFLNativeMapView.loaded = true
            } catch {
                print("Some Error Happened")
            }
        }*/

        return true
    }
    
    internal static func unloadView() {
        // SITFLNativeMapView.library.
    }

    @objc public func view() -> UIView {
        return _view
    }
    
    // MARK: OnMapReadyListener
    public func onMapReady(map: SitumWayfinding.SitumMap) {
        print("On Map Ready")
        
        
        // Send delegate to dart
        if let del = SITFLNativeMapView.delegate {
            del.onMapReady()
        }
    }
    
    // MARK: OnPoiSelection Delegate functions
    public func onPoiSelected(poi: SITPOI, level: SITFloor, building: SITBuilding) {
        print("On poi Selected detected")
        if let del = SITFLNativeMapView.delegate {
            del.onPoiSelected()
        }
    }
    
    public func onPoiDeselected(building: SITBuilding) {
        print("On Poi Deselected detected")
        if let del = SITFLNativeMapView.delegate {
            del.onPoiDeselected()
        }
    }
}
