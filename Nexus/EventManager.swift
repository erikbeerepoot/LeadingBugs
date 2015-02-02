//
//  Event.swift
//  Nexus
//
//  Created by Erik E. Beerepoot on 2014-12-24.
//  Copyright (c) 2014 Dactyl Studios. All rights reserved.
//

import Foundation


let event_hello : String = "hello";
let event_presenceChange : String = "presence_change";
let event_manualPresenceChange : String = "manual_presence_change";


class EventManager : SlackRealTimeConnectionDelegate {
   
    func didReceiveEvent(eventData: JSON, onConnection sourceConnection : SlackConnection) {
        //process event
        
        switch(eventData["type"].string!){
            case event_hello:
                println("Hello message was sent!");
            case event_presenceChange:
                fallthrough
            case event_manualPresenceChange:
                processEvent_presenceChange(eventData,withConnection :sourceConnection);
            default:
                println("Unknown event received!");
        }
        
    }

    func processEvent_presenceChange(eventData : JSON, withConnection sourceConnection : SlackConnection) -> (){
        if(eventData["type"].string != event_presenceChange){
            return;
        }
        
        //process presence change
        var message : Message? = nil;
        let channel : String = kTestChannelID;
        switch(eventData["presence"]){
            case "active":
                //send hello message
                message = Message(aChannel: channel, messageText: "Hello");
            case "offline":
                //taunt user
                message = Message(aChannel: channel, messageText: "Goodbye");
            case "away":
                //do nothing?
                message = Message(aChannel: channel, messageText: eventData["user"].string! + "Went to take a nap.");
            default:
                println("Unknown user presence. Not handling.");
        }
        
        //actually send the message
        if(message != nil){
            MessageController.sendMessage(message!, onConnection: sourceConnection);
        }
    }
}
