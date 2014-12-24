//
//  SlackAPIEndpoints.swift
//  Nexus
//
//  Created by Erik E. Beerepoot on 2014-12-19.
//  Copyright (c) 2014 Dactyl Studios. All rights reserved.
//

import Foundation

public let kClientSecret = "01ad48926afe592a28f8571ae80cc4e9"

public let kAuthorizationKey = "access_token";
public let kOKKey = "ok";
public let kErrorKey = "error";
public let kStateKey = "state";
public let kCodeKey = "code";
public let kURLKey = "url";

public let kGeneralChannelID = "C024G2VPX";
public let kTestChannelID = "G033JS5T7";

public struct SlackIDs {
    public static let kTeamID = "T024G2VPR";
    public static let kClientID = "2152097807.3263247755";
}

public struct SlackEndpoints {
    public static let kAuthorizationEndpoint = "https://slack.com/oauth/authorize";
    public static let kOAuthAccessEndpoint = "https://slack.com/api/oauth.access";
    public static let kConnectEndpoint = "https://slack.com/api/rtm.start";
    public static let kSendMessageEndpoint = "https://slack.com/api/chat.postMessage";
}