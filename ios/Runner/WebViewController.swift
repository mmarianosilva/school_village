//
//  WebViewController.swift
//  Runner
//
//  Created by Jonathan Sudhakar on 5/2/18.
//  Copyright © 2018 The Chromium Authors. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    //MARK: Properties
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var closeBtn: UIButton!
    
    var url: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
//            let pdf = Bundle.main.path(forResource: self.url, ofType: "")!
//            if let resourceUrl = Bundle.main.url(forResource: url, withExtension: "pdf") {
//                if FileManager.default.fileExists(atPath: resourceUrl.path) {
//                    print("file found")
//                }
//            }
            let pdfURL = NSURL.fileURL(withPath: url)
//            let pdfURL = NSURL.fileURL(withPath: pdf)
            let data = try Data(contentsOf: pdfURL)
            self.webView?.scalesPageToFit=true;
            self.webView?.load(data, mimeType: "application/pdf", textEncodingName:"", baseURL: (pdfURL.deletingLastPathComponent()))
        }
        catch {
            // catch errors here
        }
        
        self.closeBtn?.addTarget(self, action: Selector(("buttonClicked:")), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buttonClicked(_ sender: AnyObject?) {
        if sender === self.closeBtn {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func updateZoomToAspectToFit(webView: UIWebView) {
        let contentSize: CGSize = webView.scrollView.contentSize //PDF size
        let viewSize:CGSize = webView.bounds.size
        let extraLength = contentSize.height - viewSize.height
        let extraWidth = contentSize.width - viewSize.width
        let shouldScaleToFitHeight = extraLength > extraWidth
        let zoomRangeFactor:CGFloat = 4
        if shouldScaleToFitHeight {
            let ratio:CGFloat = (viewSize.height / contentSize.height)
            webView.scrollView.minimumZoomScale = ratio / zoomRangeFactor
            webView.scrollView.maximumZoomScale = ratio * zoomRangeFactor
            webView.scrollView.zoomScale = ratio
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
