import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let environmentName = Bundle.main.object(forInfoDictionaryKey:"EnvironmentName")
    print("[environmentName]:\(environmentName!)")
    //    UMCommonLogSwift.setUpUMCommonLogManager()
    UMCommonSwift.setLogEnabled(bFlag: true)
    if ("\(environmentName!)" == "dev") {
        UMCommonSwift.initWithAppkey(appKey: "60adbecc53b6726499109624", channel: "10000")
    } else {
        UMCommonSwift.initWithAppkey(appKey: "60af5308dd01c71b57c7b05c", channel: "10001")
    }

//    #if DEBUG
//    UMCommonSwift.initWithAppkey(appKey: "60adbecc53b6726499109624", channel: "10000")
//    #else
//    UMCommonSwift.initWithAppkey(appKey: "60af5308dd01c71b57c7b05c", channel: "10000")
//    #endif
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
