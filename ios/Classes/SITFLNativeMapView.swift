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

@objc public class SITFLNativeMapView: NSObject, FlutterPlatformView {
    private static var mapView: UIView?
    internal static var loaded: Bool = false
    
    private var _view: UIView
    
    internal static var library: SitumMapsLibrary?
    internal static var buildingId: String?

    @objc init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        
        let controller = UIApplication.shared.windows.first!.rootViewController as! FlutterViewController

        if SITFLNativeMapView.loaded {            
            SITFLNativeMapView.library?.presentInNewView(_view, controlledBy: controller)
        } else {                        
            SITFLNativeMapView.buildingId = "SET_BUILDING_IDENTIFIER_HERE"
            let credentials = Credentials(user: "SET_USER_EMAIL_HERE", apiKey: "SET_APIKEY_HERE", googleMapsApiKey: "SET_GOOGLE_APIKEY_HERE ")

            
            let settings = LibrarySettings.Builder()
                .setCredentials(credentials: credentials)
                .setBuildingId(buildingId: SITFLNativeMapView.buildingId!)
                .setShowPoiNames(showPoiNames: true)
                .setEnablePoiClustering(enablePoisClustering: true)
                .setShowSearchBar(showSearchBar: false)
                .setUseRemoteConfig(useRemoteConfig: true)
                .setShowBackButton(showBackButton: false)
                .build()
            
            
                SITFLNativeMapView.library = SitumMapsLibrary(containedBy: _view, controlledBy: controller, withSettings: settings)
            
            do {
                try SITFLNativeMapView.library!.load()
                        
                SITFLNativeMapView.loaded = true
            } catch {
                print("Some Error Happened")
            }
        }
        
        
        
        
        super.init()
        // iOS views can be created here
    }

    @objc public func view() -> UIView {
        return _view
    }
}
