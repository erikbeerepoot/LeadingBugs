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

class ViewController: NSViewController, SlackConnectionDelegate {

    enum state {
        case initialState;
        case preAuthorizationState;
        case authorizationState;
        case authorizedState;
    }
    
    let testMessage : NSString = "Hello, world!";
    
    var currentState : state = state.initialState;
    var stateTimer : NSTimer? = nil;
    var smileView : SmileView? = nil;
    var webView : WebView? = nil;
    var connection : SlackConnection? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //present initial view
        advanceStateMachine();

    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func advanceStateMachine() -> () {
        switch(currentState){
        case .initialState:
            presentSmileViewWithText("Hello!");
            currentState = state.preAuthorizationState;
            
            //set timer to goto next state
            self.stateTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "advanceStateMachine", userInfo: nil, repeats: false);
            break;
        case .preAuthorizationState:
            smileView!.SetTextToDisplay("Authorizing...");
            smileView!.setNeedsDisplayInRect(smileView!.frame)
            
            //set timer to goto next state
            currentState = state.authorizationState;
            self.stateTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "advanceStateMachine", userInfo: nil, repeats: false);
            break;
        case .authorizationState:
            smileView?.hidden = true;
            presentAuthorizationView();
            break;
        case .authorizedState:
            break;
        default:
            //error
            break;
        }
    }
    
    func presentAuthorizationView () -> () {
        //create webview
        webView = WebView(frame: self.view.frame);
        webView?.policyDelegate = self;
        self.view.addSubview(webView!);
        
        //add constraints
        //since swift doesn't allow us to use macros
        var viewBindingsDict: NSMutableDictionary = NSMutableDictionary()
        viewBindingsDict.setValue(webView, forKey: "webView")
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[webView]|", options: nil, metrics: nil, views: viewBindingsDict));
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[webView]|", options: nil, metrics: nil, views: viewBindingsDict));
        
        //perform authorization
        if(connection==nil) {
            connection = SlackConnection();
        }
        connection?.SetDelegate(self);
        connection?.Authorize();
    }
    
    func presentSmileViewWithText (text : NSString) -> () {
        smileView = SmileView(frame:self.view.frame);
        smileView?.SetTextToDisplay(text);
        self.view.addSubview(smileView!);
    }
    
    func didReceiveURLResponseWithData(response : NSURLResponse, data : NSData){
        webView?.mainFrame.loadData(data, MIMEType: "text/html", textEncodingName: "UTF-8", baseURL:response.URL);
    }
    
    func authorizationComplete() -> (){
        webView?.hidden = true;
        self.presentSmileViewWithText("Authorized!");
        connection?.Connect();
    }
    
    func didConnect() -> () {
        smileView?.SetTextToDisplay("Nexus running...");
        smileView!.setNeedsDisplayInRect(smileView!.frame)
        
        //send test message
        connection?.SendMessageToChannelWithName("Hello, everyone. My name is Nexus. Erik is my Master", channelName: NSString(string:kTestChannelID));
    }
    
    override func webView(webView: WebView!,
        decidePolicyForNavigationAction actionInformation: [NSObject : AnyObject]!,
        request: NSURLRequest!,
        frame: WebFrame!,
        decisionListener listener: WebPolicyDecisionListener!){

        //interpret results
        let actInfo = actionInformation as NSDictionary;
        if(actInfo.objectForKey(WebActionNavigationTypeKey) as Int == WebNavigationType.FormSubmitted.rawValue){
            //tried to submit form, parse code
            var originalURL = actInfo.objectForKey(WebActionOriginalURLKey) as NSURL;
            connection?.CompleteAuthorizationWithURL(originalURL.absoluteString!);
        }
        listener.use();
    }
    


}

