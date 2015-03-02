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
        requiredParameters["type"] = "message";
//        requiredParameters
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

struct MessageController {
    static var messageCount : Int = 0;
    
    static func sendMessage(message : Message, onConnection sourceConnection : SlackConnection) -> (Bool){

        
        //configure message parameters
        let url = NSURL(string:SlackEndpoints.sendMessage)!;
        message.updateArgument("username", withValue: kBotName);        
        sourceConnection.send(url, sendObject: message, callback: nil);
        
        //increase "global" message count
        messageCount++;
        return true;
    }


    
}