//
//  SlackConnection.swift
//  Nexus
//
//  Created by Erik E. Beerepoot on 2014-12-19.
//  Copyright (c) 2014 Dactyl Studios. All rights reserved.
//

import AppKit
import Foundation

//MARK: Protocol: SlackConnectionControllerDelegate
protocol SlackConnectionControllerDelegate {
    func connectionFailedWithIdentifier(identifier : String, error: NSError) -> ();
    func didCreateConnectionWithIdentifier(identifier : String) -> ();
    func didDestroyConnectionWithIdentifier(identifier : String) -> ();
}

class SlackConnectionController : SlackConnectionDelegate {
    //MARK: Member variables
    var connections : Dictionary<String,SlackConnection>? = nil;
    var delegate : SlackConnectionControllerDelegate? = nil;
    
    //MARK: Construction/Destruction
    init() {
        connections = Dictionary();
    }
    
    //MARK: Main logic
    func createConnection() -> (){
        let newConnection = SlackConnection();
        let identifier = NSUUID().UUIDString;

        connections?.updateValue(newConnection, forKey: identifier);
    }

    /**
     @name: destroyConnectionWithIdentifier
     @brief: Disconnects and destroys the connection with the given identifier
     @param: the identifier of the connection
     @returns: true, if the connection was found, false if not found
    */
    func destroyConnectionWithIdentifier(identifier : String) -> (Bool){
        let connection = connections?[identifier];
        if(connection != nil){
            connection?.disconnect();
        } else {
            return false;
        }
        return true;
    }
    
    //MARK: Delegate methods
    func setDelegate(aDelegate : SlackConnectionControllerDelegate){
        delegate = aDelegate;
    }
    
    /**
     @name: connectionDidFinishWithError
     @brief: Method called when the connection attempt has finished
     @param: error - The error object (if present)
     @param: sender - The connection object invoking the method
    */
    func connectionDidFinishWithError(error : NSError?, sender : SlackConnection) -> (){

        //find key for the connection
        let identifier = keyForConnection(sender);
        if(identifier==nil){
            //uh-oh
            return;
        }
        
        //we've found the connection, notify delegate of results
        if(error==nil){
            self.delegate?.didCreateConnectionWithIdentifier(identifier!);
        } else {
            self.delegate?.connectionFailedWithIdentifier(identifier!,error:error!);
        }
    }
    
    /**
    @name: connectionDidDisconnectWithError
    @brief: Method called when the connection has been disconnected
    @param: error - The error object (if present)
    @param: sender - The connection object invoking the method
    */
    func connectionDidDisconnectWithError(error: NSError?, sender : SlackConnection) {
        //find key for the connection
        let identifier = keyForConnection(sender);
        if(identifier==nil){
            //uh-oh
            return;
        }
        //delete the connection
        connections?[identifier!] = nil;
        
        //notify the delegate this connection has now been destroyed
        self.delegate?.didDestroyConnectionWithIdentifier(identifier!);
    }
    
    //MARK: Helper functions
    /**
    @name: keyForConnection
    @brief: Finds the key for the connection passed to the method (if it exists)
    @param: theConnection - the connection we want to find
    @returns: the key if it exists, nil otherwise
    */
    func keyForConnection(theConnection : SlackConnection) -> (String?) {
        var connectionIdentifier : String? = nil;
        for (identifier,connection) in connections! {
            if(connection===theConnection){
                connectionIdentifier = identifier;
                break;
            }
        }
        return connectionIdentifier;
    }
}


    
//    //    func PerformRequestWithURLAndJSONData(url : NSURL, jsonDict : NSDictionary, aCompletionHandler : (NSDictionary!,NSURLResponse!,NSError?) -> ()) -> (){
//    func SendMessageToChannelWithName(message : NSString, channelName : NSString) -> Bool {
//        if(!isConnected) { return false; }
//        
//        //set values
//        var paramDict = NSDictionary(objectsAndKeys: NSString(string: token!),"token",NSString(string: kBotName),"username",channelName,"channel",message.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!,"text");
//    //    PerformRequestWithURLAndJSONData(NSURL(string: SlackEndpoints.kSendMessageEndpoint)!, jsonDict: paramDict, aCompletionHandler: MessageSentHandler);
//        
//        return true;
//    }
//    
//    func MessageSentHandler(data : NSDictionary?, urlResponse : NSURLResponse!, error : NSError?) -> (){
//        if(data != nil){
//            NSLog("Connection attempt result: %@", data!);
//            let result = data!.objectForKey(kOKKey) as Int;
//            if(result==1){
//                //success!
//                isConnected = true;
//            } else {
//                NSLog("Failed to connect to Slack. Error: %@", data!.objectForKey(kErrorKey) as NSString);
//                isConnected = false;
//            }
//        } else {
//            //bad stuff happened
//        }
//    }