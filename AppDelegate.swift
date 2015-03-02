//
//  AppDelegate.swift
//  LeadingBugs
//
//  Created by Erik E. Beerepoot on 2015-03-02.
//  Copyright (c) 2015 MediaCore Technologies Inc. All rights reserved.
//

import Cocoa
import WebKit
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var contentViewController : MainViewController? = nil;
    var authView : WebView? = nil;
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        //we can't use the app without any windows...
        assert(NSApplication.sharedApplication().windows.count>0);
        
        //get the first window, and get the contentView controller for setting up main Nexus logic
        let mainWindow = NSApplication.sharedApplication().windows.first as NSWindow;
        contentViewController = (mainWindow.contentViewController as MainViewController);
        
        //we also can't use the app without the window having a valid contentViewController
        assert(contentViewController != nil);
        authView = contentViewController!.authorizationView;
        //nexus.configureWithWebView(&authView!,andDelegate:contentViewController!);
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        
    }

    func configureWithWebView(inout authorizationView : WebView) -> (){
        //Create controller objects
        connectionController = SlackConnectionController();
        connectionController?.authorizationController?.setWebView(&authorizationView);
        connectionController?.delegate = self;
        
        //create new connection (if we haven't already created one)
        if(connectionID == nil || connectionID?.isEmpty==true){
            connectionID = connectionController?.createConnection(self);
        }
        delegate = aDelegate;
    }

}

