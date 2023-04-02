import UIKit
import Flutter
import GoogleMaps
import Firebase
import receive_sharing_intent

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
   GMSServices.provideAPIKey("AIzaSyCgqe3NTYPtITpgHJblkRhzyGL86UzgYbo")
    GeneratedPluginRegistrant.register(with: self)
//    let sharedSuiteName: String = "group.com.solstice.com"
//    let sharedDataKey: String = "SharedData"
//     let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
//    let methodChannel = FlutterMethodChannel(name: "com.solstice.com", binaryMessenger: controller.binaryMessenger)
//
//        methodChannel.setMethodCallHandler({
//            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
//            if call.method == "getSharedData" {
//                if let prefs = UserDefaults(suiteName: sharedSuiteName) {
//                    if let sharedText = prefs.string(forKey: sharedDataKey) {
//                        result(sharedText);
//                    }
//                    // clear out the cached data
//                    prefs.set("", forKey: sharedDataKey);
//                }
//            }
//        })
//    if #available(iOS 10.0, *) {
//        let center = UNUserNotificationCenter.current()
//        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
//
//            print("Registered")
//        }
//        UNUserNotificationCenter.current().delegate = self
//        application.registerForRemoteNotifications()
//    } else {
//        // Fallback on earlier versions
//    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("in receive intent ")
        let sharingIntent = SwiftReceiveSharingIntentPlugin.instance
        if sharingIntent.hasMatchingSchemePrefix(url: url) {
            
            return sharingIntent.application(app, open: url, options: options)
           
        }
        
        // For example
        // return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[.sourceApplication] as? String)
        return super.application(app, open: url, options: options)
    }
    
    
    // This method will be called when app received push notifications in foreground
       override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
       {
           completionHandler([.alert, .badge, .sound])
       }
       
       override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
           print(userInfo)
       }
    
 // If the application is using multiple libraries, which needs to implement this function here in AppDelegate, you should check if the url is made from SwiftReceiveSharingIntentPlugin (if so, return the sharingIntent response) or call the handler of specific librabry
//    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//         let sharingIntent = SwiftReceiveSharingIntentPlugin.instance
//         if sharingIntent.hasMatchingSchemePrefix(url: url) {
//             return sharingIntent.application(app, open: url, options: options)
//         }
//
//        // For example
//        // return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[.sourceApplication] as? String)
//        return false
//    }
}
