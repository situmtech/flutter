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
    
    func onPoiSelected(poi: SITPOI, level: SITFloor, building: SITBuilding)
    
    func onPoiDeselected(building: SITBuilding)
    
    func onMapReady()
    
    func onNavigationRequested(navigation: Navigation)
    
    func onNavigationStarted(navigation: Navigation)
    
    func onNavigationError(navigation: Navigation, error: Error)
    
    func onNavigationFinished(navigation: Navigation)
}


@objc public class SITFLNativeMapView: NSObject, FlutterPlatformView, OnMapReadyListener, OnPoiSelectionListener, OnNavigationListener {

    private static var mapView: UIView?
    internal static var loaded: Bool = false
    
    private var _view: UIView
    
    internal static var library: SitumMapsLibrary?
    internal static var buildingId: String?
    internal static var delegate: SITFLNativeMapViewDelegate?
    internal static var lockCameraToBuilding: Bool = false

    @objc init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {        
        _view = UIView.init(frame: CGRect(x:frame.origin.x , y: frame.origin.y, width: frame.size.width, height: frame.size.height))
        SITFLNativeMapView.mapView = _view
        super.init()
        
        let controller = UIApplication.shared.windows.first!.rootViewController as! FlutterViewController
        
        if let arguments = args as? Dictionary<String, Any>,
           let lockCamera = arguments["lockCameraToBuilding"] as? Bool{
            SITFLNativeMapView.lockCameraToBuilding = lockCamera
         }

        if SITFLNativeMapView.loaded {
                        
            SITFLNativeMapView.library?.presentInNewView(SITFLNativeMapView.mapView!, controlledBy: controller)
        
        } else {
                        
            if let arguments = args as? Dictionary<String, Any>,
               let buildingId = arguments["buildingIdentifier"] as? String,
               let situmUser = arguments["situmUser"] as? String,
              let situmApikey = arguments["situmApiKey"] as? String,
              let googleMapsApiKey = arguments["googleMapsApiKey"] as? String,
               let showPoiNames = arguments["showPoiNames"] as? Bool,
               let showSearchBar = arguments["hasSearchView"] as? Bool,
               let enablePoiClustering = arguments["enablePoiClustering"] as? Bool,
               let useRemoteConfig = arguments["useRemoteConfig"] as? Bool,
               let floorListVisible = arguments["showFloorSelector"] as? Bool
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
                    .setShowNavigationIndications(showNavigationIndications: false).setFloorsListVisible(floorsListVisible:floorListVisible)
                    .build()
                let library = SitumMapsLibrary(containedBy: _view, controlledBy: controller, withSettings: settings)
                // Set delegates
                library.setOnMapReadyListener(listener: self)
                library.setOnPoiSelectionListener(listener: self)
                library.setOnNavigationListener(listener: self)
                if  let navigationsSettings = arguments["navigationSettings"] as? Dictionary<String, AnyObject>{
                    library.addNavigationRequestInterceptor { navigationRequest in
                        if let outsideRouteThreshold = navigationsSettings["outsideRouteThreshold"]{
                            navigationRequest.outsideRouteThreshold = outsideRouteThreshold as! Int
                        }
                        if let distanceToGoalThreshold = navigationsSettings["distanceToGoalThreshold"]{
                            navigationRequest.distanceToGoalThreshold = distanceToGoalThreshold as! Int
                        }
                    }
                }
                
                configureDirectionsRequest(for: library, arguments: arguments)
                
                SITFLNativeMapView.library = library
                            
                
                do {
                    try SITFLNativeMapView.library!.load()
                            
                    SITFLNativeMapView.loaded = true
                } catch {
                    print("Some Error Happened")
                }
                
            } else {
                print("Unable to find args")
            }
            
        }
        
        
        
        
        // iOS views can be created here
    }
    
    private func configureDirectionsRequest(for library:SitumMapsLibrary,arguments:Dictionary<String, Any> ){
        if  let directionsSettings = arguments["directionsSettings"] as? Dictionary<String, AnyObject>{
            library.addDirectionsRequestInterceptor { directionsRequest in
                if let minimizeFloorChanges = directionsSettings["minimizeFloorChanges"] as? Bool{
                    directionsRequest.setMinimizeFloorChanges(minimizeFloorChanges)
                }
            }
        }
    }
    
    internal static func loadView() -> Bool {
        if library == nil {
            return false
        }
        
        if (SITFLNativeMapView.loaded) {

            let controller = UIApplication.shared.windows.first!.rootViewController as! FlutterViewController

            
            SITFLNativeMapView.library?.presentInNewView(SITFLNativeMapView.mapView!, controlledBy: controller)
            //self.onMapReady(map: SITFLNativeMapView.library!)

            return true
            
            
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

        return false
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
        
        if (SITFLNativeMapView.lockCameraToBuilding){
            if let buildignId = SITFLNativeMapView.buildingId{
                SITFLNativeMapView.library?.lockCameraToBuilding(buildingId: buildignId, completion: { result in
                })
            }
        }
        
        // Send delegate to dart
        if let del = SITFLNativeMapView.delegate {
            del.onMapReady()
        }
    }
    
    //TODO: Move delegate listeners to its own class
    
    // MARK: OnPoiSelection Delegate functions
    public func onPoiSelected(poi: SITPOI, level: SITFloor, building: SITBuilding) {
        print("On poi Selected detected 2")
        if let del = SITFLNativeMapView.delegate {
            del.onPoiSelected(poi: poi, level: level, building: building)
        }
    }
    
    public func onPoiDeselected(building: SITBuilding) {
        print("On Poi Deselected detected")
        if let del = SITFLNativeMapView.delegate {
            del.onPoiDeselected(building: building)
        }
    }
    
    
    // MARK: OnNavigationListener Delegate functions
    public func onNavigationRequested(navigation: Navigation) {
        if let del = SITFLNativeMapView.delegate {
            del.onNavigationRequested(navigation: navigation)
        }
    }
    
    public func onNavigationStarted(navigation: Navigation) {
        if let del = SITFLNativeMapView.delegate {
            del.onNavigationStarted(navigation: navigation)
        }
    }
    
    public func onNavigationError(navigation: Navigation, error: Error) {
        if let del = SITFLNativeMapView.delegate {
            del.onNavigationError(navigation: navigation, error: error)
        }
    }
    
    public func onNavigationFinished(navigation: Navigation) {
        if let del = SITFLNativeMapView.delegate {
            del.onNavigationFinished(navigation: navigation)
        }
    }
}
