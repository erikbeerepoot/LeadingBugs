/*
*      ___           ___           ___           ___                         ___           ___
*     /  /\         /  /\         /  /\         /  /\          ___          /  /\         /  /\          ___
*    /  /::\       /  /::\       /  /::\       /  /::\        /  /\        /  /::\       /  /::\        /__/\
*   /  /:/\:\     /  /:/\:\     /  /:/\:\     /  /:/\:\      /  /::\      /  /:/\:\     /  /:/\:\       \  \:\
*  /  /::\ \:\   /  /::\ \:\   /  /::\ \:\   /  /::\ \:\    /  /:/\:\    /  /:/  \:\   /  /:/  \:\       \__\:\
* /__/:/\:\_\:| /__/:/\:\_\:\ /__/:/\:\_\:\ /__/:/\:\ \:\  /  /::\ \:\  /__/:/ \__\:\ /__/:/ \__\:\      /  /::\
* \  \:\ \:\/:/ \__\/  \:\/:/ \__\/~|::\/:/ \  \:\ \:\_\/ /__/:/\:\ \:\ \  \:\ /  /:/ \  \:\ /  /:/     /  /:/\:\
*  \  \:\_\::/       \__\::/     |  |:|::/   \  \:\ \:\   \__\/  \:\_\/  \  \:\  /:/   \  \:\  /:/     /  /:/__\/
*   \  \:\/:/        /  /:/      |  |:|\/     \  \:\_\/        \  \:\     \  \:\/:/     \  \:\/:/     /__/:/
*    \__\::/        /__/:/       |__|:|~       \  \:\           \__\/      \  \::/       \  \::/      \__\/
*        ~~         \__\/         \__\|         \__\/                       \__\/         \__\/
* @name: JSON.swift
* @author: Erik E. Beerepoot
* @company: Barefoot Inc.
* @brief: HTTP request abstractions
*/

import Foundation

func performRequestWithURL(url : NSURL,#queryParams : NSDictionary,andCompletionHandler aCompletionHandler : (NSData!,NSURLResponse!,NSError?) -> ()) -> (){
    
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
//            let jsonDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary;
            aCompletionHandler(data,response,nil);
    });
    task.resume();
}

func performRequestWithURL(url : NSURL,token : String, #serializableObject : SerializableParameterObject , andCompletionHandler aCompletionHandler : (NSData!,NSURLResponse!,NSError?) -> ()) -> (){
    
    var sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration();
    var urlSession = NSURLSession(configuration: sessionConfiguration);
    
    //append parameters
    var urlString = String(url.absoluteString!) + "?token=" + token + serializableObject.serialize();
    
    //create task & start it
    let newUrl = NSURL(string:urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!;
    var task = urlSession.dataTaskWithURL(newUrl, completionHandler:
        { (data : NSData!, response: NSURLResponse!,error: NSError!) in
            //parse JSON back to dictionary
//            let jsonDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary;
            aCompletionHandler(data,response,nil);
    });
    task.resume();
}