//
//  SlackConnection.swift
//  Nexus
//
//  Created by Erik E. Beerepoot on 2014-12-19.
//  Copyright (c) 2014 Dactyl Studios. All rights reserved.
//

import AppKit
import Foundation

protocol SlackConnectionDelegate {
    func didReceiveURLResponseWithData(response : NSURLResponse,data : NSData) -> ();
    func didConnect() -> ();
}

class SlackConnection {
    
    var authorizationInProgress : Bool = false;
    var isAuthorized : Bool = false;
    var isConnected : Bool = false;
    var delegate : SlackConnectionDelegate? = nil;
    var token : NSString? = nil;
    /**
        @name: Init
        @brief: Class initialization
    */
    init() {
        Connect();
    }

    func SetDelegate(aDelegate : SlackConnectionDelegate){
        delegate = aDelegate;
    }
    
    /**
        @name: Connect
        @brief: Connects to slack (authenticated)
        @returns: Success (true) or failure (false)
    */
    func Connect() -> (Bool){
        if(!isAuthorized){ return false; }
        
        //we are authorized, attempt a connection
        println("Connecting...");
        
        let tokenDict = NSDictionary(object: token!, forKey: "token");
        let URL : NSURL = NSURL(string: SlackEndpoints.kConnectEndpoint)!;
        return false;
    }
    
    /**
    @name: Disconnect
    @brief: Disconnects from Slack
    @returns: Success (true) or failure (false)
    */
    func Disconnect() -> (Bool){
        return false;
    }
    
    
    
    
    func ConnectionHandler(data : NSDictionary?, urlResponse : NSURLResponse!, error : NSError?) -> () {
        if(data != nil){
            NSLog("Connection attempt result: %@", data!);
            let result = data!.objectForKey(kOKKey) as Int;
            if(result==1){
                //success!
                isConnected = true;
                delegate?.didConnect()
            } else {
                NSLog("Failed to connect to Slack. Error: %@", data!.objectForKey(kErrorKey) as NSString);
                isConnected = false;
            }
        } else {
            //bad stuff happened
        }
    }

    
    
    
    //    func PerformRequestWithURLAndJSONData(url : NSURL, jsonDict : NSDictionary, aCompletionHandler : (NSDictionary!,NSURLResponse!,NSError?) -> ()) -> (){
    func SendMessageToChannelWithName(message : NSString, channelName : NSString) -> Bool {
        if(!isConnected) { return false; }
        
        //set values
        var paramDict = NSDictionary(objectsAndKeys: NSString(string: token!),"token",NSString(string: kBotName),"username",channelName,"channel",message.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!,"text");
    //    PerformRequestWithURLAndJSONData(NSURL(string: SlackEndpoints.kSendMessageEndpoint)!, jsonDict: paramDict, aCompletionHandler: MessageSentHandler);
        
        return true;
    }
    
    func MessageSentHandler(data : NSDictionary?, urlResponse : NSURLResponse!, error : NSError?) -> (){
        if(data != nil){
            NSLog("Connection attempt result: %@", data!);
            let result = data!.objectForKey(kOKKey) as Int;
            if(result==1){
                //success!
                isConnected = true;
            } else {
                NSLog("Failed to connect to Slack. Error: %@", data!.objectForKey(kErrorKey) as NSString);
                isConnected = false;
            }
        } else {
            //bad stuff happened
        }
    }
    
    
}