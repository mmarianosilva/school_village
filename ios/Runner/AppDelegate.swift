import UIKit
import Flutter
import AVFoundation
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var alarmSound: AVAudioPlayer?
    let audioSession = AVAudioSession.sharedInstance()
    var _resumingFromBackground: Bool?
    
    func prepareAudioPlayer(){
        if let sound = self.setupAudioPlayerWithFile(file: "alarm", type: "wav") {
            self.alarmSound = sound
        }
    }
    
    override func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?)
        -> Bool {
            
            prepareAudioPlayer()
            
            GeneratedPluginRegistrant.register(with: self)

            GMSServices.provideAPIKey("AIzaSyBVRFQqX_6Xp01lE2vO2Uozw0TNX9OiUOg")
            
            let controller : FlutterViewController = window?.rootViewController as! FlutterViewController;
            let pdfViewChannel = FlutterMethodChannel.init(name: "schoolvillage.app/pdf_view",
                                                           binaryMessenger: controller.binaryMessenger);
            pdfViewChannel.setMethodCallHandler({(call: FlutterMethodCall, result: FlutterResult) -> Void in
                
                let path = call.arguments as! String
                _ = controller.lookupKey(forAsset: path)!
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "webViewController") as! WebViewController
                newViewController.modalPresentationStyle = .overFullScreen
                newViewController.url  = path
                self.window?.rootViewController?.present(newViewController, animated: true, completion: nil)
            })
            
            let audioChannel = FlutterMethodChannel.init(name: "schoolvillage.app/audio",
                                                           binaryMessenger: controller.binaryMessenger);
            audioChannel.setMethodCallHandler({(call: FlutterMethodCall, result: FlutterResult) -> Void in
                if ("playBackgroundAudio" == call.method) {
                    self.playBackgroundAudio()
                } else if("stopBackgroundAudio" == call.method) {
                    self.stopBackgroundAudio()
                }
            })
            
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func playBackgroundAudio(){
        print("playBackgroundAudio")
//        if(UIApplication.shared.applicationState != .active) {
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayback, with: .duckOthers)
                try audioSession.setActive(true)
            } catch {
                print("AudioSession error setActive(true)\naudioSession.setCategory(AVAudioSessionCategoryPlayback, with: .duckOthers)")
            }
            
            if(self.alarmSound == nil) {
                prepareAudioPlayer()
            }
            
            self.alarmSound?.play()
//        }
    }
    
    func stopBackgroundAudio() {
        self.alarmSound?.stop()
        do {
            try self.audioSession.setActive(false)
        } catch {
            print("AudioSession error setActive(false)")
        }
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
