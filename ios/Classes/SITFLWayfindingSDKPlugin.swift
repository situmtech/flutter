//
//  SITFLWayfindingSDKPlugin.swift
//  situm_flutter_wayfinding
//
//  Created by Abraham Barros Barros on 20/10/22.
//

import Foundation
import SitumWayfinding
import Flutter

@objc public class SITFLWayfindingSDKPlugin: NSObject, FlutterPlugin, SITFLNativeMapViewDelegate {

    var channel : FlutterMethodChannel?
    static var factory : SITFLNativeMapViewFactory?
    
    @objc public static func register(with registrar: FlutterPluginRegistrar) {
        
        factory = SITFLNativeMapViewFactory(messenger: registrar.messenger())
        registrar.register(factory!, withId: "<platform-view-type>")
        
        let channel = FlutterMethodChannel(name: "situm.com/flutter_wayfinding", binaryMessenger: registrar.messenger())
        
        let instance = SITFLWayfindingSDKPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
        
    }
    
    @objc func handleSelectPoi(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let args = call.arguments as? Dictionary<String, String>,
           let poiIdentifier = args["id"],
           let buildingIdentifier = args["buildingId"] {
            // Retrieve poi from dart
            
            if (SITFLNativeMapView.wyfLoaded == false) {
                print("Library not loaded, wait before select poi")
                
                return
            }
            
            
            let selectedPoi = SITPOI(identifier: poiIdentifier, createdAt: Date(), updatedAt: Date(), customFields: [:])
            
            // Connect back poi handler
            
            // let poi = SITPOI(identifier: "126465", createdAt: Date(), updatedAt: Date(), customFields: [:])
            SITCommunicationManager.shared().fetchBuildingInfo(buildingIdentifier, withOptions: nil, success: { [weak self] mapping in
                guard mapping != nil, let buildingInfo = mapping!["results"] as? SITBuildingInfo else {return}
                let pois = buildingInfo.indoorPois.sorted(by: { $0.name > $1.name })
                
                for poi in pois {
                    if poi.identifier == selectedPoi.identifier {
                        if let lib = SITFLNativeMapView.library {
                            // print("Selecting poi \(poi)")
                            lib.selectPoi(poi: poi) { [weak self] result in
                                switch result {
                                case .success:
                                    print("POI: selection succeeded")
                                case .failure(let reason):
                                    print("failure with reason: \(reason)")
                                }
                            }
                            
                        } else {
                            print("Library not found")
                        }
                    }
                }
                
            }, failure: { error in
                print("fetchBuildingInfo \(error)")
            })

        }

    }
    
    func handleFilterPois(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("handle filter pois")
        
        // Receive poi filtering
        
        if (SITFLNativeMapView.wyfLoaded == false) {
            print("Unable to filter pois")
            // Return with error
        }
        
        if let args = call.arguments as? Dictionary<String, [String]>,
           let categories = args["categoryIdsFilter"] {
            
            print("found categories \(categories) in args: \(args)")
            SITFLNativeMapView.library?.filterPois(by: categories)
        } else {
            // Handle unable to retrieve needed params
            print("Unable to find categories on arguments")
        }
    }
    
