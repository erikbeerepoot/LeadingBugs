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
* @name: SlackConnectionController.swift
* @author: Erik E. Beerepoot
* @company: Barefoot Inc.
* @brief: Controller object for SlackConnections. Essentially, it manages
* the connection & authorization process, and keeps track of all the connections in flight.
*/

import AppKit
import Foundation

//MARK: Protocol: SlackConnectionControllerDelegate
protocol SlackConnectionControllerDelegate {
    func connectionFailedWithIdentifier(identifier : String,andError error: NSError) -> ();
    func didCreateConnectionWithIdentifier(identifier : String) -> ();
    func didDestroyConnectionWithIdentifier(identifier : String) -> ();
    func connectionAttemptForIdentfier(identifier : String) -> ();
}

class SlackConnectionController : SlackConnectionDelegate,AuthorizationControllerDelegate {
    //MARK: Member variables
    var authorizationController : AuthorizationController? = nil;
    var connections : Dictionary<String,SlackConnection>? = nil;
    var delegate : SlackConnectionControllerDelegate? = nil;

    
    //MARK: Construction/Destruction
    init() {
        connections = Dictionary();
        
        //configure authorization controller
        authorizationController = AuthorizationController();
        authorizationController?.delegate = self;
    }
    
    //MARK: Main logic
    
    /**
    Creates a new connection, returning the unique identifier.    
    @param: rtDelegate - The RealTime delegate. The delegate object that receives real-time event notifications.
    @returns: The UID of this connection.
    */
    func createConnection(rtDelegate : SlackRealTimeConnectionDelegate?) -> (String){
        let newConnection = SlackConnection();
        let identifier = NSUUID().UUIDString;
        newConnection.delegate = self;
        newConnection.rtDelegate = rtDelegate;
        
        //attemp authorization
        if(!authorizationController!.authorized){
            authorizationController!.startAuthorization();
        }

        //update delegate
        delegate?.connectionAttemptForIdentfier(identifier);
        
        //new connection in dict
        connections?.updateValue(newConnection, forKey: identifier);
        return identifier;
    }
    
    /**
     @name: connectionForIdentifier
     @brief: Returns the SlackConnection for the identifier, if it exists
     @returns: reference to SlackConnection
    */
    func connectionForIdentifier(id : String) -> SlackConnection? {
        return connections?[id];
    }
    
    /**
     * @name: getConnection
     * @brief: Returns an arbitrary connection 
     * @returns: a SlackConnection instance
     */
    func getConnection() -> SlackConnection? {
        if(connections?.count<1){
            return nil;
        } else {
            for (connKey,connValue) in connections! {
                return connValue;
            }
        }
        return nil;
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
            self.delegate?.connectionFailedWithIdentifier(identifier!,andError:error!);
            connections?[identifier!] = nil;
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
    
    //MARK: Delegate methods
    func authorizationDidFinishWithError(error : NSError?) -> (){
        if(error == nil){
            //if we have connections in our dict, connect them
            for connection in connections!.values {
                connection.authorized = true;
                connection.token = authorizationController!.authorizationToken;
                connection.connect(enableRealTimeEvents:true);
            }
        } else {
            //create error
            let userInfo = [
                NSLocalizedDescriptionKey : String("Could not connect: not authorized."),
                NSLocalizedFailureReasonErrorKey : String("Could not authorize with Slack!"),
                NSLocalizedRecoverySuggestionErrorKey : String("Unknown")
            ];
            let err = NSError(domain: kAuthorizationErrorDomain, code: -1, userInfo: userInfo);
            
            //not authorized, cannot connect
            for id in connections!.keys {
                self.delegate?.connectionFailedWithIdentifier(id, andError:err);
            }
            //destroy all connections
            connections = nil;
        }
    }

}