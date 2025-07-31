import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    static var app: AppDelegate { UIApplication.shared.delegate! as! AppDelegate }
    var rootViewController: FlutterViewController { window!.rootViewController as! FlutterViewController }

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        if let controller = window?.rootViewController as? FlutterViewController {
            HeThongMay.register(with: controller)
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

}
