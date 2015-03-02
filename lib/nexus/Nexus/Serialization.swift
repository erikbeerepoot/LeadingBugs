//
//  Dictionary+More.swift
//  Nexus
//
//  Created by Erik E. Beerepoot on 2014-12-22.
//

import Foundation


func encodeDictionary(dict : Dictionary<String,String>?) -> String{
    if dict == nil {
        return String("");
    }
    
    if dict!.count == 0 {
        return String("");
    }
    var encodedString = String("&");
    
    //append all keys & values in the dict
    for (key,value) in dict! {
        encodedString += key + "=" + value + "&";
    }
    return encodedString;
}
