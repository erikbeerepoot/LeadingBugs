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
    var sentCallback : ((Bool,NSError?) -> ())? = nil;
    var delegate : SlackConnectionDelegate? = nil;
    var connected : Bool = false;
    var authorized : Bool = false;
    var token : NSString? = nil;
    
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
        performRequestWithURL(URL, queryParams:tokenDict,andCompletionHandler:connectionHandler);
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
    
    func send(url : NSURL,sendObject : SerializableParameterObject, callback : ((result : Bool, error : NSError?) -> ())?) -> (){
        sentCallback = callback;
        performRequestWithURL(url,token!, serializableObject: sendObject, andCompletionHandler:sentHandler);
    }
    
    
    /**
     * @name: connectionHandler
     * @brief: Callback invoked when connection attempt completes
     * @param: data - data received
     * @param: urlResponse - URL response received
     * @param: error (optional) - Error received, nil if no error
     */
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
    
    /**
    * @name: sentHandler
    * @brief: Callback invoked when send completed
    * @param: data - data received
    * @param: urlResponse - URL response received
    * @param: error (optional) - Error received, nil if no error
    */
    func sentHandler(data : NSDictionary?, urlResponse : NSURLResponse!, error : NSError?) -> () {
        if(data != nil){
            let result = data!.objectForKey(kOKKey) as Bool;
            sentCallback?(result,error);
        }
    }
    
}