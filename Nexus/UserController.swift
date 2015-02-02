//
//  userExtensions.swift
//  Nexus
//
//  Created by Erik E. Beerepoot on 2015-02-01.
//  Copyright (c) 2015 Dactyl Studios. All rights reserved.
//

import Foundation

class UserController {
    var users : Dictionary<String,user> = Dictionary();
    
    init(connection : SlackConnection) {
        //query slack for users
        let tokenDict = NSDictionary(object: connection.token!, forKey: "token");
        let URL : NSURL = NSURL(string: SlackEndpoints.userList)!;
        performRequestWithURL(URL, queryParams:tokenDict,andCompletionHandler:sentHandler);
    }
    
    /**
    * Callback to process data on completion of request
    * @name: sentHandler
    * @brief: Callback invoked when send completed
    * @param: data - data received
    * @param: urlResponse - URL response received
    * @param: error (optional) - Error received, nil if no error
    */
    func sentHandler(data : NSData?, urlResponse : NSURLResponse!, error : NSError?) -> () {
        let jsonObject = JSON(data:data!,options:NSJSONReadingOptions.MutableContainers);

        //get the array of members, return if empty
        let userArrayJSON : Array<JSON>? = jsonObject["members"].array;
        if(userArrayJSON == nil) {
            return;
        }
        
        //parse the JSON for each user
        for userJSON in userArrayJSON! {
            let currentUser : user = user();
            currentUser.packObject(userJSON);
        }
        
    }
    
    /**
     Returs a user instance for the given UID, if it exists
     @param: UID - the unique user id, in string form
     @returns: user object, nil if the user does not exist (or is not cached)
     */
    func userWithUID(UID : String) -> (user?){
        return users[UID];
    }
}