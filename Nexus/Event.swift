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



enum Event : SlackRealTimeConnectionDelegate {
   
    func didReceiveEvent(eventData: JSON, sourceConnection : SlackConnection) {
        //process event
        
        switch(eventData["type"]){
            case event_hello:
                println("Hello message was sent!");
            case event_presenceChange:
                processEvent_presenceChange(eventData);
            
        }
        
    }
}

func processEvent_presenceChange(eventData : JSON, sourceConnection : SlackConnection) -> (){
    if(eventData["type"] != event_presenceChange){
        return;
    }
    
    //process presence change
    var message : Message? = nil;
    switch(eventData["presence"]){
        case "active":
            //send hello message
            message = Message(aChannel: eventData["channel"], messageText: "Hello");
        case "offline":
            //taunt user
            message = Message(aChannel: eventData["channel"], messageText: "Goodbye");
        case "away":
            //do nothing?
            message = Message(aChannel: eventData["channel"], messageText: eventData["user"] + "Went to take a nap.");
        
    }
    
    if(message){
        sourceConnection.send(SlackEndpoints.kSendMessageEndpoint, sendObject: message, callback: nil);
    }
}

