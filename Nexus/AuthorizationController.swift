//
//  AuthorizationController.swift
//  Nexus
//
//  Created by Erik E. Beerepoot on 2014-12-21.
//  Copyright (c) 2014 Dactyl Studios. All rights reserved.
//

import Foundation
import WebKit

//MARK: Protocol: AuthorizationControllerDelegate
protocol AuthorizationControllerDelegate {
    func authorizationDidFinishWithError(error : NSError?) -> ();
}

class AuthorizationController {
    //member variables
    var delegate : AuthorizationControllerDelegate? = nil;
    var authorized : Bool = false;
    var authorizationToken : String = String();
    
    //auth view
    private var m_authorizationView : WebView? = nil;
    
    func setAuthorizationView(authorizationView : WebView) -> (){
        m_authorizationView = authorizationView;
        m_authorizationView?.policyDelegate = self;
    }
    
    //MARK: Authorization methods
    /**
    @name: startAuthorization
    @brief: Starts authorization process with Slack
    @returns: True, if the process has been started. False, if not.
    */
    func startAuthorization() -> (Bool){
        if authorized { return true; }
        if m_authorizationView==nil { return false; }
        
        println("Authorizing with slack...");
        
        //setup session
        var sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration();
        var urlSession = NSURLSession(configuration: sessionConfiguration);
        
        //create authorization request
        var url = NSURL(string: SlackEndpoints.kAuthorizationEndpoint + "?client_id=" + SlackIDs.kClientID +  "&team=" + SlackIDs.kTeamID + "&scope=read,post,client");
        
        //send auth GET request
        var authTask = urlSession.dataTaskWithURL(url!, completionHandler:
            { (data : NSData!, response: NSURLResponse!,error: NSError!) in
                //process results
                if(error==nil){
                    let statusCode = (response as NSHTTPURLResponse).statusCode;
                    if(statusCode==kStatusCodeOK){
                        //show authorization prompt on UI
                        dispatch_async(dispatch_get_main_queue(),{
                            let url : NSURL = response.URL!
                            self.m_authorizationView?.mainFrame.loadData(data, MIMEType: "text/html", textEncodingName: "UTF-8", baseURL:url);
                            self.m_authorizationView?.hidden = false;
                        });
                    }
                } else {
                    //tell delegate about the error
                    dispatch_async(dispatch_get_main_queue(),{
                        let err = error!;
                        self.delegate?.authorizationDidFinishWithError(err);
                    });
                }
        })
        
        //kick off task
        authTask.resume();
        return true;
    }
    

    func processAuthorizationResponseWithURL(urlString : NSString) -> () {
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
                    self.completeAuthorizationWithCode(code);

                } else {
                    var httpResponse = response as NSHTTPURLResponse;
                    NSLog("URL: %@", httpResponse.URL!);
                }
        });
        authTask.resume();
    }

    func completeAuthorizationWithCode(theCode : NSString) -> (){
        if(authorized) { return };
        
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
                                    self.delegate?.authorizationDidFinishWithError(nil);
                                    
                                    //hide webview
                                    self.m_authorizationView?.hidden = true;
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
    
    //MARK: WebView & Co delegate methods
    func webView(webView: WebView!,
        decidePolicyForNavigationAction actionInformation: [NSObject : AnyObject]!,
        request: NSURLRequest!,
        frame: WebFrame!,
        decisionListener listener: WebPolicyDecisionListener!){

        //interpret results
        let actInfo = actionInformation as NSDictionary;
        if(actInfo.objectForKey(WebActionNavigationTypeKey) as Int == WebNavigationType.FormSubmitted.rawValue){
            //tried to submit form, parse code
            var originalURL = actInfo.objectForKey(WebActionOriginalURLKey) as NSURL;
            self.processAuthorizationResponseWithURL(originalURL.absoluteString!);
        }
        listener.use();
    }
}