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


protocol NexusDelegate {
    var authorizationView : WebView { get };
    func shouldDisplayText(text : String) -> ();
    func shouldDisplayAuthorizationView(shouldDisplayView : Bool) ->();
}

class Nexus : SlackRealTimeConnectionDelegate, SlackConnectionControllerDelegate {
   
    //controllers
    var connectionController : SlackConnectionController? = nil;
    var connectionID : String? = nil;
    
    //slack data controllers
    var userController : UserController? = nil;

    var delegate : NexusDelegate? = nil;
    
    /**
    This method configures the main logic. The WebView is required for the application to authorize with Slack.
    :param: authorizationView - Reference to the WebView presented when a user is asked to authorize.
    :param: aDelegate - The object we send delegate events to.
    */
    func configureWithWebView(inout authorizationView : WebView, andDelegate aDelegate : NexusDelegate) -> (){
        //Create controller objects
        connectionController = SlackConnectionController();
        connectionController?.authorizationController?.setWebView(&authorizationView);
        connectionController?.delegate = self;
        
        //create new connection (if we haven't already created one)
        if(connectionID == nil || connectionID?.isEmpty==true){
            connectionID = connectionController?.createConnection(self);
        }        
        delegate = aDelegate;
    }
    
    /**
    Callback invoked when an event arrives from Slack
    @param: eventData - The JSON object associated with this event
    @param: sourceConnection - the SlackConnection this event was received on
    */
    func didReceiveEvent(eventData: JSON, onConnection sourceConnection : SlackConnection) {
        //process event
        
        switch(eventData["type"].string!){
            case event_hello:
                //We've connected, let's grab the users
                userController = UserController(connection:connectionController!.connectionForIdentifier(connectionID!)!);
            
                //schedule the coffee task
                let ct : CoffeeTask = CoffeeTask();
                ct.callback = coffeeTask;
                TaskScheduler.ScheduleTask(ct);
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
    
    /**
    Process a change in user presence
    @param: eventData - the JSON object associated with this event
    @param: sourceConnection - The connection this event was received on
    */
    func processEvent_presenceChange(eventData : JSON, withConnection sourceConnection : SlackConnection) -> (){
        if(eventData["type"].string != event_presenceChange){
            return;
        }
        
        //Grab the user
        let targetUser : user? = userController?.userWithUID(eventData["user"].string!);
        if(targetUser == nil){
            return;
        }
        
        //process presence change
        var message : Message? = nil;
        let channel : String = kTestChannelID;
        switch(eventData["presence"]){
            case "active":
                //send hello message
                message = Message(aChannel: channel, messageText: "Hello "
                        + targetUser!.name!
                        + "!");
            case "offline":
                //taunt user
                message = Message(aChannel: channel, messageText: "Goodbye"
                    + targetUser!.name!
                    + "!");
            case "away":
                //do nothing?
                message = Message(aChannel: channel, messageText: targetUser!.name! + " went to take a nap.");
            default:
                println("Unknown user presence. Not handling.");
        }
        
        //actually send the message
        if(message != nil){
            MessageController.sendMessage(message!, onConnection: sourceConnection);
        }
    }
    
    /**********************************************************************
    *                          Task Callbacks                             *
    **********************************************************************/
    //MARK: Task callbacks
    
    /**
    A callback invoked  when the coffeeTask expires.
    */
    func coffeeTask() -> () {
        let targetUser : user? = userController?.getRandomActiveUser();
        
        if(targetUser != nil){
            //we've found a victim, send the unwitting participant a message
            let message = Message(aChannel: kTestChannelID, messageText: "@" + targetUser!.name! + "! Go make coffee!");
            
            //actually send the message
            MessageController.sendMessage(message, onConnection: connectionController!.connectionForIdentifier(connectionID!)!);
  
        }
    }
    
    /**********************************************************************
    *                   ConnectionControllerDelegate                      *
    **********************************************************************/
    //MARK: Delegate methods
    
    func connectionAttemptForIdentfier(identifier : String) -> (){
        delegate?.shouldDisplayText("Connecting...");
        delegate?.shouldDisplayAuthorizationView(false);
    }
    
    func connectionFailedWithIdentifier(identifier : String, andError: NSError) -> (){
        delegate?.shouldDisplayText("Connection failed!");
        delegate?.shouldDisplayAuthorizationView(false);
    }
    func didCreateConnectionWithIdentifier(identifier : String) -> (){
        delegate?.shouldDisplayText("Running...");
        delegate?.shouldDisplayAuthorizationView(false);
    }
    func didDestroyConnectionWithIdentifier(identifier : String) -> (){
        delegate?.shouldDisplayText("Stopped...");
        delegate?.shouldDisplayAuthorizationView(false);
    }
}
