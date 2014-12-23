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
class Message : SerializableParameterObject {
    init(aChannel : String, messageText : String) {
        super.init();
        
        //put in dict
        requiredParameters["channel"] = aChannel;
        requiredParameters["text"] = messageText;
    }
    
    func updateArgument(argumentName : String, withValue value : String) -> (){
        optionalParameters[argumentName] = value;
    }
    
    func removeArgumentWithName(argumentName : String) -> (Bool){
        if(optionalParameters[argumentName]==nil){
            return false;
        } else {
            optionalParameters[argumentName]=nil;
        }
        return true;
    }
    
};