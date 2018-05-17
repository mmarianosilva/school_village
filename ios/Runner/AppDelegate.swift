import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController;
    let pdfViewChannel = FlutterMethodChannel.init(name: "schoolvillage.app/pdf_view",
                                                   binaryMessenger: controller);
    pdfViewChannel.setMethodCallHandler({
        (call: FlutterMethodCall, result: FlutterResult) -> Void in
        
        let path = call.arguments as! String
        let key = controller.lookupKey(forAsset: path)!

        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "webViewController") as! WebViewController
        newViewController.url  = path
        self.window?.rootViewController?.present(newViewController, animated: true, completion: nil)
    });
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
