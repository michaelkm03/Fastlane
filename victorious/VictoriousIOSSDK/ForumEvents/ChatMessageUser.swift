//
//  ChatMessageUser.swift
//  victorious
//
//  Created by Sebastian Nystorm on 23/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// The user referenced in chat messages.
public struct ChatMessageUser {
    
    public let id: Int
    public let name: String
    public let profileURL: NSURL
    
    init?(json: JSON) {
        guard let profileURL = json["profile_url"].URL,
            let name = json["name"].string,
            let id = json["id"].int ?? Int(json["id"].stringValue) else {
            return nil
        }
        self.id = id
        self.name = name
        self.profileURL = profileURL
    }
    
    public init(id: Int, name: String, profileURL: NSURL) {
        self.id = id
        self.name = name
        self.profileURL = profileURL
    }
    
    // MARK: - DictionaryConvertible
    
    public func toDictionary() -> [String: AnyObject] {
        var dictionary = [String: AnyObject]()
        dictionary["id"] = id
        dictionary["profile_url"] = profileURL.absoluteString
        dictionary["name"] = name
        return dictionary
    }
}
