//
//  consants.swift
//  LeadingBugs
//
//  Created by Erik E. Beerepoot on 2015-03-02.
//  Copyright (c) 2015 MediaCore Technologies Inc. All rights reserved.
//

import Foundation

public struct appConstants {
    public static let appName = "LeadingBugs";
    
    //error domains
    public static let authorizationErrorDomain = "authorizationErrorDomain";
    
    //API return value keys
    public static let authorizationKey = "access_token"
    public static let okKey = "ok";
    public static let errorKey = "error";
    public static let stateKey = "state";
    public static let codeKey = "code";
    public static let urlKey = "url";
    
    //app key and secret
    public static let key = "b1e7adb038858b9b1faafee253642a6b";
    public static let secret = "6a85c9aae8415f4efc708203b5e6c9bcae1e857090909186ccf731ccb2bb24b0";
}

public struct endpoints {
    public static let authorization = "https://trello.com/1/authorize";
    public static let connect = "https://trello.com/1/connect";
}