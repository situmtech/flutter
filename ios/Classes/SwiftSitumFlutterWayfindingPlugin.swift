import Flutter
import UIKit

public class SwiftSitumFlutterWayfindingPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "situm_flutter_wayfinding", binaryMessenger: registrar.messenger())
    let instance = SwiftSitumFlutterWayfindingPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
