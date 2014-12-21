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
    func authorizationComplete() -> ();
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
        PerformAuthRequestWithURLAndParameters(URL, parameters : tokenDict, aCompletionHandler: ConnectionHandler)
        
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

    /**
        @name: Disconnect
        @brief: Disconnects from Slack
        @returns: Success (true) or failure (false)
    */
    func Disconnect() -> (Bool){
        return false;
    }
    
    
    func PerformAuthRequestWithURLAndParameters(url : NSURL, parameters : NSDictionary, aCompletionHandler : (NSDictionary?,NSURLResponse!,NSError?) -> ()) -> (){
        var sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration();
        var urlSession = NSURLSession(configuration: sessionConfiguration);
        
        //append parameters
        var urlString = NSMutableString(string : url.absoluteString!);
        urlString.appendString("?");
        for parameter in parameters {
            urlString.appendString((parameter.key as String) + "=" + (parameter.value as String) + "&");
        }
        
        //create task & start it
        let newUrl = NSURL(string: urlString)!;
        var task = urlSession.dataTaskWithURL(newUrl, completionHandler:
            { (data : NSData!, response: NSURLResponse!,error: NSError!) in
                //parse JSON back to dictionary
                let jsonDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary;
                aCompletionHandler(jsonDict,response,nil);
        });
        task.resume();
    }
    
    func PerformRequestWithURLAndJSONData(url : NSURL, jsonDict : NSDictionary, aCompletionHandler : (NSDictionary!,NSURLResponse!,NSError?) -> ()) -> (){
        
        var sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration();
        var urlSession = NSURLSession(configuration: sessionConfiguration);
        
        //append parameters
        var urlString = NSMutableString(string : url.absoluteString!);
        urlString.appendString("?");
        for parameter in jsonDict {
            urlString.appendString(NSString(string : parameter.key as String) + "=" + NSString(string : parameter.value as String)  + "&");
        }
        
        //create task & start it
        let newUrl = NSURL(string:urlString)!;
        var task = urlSession.dataTaskWithURL(newUrl, completionHandler:
            { (data : NSData!, response: NSURLResponse!,error: NSError!) in
                //parse JSON back to dictionary
                let jsonDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary;
                aCompletionHandler(jsonDict,response,nil);
        });
        task.resume();
    }
    
    /**
        @name: Authorize
        @brief: Performs authorization with Slack
        @returns: Success (true) or failure (false)
    */
    func Authorize() -> (Bool){
        if(isAuthorized) {
            return true;
        }
        
        var success : Bool = false;
        println("Authorizing with slack...");
        
        //setup session
        var sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration();
        var urlSession = NSURLSession(configuration: sessionConfiguration);

        //create authorization request
        var url = NSURL(string: SlackEndpoints.kAuthorizationEndpoint + "?client_id=2152097807.3263247755&team=T024G2VPR&scope=read,post,client");
        
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
    
    func CompleteAuthorizationWithURL(urlString : NSString) -> () {
        if(authorizationInProgress || isAuthorized) { return };
        
        //setup session
        var sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration();
        var urlSession = NSURLSession(configuration: sessionConfiguration);
        
        //update url to perform authorization
        var url = NSURL(string: urlString);
        
        var authTask = urlSession.dataTaskWithURL(url!, completionHandler:
            { (data : NSData!, response: NSURLResponse!,error: NSError!) in

                if(error != nil){
                    //grab the code from the error dict
                    let errorDict : NSDictionary = error.userInfo!;
                    let failingString : NSString = errorDict.objectForKey("NSErrorFailingURLStringKey") as NSString;
                    
                    //create a dictionary of parameter values
                    var queryStringDict = NSMutableDictionary()
                    let urlComponents : NSArray = failingString.componentsSeparatedByString("?");
                    let urlParameters : NSArray = urlComponents.objectAtIndex(1).componentsSeparatedByString("&")
                    let codeComponents : NSArray = urlParameters.objectAtIndex(0).componentsSeparatedByString("=");
                    let code  : NSString = codeComponents.objectAtIndex(1) as NSString;
                    self.CompleteAuthorizationWithCode(code);
                    self.authorizationInProgress = false;
                } else {
                    var httpResponse = response as NSHTTPURLResponse;
                    NSLog("URL: %@", httpResponse.URL!);
                    self.authorizationInProgress = false;
                }
                });
        authTask.resume();
        authorizationInProgress = true;
    }
    
    func CompleteAuthorizationWithCode(theCode : NSString) -> (){
        var success = false;
        
        //setup session
        var sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration();
        var urlSession = NSURLSession(configuration: sessionConfiguration);
        
        //update url to perform authorization
        var url = NSURL(string: SlackEndpoints.kOAuthAccessEndpoint + "?client_id=" + SlackIDs.kClientID + "&client_secret=" + kClientSecret + "&code=" + theCode);
        
        var authTask = urlSession.dataTaskWithURL(url!, completionHandler:
            { (data : NSData!, response: NSURLResponse!,error: NSError!) in
                success = false;
                if(error==nil){
                    let httpResponse = response as NSHTTPURLResponse;
                    let statusCode = httpResponse.statusCode;
                    
                    if(statusCode==kStatusCodeOK){
                        //parse data
                        let jsonData = NSJSONSerialization.JSONObjectWithData(data,options: NSJSONReadingOptions.MutableContainers, error: nil)

                        if(jsonData is NSDictionary) {
                            //check result
                            let jsonDict = jsonData as NSDictionary;
                            let successObject = jsonDict.objectForKey("ok");
                            if(successObject != nil){
                                let successCode = successObject as Int;
                                if(successCode == 0){
                                    NSLog("Failed with error: %@", jsonDict.objectForKey("error") as NSString);
                                } else {
                                    NSLog("Success!");
                                    self.isAuthorized = true;
                                    self.token = jsonDict.objectForKey(kAuthorizationKey) as String;
                                    
                                    dispatch_async(dispatch_get_main_queue(),{
                                        let delegateObj = self.delegate! as SlackConnectionDelegate
                                        self.delegate?.authorizationComplete();
                                    });
                                }
                            }
                        } else {
                            //error
                        }
                        success = true;
                    }                    
                }
        })
        authTask.resume();
    }
    //    func PerformRequestWithURLAndJSONData(url : NSURL, jsonDict : NSDictionary, aCompletionHandler : (NSDictionary!,NSURLResponse!,NSError?) -> ()) -> (){
    func SendMessageToChannelWithName(message : NSString, channelName : NSString) -> Bool {
        if(!isConnected) { return false; }
        
        //set values
        var paramDict = NSDictionary(objectsAndKeys: NSString(string: token!),"token",NSString(string: kBotName),"username",channelName,"channel",message.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!,"text");
        PerformRequestWithURLAndJSONData(NSURL(string: SlackEndpoints.kSendMessageEndpoint)!, jsonDict: paramDict, aCompletionHandler: MessageSentHandler);
        
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