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
* @name: Nexus.swift
* @author: Erik E. Beerepoot
* @company: Barefoot Inc.
* @brief: Main bot logic
*/
import Foundation
import AppKit
import WebKit

let event_hello : String = "hello";
let event_presenceChange : String = "presence_change";
let event_manualPresenceChange : String = "manual_presence_change";


class Nexus : SlackRealTimeConnectionDelegate, SlackConnectionControllerDelegate {
   
    //controllers
    var connectionController : SlackConnectionController? = nil;
    var connectionID : String? = nil;

    func initWithWebView(inout authorizationView : WebView) -> (){

        //Create controller objects
        let authorizationController = AuthorizationController();
        authorizationController.setWebView(&authorizationView);
        connectionController = SlackConnectionController(authController: authorizationController);
        connectionController?.delegate = self;
        
        //create new connection
        connectionID = connectionController?.createConnection(self);
    }
    
    
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

    
    /**********************************************************************
     *                      Event Processing Code                         *
     **********************************************************************/
    //MARK: Event processing code
    
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
    
    /**********************************************************************
    *                   ConnectionControllerDelegate                      *
    **********************************************************************/
    //MARK: Delegate methods
    func connectionAttemptForIdentfier(identifier : String) -> (){

//        smileView?.SetTextToDisplay("Connecting...");
//        smileView?.setNeedsDisplayInRect(self.view.frame);
    }
    
    func connectionFailedWithIdentifier(identifier : String, andError: NSError) -> (){
//        smileView?.SetTextToDisplay("Connection failed!");
    }
    func didCreateConnectionWithIdentifier(identifier : String) -> (){
//        smileView?.SetTextToDisplay("Nexus running...");
//        smileView?.hidden = false;
//        smileView?.setNeedsDisplayInRect(self.view.frame);
    }
    func didDestroyConnectionWithIdentifier(identifier : String) -> (){
//        smileView?.SetTextToDisplay("Nexus stopped.");
//        authorizationView?.hidden = true;
//        smileView?.hidden = false;
    }
}
