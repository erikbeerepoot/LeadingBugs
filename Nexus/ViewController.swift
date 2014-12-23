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

class ViewController: NSViewController, SlackConnectionControllerDelegate {
    
    //views
    var smileView : SmileView? = nil;
    var authorizationView : WebView? = nil;

    //controllers
    var connectionController : SlackConnectionController? = nil;
    
    var connectionID : String? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create views
        smileView = SmileView(frame:self.view.frame);
        smileView?.SetTextToDisplay("Hello!");
        authorizationView = WebView(frame: self.view.frame);
        authorizationView?.hidden = true;
            
        //add views to the view hierarchy
        if smileView != nil {
            self.view.addSubview(smileView!);
        }
        
        //we *need* an authorizationView to be able to use this app
        assert(authorizationView != nil);
        self.view.addSubview(authorizationView!);
        
        //Add webview constraints for scaling, since swift doesn't allow us to use macros
        var viewBindingsDict: NSMutableDictionary = NSMutableDictionary()
        viewBindingsDict.setValue(authorizationView, forKey: "webView")
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[webView]|", options: nil, metrics: nil, views: viewBindingsDict));
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[webView]|", options: nil, metrics: nil, views: viewBindingsDict));
        
        //Create controller objects
        let authorizationController = AuthorizationController();
        authorizationController.setWebView(authorizationView!);
        connectionController = SlackConnectionController(authController: authorizationController);
        connectionController?.delegate = self;
        connectionID = connectionController?.createConnection();
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //MARK: Delegate methods
    func connectionFailedWithIdentifier(identifier : String, andError: NSError) -> (){
        smileView?.SetTextToDisplay("Connection failed.");
        authorizationView?.hidden = true;
        smileView?.hidden = false;
    }
    func didCreateConnectionWithIdentifier(identifier : String) -> (){
        smileView?.SetTextToDisplay("Nexus running...");
        authorizationView?.hidden = true;
        smileView?.hidden = false;
        
        //send test message
        let connection = connectionController?.connectionForIdentifier(connectionID!);
        let msg = Message(aChannel: kTestChannelID, messageText: "Hello, world!");
        let url = NSURL(string:SlackEndpoints.kSendMessageEndpoint)!;
        connection?.send(url, sendObject: msg, callback: nil);
        
        
        //connection?.s("Hello, everyone. My name is Nexus. Erik is my Master", channelName: NSString(string:kTestChannelID));
    }
    func didDestroyConnectionWithIdentifier(identifier : String) -> (){
        smileView?.SetTextToDisplay("Nexus stopped.");
        authorizationView?.hidden = true;
        smileView?.hidden = false;
    }

    
}



