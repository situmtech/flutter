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
    var currentView:SITFLNativeMapView?

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
        currentView = SITFLNativeMapView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
        return currentView!
    }
}

internal protocol SITFLNativeMapViewDelegate {
    
    func onPoiSelected(poi: SITPOI, level: SITFloor, building: SITBuilding)
    
    func onPoiDeselected(building: SITBuilding)
    
    func onNavigationRequested(navigation: Navigation)
    
    func onNavigationStarted(navigation: Navigation)
    
    func onNavigationError(navigation: Navigation, error: Error)
    
    func onNavigationFinished(navigation: Navigation)
    
    func onCustomPoiCreated(customPoi: CustomPoi)
    
    func onCustomPoiRemoved(customPoi: CustomPoi)
    
    func onCustomPoiSelected(customPoi: CustomPoi)
    
    func onCustomPoiDeselected(customPoi: CustomPoi)
}


@objc public class SITFLNativeMapView: NSObject, FlutterPlatformView {

    private  var mapView: UIView?
    
    @objc init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {        
        mapView = UIView.init(frame: CGRect(x:frame.origin.x , y: frame.origin.y, width: frame.size.width, height: frame.size.height))
        super.init()
    }

    @objc public func view() -> UIView {
        return mapView!
    }
    
}


//Extension for Situm Wayfinding implementacion

extension SITFLNativeMapView{
    // TODO Probably all these static variables should be in a different class as Flutter destroy and recreates this view as it sees proper
    internal static var wyfStarted: Bool =  false
    internal static var wyfLoaded: Bool = false
    internal static var library: SitumMapsLibrary?
    internal static var buildingId: String?
    internal static var delegate: SITFLNativeMapViewDelegate?
    internal static var lockCameraToBuilding: Bool = false
    internal static var mapLoadCompletionCallback:((Bool)->())?
        
    internal func loadWYFView(arguments args: Any?, completion:@escaping (Bool)->()){
        let controller = UIApplication.shared.windows.first!.rootViewController as! FlutterViewController
        //Store the completion handler to notify when the map is ready
        SITFLNativeMapView.mapLoadCompletionCallback = completion
        if (!SITFLNativeMapView.wyfStarted){
            SITFLNativeMapView.wyfStarted = true
            initializeLibrary(arguments: args, controller: controller)
            do {
                try SITFLNativeMapView.library!.load()
                //Here we have to wait to receive the onMapReadyCallback to call the completion
            } catch {
                SITFLNativeMapView.wyfStarted = false
                completion(false)
                print("Some Error Happened")
            }
        }else{
            if SITFLNativeMapView.library == nil {
                completion(false)
            }
            SITFLNativeMapView.library?.presentInNewView(mapView!, controlledBy: controller)
            completion(true)
        }
    }
    
    
    func unloadView() {
        SITFLNativeMapView.wyfStarted = false
        SITFLNativeMapView.library?.unload()
    }
    

    //TODO Move translation of React arguments to native objects to SDK -> Mappings project
    private func initializeLibrary(arguments: Any?, controller: UIViewController){
        
        if let arguments = arguments as? Dictionary<String, Any>,
           let lockCamera = arguments["lockCameraToBuilding"] as? Bool{
            SITFLNativeMapView.lockCameraToBuilding = lockCamera
         }
        
        if let arguments = arguments as? Dictionary<String, Any>,
           let buildingId = arguments["buildingIdentifier"] as? String,
           let situmUser = arguments["situmUser"] as? String,
          let situmApikey = arguments["situmApiKey"] as? String,
          let googleMapsApiKey = arguments["googleMapsApiKey"] as? String,
           let showPoiNames = arguments["showPoiNames"] as? Bool,
           let showSearchBar = arguments["hasSearchView"] as? Bool,
           let enablePoiClustering = arguments["enablePoiClustering"] as? Bool,
           let useRemoteConfig = arguments["useRemoteConfig"] as? Bool,
           let floorListVisible = arguments["showFloorSelector"] as? Bool,
           let minZoom = arguments["minZoom"] as? Float,
           let maxZoom = arguments["maxZoom"] as? Float,
           let positioningFabVisible = arguments["showPositioningButton"] as? Bool
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
                .setShowNavigationIndications(showNavigationIndications: false)
                .setFloorsListVisible(floorsListVisible:floorListVisible)
                .setMinZoom(minZoom: minZoom)
                .setMaxZoom(maxZoom: maxZoom)
                .setPositioningFabVisible(positioningFabVisible: positioningFabVisible)
                .build()
            let library = SitumMapsLibrary(containedBy: mapView!, controlledBy: controller, withSettings: settings)
            // Set delegates
            library.setOnMapReadyListener(listener: self)
            library.setOnPoiSelectionListener(listener: self)
            library.setOnNavigationListener(listener: self)
            library.setOnCustomPoiChangeListener(listener: self)
            configureNavigationRequest(for: library, arguments: arguments)
            configureDirectionsRequest(for: library, arguments: arguments)
            
            SITFLNativeMapView.library = library
        } else {
            print("Unable to find args")
        }
    }
    
    private func configureNavigationRequest(for library:SitumMapsLibrary,arguments:Dictionary<String, Any> ){
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
    
}

//Extension for callbacks
extension SITFLNativeMapView : OnMapReadyListener, OnPoiSelectionListener, OnNavigationListener, OnCustomPoiChangeListener {
    // MARK: OnMapReadyListener
    public func onMapReady(map: SitumWayfinding.SitumMap) {
        print("On Map Ready")
        
        if (SITFLNativeMapView.lockCameraToBuilding){
            if let buildignId = SITFLNativeMapView.buildingId{
                SITFLNativeMapView.library?.lockCameraToBuilding(buildingId: buildignId, completion: { result in
                })
            }
        }
        
        //The load callback is still waiting for the map to be fully laoded, we notify it here
        notifyLoadCallbackCompleted()
    }
    
    private func notifyLoadCallbackCompleted(){
        SITFLNativeMapView.mapLoadCompletionCallback!(true)
        SITFLNativeMapView.wyfLoaded = true
    }
    
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
    
    public func onCustomPoiCreated(customPoi: CustomPoi) {
        print("On Custom Poi created detected")
        if let del = SITFLNativeMapView.delegate {
            del.onCustomPoiCreated(customPoi: customPoi)
        }
    }
    
    public func onCustomPoiRemoved(customPoi: CustomPoi) {
        print("On Custom Poi removed detected")
        if let del = SITFLNativeMapView.delegate {
            del.onCustomPoiRemoved(customPoi: customPoi)
        }
    }

    public func onCustomPoiSelected(customPoi: CustomPoi) {
        print("On Custom Poi selected detected")
        if let del = SITFLNativeMapView.delegate {
            del.onCustomPoiSelected(customPoi: customPoi)
        }
    }
    
    public func onCustomPoiDeselected(customPoi: CustomPoi) {
        print("On Custom Poi deselected detected")
        if let del = SITFLNativeMapView.delegate {
            del.onCustomPoiDeselected(customPoi: customPoi)
        }
    }
}
