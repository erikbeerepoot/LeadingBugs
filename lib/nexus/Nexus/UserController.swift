//
//  userExtensions.swift
//  Nexus
//
//  Created by Erik E. Beerepoot on 2015-02-01.
//  Copyright (c) 2015 Dactyl Studios. All rights reserved.
//

import Foundation

class UserController {
    var users : Dictionary<String,ExtendedUser> = Dictionary();
    
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
            
            //now add to the user cache (if we have an id, which we definitely should!)
            if(currentUser.id != nil){
                users[currentUser.id!] = currentUser as? ExtendedUser;
            }
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
    
    /**
    * Returns a random user from the user dictionary, or nil if no users are present.
    * @notes: Notices that it returns a random user, not necessarily and active user.
    * for that, see getRandomActiveUser()
    * @returns: a user, by value.
    */
    func getRandomUser() -> (user?){
        let randomNum = Int(arc4random_uniform(UInt32(users.count)));

        var index = 0;
        for value in users.values {
            if(index==randomNum){
                return value;
            }
            index++;
        }
        return nil;
    }
    
    /**
    Returns a random *active* user from the user dictionary, or nil if no users are present.
    @returns: a user, by value.
    */
    func getRandomActiveUser() -> (user?){
        var userList : Array<ExtendedUser> = Array();

        //Prune the user dict to only active users (& generate an array for indexing)
        for value in users.values {
            if(value.presence != "inactive"){
                userList.append(value as ExtendedUser);
            }
        }
        
        //generate a random number for user selection
        let randomNum = Int(arc4random_uniform(UInt32(userList.count)));
        return userList[randomNum];
    }
}