    @objc public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "load") {
            handleLoad(call, result: result)
        } else if (call.method == "unload") {
            handleUnload()
        } else if (call.method == "selectPoi") {
            handleSelectPoi(call, result: result)
        } else if (call.method == "filterPoisBy") {
            handleFilterPois(call, result: result)
        }else if (call.method == "startPositioning") {
            handleStartPositioning(call, result: result)
        }else if (call.method == "stopPositioning") {
            handleStopPositioning(call, result: result)
        }else if (call.method == "stopNavigation") {
            handleStopNavigation(call, result: result)
        }else if (call.method == "findMyCarMode") {
            handleFindMyCarMode(call, result: result)
        } else if (call.method == "selectCustomPoi") {
            handleSelectCustomPoi(call, result: result)
        } else if (call.method == "removeCustomPoi") {
            handleRemoveCustomPoi(call, result: result)
        } else if (call.method == "getCustomPoi") {
            handleGetCustomPoi(call, result: result)
        }
        else {
            print("Method not handled. ")
        }
    }
    
    func handleStartPositioning(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        SITFLNativeMapView.library?.startPositioning()
        return result("SUCCESS")
    }
    
    func handleStopPositioning(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        SITFLNativeMapView.library?.stopPositioning()
        return result("SUCCESS")
    }
    
    func handleStopNavigation(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        SITFLNativeMapView.library?.stopNavigation()
        return result("SUCCESS")
    }
    
    func handleLoad(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("Load method detected")
        SITFLNativeMapView.delegate = self
        // Call load
        SITFLWayfindingSDKPlugin.factory?.currentView?.loadWYFView(arguments: call.arguments) {loaded in
            if (loaded){
                return result("SUCCESS")
            }else{
                return result("FAILURE")
            }
        }
    }
    
    func handleUnload() {
        print("unload method detected")
    }

    func handleFindMyCarMode(_ call: FlutterMethodCall, result: @escaping FlutterResult){
        print("Find my car mode called")
        SITFLNativeMapView.library?.activateFindMyCarMode()
        return result("SUCCESS")
    }

    func handleSelectCustomPoi(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("Select custom poi called")
        SITFLNativeMapView.library?.selectCustomPoi(completion: { result in
                switch result {
                case .success:
                    print("SUCCESS")
                case .failure(let reason):
                    print("Failed to select custom poi \(reason)")
                }
            })
        return result("SUCCESS")
    }

    func handleRemoveCustomPoi(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("Remove custom poi called")
        SITFLNativeMapView.library?.removeCustomPoi()
        return result("SUCCESS")
    }
    
    func handleGetCustomPoi(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("Get custom marker called")
        let customPoi = SITFLNativeMapView.library?.getCustomPoi()
        if (customPoi != nil) {
            let customPoiDict: [String: Any] = [
                "name": customPoi!.name,
                "description": customPoi!.description,
                "buildingId": Int(customPoi!.buildingId),
                "levelId": Int(customPoi!.floorId),
                "mapPosition": [
                    "latitude": customPoi!.latitude,
                    "longitude": customPoi!.longitude,

                ]
            ]
            return result(customPoiDict)
        }
        return result(nil)
    }
    
    // MARK: SITFLNativeMapViewDelegate methods implementation
    
    
    
    func onPoiSelected(poi: SITPOI, level: SITFloor, building: SITBuilding) {
        print("On Poi Selected Detected")
        if(self.channel == nil){
            print("Channel null")
        }
        let arguments = ["buildingId": building.identifier,
                         "buildingName":building.name,"floorId":level.identifier,
                         "floorName":level.name,
                         "poiId":poi.identifier,
                         "poiName":poi.name,
                         "poiInfoHtml":poi.infoHTML]
        
        self.channel?.invokeMethod("onPoiSelected", arguments: arguments) //
        
    }
    
    func onPoiDeselected(building: SITBuilding) {
        print("On Poi Deselected Detected")
        let arguments = ["buildingId": building.identifier,
                         "buildingName":building.name]
        self.channel?.invokeMethod("onPoiDeselected", arguments: arguments)
    }
    
    func onNavigationRequested(navigation: Navigation) {
        print("Navigation Requested")
        let arguments = ["destinationId":navigation.destination.identifier]
        self.channel?.invokeMethod("onNavigationRequested", arguments: arguments)
    }
    
    func onNavigationStarted(navigation: Navigation) {
        print("Navigation Started")
        var arguments:Dictionary<String, Any?> = ["destinationId":navigation.destination.identifier]
        if let route = navigation.route{
            arguments["routeDistance"] = Double(route.distance())
        }
        self.channel?.invokeMethod("onNavigationStarted", arguments: arguments)
    }
    
    
    func onNavigationError(navigation: Navigation, error: Error) {
        print("Navigation Error")
        let arguments = ["error":error.localizedDescription,
                         "destinationId":navigation.destination.identifier]
        self.channel?.invokeMethod("onNavigationError", arguments: arguments)
    }
    
    func onNavigationFinished(navigation: Navigation) {
        print("Navigation Finished")
        let arguments = ["destinationId":navigation.destination.identifier]
        self.channel?.invokeMethod("onNavigationFinished", arguments: arguments)
    }
    
    func onCustomPoiSet(customPoi: CustomPoi) {
        print("Custom POI set")
        let arguments: [String: Any] = [
            "name": customPoi.name,
            "description": customPoi.description,
            "buildingId": Int(customPoi.buildingId),
            "levelId": Int(customPoi.floorId),
            "mapPosition": [
                "latitude": customPoi.latitude,
                "longitude": customPoi.longitude,

            ]
        ]
        self.channel?.invokeMethod("onCustomPoiSet", arguments: arguments)
    }
    
    func onCustomPoiRemoved(poiId: String) {
        print("Custom POI removed")
        let arguments = ["poiId": poiId]
        self.channel?.invokeMethod("onCustomPoiRemoved", arguments: arguments)
    }
    
    func onCustomPoiSelected(poiId: String) {
        print("Custom POI selected")
        let arguments = ["poiId": poiId]
        self.channel?.invokeMethod("onCustomPoiSelected", arguments: arguments)
    }
    
    func onCustomPoiDeselected(poiId: String) {
        print("Custom POI deselected")
        let arguments = ["poiId": poiId]
        self.channel?.invokeMethod("onCustomPoiDeselected", arguments: arguments)
    }
}
