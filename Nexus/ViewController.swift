//
//  ViewController.swift
//  Nexus
//
//  Created by Erik E. Beerepoot on 2014-12-20.
//  Copyright (c) 2014 Dactyl Studios. All rights reserved.
//

import Foundation
import AppKit
import WebKit

class ViewController: NSViewController {
    
    //views
    var smileView : SmileView? = nil;
    var authorizationView : WebView? = nil;

    //controllers
    var connectionController : SlackConnectionController? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create views
        smileView = SmileView(frame:self.view.frame);
        smileView?.SetTextToDisplay("Hello!");
        authorizationView = WebView(frame: self.view.frame);
        authorizationView?.hidden = true;
        

        //Add webview constraints for scaling, since swift doesn't allow us to use macros
        var viewBindingsDict: NSMutableDictionary = NSMutableDictionary()
        viewBindingsDict.setValue(authorizationView, forKey: "webView")
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[webView]|", options: nil, metrics: nil, views: viewBindingsDict));
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[webView]|", options: nil, metrics: nil, views: viewBindingsDict));
    
        //add views to the view hierarchy
        if smileView != nil {
            self.view.addSubview(smileView!);
        }
        
        if authorizationView != nil {
            self.view.addSubview(authorizationView!);
        }
        
        //Create controller objects
        let authorizationController = AuthorizationController();
        let connectionController = SlackConnectionController();
        authorizationController.authorizationView = authorizationView;
        connectionController.authorizationController = authorizationController;
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
}
   

    
//
//    func didConnect() -> () {
//        smileView?.SetTextToDisplay("Nexus running...");
//        smileView!.setNeedsDisplayInRect(smileView!.frame)
//        
//        //send test message
//        //   connection?.SendMessageToChannelWithName("Hello, everyone. My name is Nexus. Erik is my Master", channelName: NSString(string:kTestChannelID));
//    }
//    
//    func presentAuthorizationView () -> () {
//        //create webview
//        webView = WebView(frame: self.view.frame);
//        webView?.policyDelegate = self;
//        self.view.addSubview(webView!);
//        
//    }
//    
//    func didReceiveURLResponseWithData(response : NSURLResponse, data : NSData){
//        webView?.mainFrame.loadData(data, MIMEType: "text/html", textEncodingName: "UTF-8", baseURL:response.URL);
//    }
//    
//    override func webView(webView: WebView!,
//        decidePolicyForNavigationAction actionInformation: [NSObject : AnyObject]!,
//        request: NSURLRequest!,
//        frame: WebFrame!,
//        decisionListener listener: WebPolicyDecisionListener!){
//
//        //interpret results
////        let actInfo = actionInformation as NSDictionary;
////        if(actInfo.objectForKey(WebActionNavigationTypeKey) as Int == WebNavigationType.FormSubmitted.rawValue){
////            //tried to submit form, parse code
////            var originalURL = actInfo.objectForKey(WebActionOriginalURLKey) as NSURL;
////            connection?.CompleteAuthorizationWithURL(originalURL.absoluteString!);
////        }
//        listener.use();
//    }
//    
//
//
//}
//