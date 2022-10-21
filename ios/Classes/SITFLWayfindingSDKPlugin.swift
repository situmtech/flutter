//
//  SITFLWayfindingSDKPlugin.swift
//  situm_flutter_wayfinding
//
//  Created by Abraham Barros Barros on 20/10/22.
//

import Foundation
import SitumWayfinding
import Flutter

@objc public class SITFLWayfindingSDKPlugin: NSObject, FlutterPlugin {
    @objc public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "situm.com/flutter_wayfinding", binaryMessenger: registrar.messenger())
        
        let instance = SITFLWayfindingSDKPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
    }
    
    @objc public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "selectPoi") {
            
            print("Received call message")
            if let args = call.arguments as? Dictionary<String, String>,
               let poiIdentifier = args["identifier"] {
                // Retrieve poi from dart
                let selectedPoi = SITPOI(identifier: poiIdentifier, createdAt: Date(), updatedAt: Date(), customFields: [:])
                
                // Connect back poi handler
                
                // let poi = SITPOI(identifier: "126465", createdAt: Date(), updatedAt: Date(), customFields: [:])
                SITCommunicationManager.shared().fetchBuildingInfo("11871", withOptions: nil, success: { [weak self] mapping in
                    guard mapping != nil, let buildingInfo = mapping!["results"] as? SITBuildingInfo else {return}
                    let pois = buildingInfo.indoorPois.sorted(by: { $0.name > $1.name })
                    
                    for poi in pois {
                        if poi.identifier == selectedPoi.identifier {
                            if let lib = SITFLNativeMapView.library {
                                print("Selecting poi \(poi)")
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

            
            
            
            
            
            
            
            
        } else {
            print("Method not handled. ")
        }
    }
}
