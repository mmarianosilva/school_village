import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var mySound: AVAudioPlayer?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
        ) -> Bool {
        
        if let sound = self.setupAudioPlayerWithFile(file: "alarm", type: "wav") {
            self.mySound = sound
        }
        
        GeneratedPluginRegistrant.register(with: self)
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController;
        let pdfViewChannel = FlutterMethodChannel.init(name: "schoolvillage.app/pdf_view",
                                                       binaryMessenger: controller);
        pdfViewChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            
            let path = call.arguments as! String
            _ = controller.lookupKey(forAsset: path)!
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "webViewController") as! WebViewController
            newViewController.url  = path
            self.window?.rootViewController?.present(newViewController, animated: true, completion: nil)
        });
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("native code:")
        if(application.applicationState == .background){
            print("Application state = Background")
        }else if(application.applicationState == .inactive){
            print("Application state = inactive")
        }else if(application.applicationState == .active){
            print("Application state = active")
        }
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback, with: .duckOthers)
            try audioSession.setActive(true)
        } catch {
            print("Player not available")
        }
        
        self.mySound?.play()
        completionHandler(.newData)
    }
    
    func setupAudioPlayerWithFile(file: NSString, type: NSString) -> AVAudioPlayer? {
        
        let path = Bundle.main.path(forResource: file as String, ofType: type as String)
        let url = NSURL.fileURL(withPath: path!)
        var audioPlayer: AVAudioPlayer?
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url)
        } catch {
            print("Player not available")
        }
        
        return audioPlayer
    }

}
