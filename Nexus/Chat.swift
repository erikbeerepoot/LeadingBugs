//
//  Chat.swift
//  Nexus
//
//  Created by Erik E. Beerepoot on 2014-12-22.
//  Copyright (c) 2014 Dactyl Studios. All rights reserved.
//

import Foundation

//the optional fields go in a mutable dictionary
//the required fields don't because we don't want to have someone remove them
class Message {
    //mandatory fields
    var token : String;
    var channel : String;
    var text : String;

    //dict of keys and values
    var parameters = NSMutableDictionary();
    
    init(aToken : String, aChannel : String, messageText : String) {
        token = aToken;
        channel = aChannel;
        text = messageText;
    }
    
    func updateArgument(argumentName : String, withValue value : String) -> (){
        parameters[argumentName] = value;
    }
    
    func removeArgumentWithName(argumentName : String) -> (Bool){
        if(parameters[argumentName]==nil){
            return false;
        } else {
            parameters[argumentName]=nil;
        }
        return true;
    }
    
};