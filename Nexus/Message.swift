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
* @name: Message.swift
* @author: Erik E. Beerepoot
* @company: Barefoot Inc.
* @brief: Message class
*/

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