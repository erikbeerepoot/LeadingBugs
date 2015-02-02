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

class ViewController: NSViewController, SmileViewDelegate {
    
    //views
    var smileView : SmileView? = nil;
    var authorizationView : WebView? = nil;
    
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
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func updateStatus(statusString : String) -> () {
        smileView?.SetTextToDisplay(statusString);
    }
    
    func shouldShowAuthorizationView(shouldShowAuthorizationView : Bool){
        if(shouldShowAuthorizationView){
            smileView?.hidden = true;
            authorizationView?.hidden = false;
            authorizationView?.setNeedsDisplayInRect(self.view.frame);
        } else {
            smileView?.hidden = false;
            authorizationView?.hidden = true;
            smileView?.setNeedsDisplayInRect(self.view.frame);
        }
    }
    
    func animationHasCompleted() {
    }

    
}



