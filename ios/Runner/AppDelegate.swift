import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//    UMCommonLogSwift.setUpUMCommonLogManager()
    UMCommonSwift.setLogEnabled(bFlag: true)
    UMCommonSwift.initWithAppkey(appKey: "60adbecc53b6726499109624", channel: "DEV")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
