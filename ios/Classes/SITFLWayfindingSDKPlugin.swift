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
    var mapReady: Bool = false
    
    
    @objc public static func register(with registrar: FlutterPluginRegistrar) {
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
            
            if (mapReady == false) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // your code here
                    self.handleSelectPoi(call, result: result)
                }
                
                return
            }
            
            if (SITFLNativeMapView.loaded == false) {
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
        
        if (SITFLNativeMapView.loaded == false) {
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
        } else {
            print("Method not handled. ")
        }
    }
    
    func handleLoad(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("Load method detected")
        
        SITFLNativeMapView.delegate = self
        // Call load
        let success =  SITFLNativeMapView.loadView()
        
        if (success) {
            print("Success loading view")
        } else {
            print("Failure loading view")
        }
        return result("SUCCESS");
    }
    
    func handleUnload() {
        print("unload method detected")
        
        
        
    }
    
    // MARK:
    
    func onPoiSelected() {
        print("On Poi Selected Detected")
        
        self.channel?.invokeMethod("onPoiSelected", arguments: nil) //
        
    }
    
    func onPoiDeselected() {
        print("On Poi Deselected Detected")
        self.channel?.invokeMethod("onPoiDeselected", arguments: nil)
    }
    
    func onMapReady() {
        print("On Map Ready Detected")
        
        mapReady = true
        
        // Send method
        self.channel?.invokeMethod("onMapReady", arguments: nil)
    }
    
}
