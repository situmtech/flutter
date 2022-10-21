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
    private var _view: UIView
    
    internal static var library: SitumMapsLibrary?
    internal static var buildingId: String?

    @objc init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView()
        super.init()
        // iOS views can be created here
        createNativeView(view: _view)
    }

    @objc public func view() -> UIView {
        return _view
    }

    func createNativeView(view _view: UIView){
        _view.backgroundColor = UIColor.blue
        
        SITFLNativeMapView.buildingId = "SET_BUILDING_ID_HERE"
        let credentials = Credentials(user: "SET_USER_HERE", apiKey: "SET_APIKEY_HERE", googleMapsApiKey: "SET_GOOGLE_APIKEY_HERE")
        
        
        let settings = LibrarySettings.Builder().setCredentials(credentials: credentials).setBuildingId(buildingId: SITFLNativeMapView.buildingId!).build()
        
        let controller = UIApplication.shared.windows.first!.rootViewController as! FlutterViewController
        SITFLNativeMapView.library = SitumMapsLibrary(containedBy: _view, controlledBy: controller, withSettings: settings)
        
        
        // Establish delegates and callbacks
        do {
            try SITFLNativeMapView.library!.load()
            
        } catch {
            print("Some Error Happened")
        }
    }
}
