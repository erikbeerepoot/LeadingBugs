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

class MessageController {
    var messageCount : Int = 0;
    
    func sendMessage(message : Message) -> (Bool){
        
        //send test message
        let url = NSURL(string:SlackEndpoints.kSendMessageEndpoint)!;
        let connection = connectionController?.connectionForIdentifier(connectionID!);
        let msg = Message(aChannel: kTestChannelID, messageText: "Ahhh. What a beautiful day to be alive!");
        msg.updateArgument("username", withValue: "nexus");
        connection?.send(url, sendObject: msg, callback: nil);
        
        messageCount++;
        return true;
    }


    
}