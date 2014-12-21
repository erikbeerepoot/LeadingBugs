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
}

class SlackConnection {
    

    var isConnected : Bool = false;
    var delegate : SlackConnectionDelegate? = nil;
    
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
        println("Connecting...");
        Authorize();
        return false;
    }

    /**
        @name: Disconnect
        @brief: Disconnects from Slack
        @returns: Success (true) or failure (false)
    :returns: <#return value description#>
    */
    func Disconnect() -> (Bool){
        return false;
    }
    
    /**
        @name: Authorize
        @brief: Performs authorization with Slack
        @returns: Success (true) or failure (false)
    */
    func Authorize() -> (Bool){
        var success : Bool = false;
        println("Authorizing with slack...");
        
        //setup session
        var sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration();
        var urlSession = NSURLSession(configuration: sessionConfiguration);

        //create authorization request
        var url = NSURL(string: SlackEndpoints.kAuthorizationEndpoint + "?client_id=2152097807.3263247755&team=T024G2VPR");
        
        //send auth GET request
        var authTask = urlSession.dataTaskWithURL(url!, completionHandler:
            { (data : NSData!, response: NSURLResponse!,error: NSError!) in
                success = false;
                if(error==nil){
                    let httpResponse = response as NSHTTPURLResponse;
                    let statusCode = httpResponse.statusCode;
                    
                    
                    
                    if(statusCode==kStatusCodeOK){
                        //parse data
                        dispatch_async(dispatch_get_main_queue(),{
                            let delegateObj = self.delegate! as SlackConnectionDelegate
                            self.delegate?.didReceiveURLResponseWithData(response,data:data);
                        });

                        success = true;
                    }

                }
            })
        
        //kick off task
        authTask.resume();
        return success;
    }
    
    func CompleteAuthorization() -> (){
        var success = false;
        
        //setup session
        var sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration();
        var urlSession = NSURLSession(configuration: sessionConfiguration);
        
        //update url to perform authorization
        var url = NSURL(string: SlackEndpoints.kAuthorizationEndpoint + "?client_id=2152097807.3263247755&client_secret=01ad48926afe592a28f8571ae80cc4e9");
        
        var authTask = urlSession.dataTaskWithURL(url!, completionHandler:
            { (data : NSData!, response: NSURLResponse!,error: NSError!) in
                success = false;
                if(error==nil){
                    let httpResponse = response as NSHTTPURLResponse;
                    let statusCode = httpResponse.statusCode;
                    
                    if(statusCode==kStatusCodeOK){
                        //parse data
                        //let jsonArray = NSJSONSerialization.JSONObjectWithData(data,options: NSJSONReadingOptions.MutableContainers, error: nil)
                        success = true;
                    }                    
                }
        })

    }
    
    
}