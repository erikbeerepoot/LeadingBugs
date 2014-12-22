//
//  AuthorizationController.swift
//  Nexus
//
//  Created by Erik E. Beerepoot on 2014-12-21.
//  Copyright (c) 2014 Dactyl Studios. All rights reserved.
//

import Foundation
import WebKit

protocol AuthorizationControllerDelegate {
    func authorizationDidFinish() -> ();
    func showAuthorizationPromptWithURLandData(url : NSURL, data : NSData) -> ();
    func authorizationDidFailWithError(error : NSError) -> ();
}

class AuthorizationController {
    //member variables
    var delegate : AuthorizationControllerDelegate? = nil;
    var authorized : Bool = false;
    var authorizationToken : String = String();
    
    //auth view
    var authorizationView : WebView? = nil;
    
    /**
    @name: Authorize
    @brief: Performs authorization with Slack
    @returns: Success (true) or failure (false)
    */
    func StartAuthorization() -> (Bool){
        if authorized { return true; }
        if authorizationView==nil { return false; }
        
        println("Authorizing with slack...");
        
        //setup session
        var sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration();
        var urlSession = NSURLSession(configuration: sessionConfiguration);
        
        //create authorization request
        var url = NSURL(string: SlackEndpoints.kAuthorizationEndpoint + "?client_id=2152097807.3263247755&team=T024G2VPR&scope=read,post,client");
        
        //send auth GET request
        var authTask = urlSession.dataTaskWithURL(url!, completionHandler:
            { (data : NSData!, response: NSURLResponse!,error: NSError!) in
                if(error==nil){
                    let httpResponse = response as NSHTTPURLResponse;
                    let statusCode = httpResponse.statusCode;

                    
                    if(statusCode==kStatusCodeOK){
                        //parse data
                        dispatch_async(dispatch_get_main_queue(),{
                            let url : NSURL = response.URL!
                            self.delegate?.showAuthorizationPromptWithURLandData(url, data: data);
                        });
                    }
                    
                } else {
                    //tell delegate about the error
                    dispatch_async(dispatch_get_main_queue(),{
                        let err = error!;
                        self.delegate?.authorizationDidFailWithError(err);
                    });
                }
        })
        
        //kick off task
        authTask.resume();
    }
    

    func authorizationResponseWithURL(urlString : NSString) -> () {
        if(authorized) { return };
        
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

                } else {
                    var httpResponse = response as NSHTTPURLResponse;
                    NSLog("URL: %@", httpResponse.URL!);
                }
        });
        authTask.resume();
    }

    func CompleteAuthorizationWithCode(theCode : NSString) -> (){
        
        //setup session
        var sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration();
        var urlSession = NSURLSession(configuration: sessionConfiguration);
        
        //update url to perform authorization
        var url = NSURL(string: SlackEndpoints.kOAuthAccessEndpoint + "?client_id=" + SlackIDs.kClientID + "&client_secret=" + kClientSecret + "&code=" + theCode);
        
        var authTask = urlSession.dataTaskWithURL(url!, completionHandler:
            { (data : NSData!, response: NSURLResponse!,error: NSError!) in
                if(error==nil){
                    let httpResponse = response as NSHTTPURLResponse;
                    let statusCode = httpResponse.statusCode;
                    
                    if(statusCode==kStatusCodeOK){
                        //parse data
                        let jsonData : AnyObject? = NSJSONSerialization.JSONObjectWithData(data,options: NSJSONReadingOptions.MutableContainers, error: nil)
                        
                        if(jsonData is NSDictionary) {
                            //check result
                            let jsonDict = jsonData as NSDictionary;
                            let successObject : AnyObject? = jsonDict.objectForKey("ok");

                            if(successObject != nil){
                                let successCode = successObject as Int;
                                if(successCode == 0){
                                    NSLog("Failed with error: %@", jsonDict.objectForKey("error") as NSString);
                                } else {
                                    NSLog("Success!");

                                    self.authorizationToken = jsonDict.objectForKey(kAuthorizationKey) as String;
                                    self.authorized = true;
                                    self.delegate?.authorizationDidFinish();
                                }
                            }
                        } else {
                            //error
                        }
                    }
                }
        })
        authTask.resume();
    }
}