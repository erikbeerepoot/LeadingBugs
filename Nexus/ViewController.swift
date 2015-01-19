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
import StarscreamOSX


class ViewController: NSViewController, SlackConnectionControllerDelegate, SmileViewDelegate {
    
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
            smileView?.delegate = self;
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
        
        //create new connection
        connectionID = connectionController?.createConnection();               
    }

    func PrintMessage() -> () {
        println("Make coffee");
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //MARK: Delegate methods
    func connectionAttemptForIdentfier(identifier : String) -> (){
        smileView?.SetTextToDisplay("Connecting...");
        smileView?.setNeedsDisplayInRect(self.view.frame);
    }
    
    func connectionFailedWithIdentifier(identifier : String, andError: NSError) -> (){
        smileView?.SetTextToDisplay("Connection failed!");
        smileView?.hidden = false;
        smileView?.setNeedsDisplayInRect(self.view.frame);
    }
    func didCreateConnectionWithIdentifier(identifier : String) -> (){
        smileView?.SetTextToDisplay("Nexus running...");
        smileView?.hidden = false;
        smileView?.setNeedsDisplayInRect(self.view.frame);
        
        //send test message
        let url = NSURL(string:SlackEndpoints.kSendMessageEndpoint)!;
        let connection = connectionController?.connectionForIdentifier(connectionID!);
        let msg = Message(aChannel: kTestChannelID, messageText: "Ahhh. What a beautiful day to be alive!");
        msg.updateArgument("username", withValue: "nexus");
        connection?.send(url, sendObject: msg, callback: nil);
    }
    func didDestroyConnectionWithIdentifier(identifier : String) -> (){
        smileView?.SetTextToDisplay("Nexus stopped.");
        authorizationView?.hidden = true;
        smileView?.hidden = false;
    }
    
    func animationHasCompleted() {
        if(connectionID != nil){
            connectionID = connectionController?.createConnection();
        }
    }

    
}



