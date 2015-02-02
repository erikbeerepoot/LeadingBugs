//
//  AppDelegate.swift
//  Nexus
//
//  Created by Erik E. Beerepoot on 2014-12-20.
//  Copyright (c) 2014 Dactyl Studios. All rights reserved.
//

import Cocoa
import WebKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var contentViewController : MainViewController? = nil;
    var authView : WebView? = nil;
    let nexus : Nexus = Nexus();
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        //we can't use the app without any windows...
        assert(NSApplication.sharedApplication().windows.count>0);
        
        //get the first window, and get the contentView controller for setting up main Nexus logic
        let mainWindow = NSApplication.sharedApplication().windows.first as NSWindow;
        contentViewController = mainWindow.contentViewController as MainViewController;

        //we also can't use the app without the window having a valid contentViewController
        assert(contentViewController != nil);
        authView = contentViewController!.authorizationView;
        nexus.configureWithWebView(&authView!,andDelegate:contentViewController!);
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application

    }


}

