//
//  Dictionary+More.swift
//  Nexus
//
//  Created by Erik E. Beerepoot on 2014-12-22.
//  Copyright (c) 2014 Dactyl Studios. All rights reserved.
//

import Foundation


func encodeDictionary(dict : Dictionary<String,String>) -> String{
    if dict.count == 0 {
        return String("");
    }
    var encodedString = String("&");
    
    //append all keys & values in the dict
    for (key,value) in dict {
        encodedString += key + "=" + value + "&";
    }
    return encodedString;
}
