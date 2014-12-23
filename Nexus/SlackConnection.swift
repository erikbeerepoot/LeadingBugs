//
//  SlackConnection.swift
//  Nexus
//
//  Created by Erik E. Beerepoot on 2014-12-21.
//  Copyright (c) 2014 Dactyl Studios. All rights reserved.
//

import Foundation

protocol SlackConnectionDelegate {
    func connectionDidFinishWithError(error : NSError?, sender: SlackConnection) -> ();
    func connectionDidDisconnectWithError(error : NSError?, sender : SlackConnection) -> ();
}

class SlackConnection {
    var delegate : SlackConnectionDelegate? = nil;
    var connected : Bool = false;
    var authorized : Bool = false;
    var token : NSString? = nil;
    
    /**
    @name: Init
    @brief: Class initialization
    */
    init() {}
    
    func SetDelegate(aDelegate : SlackConnectionDelegate){
        delegate = aDelegate;
    }
    
    /**
    @name: Connect
    @brief: Connects to slack (authenticated)
    @returns: Success (true) or failure (false)
    */
    func connect() -> (Bool){
        if(!authorized){ return false; }
        
        //we are authorized, attempt a connection
        println("Connecting...");
        
        let tokenDict = NSDictionary(object: token!, forKey: "token");
        let URL : NSURL = NSURL(string: SlackEndpoints.kConnectEndpoint)!;
        PerformRequestWithURLAndQueryParameters(URL,tokenDict,connectionHandler);
        return true;
    }
    
    /**
    @name: Disconnect
    @brief: Disconnects from Slack
    @returns: Success (true) or failure (false)
    */
    func disconnect() -> (Bool){
        return false;
    }
    
    func connectionHandler(data : NSDictionary?, urlResponse : NSURLResponse!, error : NSError?) -> () {
        if(data != nil){
            NSLog("Connection attempt result: %@", data!);
            let result = data!.objectForKey(kOKKey) as Int;
            if(result==1){
                //success!
                connected = true;
                delegate?.connectionDidFinishWithError(nil,sender:self);
            } else {
                NSLog("Failed to connect to Slack. Error: %@", data!.objectForKey(kErrorKey) as NSString);
                delegate?.connectionDidFinishWithError(error,sender:self);
                connected = false;
            }
        } else {
            //bad stuff happened
        }
    }
    
}