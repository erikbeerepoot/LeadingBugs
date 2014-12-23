//
//  HTTPRequest.swift
//  Nexus
//
//  Created by Erik E. Beerepoot on 2014-12-21.
//  Copyright (c) 2014 Dactyl Studios. All rights reserved.
//

import Foundation

func performRequestWithURL(url : NSURL,#queryParams : NSDictionary,andCompletionHandler aCompletionHandler : (NSDictionary!,NSURLResponse!,NSError?) -> ()) -> (){
    
    var sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration();
    var urlSession = NSURLSession(configuration: sessionConfiguration);
    
    //append parameters
    var urlString = NSMutableString(string : url.absoluteString!);
    urlString.appendString("?");
    for parameter in queryParams {
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

func performRequestWithURL(url : NSURL,token : String, #serializableObject : SerializableParameterObject , andCompletionHandler aCompletionHandler : (NSDictionary!,NSURLResponse!,NSError?) -> ()) -> (){
    
    var sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration();
    var urlSession = NSURLSession(configuration: sessionConfiguration);
    
    //append parameters
    var urlString = String(url.absoluteString!) + "?token=" + token + serializableObject.serialize();
    
    //create task & start it
    let newUrl = NSURL(string:urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!;
    var task = urlSession.dataTaskWithURL(newUrl, completionHandler:
        { (data : NSData!, response: NSURLResponse!,error: NSError!) in
            //parse JSON back to dictionary
            let jsonDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary;
            aCompletionHandler(jsonDict,response,nil);
    });
    task.resume();
}