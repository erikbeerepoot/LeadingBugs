//
//  AppDelegate.swift
//  LeadingBugs
//
//  Created by Erik E. Beerepoot on 2015-03-02.
//  Copyright (c) 2015 MediaCore Technologies Inc. All rights reserved.
//

import Cocoa
import WebKit

protocol WebDelegate {
    var authorizationView : WebView { get };
    func shouldDisplayText(text : String) -> ();
    func shouldDisplayAuthorizationView(shouldDisplayView : Bool) ->();
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, ConnectionControllerDelegate {
    var connectionController : ConnectionController? = nil;
    var contentViewController : MainViewController? = nil;
    var authView : WebView? = nil;
    
    //TODO: Move this stuff out of the app delegate
    var connectionID : String? = nil;
    var aDelegate : WebDelegate? = nil;
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        //we can't use the app without any windows...
        assert(NSApplication.sharedApplication().windows.count>0);
        
        //get the first window, and get the contentView controller for setting up main Nexus logic
        let mainWindow = NSApplication.sharedApplication().windows.first as NSWindow;
        contentViewController = (mainWindow.contentViewController as MainViewController);
        
        //we also can't use the app without the window having a valid contentViewController
        assert(contentViewController != nil);
        authView = contentViewController!.authorizationView;
        configureWithWebView(&authView!,andDelegate:contentViewController!);
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        
    }

    func configureWithWebView(inout authorizationView : WebView, andDelegate delegate : WebDelegate) -> (){
        //Create controller objects
        connectionController = ConnectionController();
        connectionController?.authorizationController?.setWebView(&authorizationView);
        connectionController?.delegate = self;
        
        //Create parameter object to specific connection
        var parameters : Dictionary<String,String> = Dictionary();
        parameters["key"] = appConstants.key;
        parameters["name"] = "LeadingBugs";
        parameters["response_type"] = "token";
        
        //create new connection (if we haven't already created one)
        if(connectionID == nil || connectionID?.isEmpty==true){
            connectionID = connectionController?.createConnection(parameters:parameters,rtDelegate:nil);
        }
        aDelegate = delegate;
    }
    
    /**********************************************************************
    *                   ConnectionControllerDelegate                      *
    **********************************************************************/
    //MARK: Delegate methods
    
    func connectionAttemptForIdentfier(identifier : String) -> (){
        aDelegate?.shouldDisplayText("Connecting...");
        aDelegate?.shouldDisplayAuthorizationView(false);
    }
    
    func connectionFailedWithIdentifier(identifier : String, andError: NSError) -> (){
        aDelegate?.shouldDisplayText("Connection failed!");
        aDelegate?.shouldDisplayAuthorizationView(false);
    }
    func didCreateConnectionWithIdentifier(identifier : String) -> (){
        aDelegate?.shouldDisplayText("Running...");
        aDelegate?.shouldDisplayAuthorizationView(false);
    }
    func didDestroyConnectionWithIdentifier(identifier : String) -> (){
        aDelegate?.shouldDisplayText("Stopped...");
        aDelegate?.shouldDisplayAuthorizationView(false);
    }

}

