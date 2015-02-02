//
//  userExtensions.swift
//  Nexus
//
//  Created by Erik E. Beerepoot on 2015-02-01.
//  Copyright (c) 2015 Dactyl Studios. All rights reserved.
//

import Foundation

class UserController {
    
    var users : Dictionary<String,user> = Dictionary();
    
    init() {
        //query slack for users
        
    }
    
    func userWithUID(UID : String) -> (user?){
        return users[UID];
    }
}