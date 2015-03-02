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

class MainViewController: NSViewController, SmileViewDelegate, NexusDelegate {
    
    //views
    var smileView : SmileView? = nil;
    
    var _authorizationView : WebView? = nil;
    
    var authorizationView : WebView {
        //set up an auth view if required
        if(_authorizationView == nil){
            _authorizationView = WebView(frame: self.view.frame);
            _authorizationView?.hidden = true;
        }
        //make sure we have an authorization view, we can't continue without it
        assert(_authorizationView != nil)
        self.view.addSubview(_authorizationView!);
        
        //Add webview constraints for scaling, since swift doesn't allow us to use macros
        var viewBindingsDict: NSMutableDictionary = NSMutableDictionary()
        viewBindingsDict.setValue(_authorizationView, forKey: "webView")
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[webView]|", options: nil, metrics: nil, views: viewBindingsDict));
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[webView]|", options: nil, metrics: nil, views: viewBindingsDict));
        
        return _authorizationView!;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create views
        smileView = SmileView(frame:self.view.frame);
        smileView?.SetTextToDisplay("Hello!");
        _authorizationView = WebView(frame: self.view.frame);
        _authorizationView?.hidden = true;
            
        //add views to the view hierarchy
        if smileView != nil {
            self.view.addSubview(smileView!);
            smileView?.delegate = self;
        }
        
        //we *need* an authorizationView to be able to use this app
        assert(_authorizationView != nil);
        self.view.addSubview(_authorizationView!);
        
        //Add webview constraints for scaling, since swift doesn't allow us to use macros
        var viewBindingsDict: NSMutableDictionary = NSMutableDictionary()
        viewBindingsDict.setValue(_authorizationView, forKey: "webView")
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[webView]|", options: nil, metrics: nil, views: viewBindingsDict));
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[webView]|", options: nil, metrics: nil, views: viewBindingsDict));        
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    /************************************************************************
     *                          Delegate Methods                            *
     ************************************************************************/
    //MARK: Delegate methods
    func shouldDisplayText(text: String) {
        if(self.smileView != nil){
            dispatch_async(dispatch_get_main_queue(),{
                self.smileView!.SetTextToDisplay(text);
            });
        }
    }
    
    func shouldDisplayAuthorizationView(shouldDisplayView : Bool) ->(){
        
        if(shouldDisplayView){
            dispatch_async(dispatch_get_main_queue(),{
                self.smileView?.hidden = true;
                self.authorizationView.hidden = false;
                self.authorizationView.setNeedsDisplayInRect(self.view.frame);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(),{
                self.smileView?.hidden = false;
                self.authorizationView.hidden = true;
                self.smileView?.setNeedsDisplayInRect(self.view.frame);
            });
        }
    }
    
    func animationHasCompleted() {
    }

    
}



