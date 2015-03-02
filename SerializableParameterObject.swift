//
//  File.swift
//  Nexus
//
//  Created by Erik E. Beerepoot on 2014-12-22.
//  Copyright (c) 2014 Dactyl Studios. All rights reserved.
//

import Foundation

class SerializableParameterObject {
    var optionalParameters : Dictionary<String,String> = Dictionary();
    var requiredParameters : Dictionary<String,String> = Dictionary();
    
    func serialize() -> (String) {
        return (encodeDictionary(requiredParameters) + encodeDictionary(optionalParameters));
    }
}