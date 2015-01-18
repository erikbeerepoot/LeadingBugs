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

class AuthorizationController : NSObject {
    //member variables
    var delegate : AuthorizationControllerDelegate? = nil;
    var authorized : Bool = false;
    var authorizationToken : String = String();
    var state : String = NSString(format: "%d", arc4random());
    
    //auth view
    private var m_authorizationView : WebView? = nil;
    
    func setWebView(authorizationView : WebView) -> (){
        m_authorizationView = authorizationView;
        m_authorizationView!.policyDelegate = self;
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
        var url = NSURL(string: SlackEndpoints.kAuthorizationEndpoint + "?client_id=" + SlackIDs.kClientID +  "&team=" + SlackIDs.kTeamID + "&scope=read,post,client&" + kStateKey + "=" + state);
        
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
                                    //update state
                                    self.authorizationToken = jsonDict.objectForKey(kAuthorizationKey) as String;
                                    self.authorized = true;

                                    //hide webview
                                    dispatch_async(dispatch_get_main_queue(),{
                                        self.m_authorizationView!.hidden = true;
                                        self.m_authorizationView!.removeFromSuperview();
                                        self.m_authorizationView = nil;               
                                    });
                 
                                }
                                
                                //notify delegate
                                self.delegate?.authorizationDidFinishWithError(nil);
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
    override func webView(webView: WebView!,
        decidePolicyForNavigationAction actionInformation: [NSObject : AnyObject]!,
        request: NSURLRequest!,
        frame: WebFrame!,
        decisionListener listener: WebPolicyDecisionListener!){
        
        let actInfo = actionInformation as NSDictionary;
            
        //check if the user pressed a form submitted button
        if(actInfo.objectForKey(WebActionNavigationTypeKey) as Int == WebNavigationType.FormSubmitted.rawValue){
            //tried to submit form, check request validity
            var originalURL = actInfo.objectForKey(WebActionOriginalURLKey) as NSURL;
            if originalURL.absoluteString != request.URL.absoluteString {
                let code = parseQueryParametersForURL(request.URL);
                self.completeAuthorizationWithCode(code!);
            }
        }
        listener.use();
    }
    
    /**
     * @name: parseQueryParametersForURL
     * @brief: Parses the query string in the given URL, looking for "state" and "code", which are values needed for authorization
     * @param: url - the url to parse
     * @returns: String - the resulting code, nil if an error occurred
    */
    func parseQueryParametersForURL(url : NSURL) -> (String?){
        //parse string, get code & state
        let queryParameters = (url.query!).componentsSeparatedByString("&") ;
        var aCode : String? = nil;
        var aState : String? = nil;
        
        //for each parameter, check if it matches state or code
        for parameter in queryParameters {
            if parameter.rangeOfString(kCodeKey) != nil {
                aCode = parameter.componentsSeparatedByString("=")[1];
                continue;
            } else if parameter.rangeOfString(kStateKey) != nil {
                aState = parameter.componentsSeparatedByString("=")[1];
            }
        }
        
        //verify state received is the same as sent
        if state != aState {
            //uh-oh, man in the middle attack? Notify delegate!
            let userInfo = [
                NSLocalizedDescriptionKey : String("Failed to authorize."),
                NSLocalizedFailureReasonErrorKey : String("Suspicious behaviour: state mismatch!"),
                NSLocalizedRecoverySuggestionErrorKey : String("Verify security of your system.")
            ];
            
            let err = NSError(domain: kAuthorizationErrorDomain, code: -1, userInfo: userInfo);
            self.delegate?.authorizationDidFinishWithError(err);
            return nil;
        }
        
        if(aCode==nil){
            let userInfo = [
                NSLocalizedDescriptionKey : String("Failed to authorize."),
                NSLocalizedFailureReasonErrorKey : String("Did not receive a code from Slack server!"),
                NSLocalizedRecoverySuggestionErrorKey : String("Please try authorizing again.")
            ];
            
            let err = NSError(domain: kAuthorizationErrorDomain, code: -1, userInfo: userInfo);
            self.delegate?.authorizationDidFinishWithError(err);
            return nil;
        }
        return aCode!;
    }
}



