//
//  JSON.swift
//  Nexus
//
//  Created by Erik E. Beerepoot on 2014-12-23.
//  Copyright (c) 2014 Dactyl Studios. All rights reserved.
//

import Foundation

public enum JSON  {
    case Array([AnyObject])
    case Dictionary([Swift.String : AnyObject])
    case String(Swift.String)
    case Number(Float)
    case Null
    
    public static func wrap(object : AnyObject?) -> (JSON){
        if let str = object as? Swift.String {
            return .String(str);
        }
        if let array = object as? [AnyObject]{
            return .Array(array);
        }
        if let dict = object as? [Swift.String : AnyObject]{
            return .Dictionary(dict);
        }
        if let number = object as? NSNumber {
            return .Number(number.floatValue);
        }
        println("Unsupported type found in JSON object");
        return .Null;
    }
    
    public static func parse(jsonData : NSData) -> (JSON) {
        var error : NSError? = nil;
        let json : AnyObject? = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments, error: &error);
        
        //check if parsing was successful
        if(error != nil){
            println("JSON parsing failed with error: " + error!.localizedDescription)
        } else {
            return wrap(json);
        }
        return .Null;
    }
    
    public var string : Swift.String? {
        switch self {
        case .String(let s):
            return s;
        default:
            return nil;
        }
    }
    
    public var int : Int? {
        switch self {
        case .Number(let s):
            return Int(s);
        default:
            return nil;
        }
    }
    
    public var dictionary : [Swift.String : JSON]? {
        switch self {
        case .Dictionary(let dict):
            var jsonObject : [Swift.String : JSON] = [:];
            for (key,value) in dict {
                jsonObject[key] = JSON.wrap(value);
            }
            return jsonObject;
        default:
            return nil;
        }
    }
    
    public var array : [JSON]? {
        switch self {
        case .Array(let array):
            let jsonArray = array.map({JSON.wrap($0)});
            return jsonArray;
        default:
            return nil;
        }
    }
    
    public subscript(key : Swift.String) -> (JSON?) {
        switch self {
        case .Dictionary(let d):
            if let value : AnyObject = d[key]? {
                return JSON.wrap(value);
            }
            fallthrough
        default:
            return nil;
        }
    }
    
    public subscript(index : Int) -> (JSON?) {
        switch self {
        case .Array(let a):
            return JSON.wrap(a[index]);
        default:
            return nil;
            
        }
    }
    
    
}